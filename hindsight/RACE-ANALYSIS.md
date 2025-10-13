
  1. Store Initialization and Test Execution Flow

  sequenceDiagram
      participant Test
      participant SQLStoreRunner
      participant TempDB
      participant PostgreSQL as PostgreSQL.hs
      participant ED as EventDispatcher
      participant Pool
      participant DB as Database

      Test->>SQLStoreRunner: runTest(testBasicEventReception)
      SQLStoreRunner->>TempDB: Temp.withConfig
      TempDB-->>SQLStoreRunner: db instance
      SQLStoreRunner->>PostgreSQL: newSQLStore(connStr)

      Note over PostgreSQL: newSQLStoreWithProjections
      PostgreSQL->>Pool: acquire connection pool
      PostgreSQL->>PostgreSQL: catchUpSyncProjections

      PostgreSQL->>ED: EventDispatcher.start(connStr, pool, config)
      Note over ED: Initialize state
      ED->>DB: getLatestPositionFromDatabase
      DB-->>ED: SQLCursor position
      ED->>ED: Create placeholder async
      ED->>ED: Cancel placeholder
      ED->>ED: async $ dispatcherLoop

      Note over ED: dispatcherLoop starts
      ED->>ED: Connection.acquire
      ED->>ED: putMVar notificationConn
      ED->>ED: withNotificationListener "event_store_transaction"
      ED->>ED: processPendingEvents (initial)
      ED->>ED: putMVar readySignal

      ED-->>PostgreSQL: takeMVar readySignal (blocks until ready)
      PostgreSQL-->>SQLStoreRunner: SQLStoreHandle

      SQLStoreRunner->>Pool: createSchema
      SQLStoreRunner->>Test: execute test with store

      Note over Test: Test execution begins

  2. Test Execution: Basic Event Reception

  sequenceDiagram
      participant Test
      participant Store
      participant ED as EventDispatcher
      participant Sub as Subscription
      participant DB as Database

      Test->>Test: Create streamId, receivedEvents, completionVar
      Test->>Store: insertEvents(events 1-3 + tombstone)
      Store->>DB: Insert events with version checking
      DB->>DB: NOTIFY 'event_store_transaction'
      Store-->>Test: SuccessfulInsertion

      Test->>Store: subscribe(matcher, FromBeginning)
      Store->>Sub: subscribeWithDispatcher

      Note over Sub: Registration Phase
      Sub->>ED: registerSubscription(eventNames, selector)
      ED->>ED: Create RealtimeSubscription (status: WaitingForCatchUp)
      ED->>ED: Store in subscriptions Map
      ED-->>Sub: RegistrationResult{subId, eventQueue, currentPosition}

      Note over Sub: Catch-up Decision
      Sub->>ED: getCurrentPosition
      ED-->>Sub: dispatcher current position
      Sub->>Sub: Compare positions, decide if catch-up needed

      alt Catch-up needed
          Sub->>Sub: doCatchUpPhase
          Sub->>DB: fetchEventsInRange
          DB-->>Sub: events
          Sub->>Sub: Process events, update state
      else No catch-up needed
          Sub->>Sub: Use current state as catch-up position
      end

      Note over Sub: Activation Phase
      Sub->>ED: activateSubscription(subId, catchUpPosition)
      ED->>ED: atomically { set lastDeliveredPosition, set status Active }

      Note over Sub: Real-time Phase
      Sub->>Sub: consumeFromDispatcherQueue

      Note over ED: Meanwhile, in dispatcher loop
      ED->>ED: processPendingEvents
      ED->>DB: fetchEventsForSubscriptions
      DB-->>ED: events
      ED->>ED: distributeEventBatch to active subscriptions
      ED->>Sub: writeTBQueue eventBatch

      Sub->>Sub: readTBQueue (blocks)
      Sub-->>Test: Process events through matcher
      Test->>Test: Tombstone received, putMVar completionVar

      Test->>Test: takeMVar completionVar (wait for tombstone)
      Test->>Sub: handle.cancel
      Test->>Test: Assert received events = [1,2,3]

  3. EventDispatcher Main Loop

  stateDiagram-v2
      [*] --> Initializing: start()

      Initializing --> WaitingForReady: async dispatcherLoop

      state dispatcherLoop {
          [*] --> AcquireConnection
          AcquireConnection --> SetupLISTEN: Connection acquired
          SetupLISTEN --> InitialFetch: withNotificationListener
          InitialFetch --> SignalReady: processPendingEvents
          SignalReady --> MainLoop: putMVar readySignal

          state MainLoop {
              [*] --> CheckShutdown
              CheckShutdown --> WaitForNotifications: No shutdown
              CheckShutdown --> [*]: Shutdown requested

              WaitForNotifications --> PingConnection: Timeout or notification
              PingConnection --> ProcessEvents
              ProcessEvents --> CheckShutdown
          }
      }

      WaitingForReady --> Ready: takeMVar readySignal
      Ready --> [*]: Return dispatcher

  4. Race Condition Window Analysis

  sequenceDiagram
      participant Store
      participant ED as EventDispatcher
      participant EDLoop as Dispatcher Loop
      participant Sub as Subscription
      participant Test

      Note over Store,EDLoop: Critical Race Window

      Store->>ED: EventDispatcher.start
      ED->>EDLoop: async dispatcherLoop

      par Dispatcher initialization
          EDLoop->>EDLoop: Connection.acquire
          EDLoop->>EDLoop: LISTEN setup
          EDLoop->>EDLoop: processPendingEvents
          Note over EDLoop: DELAY HERE PREVENTS HANG
          EDLoop->>ED: putMVar readySignal
      and Store waiting
          ED->>ED: takeMVar readySignal (blocks)
      end

      ED-->>Store: dispatcher returned
      Store-->>Test: store handle

      Note over Test: If test proceeds too quickly...
      Test->>Test: insertEvents (immediate)
      Test->>Sub: subscribe (immediate)

      rect rgb(255, 200, 200)
          Note over Sub,EDLoop: RACE CONDITION ZONE
          Sub->>ED: registerSubscription
          Sub->>ED: getCurrentPosition
          Sub->>ED: activateSubscription
          Note over EDLoop: Dispatcher might not be<br/>fully operational yet
      end

  5. Event Processing and Distribution Flow

  flowchart TB
      subgraph EventDispatcher
          A[processPendingEvents] --> B{Check subscriptions}
          B -->|Has subscriptions| C[Get active subscriptions]
          B -->|No subscriptions| D[Update position only]

          C --> E[fetchEventsForSubscriptions]
          E --> F[Get min position across subscriptions]
          F --> G[Query events from DB]
          G --> H[Create EventBatch]
          H --> I[distributeEventBatch]

          I --> J[For each subscription]
          J --> K{Event after lastDelivered?}
          K -->|Yes| L{Queue full?}
          K -->|No| J
          L -->|No| M[writeTBQueue]
          L -->|Yes| N[Mark as lagging]
          M --> O[Update lastDeliveredPosition]
      end

      subgraph Subscription
          P[consumeFromDispatcherQueue] --> Q[readTBQueue with timeout]
          Q --> R{Timeout?}
          R -->|Yes| S{Cancelled?}
          R -->|No| T[Process batch]
          S -->|Yes| U[Exit]
          S -->|No| Q
          T --> V[Process each event]
          V --> W{Continue?}
          W -->|Yes| Q
          W -->|No| U
      end

      M -.-> Q

  Analysis and Hypotheses

  Based on these diagrams and the code analysis, here are my hypotheses for the race condition:

  Hypothesis 1: EventDispatcher Initialization Incomplete ⭐ Most Likely

  The EventDispatcher.start function waits for readySignal, but there's a gap between when the dispatcher is "ready" (signaled) and when it's actually processing events correctly. The
  evidence:
  - Adding a delay after EventDispatcher.start fixes the issue
  - The dispatcher might signal ready before the notification loop is fully operational
  - The forever loop starts after putMVar readySignal, creating a timing window

  Hypothesis 2: LISTEN Command Effectiveness Delay

  PostgreSQL's LISTEN might not be immediately effective after setup. While the connection is established and LISTEN is called, there might be a brief window where notifications are lost.
  Evidence:
  - Adding delay after LISTEN setup (before processPendingEvents) also fixes the issue
  - PostgreSQL documentation warns about LISTEN timing issues

  Hypothesis 3: Initial Position Synchronization

  During initialization, getLatestPositionFromDatabase is called twice:
  1. In EventDispatcher.start (line 216)
  2. In processPendingEvents during initialization (line 460)

  If events are inserted between these calls, the dispatcher's view of "latest position" might be inconsistent.

  Hypothesis 4: Subscription Activation Race

  When a subscription transitions from catch-up to active:
  1. It registers with dispatcher (gets added to subscriptions map)
  2. Performs catch-up if needed
  3. Calls activateSubscription to set status to Active

  If events arrive during this transition, they might be lost because:
  - The subscription is registered but not yet active
  - The dispatcher sees it in the map but skips it (not Active)
  - Events inserted during this window are never delivered

  Hypothesis 5: Test Timing Creates Perfect Storm

  The test sequence might create the perfect timing for the race:
  1. Store creation completes
  2. Test immediately inserts events (triggering NOTIFY)
  3. Test immediately creates subscription
  4. The dispatcher receives the NOTIFY but isn't ready to process it correctly
  5. The subscription waits forever for events that were already notified

  Root Cause Assessment

  The most likely root cause is Hypothesis 1 combined with Hypothesis 4. The EventDispatcher signals it's ready before it's actually in its main processing loop, and subscriptions can
  register and activate during this critical window, leading to lost events or notifications.

  The fix would be to ensure the EventDispatcher is fully in its processing loop before signaling ready, or to implement a more robust event recovery mechanism that doesn't rely on perfect
  notification timing.
