_ = require 'lodash'
keywordsMap = require './keywords.json'
keys = _.keys keywordsMap

exports.getReply = (text) ->
  for key in keys
    if ~text.indexOf(key)
      return keywordsMap[key]

  return null
