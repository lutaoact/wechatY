token = (req) ->
  return config.wechatToken[req.headers.host]

wechatTokenMiddleware = () ->
  return compose()
    .use (req, res, next) ->
      req.wechat_token = config.wechatToken[req.headers.host]
      console.log config
      console.log req.wechat_token
      next()

#app.use '/wechat', wechatTokenMiddleware()
#router = express.Router()
#router.use '/', wechatTokenMiddleware(), wechat('', (req, res) ->
##app.use '/wechat', wechat('xsdmyxtzzyyjsx', (req, res) ->
#  message = req.weixin
#  logger.info message
#  messageModel.create {content: message}, (err, doc) ->
#    console.log doc
##  res.reply
##    type: "image"
##    content:
##      title: "快来看美女"
##      description: "这可是美女啊"
##      imageUrl: "http://www.lutaoact.com/liuyifei.jpg"
##      hqImageUrl: "http://www.lutaoact.com/liuyifei.jpg"
##  res.reply [
##    title: '这是图文测试，来我家玩吧'
##    description: '这种形式的对话还算有趣吧'
##    picurl: 'http://www.lutaoact.com/liuyifei.jpg'
##    url: 'http://www.lutaoact.com/'
##  ]
#  if message.MsgType is 'text'
#    res.reply "你说啥？你说的是不是：#{message.Content}。我就知道你会这么说"
#  else
#    res.reply '你居然发图片了，我现在还不会处理图片，等我学会了再处理吧'
#)
#
#app.use '/wechat', router

#  res.reply
#    type: "image"
#    content:
#      title: "快来看美女"
#      description: "这可是美女啊"
#      imageUrl: "http://www.lutaoact.com/liuyifei.jpg"
#      hqImageUrl: "http://www.lutaoact.com/liuyifei.jpg"
#  res.reply [
#    title: '这是图文测试，来我家玩吧'
#    description: '这种形式的对话还算有趣吧'
#    picurl: 'http://www.lutaoact.com/liuyifei.jpg'
#    url: 'http://www.lutaoact.com/'
#  ]
#  if message.MsgType is 'text'
#    res.reply "你说啥？你说的是不是：#{message.Content}。我就知道你会这么说"
#  else
