// Check available methods on the Kurrent client
const k = require('@kurrent/kurrentdb-client');

console.log('Top-level exports:');
console.log(Object.keys(k).sort().join('\n'));

console.log('\n\nKurrentDBClient methods:');
const KurrentDBClient = k.KurrentDBClient;
if (KurrentDBClient) {
    const methods = Object.getOwnPropertyNames(KurrentDBClient.prototype)
        .filter(n => n !== 'constructor')
        .sort();
    console.log(methods.join('\n'));
}
