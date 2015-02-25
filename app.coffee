wechat = require 'wechat'
express = require 'express'
path = require 'path'
logger = require('./logger').logger
config = require 'config'
console.log config
compose = require('composable-middleware')

mongoose = require 'mongoose'
mongoose.connect config.mongo.uri
Schema = mongoose.Schema

messageSchema = new Schema
  content: {}

messageModel = mongoose.model 'message', messageSchema

app = express()
port = config.port

app.use(express.static(path.join(__dirname, 'public')))

morgan = require 'morgan'
fs = require 'fs'
accessLog = fs.createWriteStream(config.morgan.accessLog, { flags: 'a' })
errorLog = fs.createWriteStream(config.morgan.errorLog, { flags: 'a' })
app.use(morgan('combined', {stream: accessLog}))
app.use(morgan('dev'))

logger.info "server listening on port #{port}..."

app.get '/', (req, res) ->
  res.send hello: 'girlfriend'

#需要设置端口转发，对9000端口的访问都转发到80
app.use '/wechat', wechat('xsdmyxtzzyyjsx', (req, res) ->
  message = req.weixin
  logger.info message
  messageModel.create {content: message}, (err, doc) ->
    console.log doc
  res.reply '自动回复被你们玩坏了，正在修理，过几天再来玩吧，肯定会变得更好玩的'
)

app.listen port
