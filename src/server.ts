import express from 'express'
import {Request, Response} from "express";
const app = express()
const router = express.Router()

app.get('/ping', (req: Request, res: Response) => {
    res.send('Hello asdfasdfWorld')
})

app.get('/ping/:message', (req: Request, res: Response) => {
    res.send(req.params.message)
})

const port = process.env.PORT || 3000
app.listen(port, () => {
    console.log(`Server started. Listening on port: ${port}`)
})