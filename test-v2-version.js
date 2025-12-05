// Quick test to verify V2 protocol version mismatch detection
const { KurrentDBClient } = require("@kurrent/kurrentdb-client");

async function test() {
    const client = KurrentDBClient.connectionString("kurrentdb://localhost:2113?tls=false");
    const streamName = "test-v2-version-" + Date.now();

    console.log("Testing V2 protocol version mismatch detection...");

    // Step 1: Create stream with one event
    console.log("\n1. Creating stream with one event (NoStream expectation)...");
    const firstResult = await client.multiStreamAppend([{
        streamName: streamName,
        expectedState: "no_stream",
        events: [{
            id: crypto.randomUUID(),
            type: "TestEvent",
            data: { value: 1 },
            contentType: "application/json"
        }]
    }]);
    console.log("   Success! Stream at revision:", firstResult.responses[0].revision.toString());

    // Step 2: Try to append with wrong version (should FAIL)
    console.log("\n2. Appending with wrong version (expecting 99, actual is 0)...");
    try {
        await client.multiStreamAppend([{
            streamName: streamName,
            expectedState: 99n,  // Wrong - stream is at 0
            events: [{
                id: crypto.randomUUID(),
                type: "TestEvent",
                data: { value: 2 },
                contentType: "application/json"
            }]
        }]);
        console.log("   ERROR: Should have failed but succeeded!");
    } catch (error) {
        console.log("   Good! Got expected error:", error.type);
        console.log("   Message:", error.message);
    }

    // Step 3: Verify correct version works
    console.log("\n3. Appending with correct version (expecting 0)...");
    try {
        const result = await client.multiStreamAppend([{
            streamName: streamName,
            expectedState: 0n,  // Correct version
            events: [{
                id: crypto.randomUUID(),
                type: "TestEvent",
                data: { value: 3 },
                contentType: "application/json"
            }]
        }]);
        console.log("   Success! Stream now at revision:", result.responses[0].revision.toString());
    } catch (error) {
        console.log("   ERROR:", error);
    }

    await client.dispose();
    console.log("\nDone!");
}

test().catch(console.error);
