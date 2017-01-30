node-uglifier
=========

As I have just completed a huge pure Nodejs project in 80+ files. I started to search for methods to have at least a minimal protection for my server side code.
I found no simple solution that could **handle** the NodeJS module system** well so I created **node-uglifier**. My almost 500Kb code in about 80 files got packed into a single file with around 150Kb size.

Life safer new feature: **Export all your dependencies including optional source files** (like coffee) to a new folder. So if you have many "main files" within your project folder
and a lot of common dependencies for them this saves your ass if you have to give your co worker the minimal set of files that one of the main needs.

If you like the project and you want me to share developements in the future too.
Please take 15 seconds of your time and visit my GITHUB page too to pass some love in the form of stars there. Thanks!
[github zsoltszabo](https://github.com/zsoltszabo/node-uglifier)


All the examples below are from teh unit tests of the project. Project contains testproject merged and uglified in many non lethal ways:)

**npm install "node-uglifier"**

### merge and uglify
```javascript
var NodeUglifier = require("node-uglifier");
var nodeUglifier = new NodeUglifier("lib_compiled/test/testproject/main.js");
nodeUglifier.merge().uglify();

//exporting
nodeUglifier.exportToFile("lib_compiled/test/resultFiles/simpleMergeAndUglify.js");
nodeUglifier.exportSourceMaps("lib_compiled/test/resultFiles/sourcemaps/simpleMergeAndUglify.js");
//DONE

//in case you need it get the string
//if you call it before uglify(), after merge() you get the not yet uglified merged source
var uglifiedString=nodeUglifier.toString();
```


### one liner
```javascript
new NodeUglifier("lib_compiled/test/testproject/main.js").uglify().exportToFile("lib_compiled/test/resultFiles/simpleMergeAndUglify.js");
```


### The dependencies exporting:
```javascript
var exportDir="lib_test_project_export/";
var mainFile="lib_compiled/test/testproject/main.js";
var  nodeUglifier=new NodeUglifier(mainFile)

//The second parameter to exportDependencies is optional, handy if you have coffee source files too. 
//It copies the counterpart file too with the arbitrary "coffee" extension of every project
//dependency file that is found in the arbitrary "lib_compiled" folder.
//If a counterpart file is not found, it is written out to console with WARNING.
nodeUglifier.exportDependencies(exportDir,{"coffee":{"src":"lib_compiled"}})
```

So the above example created the lib_test_project_export/src and lib_test_project_export/lib_compiled folders with the minimal set of js and coffee files that are required for
the test_project



Leave out files from merging
--------
**They might not need protection, too large, or LOADED DYNAMIC**
```javascript
//You can keep files external if you pass an option to the NodeUglifier class.
//mergeFileFilter keeps relative paths to the files
//mergeFileFilterWithExport are copied to the ./lib_external folder and
//references to them will be modified in the merged file.
var options={mergeFileFilterWithExport:["./lib_static/test/","./depa/constants.js"],\
mergeFileFilter:["./depDynamic/filename_used_in_dynamic_require.js"]}
var nodeUglifier=new NodeUglifier("lib_compiled/test/testproject/main.js",options);
var nodeUglifier.exportToFile("lib_compiled/test/resultFiles/simpleMergeWithFilterAndUglify.js");
```

+1
It handles as well:
* new(require(module))(constructorParams)
* require(module)()
* require(module)(something)
* require('./randomJsonFile.json')


how it works
--------

It visits all "required" files recursively. It merges all your files into a single one (core and npm modules aside). Than you can apply uglify to that single merged file.
A combined file has the benefit of removing module name and module structure information as well. Making reverse engineering a bit harder.

You can find examples in the lib_compiled/test/unitTest.js. Here is a taste of how it works from the unit tests.

!!!For smooth operation set the working directory to the project's root. So start node in the project's root.!!!


Notes
--------
Obviously you need to avoid cycles in your merged dependencies. Though they are all detected and written out to console, so no worries.

Also at the moment obviously it cannot handle dynamic module loading. You will get warnings for those.

I like programing in high level interpreted languages but I hate filthy thieves, blackhat hackers. They can steal the fruit of your hard work in just a fraction of the time of that it took you to create it.
If you have an idea, contribution how to protect a full NodeJS app even better, obfuscate it better just contact me, commit to Github for creds:). I would like to make this project
a one stop shop for NodeJs project protection.

Compile coffee sources:
coffee -m -wco lib_compiled src

To run unit tests, after installing nodeunit...
nodeunit lib_compiled\test\unitTest.js
If you change the code you probably need to change IS_RE_CREATE_TEST_FILES=false to true in the unitTest.js, to not check the new output against the outdated output format.

It is tested on Windows if you find problems on Linux please contact me.



Change log
--------
0.5.4
* Ironing out path separator bug in some cases on Linux. Unit tests works on linux.

0.5.3
* Long time request: Added option "packNodeModules:true" to try to pack modules from node_modules directory as well
** Needless to mention that there are a lot of dynamic requires in most of the big modules like ExpressJs
** So one would need to build a generic solution to solve this like indexing and caching all files and writing stub functions
** And it could still go horribly wrong with native modules. So it is beyond the scope atm.

0.5.2
* Added directory index require support

0.5.1
* Added express server test case

0.5
* Updated dependencies (resolved 'requireStatements.each is not a function' bug from new SugarJs version)
** fixed dependencies to exact versions, to avoid breaking compatibility
* Added ES6 syntax support. Note it is still not stable in the Uglify-Js-Harmony branch that I use for uglifying the combined code
** import does not work

0.4.3
* mergeFileFilter now does not change relative position of files to **allow dynamic loading of those files**,
* if you want the old functionality of mergeFileFilter usemergeFileFilterWithExport,
* Fixed doc, fixed dependency export not copying file content.,
* upgraded tests to coffeescript 1.9, that changes source file extension,
      
      
0.3.2-0.3.3 Documentation tidy up

0.3.1 Small coffee file bug fix in npm version

0.3.0 Handles require JSON files by changing the source to be correct JS syntax.

0.2.5 
* Life safer new feature: Export all your dependencies including source files to a new folder
* Basically you can separate your project this way and limit the files your co worker can see.
* see the very short unit test: exports.testDependenciesExport

0.2.3 Removed unused execSync module, (in new Node versions it was giving error)

0.2.1  Readme errors

0.2.0:
* I got inquiry on Github about why meanstack cannot be merged. That project is now included in the testprojects and a new unit test created for it: testOnMeanStack.coffee
* In that test file I write down the issues I had and how I resolved those. In short it had fancy require statements and same filenames as module names.
* Also now there is a "Warning!:" console log for unprocessed require statements. (they will be 95% of the time dynamic ones)

0.1.8: Throws error for cyclic dependencies, listing all of them.

0.1.6: 
* Bug fix for filtered out dependency check on merged files.
* Added suppressFilteredDependentError:true option. 
* (handy if you want to remove part of project from production, you only have to then delete these files auto from lib_external with your build script)
* new NodeUglifier("lib_compiled/test/testproject/main.js",{suppressFilteredDependentError:true})

0.1.5: Added strings to hex converting to uglify options - nodeUglifier.uglify({strProtectionLvl:1})

License
--------
The MIT License

Copyright (c) 2013-2015 Zsolt Istvan Szabo (zsoltszabo317@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
