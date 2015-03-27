wechat = require 'wechat'
express = require 'express'
path = require 'path'
logger = require('./logger').logger
config = require 'config'
console.log config
compose = require('composable-middleware')
_ = require 'lodash'
_s = require 'underscore.string'
_u = require './lib/util'
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
  name: String
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

WordsForYang = require './lib/WordsForYang.json'
keyReplyMap = require './lib/keyReply'
globalCounter = {}
moment = require 'moment'

app.use '/wechat', wechat('xsdmyxtzzyyjsx', (req, res) ->
  message = req.weixin
  logger.info message
  messageModel.create {content: message}, (err, doc) ->
    if err
      console.log err

  # 处理订阅时的回复
  if message.MsgType is 'event' and message.Event is 'subscribe'
    return res.reply Const.Subscribe

  # 处理关键词回复
  if message.MsgType is 'text'
    keyReply = keyReplyMap[message.Content]
    if keyReply
      if message.Content is '爱你'
        if message.FromUserName is config.Yang
          return res.reply "主人心情不太好，暂时没法跟大家聊天了……"
        else
          return res.reply "主人说，这篇不能看，不好意思……"
      else
        return res.reply keyReply

    #如果在回复的文本里找到了关键字
#    if _u.getReply message.Content
#      return res.reply _u.getReply message.Content

  if message.FromUserName is config.Yang
    return res.reply "主人心情不太好，暂时没法跟大家聊天了……"
  else
    return res.reply "这个，这个，主人不在，他看到留言之后，会回复的，多谢关注。"

  openid = message.FromUserName
  name = config.openid2nameMap[openid]
  nowTimestamp = new Date().getTime() // 1000
  # 处理短时间里的大量回复
  globalCounter[openid] ?= {name: name, count: 1, ts: nowTimestamp} #默认计数为1
  logger.info globalCounter
  if openid is config.Yang
    if ~~message.Content #如果解析结果为正整数，则取相应的句子
      return res.reply WordsForYang[~~message.Content] || Const.OwnerIsBack
    else
      if globalCounter[openid].count++ > 1 and nowTimestamp - globalCounter[openid].ts < 60 * 10 #10分钟
        globalCounter[openid].ts = nowTimestamp
        return res.reply _u.getRandomReply()
      else
        globalCounter[openid].ts = nowTimestamp
        hour = moment().hours()
        if hour >= 22 or hour < 1
          return res.reply Const.GoToBedEarly
        if hour >= 1 and hour < 7
          return res.reply Const.TooLate
        if hour < 10
          return res.reply Const.SoEarly

        return res.reply _u.getRandomReply() #随机回复

  update = {$inc: {count: 1}, $set: {date: new Date()}}
  update.name = name if name
  messageCountModel.findOneAndUpdate(
    {openid: openid}
    update
    {upsert: true}
    (err, messageCountDoc) ->
      if err then return logger.info err

      if name
        if messageCountDoc.count is 1
          return res.reply _s.sprintf Const.Known1st, name, messageCountDoc.count
        else
          return res.reply (_s.sprintf Const.Known, name, messageCountDoc.count) + _u.getRandomReply()
      else
        if messageCountDoc.count is 1
          return res.reply _s.sprintf Const.Unknown1st, messageCountDoc.count
        else
          return res.reply (_s.sprintf Const.Unknown, messageCountDoc.count) + _u.getRandomReply()
  )
)

app.listen port
