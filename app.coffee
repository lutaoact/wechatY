wechat = require 'wechat'
express = require 'express'
path = require 'path'
logger = require('./logger').logger
config = require 'config'
console.log config
compose = require('composable-middleware')
_ = require 'lodash'
_s = require 'underscore.string'
Const = require './lib/Const'

mongoose = require 'mongoose'
mongoose.connect config.mongo.uri
Schema = mongoose.Schema

messageSchema = new Schema
  content: {}
messageModel = mongoose.model 'message', messageSchema

messageCountSchema = new Schema
  openid: String
  count: Number
  date: Date
messageCountModel = mongoose.model 'message_count', messageCountSchema

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
  openid = message.FromUserName
  messageCountModel.findOneAndUpdate {openid: openid}, {$inc: {count: 1}, $set: {date: new Date()}}, {upsert: true}, (err, messageCountDoc) ->
    if err
      return logger.info err
    if message.FromUserName is config.FromUserName
      return res.reply '你终于来了，我一直在等你。我是活在虚拟世界的精灵，我知道主人很喜欢你，所以我一直在等你。要跟你说很多事情，不过你暂时只能听，不能问。'
    else
      name = config.openid2nameMap[message.FromUserName]
      if name
        if messageCountDoc.count is 1
          res.reply _s.sprintf Const.Known1st, name, messageCountDoc.count
        else
          res.reply _s.sprintf Const.KnownOthers, name, messageCountDoc.count
      else
        if messageCountDoc.count is 1
          res.reply_s.sprintf Const.Unknown1st, messageCountDoc.count
        else
          res.reply _s.sprintf Const.UnknownOthers, messageCountDoc.count
)

app.listen port
