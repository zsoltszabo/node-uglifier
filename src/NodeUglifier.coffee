#
#/*!
# * node-uglifier
# * Copyright (c) 2014 Zsolt Szabo Istvan
# * MIT Licensed
# *
# */
#

Errors = require("./libs/Errors")
Graph = require("./libs/js-graph-mod/src/js-graph")
fsExtra = require('fs-extra');
fs = require('fs');
_ = require('underscore')
sugar = require('sugar');sugar.extend();
path = require('path')
packageUtils = require('./libs/packageUtils')
cryptoUtils = require('./libs/cryptoUtils')
UglifyJS = require('uglify-js-harmony')
util = require("util")

saltLength = 20
UGLIFY_SOURCE_MAP_TOKEN = "UGLIFY_SOURCE_MAP_TOKEN"
#default options below
#options={mergeFileFilterWithExport:[],containerName:"cachedModules"}
### mergeFileFilterWithExport ###
#if the file has require statements to merged files, than error is thrown, so they should not depend on your merge project files
#path is relative to the main file
#can be directory, than none of the files in it is merged
#if extension is not given than all matching files are included
class NodeUglifier
    constructor: (mainFile, options = {})->
#defaults
        @options = {
            mergeFileFilterWithExport: [],
            mergeFileFilter: [],
            newFilteredFileDir: "./lib_external",
            containerName: "cachedModules",
            rngSeed: null,
            licenseFile: null,
            fileExtensions: ["js", "coffee", "json"],
            suppressFilteredDependentError: false,
            packNodeModules:false
        }
        _.extend(@options, options)

        #if we give full path it should handle it

        @mainFileAbs = path.resolve(mainFile) || path.resolve(process.cwd(), mainFile)
        #    catch me
        #      debug=1

        if !fs.existsSync(@mainFileAbs) then throw new Error("main file not found " + @mainFileAbs)
        else
            console.log("processing main file: " + @mainFileAbs)

        @salt = cryptoUtils.generateSalt(saltLength)
        @hashAlgorithm = "sha1"
        @wrappedSourceContainerName = @options.containerName

        #if we use array module container the array indices shuffled for extra obscurity
        @serialMappings = cryptoUtils.shuffleArray([0..10000], @options.rngSeed)

        @_sourceCodes = {} #hashes have source,sourceMod,sourceModWrapped

        @statistics = {}

        @filteredOutFiles = packageUtils.getMatchingFiles(@mainFileAbs, @options.mergeFileFilter)


        @lastResult = null


    getSourceContainer: (serial)->
        return @wrappedSourceContainerName + "[" + @serialMappings[serial] + "]"

    getRequireSubstitutionForMerge: (serial)->
        return @getSourceContainer(serial) + ".exports"

    getNewRelativePathForFilteredWithExport: (pathAbs)=>
        path.join(@options.newFilteredFileDir, path.basename(pathAbs))


    getNewRelativePathForFiltered: (pathAbs)=>
        relPath = path.relative(path.dirname(@mainFileAbs), path.dirname(pathAbs))
        path.join(relPath, path.basename(pathAbs))

    getRequireSubstitutionForFilteredWithExport: (pathAbs, relPathFn)=>
        relFile = relPathFn(pathAbs)
        relFileNoExt = relFile.replace(path.extname(relFile), "")
        return "require('./" + relFileNoExt.replace(/\\/g, "/") + "')"





    addWrapper: (source, serial)->
        modulesArrayStr = @getSourceContainer(serial)
        firstLine = modulesArrayStr + "={exports:{}};" + "\n"
        secondLine = "(function(module,exports) {"
        lastLine = "}).call(this," + modulesArrayStr + "," + modulesArrayStr + ".exports);"
        return "\n" + firstLine + secondLine + source + lastLine



    merge: ()->
        _this = @


        firstLine = "var " + @wrappedSourceContainerName + "=[];"
        #filteredOutFilesObj:{} has files by basename contains {source,sourceMod,pathRel,serial} #where pathRel is their saved location after exporting relative to the exported main file
        r = {source: firstLine, filteredOutFilesObj: {}, sourceMapModules: {}, pathOrder: [], cycles: []}
        #    graph.addNewVertex('k1', 'oldValue1');
        #    graph.addNewEdge('k5', 'k3');
        depGraph = new Graph();


        filteredOutFilesWithExport = packageUtils.getMatchingFiles(@mainFileAbs, @options.mergeFileFilterWithExport)


        recursiveSourceGrabber = (filePath)->
            try
                depGraph.addNewVertex(filepath, filepath);
            catch me
#do nothing path vertex exists

            source = packageUtils.readFile(filePath).toString()
            if _.isEqual(path.extname(filePath), ".json")
                source = "module.exports=(" + source + ");"

            #add source and wrapped source
            pathSaltedHash = cryptoUtils.getSaltedHash(filePath, _this.hashAlgorithm, _this.salt)
            if !_this._sourceCodes[pathSaltedHash]?
                _this._sourceCodes[pathSaltedHash] = {
                    source,
                    serial: _.keys(_this._sourceCodes).length,
                    sourceMod: source
                } #wrappedModifiedSource:packageUtils.substituteRequireWrapperFnc(source,pathSaltedHash)
                console.log(filePath + " added to sources ")

            #      if !_.isEmpty(filePath.match("express.js"))
            #        a=1+1

            sourceObj = _this._sourceCodes[pathSaltedHash]
            isSourceObjFilteredWithExport = (filteredOutFilesWithExport.filter((fFile)->return path.normalize(fFile) == path.normalize(filePath)).length > 0)
            isSourceObjFiltered = (_this.filteredOutFiles.filter((fFile)->return path.normalize(fFile) == path.normalize(filePath)).length > 0)

            ast = packageUtils.getAst(source)

            requireStatements = packageUtils.getRequireStatements(ast, filePath, _this.fileExtensions,_this.options.packNodeModules)
            #add salted hashes of files
            requireStatements.forEach((o, i)-> requireStatements[i] = _.extend(o,
                {pathSaltedHash: cryptoUtils.getSaltedHash(o.path, _this.hashAlgorithm, _this.salt)}))


            for requireStatement in requireStatements


                try
                    depGraph.addNewVertex(requireStatement.path, null);
                catch me
#do nothing path vertex exists
                try
                    depGraph.addNewEdge(filePath, requireStatement.path);
                catch me
#do nothing path edge exists


                sourceObjDep = _this._sourceCodes[requireStatement.pathSaltedHash]

                if isSourceObjFilteredWithExport and packageUtils.getIfNonNativeNotFilteredNonNpm(requireStatement.path, filteredOutFilesWithExport,
                    _this.options.fileExtensions)
#filtered out files are not allowed to have dependency on merged fiels
                    msg = "filtered files can not have dependency on merged files, file: " + filePath + " dependency: " + requireStatement.path
                    if _this.options.suppressFilteredDependentError then console.warn(msg) else throw new Error (msg)

                if !sourceObjDep?
                    recursiveSourceGrabber(requireStatement.path)

                sourceObjDep = _this._sourceCodes[requireStatement.pathSaltedHash]
                if !sourceObjDep? then throw new Error(" internal should not happen 1")
                otherSerial = sourceObjDep.serial

                isSourceObjDepFilteredWithExport = (filteredOutFilesWithExport.filter((fFile)->return path.normalize(fFile) == path.normalize(requireStatement.path)).length > 0)
                isSourceObjDepFiltered = (_this.filteredOutFiles.filter((fFile)->return path.normalize(fFile) == path.normalize(requireStatement.path)).length > 0)


                if isSourceObjDepFilteredWithExport
#replace with the new path to the filtered out file
                    replacement = _this.getRequireSubstitutionForFilteredWithExport(requireStatement.path, _this.getNewRelativePathForFilteredWithExport)
                else if isSourceObjDepFiltered
                    replacement = _this.getRequireSubstitutionForFilteredWithExport(requireStatement.path, _this.getNewRelativePathForFiltered)
                else
#replace require with wrappedSourceContainerName
                    replacement = _this.getRequireSubstitutionForMerge(otherSerial)
                    r.sourceMapModules[_this.getSourceContainer(otherSerial)] = path.relative(path.dirname(_this.mainFileAbs), requireStatement.path)

#                if requireStatement.text.indexOf("rootDependency")>-1
#                    a=1
#                    b=2
                sourceObj.sourceMod = packageUtils.replaceRequireStatement(sourceObj.sourceMod, requireStatement.text, replacement)
#                sourceObj.sourceMod = packageUtils.replaceRequireStatement(sourceObj.sourceMod, requireStatement.text, replacement)
#                sourceObj.sourceMod = packageUtils.replaceRequireStatement(sourceObj.sourceMod, requireStatement.text, replacement)


            if isSourceObjFilteredWithExport || isSourceObjFiltered

#no need to wrap filtered out external files
                if isSourceObjFiltered
                    relPathFnc = _this.getNewRelativePathForFiltered
                    basename = relPathFnc(filePath)
                else if isSourceObjFilteredWithExport
                    relPathFnc = _this.getNewRelativePathForFilteredWithExport
                    basename = path.basename(filePath)

                if r.filteredOutFilesObj[basename]
                    filteredOutFilesObj = r.filteredOutFilesObj[basename]
                    if filteredOutFilesObj.serial != sourceObj.serial then throw new Error (" external files with same filename not supported yet")
                else
                    r.filteredOutFilesObj[basename] = {pathRel: relPathFnc(filePath)}
                    _.extend(r.filteredOutFilesObj[basename], sourceObj)

            else
#add wrapped version
                if sourceObj.serial > 0
                    sourceObj.sourceModWrapped = _this.addWrapper(sourceObj.sourceMod, sourceObj.serial)
                else
                    sourceObj.sourceModWrapped = sourceObj.sourceMod
                r.pathOrder.push(filePath)
                r.source = r.source + sourceObj.sourceModWrapped


        recursiveSourceGrabber(@mainFileAbs)
        @lastResult = r

        #check for cyclic dependencies and throw error listing them
        wasCycle = true
        iter = 0
        while wasCycle and iter < 1000
            iter++
            wasCycle = false
            try
                depGraph.topologically((vertex, vertexVal)->)
            catch me
                wasCycle = true

                if me.cycle
                    r.cycles.push(me.cycle)
                    edgeToRemove = [me.cycle.last(2).last(), me.cycle.last(2).first()].reverse()
                    depGraph.removeEdge.apply(depGraph, edgeToRemove)

        if !_.isEmpty(r.cycles) then throw new Errors.CyclicDependencies(r.cycles)
        return this

#exportDir - the whole dependency structure relative to the project root will be placed here
#srcDirMap - this is an object like {coffee:{src:"lib_compiled",etc:blabla}} so if the value is found in a dependency folder than key file extendison file is searched in the key folder
    exportDependencies: (exportDir, srcDirMap = null)->
        sourceFileDidNotExistArr = []
        if !@lastResult then @merge()
        if !@lastResult.pathOrder
            throw new Error("there was no dependencies to export")
            return
        exportDirAbs = path.resolve(exportDir) || path.resolve(process.cwd(), exportDir)
        projectDir = process.cwd()
        #path is used as library
        for p in @lastResult.pathOrder
#find the sub Dirs after root
            if p.indexOf(projectDir) != 0
                throw new Error("#{p} dependency not found each dependency should be in the project Dir: #{projectDir}")
            baseDir = path.dirname(p[projectDir.length + 1..])
            baseName = path.basename(p)
            extension = path.extname(p)
            baseNameNoExtension = baseName[0..(baseName.length - extension.length - 1)]
            #copy file part
            newFile = path.resolve(path.join(exportDirAbs, baseDir, baseName))
            fsExtra.ensureDirSync(path.dirname(newFile))

            fs.createReadStream(p).pipe(fs.createWriteStream(newFile));
            #      fs.writeFileSync(newFile,p)
            #find corresponding files and copy them too
            if srcDirMap
                for mirrorExt,fromToMap of srcDirMap
                    toFromMap = _.invert(fromToMap)
                    for to,from of toFromMap
                        otherBaseDir = baseDir.replace(to, from)
                        if otherBaseDir == baseDir then continue
                        otherFile = path.join(path.resolve(process.cwd(), otherBaseDir), baseNameNoExtension + "." + mirrorExt)
                        baseNameOther = path.basename(otherFile)
                        if fsExtra.existsSync(otherFile)
#file exists do the copy
                            newFileOther = path.resolve(path.join(exportDirAbs, otherBaseDir, baseNameOther))
                            #copy file part
                            fsExtra.ensureDirSync(path.dirname(newFileOther))

                            fs.createReadStream(otherFile).pipe(fs.createWriteStream(newFileOther));
#              fs.writeFileSync(newFileOther,otherFile)
                        else
                            sourceFileDidNotExistArr.push(otherFile)
                        console.log(otherFile)
        for sourceFileDidNotExist in sourceFileDidNotExistArr
            console.log("WARNING source file did not exist: " + sourceFileDidNotExist)







    toString: ()->
        return @lastResult.source.toString()

    exportToFile: (file)->
        _this = @
        #write the new merged main file
        outFileAbs = path.resolve(file)
        fsExtra.ensureDirSync(path.dirname(outFileAbs))
        fs.writeFileSync(outFileAbs, @toString())
        outDirRoot = path.dirname(outFileAbs)
        _.keys(_this.lastResult.filteredOutFilesObj).forEach(
            (fileName)->
                copyObj = _this.lastResult.filteredOutFilesObj[fileName]
                newFile = path.resolve(outDirRoot, copyObj.pathRel)
                fsExtra.ensureDirSync(path.dirname(newFile))
                fs.writeFileSync(newFile, copyObj.sourceMod)
        )
        (_this.filteredOutFiles).forEach(
            (fileName)->
                pathRel = _this.getNewRelativePathForFiltered(fileName)
                newFile = path.resolve(outDirRoot, pathRel)
                fsExtra.ensureDirSync(path.dirname(newFile))
                fs.createReadStream(fileName).pipe(fs.createWriteStream(newFile));
        )

#both uglify and for modules
    exportSourceMaps: (file)->
        _this = @
        outFileAbs = path.resolve(file)
        sourceMapOutFileName = path.basename(outFileAbs) + ".map"
        sourceMapModulesOutFileName = path.basename(outFileAbs) + ".modules-map"
        dir = path.dirname(outFileAbs)
        fsExtra.ensureDirSync(dir)
        if @lastResult.sourceMapUglify? then fs.writeFileSync(path.join(dir, sourceMapOutFileName),
            @lastResult.sourceMapUglify.replace(UGLIFY_SOURCE_MAP_TOKEN, sourceMapOutFileName))
        fs.writeFileSync(path.join(dir, sourceMapModulesOutFileName), JSON.stringify(_this.lastResult.sourceMapModules))


#pass in standard uglify options objects compress:{},output:null into oprions
    uglify: (optionsIn = {})->
        if !@lastResult then @merge()

        options = {
            mangle: true,
            compress: {drop_console: false, hoist_funs: true, loops: true, evaluate: true, conditionals: true},
            output: {comments: false},
            strProtectionLvl: 0
        } #, reserved:"cachedModules"
        _.extend(options, optionsIn)
        if !@lastResult.source then return
        source = @toString()
        a = 1 + 1
        res = UglifyJS.minify(source, _.extend({fromString: true, outSourceMap: UGLIFY_SOURCE_MAP_TOKEN}, options));
        @lastResult.source = res.code
        @lastResult.sourceMapUglify = res.map

        switch options.strProtectionLvl
            when 1
                ast = packageUtils.getAst(@lastResult.source)
                @lastResult.source = packageUtils.getSourceHexified(ast)


        return this


module.exports = NodeUglifier


#npm publish
#
#uglifyjs test_man_combined.js -c warnings  -m toplevel -r 'require,exports' -o test_man_combined.min.js --source-map test_man_combined.map --screw-ie8
#
#//drop_console=true
#
#process,GLOBAL,require,exports