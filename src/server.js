var express = require('express');
var app = express();
var router = express.Router();
router.get('/ping', function (req, res) {
    res.send('Hello asdfasdfWorld');
});
app.use('/', router);
var port = process.env.PORT || 3000;
app.listen(port, function () {
    console.log("Server started. Listening on port: " + port);
});
