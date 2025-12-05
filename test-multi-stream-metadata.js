// Test V2 multiStreamAppend metadata preservation
// Write via multiStreamAppend (V2), read via readStream (V1)

const { KurrentDBClient, jsonEvent, FORWARDS, START, ANY } = require('@kurrent/kurrentdb-client');
const { randomUUID } = require('crypto');

async function main() {
    console.log('Testing multiStreamAppend metadata preservation...\n');

    const client = KurrentDBClient.connectionString('esdb://localhost:2113?tls=false');

    const streamName1 = `test-multi-1-${randomUUID()}`;
    const streamName2 = `test-multi-2-${randomUUID()}`;
    const correlationId = randomUUID();

    console.log(`Stream 1: ${streamName1}`);
    console.log(`Stream 2: ${streamName2}`);
    console.log(`CorrelationId: ${correlationId}`);

    // Create events with metadata (V2 requires STRING values only!)
    const event1 = jsonEvent({
        type: 'TestEvent',
        data: { name: 'event1', value: 1 },
        metadata: {
            version: "1",
            correlationId: correlationId
        }
    });

    const event2 = jsonEvent({
        type: 'TestEvent',
        data: { name: 'event2', value: 2 },
        metadata: {
            version: "1",
            correlationId: correlationId
        }
    });

    // Check if multiStreamAppend exists
    if (typeof client.multiStreamAppend !== 'function') {
        console.log('multiStreamAppend NOT available in this client version');
        console.log('Available methods:', Object.keys(client).filter(k => typeof client[k] === 'function'));
        await client.dispose();
        return;
    }

    console.log('\n=== Writing events via multiStreamAppend (V2) ===');
    try {
        const result = await client.multiStreamAppend([
            {
                streamName: streamName1,
                expectedState: ANY,
                events: [event1]
            },
            {
                streamName: streamName2,
                expectedState: ANY,
                events: [event2]
            }
        ]);
        console.log('Write result:', result);
    } catch (err) {
        console.error('multiStreamAppend error:', err.message);
        await client.dispose();
        return;
    }

    // Read back from both streams
    console.log('\n=== Reading events from stream 1 ===');
    const read1 = client.readStream(streamName1, { direction: FORWARDS, fromRevision: START });
    for await (const resolvedEvent of read1) {
        const evt = resolvedEvent.event;
        console.log('Event:', {
            id: evt.id,
            type: evt.type,
            data: evt.data,
            metadata: evt.metadata
        });
    }

    console.log('\n=== Reading events from stream 2 ===');
    const read2 = client.readStream(streamName2, { direction: FORWARDS, fromRevision: START });
    for await (const resolvedEvent of read2) {
        const evt = resolvedEvent.event;
        console.log('Event:', {
            id: evt.id,
            type: evt.type,
            data: evt.data,
            metadata: evt.metadata
        });
    }

    console.log('\n=== Done ===');
    await client.dispose();
}

main().catch(err => {
    console.error('Error:', err);
    process.exit(1);
});
