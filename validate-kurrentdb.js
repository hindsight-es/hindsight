// Quick validation script for KurrentDB using official client
const { EventStoreDBClient, jsonEvent, FORWARDS, START } = require('@eventstore/db-client');

async function main() {
    const port = process.argv[2] || '2113';
    const connectionString = `esdb://localhost:${port}?tls=false`;

    console.log(`Connecting to KurrentDB at ${connectionString}...`);

    const client = EventStoreDBClient.connectionString(connectionString);

    try {
        // 1. Append an event
        const streamName = `test-stream-${Date.now()}`;
        const event = jsonEvent({
            type: 'TestEvent',
            data: { message: 'Hello from validation script!' }
        });

        console.log(`Appending event to stream: ${streamName}...`);
        const appendResult = await client.appendToStream(streamName, [event]);
        console.log('Append result:', appendResult);

        // 2. Read it back
        console.log('Reading events back...');
        const events = client.readStream(streamName, {
            direction: FORWARDS,
            fromRevision: START,
        });

        for await (const resolvedEvent of events) {
            console.log('Got event:', {
                type: resolvedEvent.event?.type,
                data: resolvedEvent.event?.data,
            });
        }

        console.log('\nKurrentDB is working correctly!');
        process.exit(0);
    } catch (error) {
        console.error('Error:', error.message);
        process.exit(1);
    }
}

main();
