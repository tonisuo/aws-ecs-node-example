"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express = require('express');
const app = express();
const router = express.Router();
app.get('/ping', (req, res) => {
    res.send('Hello assdfasdfsddf');
});
app.get('/ping/:message', (req, res) => {
    res.send(req.params.message);
});
const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server started. Listening on port: ${port}`);
});
