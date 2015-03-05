node-uglifier
=========

As I have just completed a huge pure Nodejs project in 80+ files. I started to search for methods to have at least a minimal protection for my server side code.
I found no simple solution that could handle the **NodeJS** module system automatically so I created **node-uglifier**. My almost 500Kb code in about 80 files got packed into a single file with around 150Kb size.

If you like the project and you want me to share developements in the future too.
Please take 15 seconds of your time and visit my GITHUB page too to pass some love in the form of stars there. Thanks!
https://github.com/zsoltszabo/node-uglifier

how it works
--------

It visits all "required" files recursively. It merges all your files into a single one (core and npm modules aside). Than you can apply uglify to that single merged file.
A combined file has the benefit of removing module name and module structure information as well. Making reverse engineering a bit harder.

You can find examples in the lib_compiled/test/unitTest.js. Here is a taste of how it works from the unit tests.

!!!For smooth operation set the working directory to the project's root. So start node in the project's root.!!!

##Commands

* npm install "node-uglifier"
* NodeUglifier = require("node-uglifier");
* nodeUglifier = new NodeUglifier("lib_compiled/test/testproject/main.js");
* nodeUglifier.merge().uglify()

### export
* nodeUglifier.exportToFile("lib_compiled/test/resultFiles/simpleMergeAndUglify.js")
* nodeUglifier.exportSourceMaps("lib_compiled/test/resultFiles/sourcemaps/simpleMergeAndUglify.js");

### in case you need it
* uglifiedString=nodeUglifier.toString()
* if you call the above before uglify() but after merge() you get the not yet uglified merged source



### one liner
*  (new NodeUglifier("lib_compiled/test/testproject/main.js")).uglify().exportToFile("lib_compiled/test/resultFiles/simpleMergeAndUglify.js");


Extra
--------
You can keep files external if you pass an option to the NodeUglifier class.

* nodeUglifier=new NodeUglifier("lib_compiled/test/testproject/main.js",{mergeFileFilter:["./lib_static/test/","./depa/constants.js"]})
* nodeUglifier.exportToFile("lib_compiled/test/resultFiles/simpleMergeWithFilterAndUglify.js");

They will be copied to the ./lib_external folder and references to them will be modified in the merged file.

+1
Life safer new feature: Export all your dependencies including source files to a new folder. So if you have like many "main files" within your project folder
and a lot of common dependencies this saves your ass if you have to give your co worker the minimal set of files that one of the main needs. From the testDependenciesExport unit test:
*  exportDir="lib_test_project_export/"
*  nodeUglifier=new NodeUglifier("lib_compiled/test/testproject/main.js",{rngSeed:"hello"})
*  nodeUglifier.exportDependencies(exportDir,{coffee:{src:"lib_compiled"}})
The second parameter to exportDependencies is optional, handy if you have coffee source files too. If a source is not found, written out to console with WARNING.

+2
It handles as well:
 new(require(module))(constructorParams)
 require(module)()
 require(module)(something)
 require('./randomJsonFile.json')

Notes
--------
Obviously you need to avoid cycles in your merged dependencies. Though they are all detected and written out to console, so no worries.

Also at the moment obviously it cannot handle dynamic module loading. You will get warnings for those.

I like programing in high level interpreted languages but I hate filthy thieves, blackhat hackers. They can steal the fruit of your hard work in just a fraction of the time of that it took you to create it.
If you have any idea, contribution how to protect a full NodeJS app even better, obfuscate it better just contact me, commit to Github for creds:). I would like to make this project
a one stop shop for NodeJs project protection.

It is tested on Windows if you find problems on Linux please contact me.

Change log
--------
0.3.0 Handles require JSON files by changing the source to be correct JS syntax.

0.2.5 Life safer new feature: Export all your dependencies including source files to a new folder
      Basically you can separate your project this way and limit the files your co worker can see.
      see the very short unit test: exports.testDependenciesExport

0.2.3 Removed unused execSync module, (in new Node versions it was giving error)

0.2.1  Readme errors

0.2.0: I got inquiry on Github about why meanstack cannot be merged. That project is now included in the testprojects and a new unit test created for it: testOnMeanStack.coffee
       In that test file I write down the issues I had and how I resolved those. In short it had fancy require statements and same filenames as module names.
       Also now there is a "Warning!:" console log for unprocessed require statements. (they will be 95% of the time dynamic ones)

0.1.8: Throws error for cyclic dependencies, listing all of them.

0.1.6: Bug fix for filtered out dependency check on merged files.
       Added suppressFilteredDependentError:true option. (handy if you want to remove part of project from production, you only have to then delete these files auto from lib_external with your build script)
       ->new NodeUglifier("lib_compiled/test/testproject/main.js",{suppressFilteredDependentError:true})

0.1.5: Added strings to hex converting to uglify options - nodeUglifier.uglify({strProtectionLvl:1})
