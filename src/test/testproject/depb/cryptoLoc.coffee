GibberishAES=require('../lib_static/test/gibberish-aes')
deepModule=require('./depDeep/deepModule')

cryptoLoc = module.exports

cryptoLoc.enc=(data,key)->
  enc=GibberishAES.enc(data,deepModule.boothDeepAndShalow(key))
  return enc

cryptoLoc.dec=(data,key)->
  dec=GibberishAES.dec(data,deepModule.boothDeepAndShalow(key))
  return dec
