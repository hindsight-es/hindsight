// Test script to see how V2 multiStreamAppend handles version mismatch
const { KurrentDBClient } = require("@kurrent/kurrentdb-client");

async function test() {
    const client = KurrentDBClient.connectionString("esdb://localhost:2113?tls=false");

    const timestamp = Date.now();
    const streamA = `test-v2-stale-a-${timestamp}`;
    const streamB = `test-v2-stale-b-${timestamp}`;

    console.log("Testing V2 multiStreamAppend version mismatch handling...\n");

    try {
        // Step 1: Create both streams with initial events
        console.log("Step 1: Creating streams A and B...");
        const result1 = await client.multiStreamAppend([
            {
                streamName: streamA,
                expectedState: "no_stream",
                events: [
                    { id: crypto.randomUUID(), type: "TestEvent", data: { n: 1 }, contentType: "application/json" }
                ]
            },
            {
                streamName: streamB,
                expectedState: "no_stream",
                events: [
                    { id: crypto.randomUUID(), type: "TestEvent", data: { n: 10 }, contentType: "application/json" }
                ]
            }
        ]);

        console.log("Step 1 result:");
        console.log("  Stream A revision:", result1.responses?.find(r => r.streamName === streamA)?.revision?.toString());
        console.log("  Stream B revision:", result1.responses?.find(r => r.streamName === streamB)?.revision?.toString());

        // After writing 1 event, stream revision should be 0
        const revisionA = result1.responses?.find(r => r.streamName === streamA)?.revision;
        const revisionB = result1.responses?.find(r => r.streamName === streamB)?.revision;

        // Step 2: Update stream A to make the cursor stale
        console.log("\nStep 2: Updating stream A (making original cursor stale)...");
        const result2 = await client.appendToStream(streamA, [
            { id: crypto.randomUUID(), type: "TestEvent", data: { n: 2 }, contentType: "application/json" }
        ], { expectedRevision: revisionA });

        console.log("Step 2 result: Stream A now at revision", result2.nextExpectedRevision?.toString());

        // Step 3: Try multi-stream append with stale revision for A, valid for B
        console.log("\nStep 3: Trying multi-stream append with STALE cursor for A (rev", revisionA?.toString(), "), valid for B (rev", revisionB?.toString(), ")...");

        try {
            const result3 = await client.multiStreamAppend([
                {
                    streamName: streamA,
                    expectedState: revisionA,  // STALE! Stream A is now at revision 1, not 0
                    events: [
                        { id: crypto.randomUUID(), type: "TestEvent", data: { n: 3 }, contentType: "application/json" }
                    ]
                },
                {
                    streamName: streamB,
                    expectedState: revisionB,  // Valid
                    events: [
                        { id: crypto.randomUUID(), type: "TestEvent", data: { n: 11 }, contentType: "application/json" }
                    ]
                }
            ]);

            // If we get here, the transaction SUCCEEDED (unexpected!)
            console.log("\n!!! UNEXPECTED: Transaction SUCCEEDED with stale cursor !!!");
            console.log("Result:", JSON.stringify(result3, (k, v) => typeof v === 'bigint' ? v.toString() + 'n' : v, 2));

        } catch (error) {
            // Expected: Should fail with version mismatch
            console.log("\n=== Transaction FAILED as expected ===");
            console.log("Error name:", error.name);
            console.log("Error message:", error.message);
            console.log("Error code:", error.code);
            console.log("Error type:", error.type);
            console.log("Error constructor:", error.constructor?.name);

            // Log all properties
            console.log("\nAll error properties:");
            for (const key of Object.keys(error)) {
                console.log(`  ${key}:`, error[key]);
            }
        }

    } catch (error) {
        console.error("Unexpected error:", error);
    }

    await client.dispose();
}

test().catch(console.error);
