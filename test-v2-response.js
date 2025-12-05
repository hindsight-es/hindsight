// Test script to inspect raw V2 AppendSession response structure
const { KurrentDBClient } = require("@kurrent/kurrentdb-client");

async function test() {
    const client = KurrentDBClient.connectionString("esdb://localhost:2113?tls=false");

    const timestamp = Date.now();
    const stream1 = `test-v2-response-a-${timestamp}`;
    const stream2 = `test-v2-response-b-${timestamp}`;
    const stream3 = `test-v2-response-c-${timestamp}`;

    console.log("Testing V2 multiStreamAppend response structure...\n");

    try {
        // Multi-stream append with different event counts
        const result = await client.multiStreamAppend([
            {
                streamName: stream1,
                expectedState: "no_stream",
                events: [
                    { id: crypto.randomUUID(), type: "TestEvent", data: { n: 1 }, contentType: "application/json" },
                    { id: crypto.randomUUID(), type: "TestEvent", data: { n: 2 }, contentType: "application/json" }
                ]
            },
            {
                streamName: stream2,
                expectedState: "no_stream",
                events: [
                    { id: crypto.randomUUID(), type: "TestEvent", data: { n: 10 }, contentType: "application/json" }
                ]
            },
            {
                streamName: stream3,
                expectedState: "no_stream",
                events: [
                    { id: crypto.randomUUID(), type: "TestEvent", data: { n: 100 }, contentType: "application/json" },
                    { id: crypto.randomUUID(), type: "TestEvent", data: { n: 101 }, contentType: "application/json" },
                    { id: crypto.randomUUID(), type: "TestEvent", data: { n: 102 }, contentType: "application/json" }
                ]
            }
        ]);

        console.log("=== Full result object ===");
        console.log(JSON.stringify(result, (key, value) =>
            typeof value === 'bigint' ? value.toString() + 'n' : value
        , 2));

        console.log("\n=== Individual responses ===");
        console.log("stream1 (2 events):", stream1);
        console.log("stream2 (1 event):", stream2);
        console.log("stream3 (3 events):", stream3);

        if (result.responses) {
            result.responses.forEach((resp, i) => {
                console.log(`\nResponse ${i}:`);
                console.log("  All keys:", Object.keys(resp));
                console.log("  streamName:", resp.streamName);
                console.log("  revision:", resp.revision?.toString());
                console.log("  position:", resp.position?.toString());
                console.log("  Raw resp:", JSON.stringify(resp, (key, value) =>
                    typeof value === 'bigint' ? value.toString() + 'n' : value
                , 4));
            });
        }

        console.log("\n=== Global position ===");
        console.log("position:", result.position?.toString());

    } catch (error) {
        console.error("Error:", error);
    }

    await client.dispose();
}

test().catch(console.error);
