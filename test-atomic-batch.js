// Test script to verify KurrentDB BatchAppend atomic behavior
// This tests if multi-stream atomic appends properly enforce version checks

const { KurrentDBClient, jsonEvent, NO_STREAM, STREAM_EXISTS } = require('@kurrent/kurrentdb-client');

async function main() {
    const connectionString = `esdb://localhost:2113?tls=false`;
    console.log(`Connecting to KurrentDB at ${connectionString}...`);

    const client = KurrentDBClient.connectionString(connectionString);

    try {
        const timestamp = Date.now();
        const stream1 = `test-atomic-stream1-${timestamp}`;
        const stream2 = `test-atomic-stream2-${timestamp}`;

        // Step 1: Create stream1 with NO_STREAM expectation
        console.log(`\n1. Creating stream1 (${stream1}) with NO_STREAM expectation...`);
        const event1 = jsonEvent({
            type: 'TestEvent',
            data: { message: 'Initial event for stream1' }
        });

        const result1 = await client.appendToStream(stream1, [event1], {
            expectedRevision: NO_STREAM
        });
        console.log('   Success! Stream1 created. Next revision:', result1.nextExpectedRevision);

        // Step 2: Try multi-stream atomic append
        // stream1: with NO_STREAM (WRONG - stream exists!)
        // stream2: with NO_STREAM (correct - stream doesn't exist)
        console.log(`\n2. Attempting multi-stream atomic append...`);
        console.log(`   - stream1 (${stream1}): NO_STREAM expectation (WRONG - should fail)`);
        console.log(`   - stream2 (${stream2}): NO_STREAM expectation (correct)`);

        const batchEvent1 = jsonEvent({
            type: 'TestEvent',
            data: { message: 'Second event for stream1' }
        });
        const batchEvent2 = jsonEvent({
            type: 'TestEvent',
            data: { message: 'First event for stream2' }
        });

        try {
            // Use multiStreamAppend (KurrentDB 25.1+)
            // Note: uses expectedState, not expectedRevision
            const batchResult = await client.multiStreamAppend([
                {
                    streamName: stream1,
                    events: [batchEvent1],
                    expectedState: NO_STREAM  // This should FAIL - stream exists!
                },
                {
                    streamName: stream2,
                    events: [batchEvent2],
                    expectedState: NO_STREAM  // This should succeed - stream doesn't exist
                }
            ]);

            console.log('   UNEXPECTED SUCCESS! Batch append succeeded.');
            console.log('   Result:', JSON.stringify(batchResult, null, 2));
            console.log('\n   WARNING: Expected failure due to version mismatch on stream1!');
        } catch (error) {
            console.log('   Expected failure:', error.message || error);
            console.log('   SUCCESS: Multi-stream atomic append properly rejected!');
        }

        // Step 3: Verify stream2 was NOT created (all-or-nothing)
        console.log(`\n3. Verifying stream2 was NOT created (all-or-nothing semantics)...`);
        try {
            const verifyEvent = jsonEvent({
                type: 'TestEvent',
                data: { message: 'Verification event' }
            });

            await client.appendToStream(stream2, [verifyEvent], {
                expectedRevision: NO_STREAM
            });
            console.log('   SUCCESS: stream2 does not exist (atomic rollback worked!)');
        } catch (error) {
            console.log('   FAILURE: stream2 EXISTS - atomic rollback did NOT happen!');
            console.log('   Error:', error.message || error);
            console.log('\n   BUG CONFIRMED: KurrentDB BatchAppend is NOT atomic!');
        }

        process.exit(0);
    } catch (error) {
        console.error('Error:', error.message || error);
        console.error('Stack:', error.stack);
        process.exit(1);
    }
}

main();
