#
#/*!
# * node-uglifier
# * Copyright (c) 2014 Zsolt Szabo Istvan
# * MIT Licensed
# *
# */
#

_ = require('underscore')
sugar = require('sugar')
crypto=require("crypto")
seedrandom=require("seedrandom")

cryptoUtils=module.exports

cryptoUtils.generateSalt=(saltLength)->crypto.randomBytes(Math.ceil(saltLength / 2)).toString('hex').substring(0, saltLength);
cryptoUtils.getSaltedHash=(message,hashAlgorithm,salt)->crypto.createHmac(hashAlgorithm,salt).update(message).digest('hex')

cryptoUtils.shuffleArray=(array,seed=null)->
  randFnc=Math.random
  if seed then randFnc=seedrandom(seed);
  for i in [array.length - 1..0]
    j = Math.floor(randFnc() * (i + 1));
    temp = array[i];
    array[i] = array[j];
    array[j] = temp;

  return array;
