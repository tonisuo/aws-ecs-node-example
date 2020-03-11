const express = require('express')
const app = express()
import { Request, Response } from "express";
import { DynamoDB } from 'aws-sdk'
import Item from './Item'

const db = process.env.IS_OFFLINE ?
  new DynamoDB.DocumentClient({
    region: 'localhost',
    endpoint: `http://${process.env.DYNAMODB_HOST || 'localhost'}:${process.env.DYNAMODB_PORT || 8000}`,
  }) :
  new DynamoDB.DocumentClient();

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
}

export async function getItemById(townId: string): Promise<Item> {
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
    return data.Item as Item;
}

export async function getAttributesInItem(townId: string, attributes: string[]): Promise<Item> {
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
    return data.Item as Item;
}

app.get('/health', async (req: Request, res: Response) => {
    res.send('OK!');
})

app.get('/town', async (req: Request, res: Response) => {
    res.send(categories);
})

app.get('/town/:townId', async (req: Request, res: Response) => {
    const data = await getItemById(req.params.townId);
    res.send(data);
})

app.get('/town/:townId/:category', async (req: Request, res: Response) => {
    const townId = req.params.townId;
    const category = req.params.category;
    if (categories.categories.includes(category)) {
        const data = await getAttributesInItem(townId, [category]);
        res.send(data);
    } else {
        res.statusCode = 404;
        res.statusMessage = 'category not found';
        res.send();
    }
})

const port = process.env.PORT || 3000
app.listen(port, () => {
    console.log(`Server started. Listening on port: ${port}`);
})