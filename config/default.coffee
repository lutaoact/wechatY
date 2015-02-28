module.exports =
  hello: 'girlfriend'
  appName: 'wechatY'
  port: 8061
  morgan:
    accessLog: '/data/log/wechatY.access.log'
    errorLog : '/data/log/wechatY.error.log'
  mongo:
    uri: 'mongodb://localhost/wechatY'
#  Yang: 'oPk5NsykQOZC2OS4ttlaz0b4NRDA' #xueye
  Yang: 'oPk5Ns5T_OHKiUZxuNlHUUMcnp7A'#yang
  openid2nameMap: require '../openid2name'
