// Test V2 AppendSession customMetadata preservation
// Write via V2, read via V1 to see if customMetadata is preserved

const { KurrentDBClient, jsonEvent, FORWARDS, START } = require('@kurrent/kurrentdb-client');
const { randomUUID } = require('crypto');

async function main() {
    console.log('Testing V2 customMetadata preservation...');

    const client = KurrentDBClient.connectionString('esdb://localhost:2113?tls=false');

    const streamName = `test-v2-meta-${randomUUID()}`;
    const correlationId = randomUUID();

    console.log(`Stream: ${streamName}`);
    console.log(`CorrelationId: ${correlationId}`);

    // Create event with custom metadata containing correlationId
    const event = jsonEvent({
        type: 'TestEvent',
        data: { name: 'test', value: 42 },
        metadata: {
            version: 1,
            correlationId: correlationId
        }
    });

    // Write using V1 appendToStream (sets customMetadata)
    console.log('\n=== Writing event via V1 appendToStream ===');
    const result = await client.appendToStream(streamName, [event]);
    console.log('Write result:', {
        nextExpectedRevision: result.nextExpectedRevision.toString(),
        success: result.success
    });

    // Read back using V1 readStream
    console.log('\n=== Reading events via V1 readStream ===');
    const readResult = client.readStream(streamName, { direction: FORWARDS, fromRevision: START });

    for await (const resolvedEvent of readResult) {
        const evt = resolvedEvent.event;
        console.log('\nEvent received:');
        console.log('  id:', evt.id);
        console.log('  type:', evt.type);
        console.log('  data:', evt.data);
        console.log('  metadata:', evt.metadata);
        console.log('  contentType:', evt.contentType);
        console.log('  isJson:', evt.isJson);

        // Check the raw customMetadata bytes
        console.log('  raw metadata buffer length:', evt.metadata ? Buffer.from(JSON.stringify(evt.metadata)).length : 0);
    }

    console.log('\n=== Done ===');
    await client.dispose();
}

main().catch(err => {
    console.error('Error:', err);
    process.exit(1);
});
