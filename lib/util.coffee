_ = require 'lodash'
Const = require './Const'

keywordsMap = require './keywords.json'
keys = _.keys keywordsMap
values = _.values keywordsMap
randomWords = require './randomWords'
randomValues = values.concat randomWords

exports.getReply = (text) ->
  for key in keys
    if ~text.indexOf(key)
      return keywordsMap[key]

  return null

exports.getRandomReply = () ->
  return _.sample randomValues
