// Test script to verify KurrentDB version mismatch behavior
const { EventStoreDBClient, jsonEvent, NO_STREAM, STREAM_EXISTS } = require('@eventstore/db-client');

async function main() {
    const connectionString = `esdb://localhost:2113?tls=false`;
    console.log(`Connecting to KurrentDB at ${connectionString}...`);

    const client = EventStoreDBClient.connectionString(connectionString);

    try {
        const streamName = `test-version-mismatch-${Date.now()}`;

        // Step 1: Create the stream with NO_STREAM expectation
        console.log(`\n1. Creating stream with NO_STREAM expectation...`);
        const event1 = jsonEvent({
            type: 'TestEvent',
            data: { message: 'First event' }
        });

        const result1 = await client.appendToStream(streamName, [event1], {
            expectedRevision: NO_STREAM
        });
        console.log('   Success! Next expected revision:', result1.nextExpectedRevision);

        // Step 2: Try to append again with NO_STREAM expectation (should fail!)
        console.log(`\n2. Trying to append again with NO_STREAM expectation (should FAIL)...`);
        const event2 = jsonEvent({
            type: 'TestEvent',
            data: { message: 'Second event' }
        });

        try {
            const result2 = await client.appendToStream(streamName, [event2], {
                expectedRevision: NO_STREAM
            });
            console.log('   UNEXPECTED SUCCESS! Next expected revision:', result2.nextExpectedRevision);
            console.log('   ERROR: This should have failed with a version mismatch!');
        } catch (error) {
            console.log('   Expected failure:', error.message);
            console.log('   SUCCESS: Version mismatch properly detected!');
        }

        process.exit(0);
    } catch (error) {
        console.error('Error:', error.message);
        process.exit(1);
    }
}

main();
