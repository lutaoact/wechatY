moment = require 'moment'
_ = require 'lodash'

#console.log moment().hour()
keys = _.keys require './lib/keyReply'
console.log keys.join '、'
counter = {count: 1, ts: new Date().getTime() // 1000}
