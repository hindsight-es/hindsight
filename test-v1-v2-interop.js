// Test script to verify V1 and V2 API interoperability
const { KurrentDBClient } = require("@kurrent/kurrentdb-client");
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');
const path = require('path');
const crypto = require('crypto');

// Load V2 proto
const PROTO_PATH = path.join(__dirname, 'hindsight-kurrentdb-store/proto/v2/streams.proto');
const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
    keepCase: false,
    longs: String,
    enums: String,
    defaults: true,
    oneofs: true
});
const protoDescriptor = grpc.loadPackageDefinition(packageDefinition);
const StreamsService = protoDescriptor.kurrentdb.protocol.v2.streams.StreamsService;

async function test() {
    // V1 client (official Node.js client)
    const v1Client = KurrentDBClient.connectionString("esdb://localhost:2113?tls=false");
    // V2 client (raw gRPC)
    const v2Client = new StreamsService('localhost:2113', grpc.credentials.createInsecure());

    const timestamp = Date.now();
    const streamName = `test-v1-v2-interop-${timestamp}`;

    console.log("Testing V1 and V2 API interoperability...\n");
    console.log("Stream:", streamName);

    try {
        // Step 1: Create stream with V2 (NoStream)
        console.log("\nStep 1: Creating stream with V2 API (NoStream expectation)...");
        const result1 = await v2AppendSession(v2Client, [{
            stream: streamName,
            expectedRevision: -1, // NoStream
            records: [{
                recordId: crypto.randomUUID(),
                schema: { format: 1, name: "TestEvent" },
                data: Buffer.from(JSON.stringify({ step: 1 }))
            }]
        }]);
        console.log("V2 Step 1 succeeded. Stream revision:", result1.output[0].streamRevision);

        // Step 2: Update stream with V1 (expected revision 0)
        console.log("\nStep 2: Updating stream with V1 API (expected revision 0)...");
        const result2 = await v1Client.appendToStream(streamName, [
            { id: crypto.randomUUID(), type: "TestEvent", data: { step: 2 }, contentType: "application/json" }
        ], { expectedRevision: 0n });
        console.log("V1 Step 2 succeeded. Next expected revision:", result2.nextExpectedRevision?.toString());

        // Step 3: Try to use stale revision with V2 (should fail!)
        console.log("\nStep 3: Trying V2 with STALE expected_revision=0 (actual should be 1)...");
        try {
            const result3 = await v2AppendSession(v2Client, [{
                stream: streamName,
                expectedRevision: 0, // STALE!
                records: [{
                    recordId: crypto.randomUUID(),
                    schema: { format: 1, name: "TestEvent" },
                    data: Buffer.from(JSON.stringify({ step: 3 }))
                }]
            }]);
            console.log("!!! UNEXPECTED: V2 Step 3 SUCCEEDED with stale revision !!!");
            console.log("Result:", JSON.stringify(result3, null, 2));
        } catch (error) {
            console.log("=== V2 Step 3 FAILED as expected ===");
            console.log("Error code:", error.code);
            console.log("Error details:", error.details);
        }

    } catch (error) {
        console.error("Error:", error);
    }

    await v1Client.dispose();
    v2Client.close();
}

function v2AppendSession(client, requests) {
    return new Promise((resolve, reject) => {
        const call = client.AppendSession((err, response) => {
            if (err) {
                reject(err);
            } else {
                resolve(response);
            }
        });
        for (const req of requests) {
            call.write(req);
        }
        call.end();
    });
}

test().catch(console.error);
