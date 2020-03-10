"use strict";
exports.__esModule = true;
var express = require('express');
var app = express();
var router = express.Router();
app.get('/ping', function (req, res) {
    res.send('Hello assdfasdfsddf');
});
app.get('/ping/:message', function (req, res) {
    res.send(req.params.message);
});
var port = process.env.PORT || 3000;
app.listen(port, function () {
    console.log("Server started. Listening on port: " + port);
});
