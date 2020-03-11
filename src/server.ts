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

export async function getItemById(townId: number): Promise<Item> {
    console.log('here');
    const params = {
        TableName: 'Heidenheim',
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

export async function getAttributesInItem(townId: number, attributes: string[]): Promise<Item> {
    const params = {
        TableName: 'Heidenheim',
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
    res.send('OK!')
})

app.get('/heidenheim', async (req: Request, res: Response) => {
    const data = await getItemById(1);
    res.send(data)
})

app.get('/heidenheim/category', async (req: Request, res: Response) => {
    res.send(categories)
})

app.get('/heidenheim/category/:category', async (req: Request, res: Response) => {
    const category = req.params.category;
    if (categories.categories.includes(category)) {
        const data = await getAttributesInItem(1, [category])
        res.send(data)
    } else {
        res.statusCode = 404
        res.statusMessage = 'category not found'
        res.send()
    }
})

const port = process.env.PORT || 3000
app.listen(port, () => {
    console.log(`Server started. Listening on port: ${port}`)
    console.log(process.env.IS_OFFLINE)
})