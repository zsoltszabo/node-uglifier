fs = require('fs');
NodeUglifier=require("../NodeUglifier")
packageUtils=require('../libs/packageUtils')
path = require('path')
#_=require("\x6e\x64\x65\x72\x73\x63\x6f\x72\x65\x6e")

IS_RE_CREATE_TEST_FILES=false

#with mean stack there were multiple problems in 0.1.8
#
#there were some fancy require statements where there were multiple parentheses after require like:
#  require('./config/express')(db)
#in this case the require AST node had the first argument (db) and not the actual path.
#This has been resolved by giving precedence to the left most expression, that is the deeper in the parse tree
#
#The other problem was naming files the same as modules like in the case of express.js
#the logic assumed if a required file is found in the folder of the file in which the require statement is, than it is not module...
#Clearly I did not mimick the behaviour of the node require well
#This has been resolved by checking if there is / or \ in the require path argument, if not it is assumed to be module
#
#On the other hand it has also dynamic require statements, which obviously will not work...
# So this test tests only what supposed to work.



exports.testStuff=(test)->
  uglifySourceMap = "lib_compiled/test/resultFiles/sourcemaps/server.sourcemaps.js";
  uglifyReultFolder="lib_compiled/test/resultFiles/"
  nodeUglifier = new NodeUglifier("./lib_compiled/test/testproject2/server.js",{rngSeed:"hello"});
  mergedSource = nodeUglifier.merge();
  mergedSourceString=mergedSource.toString()

  if IS_RE_CREATE_TEST_FILES then nodeUglifier.exportToFile(uglifyReultFolder + "server.compiled_not_uglified.js");

  uglifiedSourceString = mergedSource.uglify({
    strProtectionLvl: 1
  }).toString();

  if IS_RE_CREATE_TEST_FILES then  nodeUglifier.exportToFile(uglifyReultFolder + "server.compiled.js");
  if IS_RE_CREATE_TEST_FILES then  nodeUglifier.exportSourceMaps(uglifySourceMap);

  test.equals(packageUtils.readFile(uglifyReultFolder + "server.compiled_not_uglified.js").toString(),mergedSourceString)
  test.equals(packageUtils.readFile(uglifyReultFolder + "server.compiled.js").toString(),uglifiedSourceString)

  test.done()