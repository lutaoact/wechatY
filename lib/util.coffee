_ = require 'lodash'
Const = require './Const'

keywordsMap = require './keywords.json'
keys = _.keys keywordsMap
values = _.values keywordsMap
randomValues = values.concat [Const.WhatAreYouSaying]

exports.getReply = (text) ->
  for key in keys
    if ~text.indexOf(key)
      return keywordsMap[key]

  return null

exports.getRandomReply = () ->
  return _.sample randomValues
