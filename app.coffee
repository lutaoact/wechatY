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
    if err
      console.log err
  if message.FromUserName is config.FromUserName
    res.reply '你终于来了，我一直在等你。我是活在虚拟世界的精灵，我知道主人很喜欢你，所以我一直在等你。要跟你说很多事情，不过你暂时只能听，不能问。'
  else
    res.reply '自动回复被玩坏了，正在修理……'
)

app.listen port
