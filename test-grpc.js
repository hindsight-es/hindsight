const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');

const PROTO_PATH = './hindsight-kurrentdb-store/proto/streams.proto';

const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true
});

const protoDescriptor = grpc.loadPackageDefinition(packageDefinition);
const streams = protoDescriptor.event_store.client.streams;

const client = new streams.Streams('localhost:1113', grpc.credentials.createInsecure());

console.log('Attempting to connect...');

const call = client.Read({
  options: {
    stream: { streamIdentifier: { streamName: Buffer.from('test-stream') } },
    all: null,
    readDirection: 0,
    resolveLinks: false,
    count: 10,
    noFilter: { }
  }
});

call.on('data', (response) => {
  console.log('✓ Got response:', response);
});

call.on('end', () => {
  console.log('✓ Stream ended successfully');
  process.exit(0);
});

call.on('error', (err) => {
  console.error('✗ Error:', err.message);
  process.exit(1);
});

setTimeout(() => {
  console.error('✗ Timeout after 10 seconds');
  process.exit(1);
}, 10000);
