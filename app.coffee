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

app.use '/wechat', wechat('xsdmyxtzzyyjsx', (req, res) ->
  message = req.weixin
  logger.info message
  messageModel.create {content: message}, (err, doc) ->
    if err
      console.log err
  openid = message.FromUserName
  name = config.openid2nameMap[openid]

  update = {$inc: {count: 1}, $set: {date: new Date()}}
  update.name = name if name
  messageCountModel.findOneAndUpdate(
    {openid: openid}
    update
    {upsert: true}
    (err, messageCountDoc) ->
      if err
        return logger.info err
      if openid is config.FromUserName
        if messageCountDoc.count is 1
          return res.reply WordsForYang[0]
        else
          if ~~message.Content #如果解析结果为正整数，则取相应的句子
            return res.reply WordsForYang[~~message.Content] || Const.OwnerIsBack
          else
            return res.reply Const.WhatAreYouSaying #不知道你在说什么
      else
        if name
          if messageCountDoc.count is 1
            res.reply _s.sprintf Const.Known1st, name, messageCountDoc.count
          else
            res.reply _s.sprintf Const.KnownOthers, name, messageCountDoc.count
        else
          if messageCountDoc.count is 1
            res.reply _s.sprintf Const.Unknown1st, messageCountDoc.count
          else
            res.reply _s.sprintf Const.UnknownOthers, messageCountDoc.count
  )
)

app.listen port
