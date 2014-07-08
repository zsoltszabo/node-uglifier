fs = require('fs');
NodeUglifier=require("../NodeUglifier")
packageUtils=require('../libs/packageUtils')
path = require('path')
#_=require("\x6e\x64\x65\x72\x73\x63\x6f\x72\x65\x6e")

IS_RE_CREATE_TEST_FILES=false

exports.testStuff=(test)->
  t0="./test/test2"
  t0_2="onderscore"
  t1=packageUtils.hexifyString(t0_2)
  console.log(t1)
  console.log("\n")
  test.done()

exports.testPackageUtils=(test)->
  test.deepEqual(packageUtils.getMatchingFiles("lib_compiled/test/testproject/main.js",[]),[])

  shouldBeResult1=[ 'C:\\DEV\\GITHOME\\git5\\node-uglifier\\lib_compiled\\test\\testproject\\depa\\constants.js',
                    'C:\\DEV\\GITHOME\\git5\\node-uglifier\\lib_compiled\\test\\testproject\\depa\\constants.map' ]
  #  console.log(packageUtils.getMatchingFiles("lib_compiled/test/testproject/main.js",["./depa/"])) #["main","./depa/","./depb/cryptoLoc.js","./depb/depDeep/deepModule"]
  test.deepEqual(packageUtils.getMatchingFiles("lib_compiled/test/testproject/",["./depa/"]),shouldBeResult1)
  test.deepEqual(packageUtils.getMatchingFiles("lib_compiled/test/testproject",["./depa/"]),shouldBeResult1)
  test.deepEqual(packageUtils.getMatchingFiles("lib_compiled/test/testproject/main.js",["./depa/"]),shouldBeResult1)

  shouldBeResult2=[ 'C:\\DEV\\GITHOME\\git5\\node-uglifier\\lib_compiled\\test\\testproject\\main\\main.js',
                    'C:\\DEV\\GITHOME\\git5\\node-uglifier\\lib_compiled\\test\\testproject\\main\\main.map',
                    'C:\\DEV\\GITHOME\\git5\\node-uglifier\\lib_compiled\\test\\testproject\\depb\\cryptoLoc.js',
                    'C:\\DEV\\GITHOME\\git5\\node-uglifier\\lib_compiled\\test\\testproject\\depb\\depDeep\\deepModule\\deepModule.js',
                    'C:\\DEV\\GITHOME\\git5\\node-uglifier\\lib_compiled\\test\\testproject\\depb\\depDeep\\deepModule\\deepModule.map' ]

#  console.log(packageUtils.getMatchingFiles("lib_compiled/test/testproject/main.js",["main","./depb/cryptoLoc.js","./depb/depDeep/deepModule"]))
  test.deepEqual(packageUtils.getMatchingFiles("lib_compiled/test/testproject/main.js",["main","./depb/cryptoLoc.js","./depb/depDeep/deepModule"]),shouldBeResult2)

  test.done()


exports.testMerge=(test)->

  testFile="lib_compiled/test/resultFiles/simpleMerge.js"

  nodeUglifier=new NodeUglifier("lib_compiled/test/testproject/main.js",{rngSeed:"hello"})
  mergedSource=nodeUglifier.merge().toString()

  try
    eval(mergedSource)
  catch me
    test.fail(me.toString(),"expected no error thrown from combined project")

  if IS_RE_CREATE_TEST_FILES then nodeUglifier.exportToFile(testFile)
  test.equals(packageUtils.readFile(testFile).toString(),mergedSource)

  test.done()


exports.testMergeWithFilter=(test)->

  testFile="lib_compiled/test/resultFiles/simpleMergeWithFilter.js"

  nodeUglifier=new NodeUglifier("lib_compiled/test/testproject/main.js",{rngSeed:"hello",mergeFileFilter:["./lib_static/test/","./depa/constants.js"]})
  mergedSource=nodeUglifier.merge().toString()

  if IS_RE_CREATE_TEST_FILES then   nodeUglifier.exportToFile(testFile)

  test.equals(packageUtils.readFile(testFile).toString(),mergedSource)

  test.done()

exports.testMergeWithFilterAndUglify=(test)->

  testFile="lib_compiled/test/resultFiles/simpleMergeWithFilterAndUglify.js"
  uglifySourceMap="lib_compiled/test/resultFiles/sourcemaps/simpleMergeWithFilterAndUglify.js"

  nodeUglifier=new NodeUglifier("lib_compiled/test/testproject/main.js",{rngSeed:"hello",mergeFileFilter:["./lib_static/test/","./depa/constants.js"]})
  mergedSource=nodeUglifier.merge().uglify().toString()

  if IS_RE_CREATE_TEST_FILES then   nodeUglifier.exportToFile(testFile)
  nodeUglifier.exportSourceMaps(uglifySourceMap)

  test.equals(packageUtils.readFile(testFile).toString(),mergedSource)

  test.done()


exports.testMergeWithFilterAndUglifyAndStrProtection=(test)->

  testFile="lib_compiled/test/resultFiles/simpleMergeWithFilterAndUglifyAndStrProtection.js"
  uglifySourceMap="lib_compiled/test/resultFiles/sourcemaps/simpleMergeWithFilterAndUglifyAndStrProtection.js"

  nodeUglifier=new NodeUglifier("lib_compiled/test/testproject/main.js",{rngSeed:"hello",mergeFileFilter:["./lib_static/test/","./depa/constants.js"]})
  mergedSource=nodeUglifier.merge().uglify({strProtectionLvl:1}).toString()

  if IS_RE_CREATE_TEST_FILES then nodeUglifier.exportToFile(testFile)
  nodeUglifier.exportSourceMaps(uglifySourceMap)

#  try
#    eval(mergedSource)
#  catch me
#    test.fail(me.toString(),"expected no error thrown from combined project")

  test.equals(packageUtils.readFile(testFile).toString(),mergedSource)

  test.done()