"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express = require('express');
const app = express();
const aws_sdk_1 = require("aws-sdk");
const db = process.env.IS_OFFLINE ?
    new aws_sdk_1.DynamoDB.DocumentClient({
        region: 'localhost',
        endpoint: `http://${process.env.DYNAMODB_HOST || 'localhost'}:${process.env.DYNAMODB_PORT || 8000}`,
    }) :
    new aws_sdk_1.DynamoDB.DocumentClient();
const categories = {
    categories: [
        'summary',
        'state',
        'district',
        'population',
        'website',
        'geography',
        'religion',
        'pointOfInterest'
    ]
};
async function getItemById(townId) {
    const params = {
        TableName: 'Town',
        Key: {
            id: townId
        }
    };
    const data = await db.get(params).promise();
    if (data.Item === undefined) {
        throw new Error('error');
    }
    return data.Item;
}
exports.getItemById = getItemById;
async function getAttributesInItem(townId, attributes) {
    const params = {
        TableName: 'Town',
        Key: {
            id: townId
        },
        AttributesToGet: attributes
    };
    const data = await db.get(params).promise();
    if (data.Item === undefined) {
        throw new Error('error');
    }
    return data.Item;
}
exports.getAttributesInItem = getAttributesInItem;
app.get('/health', async (req, res) => {
    res.send('OK!');
});
app.get('/town', async (req, res) => {
    res.send(categories);
});
app.get('/town/:townId', async (req, res) => {
    const data = await getItemById(req.params.townId);
    res.send(data);
});
app.get('/town/:townId/:category', async (req, res) => {
    const townId = req.params.townId;
    const category = req.params.category;
    if (categories.categories.includes(category)) {
        const data = await getAttributesInItem(townId, [category]);
        res.send(data);
    }
    else {
        res.statusCode = 404;
        res.statusMessage = 'category not found';
        res.send();
    }
});
const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server started. Listening on port: ${port}`);
});
