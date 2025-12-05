// Test script to verify V2 exact revision checking behavior
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');
const path = require('path');
const crypto = require('crypto');

// Load proto
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
    const client = new StreamsService('localhost:2113', grpc.credentials.createInsecure());

    const timestamp = Date.now();
    const streamA = `test-exact-rev-a-${timestamp}`;
    const streamB = `test-exact-rev-b-${timestamp}`;

    console.log("Testing V2 exact revision checking behavior...\n");

    try {
        // Step 1: Create streams with NoStream (-1)
        console.log("Step 1: Creating streams A and B with NoStream expectation...");
        const result1 = await appendSession(client, [
            {
                stream: streamA,
                expectedRevision: -1, // NoStream
                records: [{
                    recordId: crypto.randomUUID(),
                    schema: { format: 1, name: "TestEvent" },
                    data: Buffer.from(JSON.stringify({ n: 1 }))
                }]
            },
            {
                stream: streamB,
                expectedRevision: -1, // NoStream
                records: [{
                    recordId: crypto.randomUUID(),
                    schema: { format: 1, name: "TestEvent" },
                    data: Buffer.from(JSON.stringify({ n: 10 }))
                }]
            }
        ]);
        console.log("Step 1 succeeded.");
        console.log("  Stream A revision:", result1.output.find(o => o.stream === streamA).streamRevision);
        console.log("  Stream B revision:", result1.output.find(o => o.stream === streamB).streamRevision);

        // Step 2: Update stream A only (making revision 0 stale for A)
        console.log("\nStep 2: Updating stream A with expected_revision=0...");
        const result2 = await appendSession(client, [
            {
                stream: streamA,
                expectedRevision: 0, // Exact revision 0
                records: [{
                    recordId: crypto.randomUUID(),
                    schema: { format: 1, name: "TestEvent" },
                    data: Buffer.from(JSON.stringify({ n: 2 }))
                }]
            }
        ]);
        console.log("Step 2 succeeded.");
        console.log("  Stream A revision:", result2.output.find(o => o.stream === streamA).streamRevision);

        // Step 3: Try to use stale revision 0 for stream A (should fail!)
        console.log("\nStep 3: Trying to use STALE expected_revision=0 for stream A (actual=1)...");
        const result3 = await appendSession(client, [
            {
                stream: streamA,
                expectedRevision: 0, // STALE! Stream A is now at revision 1
                records: [{
                    recordId: crypto.randomUUID(),
                    schema: { format: 1, name: "TestEvent" },
                    data: Buffer.from(JSON.stringify({ n: 3 }))
                }]
            },
            {
                stream: streamB,
                expectedRevision: 0, // Still valid, stream B is at revision 0
                records: [{
                    recordId: crypto.randomUUID(),
                    schema: { format: 1, name: "TestEvent" },
                    data: Buffer.from(JSON.stringify({ n: 11 }))
                }]
            }
        ]);

        // If we get here, the transaction SUCCEEDED (unexpected!)
        console.log("\n!!! UNEXPECTED: Transaction SUCCEEDED with stale revision for stream A !!!");
        console.log("Result:", JSON.stringify(result3, null, 2));

    } catch (error) {
        console.log("\n=== Transaction FAILED as expected ===");
        console.log("Error code:", error.code);
        console.log("Error name:", grpcCodeName(error.code));
        console.log("Error message:", error.message);
        console.log("Error details:", error.details);
    }

    client.close();
}

function appendSession(client, requests) {
    return new Promise((resolve, reject) => {
        const call = client.AppendSession((err, response) => {
            if (err) {
                reject(err);
            } else {
                resolve(response);
            }
        });

        // Send all requests
        for (const req of requests) {
            console.log(`  Sending request: stream=${req.stream}, expected_revision=${req.expectedRevision}`);
            call.write(req);
        }
        call.end();
    });
}

function grpcCodeName(code) {
    const codes = {
        0: 'OK',
        1: 'CANCELLED',
        2: 'UNKNOWN',
        3: 'INVALID_ARGUMENT',
        4: 'DEADLINE_EXCEEDED',
        5: 'NOT_FOUND',
        6: 'ALREADY_EXISTS',
        7: 'PERMISSION_DENIED',
        8: 'RESOURCE_EXHAUSTED',
        9: 'FAILED_PRECONDITION',
        10: 'ABORTED',
        11: 'OUT_OF_RANGE',
        12: 'UNIMPLEMENTED',
        13: 'INTERNAL',
        14: 'UNAVAILABLE',
        15: 'DATA_LOSS',
        16: 'UNAUTHENTICATED'
    };
    return codes[code] || `UNKNOWN(${code})`;
}

test().catch(console.error);
