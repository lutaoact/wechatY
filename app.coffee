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
          return res.reply keyReply
        else
          return res.reply "主人说，这篇不能看，不好意思……"
      else
        return res.reply keyReply

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
      # 如果计数大于1，并且时间间隔小于10分钟，则不回复消息
      if globalCounter[openid].count++ > 1 and nowTimestamp - globalCounter[openid].ts < 60 * 10 #10分钟
        globalCounter[openid].ts = nowTimestamp
        return res.reply ''
      else
        globalCounter[openid].ts = nowTimestamp
        return res.reply Const.WhatAreYouSaying #不知道你在说什么
  else
    if globalCounter[openid].count++ > 1 and nowTimestamp - globalCounter[openid].ts < 60 * 10 #10分钟
      globalCounter[openid].ts = nowTimestamp
      return res.reply ''
    else
      globalCounter[openid].ts = nowTimestamp

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
          return res.reply _s.sprintf Const.KnownOthers, name, messageCountDoc.count
      else
        if messageCountDoc.count is 1
          return res.reply _s.sprintf Const.Unknown1st, messageCountDoc.count
        else
          return res.reply _s.sprintf Const.UnknownOthers, messageCountDoc.count
  )
)

app.listen port
