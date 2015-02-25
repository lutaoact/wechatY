log4js = require 'log4js'

log4js.configure
  appenders: [
    type        : 'console'
    layout      :
      type      : 'pattern'
      pattern   : "%d{ISO8601} %[%-5p%] - %c %m"
  ,
    type        : 'file'
    filename    : '/data/log/wechat.log'
    layout      :
      type      : 'pattern'
      pattern   : "%d{ISO8601}\t%m"
    category    : 'WECHAT'
  ]

logger = log4js.getLogger 'WECHAT'
logger.setLevel 'INFO'

exports.logger = logger
