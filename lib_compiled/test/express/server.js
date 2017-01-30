var express = require('express');
var app = express();
var path=require("path");
require('./router/router.js')(app);
var server=app.listen(3000, function () {
    console.log('Example app listening on port 3000!');
});
//console.log(". = %s", path.resolve("."));
//console.log('__dirname: ', __dirname);
//console.log('process.cwd(): ', process.cwd());
setTimeout(function () {
    server.close();
}, 100);
