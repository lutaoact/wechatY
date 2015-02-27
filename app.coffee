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

app.use '/wechat', wechat('xsdmyxtzzyyjsx', (req, res) ->
  message = req.weixin
  logger.info message
  messageModel.create {content: message}, (err, doc) ->
    if err
      console.log err
  if message.FromUserName is config.FromUserName
    return res.reply '你终于来了，我一直在等你。我是活在虚拟世界的精灵，我知道主人很喜欢你，所以我一直在等你。要跟你说很多事情，不过你暂时只能听，不能问。'
  else
    name = config.openid2nameMap[message.FromUserName]
    if name
      res.reply "我是这里的小精灵，我认识你，主人说，你叫#{name}，我刚出生不久，所以什么都不懂，你过段时间再来找我玩吧！"
    else
      res.reply "我是这里的小精灵，我不认识你，主人说，不要跟陌生人乱说话，我刚出生不久，所以什么都不懂，你过段时间再来找我玩吧！说不定我就能知道你是睡啦。"
)

app.listen port
