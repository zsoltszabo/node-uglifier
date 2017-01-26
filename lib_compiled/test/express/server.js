var express = require('express');
var app = express();
require('./router/router.js')(app);
var server=app.listen(3000, function () {
    console.log('Example app listening on port 3000!');
});
setTimeout(function () {
    server.close();
}, 100);
