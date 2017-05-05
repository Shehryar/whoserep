const http = require('http');
const router = require('./routes').router;

const PORT = process.argv[2] || 9000;

http.createServer(router).listen(PORT);

console.log('Server listening on port: ' + PORT);
