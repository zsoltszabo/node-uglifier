fs = require('fs');
fsExtra = require('fs-extra');
NodeUglifier=require("../NodeUglifier")
packageUtils=require('../libs/packageUtils')
path = require('path')
#_=require("\x6e\x64\x65\x72\x73\x63\x6f\x72\x65\x6e")


IS_RE_CREATE_TEST_FILES=true

exports.testMergeWithBothExportFilterTypes=(test)->

  testFile="lib_compiled/test/resultFiles/simpleMergeWithBothExportFilterTypes.js"

  nodeUglifier=new NodeUglifier("lib_compiled/test/testproject/main.js",{rngSeed:"hello",mergeFileFilterWithExport:["./lib_static/test/","./depa/constants.js"],mergeFileFilter:["./depDynamic/filename_used_in_dynamic_require.js"]})
  mergedSource=nodeUglifier.merge().toString()
  nodeUglifier.exportToFile(testFile)
  #dont test equality, heavily coffeescript version dependent due to comments not removed
  #  test.equals(packageUtils.readFile(testFile).toString(),mergedSource)

  try
    GLOBAL._loadDynamic=true
    #if main runs without error OK
    main=require(path.resolve(testFile));
  catch me
    test.fail("result file should run without throwing errors")


  GLOBAL._loadDynamic=false
  #if main runs without error OK
  main=require(path.resolve(testFile));


  test.done()

exports.testJsonImport=(test)->

  testFile="lib_compiled/test/resultFiles/testJsonImport.js"

  nodeUglifier=new NodeUglifier("lib_compiled/test/testJsonImport/main.js",{rngSeed:"hello"})
  mergedSource=nodeUglifier.merge().toString()

  try
    eval(mergedSource)
  catch me
    test.fail(me.toString(),"expected no error thrown from combined project")

  if IS_RE_CREATE_TEST_FILES then nodeUglifier.exportToFile(testFile)
  else
    test.equals(packageUtils.readFile(testFile).toString(),mergedSource)

  test.done()

exports.testEs6=(test)->

    testFile="lib_compiled/test/resultFiles/es6proj.js"

    nodeUglifier=new NodeUglifier("lib_compiled/test/es6proj/main.js",{rngSeed:"hello"})
    mergedSource=nodeUglifier.merge().uglify().toString()

    try
        eval(mergedSource)
    catch me
        test.fail(me.toString(),"expected no error thrown from combined project")


    if IS_RE_CREATE_TEST_FILES then nodeUglifier.exportToFile(testFile)
    else
        test.equals(packageUtils.readFile(testFile).toString(),mergedSource)

    test.done()

exports.testExpress=(test)->

    testFile="lib_compiled/test/resultFiles/express.js"

    nodeUglifier=new NodeUglifier("lib_compiled/test/express/server.js",{rngSeed:"hello"})
    mergedSource=nodeUglifier.merge().uglify().toString()

    try
        eval(mergedSource)
    catch me
        test.fail(me.toString(),"expected no error thrown from combined project")


    if IS_RE_CREATE_TEST_FILES then nodeUglifier.exportToFile(testFile)
    else
        test.equals(packageUtils.readFile(testFile).toString(),mergedSource)

    test.done()

exports.testStuff=(test)->
  t0="./test/test2"
  t0_2="onderscore"
  t1=packageUtils.hexifyString(t0_2)
  console.log(t1)
  console.log("\n")
  test.done()

relativeToDir=(dir)->
    path.relative(__dirname,dir)



exports.testPackageUtils=(test)->
  test.deepEqual(packageUtils.getMatchingFiles("lib_compiled/test/testproject/main.js",[]),[])

  shouldBeResult1=[ 'testproject\\depa\\constants.js',
                    'testproject\\depa\\constants.js.map' ]
  #  console.log(packageUtils.getMatchingFiles("lib_compiled/test/testproject/main.js",["./depa/"])) #["main","./depa/","./depb/cryptoLoc.js","./depb/depDeep/deepModule"]
  test.deepEqual(packageUtils.getMatchingFiles("lib_compiled/test/testproject/",["./depa/"]).map(relativeToDir),shouldBeResult1)
  test.deepEqual(packageUtils.getMatchingFiles("lib_compiled/test/testproject",["./depa/"]).map(relativeToDir),shouldBeResult1)
  test.deepEqual(packageUtils.getMatchingFiles("lib_compiled/test/testproject/main.js",["./depa/"]).map(relativeToDir),shouldBeResult1)

  shouldBeResult2=[ 'testproject\\main\\main.js',
                    'testproject\\main\\main.js.map',
                    'testproject\\depb\\cryptoLoc.js',
                    'testproject\\depb\\depDeep\\deepModule\\deepModule.js',
                    'testproject\\depb\\depDeep\\deepModule\\deepModule.js.map' ]

#  console.log(packageUtils.getMatchingFiles("lib_compiled/test/testproject/main.js",["main","./depb/cryptoLoc.js","./depb/depDeep/deepModule"]))
  test.deepEqual(packageUtils.getMatchingFiles("lib_compiled/test/testproject/main.js",["main","./depb/cryptoLoc.js","./depb/depDeep/deepModule"]).map(relativeToDir),shouldBeResult2)

  test.done()

exports.testDependenciesExport=(test)->
  exportDir="lib_test_project_export/"
  nodeUglifier=new NodeUglifier("lib_compiled/test/testproject/main.js",{rngSeed:"hello"})
  nodeUglifier.exportDependencies(exportDir,{"coffee":{"src":"lib_compiled"}})
  test.ok(fsExtra.existsSync(path.resolve(exportDir)))
  test.ok(fsExtra.existsSync(path.resolve(exportDir + "/src")))
  test.ok(fsExtra.existsSync(path.resolve(exportDir + "/lib_compiled")))
  try
    constantsAfterSeparation=require(path.resolve(exportDir) + "/lib_compiled/test/testproject/depa/constants.js")
  catch me
    test.fail("the new constants file should be proper requireable js")
  test.done()


testMerge=(test)->

  testFile="lib_compiled/test/resultFiles/simpleMerge.js"

  nodeUglifier=new NodeUglifier("lib_compiled/test/testproject/main.js",{rngSeed:"hello"})
  mergedSource=nodeUglifier.merge().toString()

  try
    eval(mergedSource)
  catch me
    test.fail(me.toString(),"expected no error thrown from combined project")

  nodeUglifier.exportToFile(testFile)



  #dont test equality, heavily coffeescript version dependent due to comments not removed
  #  test.equals(packageUtils.readFile(testFile).toString(),mergedSource)

  test.done()



exports.testMergeWithExportFilter=(test)->

  testFile="lib_compiled/test/resultFiles/simpleMergeWithFilter.js"

  nodeUglifier=new NodeUglifier("lib_compiled/test/testproject/main.js",{rngSeed:"hello",mergeFileFilterWithExport:["./lib_static/test/","./depa/constants.js"]})
  mergedSource=nodeUglifier.merge().toString()
  nodeUglifier.exportToFile(testFile)
  #dont test equality, heavily coffeescript version dependent due to comments not removed
#  test.equals(packageUtils.readFile(testFile).toString(),mergedSource)

  try
    GLOBAL._loadDynamic=false
    #if main runs without error OK
    main=require(path.resolve(testFile));
  catch me
    test.fail("result file should run without throwing errors")



  GLOBAL._loadDynamic=false
  #if main runs without error OK
  main=require(path.resolve(testFile));


  test.done()




exports.testMergeWithFilterAndUglify=(test)->

  testFile="lib_compiled/test/resultFiles/simpleMergeWithFilterAndUglify.js"
  uglifySourceMap="lib_compiled/test/resultFiles/sourcemaps/simpleMergeWithFilterAndUglify.js"

  nodeUglifier=new NodeUglifier("lib_compiled/test/testproject/main.js",{rngSeed:"hello",mergeFileFilterWithExport:["./lib_static/test/","./depa/constants.js"]})
  mergedSource=nodeUglifier.merge().uglify().toString()

  if IS_RE_CREATE_TEST_FILES then   nodeUglifier.exportToFile(testFile)
  else
    test.equals(packageUtils.readFile(testFile).toString(),mergedSource)

  nodeUglifier.exportSourceMaps(uglifySourceMap)


  try
    GLOBAL._loadDynamic=false
    #if main runs without error OK
    main=require(path.resolve(testFile));
  catch me
    test.fail("result file should run without throwing errors")

  test.done()


exports.testMergeWithFilterAndUglifyAndStrProtection=(test)->

  testFile="lib_compiled/test/resultFiles/simpleMergeWithFilterAndUglifyAndStrProtection.js"
  uglifySourceMap="lib_compiled/test/resultFiles/sourcemaps/simpleMergeWithFilterAndUglifyAndStrProtection.js"

  nodeUglifier=new NodeUglifier("lib_compiled/test/testproject/main.js",{rngSeed:"hello",mergeFileFilterWithExport:["./lib_static/test/","./depa/constants.js"]})
  mergedSource=nodeUglifier.merge().uglify({strProtectionLvl:1}).toString()

  if IS_RE_CREATE_TEST_FILES then nodeUglifier.exportToFile(testFile)
  else
    nodeUglifier.exportSourceMaps(uglifySourceMap)

  try
    GLOBAL._loadDynamic=false
    #if main runs without error OK
    main=require(path.resolve(testFile));
  catch me
    test.fail("result file should run without throwing errors")

#  try
#    eval(mergedSource)
#  catch me
#    test.fail(me.toString(),"expected no error thrown from combined project")

  test.equals(packageUtils.readFile(testFile).toString(),mergedSource)

  test.done()




