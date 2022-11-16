const statik = require('node-static');

var fileServer = new statik.Server('./public');

require('http').createServer(function (request, response) {
    request.addListener('end', function () {
        fileServer.serve(request, response);
    }).resume();
}).listen(process.env.PORT || 3000);
