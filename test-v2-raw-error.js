// Test script to inspect raw gRPC error for V2 version mismatch
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
    const streamA = `test-raw-error-${timestamp}`;

    console.log("Testing raw gRPC error for V2 version mismatch...\n");

    try {
        // Step 1: Create stream with initial event
        console.log("Step 1: Creating stream with NoStream expectation...");
        const result1 = await appendSession(client, [{
            stream: streamA,
            expectedRevision: -1, // NoStream
            records: [{
                recordId: crypto.randomUUID(),
                schema: { format: 1, name: "TestEvent" },
                data: Buffer.from(JSON.stringify({ n: 1 }))
            }]
        }]);
        console.log("Step 1 succeeded:", result1);

        // Step 2: Try to write again with NoStream (should fail)
        console.log("\nStep 2: Trying to write with STALE NoStream expectation...");
        const result2 = await appendSession(client, [{
            stream: streamA,
            expectedRevision: -1, // NoStream (but stream now exists!)
            records: [{
                recordId: crypto.randomUUID(),
                schema: { format: 1, name: "TestEvent" },
                data: Buffer.from(JSON.stringify({ n: 2 }))
            }]
        }]);
        console.log("Step 2 succeeded (unexpected!):", result2);

    } catch (error) {
        console.log("\n=== gRPC Error Details ===");
        console.log("Error name:", error.name);
        console.log("Error message:", error.message);
        console.log("Error code:", error.code);
        console.log("Error code name:", grpcCodeName(error.code));
        console.log("Error details:", error.details);
        console.log("Error metadata:", error.metadata?.getMap?.());
        console.log("\nAll error properties:");
        for (const key of Object.keys(error)) {
            console.log(`  ${key}:`, error[key]);
        }
        console.log("\nFull error object:");
        console.log(error);
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
