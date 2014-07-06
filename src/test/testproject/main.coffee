_ = require('underscore')
sugar = require('sugar')
C=require("./depa/constants")
cryptoLoc=require("./depb/cryptoLoc.js")
rootDependency=require("./rootDependency")
crypto	= require('crypto')
#test it with new as well, same as calling require here
deepModule=new require('./depb/depDeep/deepModule')
SomeClass=new (require('./depc/SomeClass'))("test1")
SomeClass2=new require('./depc/SomeClass2')

#calculate the sha1 of the encrypted message from constants
message=cryptoLoc.dec(cryptoLoc.enc(C.PART_A + C.PART_B,"secret"),"secret")
shasum = crypto.createHash('sha1')

r=shasum.update(message).digest("hex")
console.log(rootDependency.theNonTrivialFunction(r))

if !_.isEqual(rootDependency.theNonTrivialFunction(r),"ROOT_TEST_6af9b2faa8ae8e408decd4f7121888af71597a90")
  throw new Error("ups did not work we got: " + rootDependency.theNonTrivialFunction(r) + "  instead")

if !_.isEqual(deepModule.boothDeepAndShalow(r),deepModule.boothDeepAndShalow("6af9b2faa8ae8e408decd4f7121888af71597a90"))
  throw new Error("ups did not work we got: " + r + "  instead")

if !_.isEqual(SomeClass.get(),"test1")
  throw new Error("ups did not work we got: " + SomeClass.get() + "  instead test1 ")

if !_.isEqual((new SomeClass2("test2").get()),"test2")
  throw new Error("ups did not work we got: " + (new SomeClass2("test2").get() + "  instead test2 "))







