#
#/*!
# * node-uglifier
# * Copyright (c) 2014 Zsolt Szabo Istvan
# * MIT Licensed
# *
# */
#


fsExtra = require('fs-extra');
fs = require('fs');
_ = require('underscore')
sugar = require('sugar')
path = require('path')
sh = require('execSync')
packageUtils=require('./libs/packageUtils')
cryptoUtils=require('./libs/cryptoUtils')
UglifyJS=require('uglify-js')

saltLength=20
UGLIFY_SOURCE_MAP_TOKEN="UGLIFY_SOURCE_MAP_TOKEN"
#default options below
#options={mergeFileFilter:[],containerName:"cachedModules"}
### mergeFileFilter ###
#if the file has require statements to merged files, than error is thrown, so they should not depend on your merge project files
#path is relative to the main file
#can be directory, than none of the files in it is merged
#if extension is not given than all matching files are included
class NodeUglifier
  constructor:(mainFile,options={})->
    #defaults
    @options={mergeFileFilter:[],newFilteredFileDir:"./lib_external",containerName:"cachedModules",rngSeed:null,licenseFile:null}
    _.extend(@options,options)

    @mainFileAbs=path.resolve(process.cwd(),mainFile)

    if !fs.existsSync(@mainFileAbs) then throw new Error("main file not found " + @mainFileAbs)
    else
      console.log("processing main file: " + @mainFileAbs)

    @salt=cryptoUtils.generateSalt(saltLength)
    @hashAlgorithm="sha1"
    @wrappedSourceContainerName= @options.containerName

    #if we use array module container the array indices shuffled for extra obscurity
    @serialMappings=cryptoUtils.shuffleArray([0..10000],@options.rngSeed)

    @_sourceCodes={} #hashes have source,sourceMod,sourceModWrapped

    @statistics={}

    @lastResult=null


  getSourceContainer:(serial)->
    return @wrappedSourceContainerName + "[" + @serialMappings[serial] + "]"

  getRequireSubstitutionForMerge:(serial)->
    return @getSourceContainer(serial) + ".exports"

  getNewRelativePathForFiltered:(pathAbs)->
    path.join(@options.newFilteredFileDir,path.basename(pathAbs))

  getRequireSubstitutionForFiltered:(pathAbs)->
    relFile=@getNewRelativePathForFiltered(pathAbs)
    relFileNoExt=relFile.replace(path.extname(relFile),"")
    return "require('./" + relFileNoExt.replace("\\","/") + "')"

  addWrapper:(source,serial)->
    modulesArrayStr=@getSourceContainer(serial)
    firstLine=modulesArrayStr + "={exports:{}};" + "\n"
    secondLine="(function(module,exports) {"
    lastLine="}).call(this," + modulesArrayStr + "," + modulesArrayStr + ".exports);"
    return "\n" + firstLine + secondLine + source + lastLine



  merge:()->
    _this=@


    firstLine="var " + @wrappedSourceContainerName + "=[];"
    #filteredOutFilesObj:{} has files by basename contains {source,sourceMod,pathRel,serial} #where pathRel is their saved location after exporting relative to the exported main file
    r={source:firstLine,filteredOutFilesObj:{},sourceMapModules:{}}

    filteredOutFiles=packageUtils.getMatchingFiles(@mainFileAbs,@options.mergeFileFilter)


    recursiveSourceGrabber=(filePath)->

      source=packageUtils.readFile(filePath).toString()
      #add source and wrapped source
      pathSaltedHash=cryptoUtils.getSaltedHash(filePath,_this.hashAlgorithm,_this.salt)
      if !_this._sourceCodes[pathSaltedHash]?
        _this._sourceCodes[pathSaltedHash]={source,serial:_.keys(_this._sourceCodes).length,sourceMod:source} #wrappedModifiedSource:packageUtils.substituteRequireWrapperFnc(source,pathSaltedHash)
        console.log(filePath + " added to sources ")

      sourceObj=_this._sourceCodes[pathSaltedHash]
      isSourceObjFiltered=(filteredOutFiles.filter((fFile)->return path.normalize(fFile)==path.normalize(filePath)).length>0)

      ast=packageUtils.getAst(source)
      requireStatements=packageUtils.getRequireStatements(ast,filePath)
      #add salted hashes of files
      requireStatements.each((o,i)->requireStatements[i]= _.extend(o,{pathSaltedHash:cryptoUtils.getSaltedHash(o.path,_this.hashAlgorithm,_this.salt)}))


      for requireStatement in requireStatements
        sourceObjDep=_this._sourceCodes[requireStatement.pathSaltedHash]

        if isSourceObjFiltered and packageUtils.getIfNonNativeNotFilteredNonNpm(requireStatement.path)
          #filtered out files are not allowed to have dependency on merged fiels
          throw new Error ("filtered files can not have dependency on merged files, file: " + filePath + " dependency: " + requireStatement.path)

        if !sourceObjDep?
          recursiveSourceGrabber(requireStatement.path)

        sourceObjDep=_this._sourceCodes[requireStatement.pathSaltedHash]
        if !sourceObjDep? then throw new Error(" internal should not happen 1")
        otherSerial=sourceObjDep.serial
        isSourceObjDepFiltered=(filteredOutFiles.filter((fFile)->return path.normalize(fFile)==path.normalize(requireStatement.path)).length>0)


        if isSourceObjDepFiltered
          #replace with the new path to the filtered out file
          replacement=_this.getRequireSubstitutionForFiltered(requireStatement.path)
        else
          #replace require with wrappedSourceContainerName
          replacement=_this.getRequireSubstitutionForMerge(otherSerial)
          r.sourceMapModules[_this.getSourceContainer(otherSerial)]=path.relative(path.dirname(_this.mainFileAbs),requireStatement.path)

        sourceObj.sourceMod=packageUtils.replaceRequireStatement(sourceObj.sourceMod,requireStatement.text,replacement)



      if isSourceObjFiltered
        #no need to wrap filtered out external files
        basename=path.basename(filePath)
        if r.filteredOutFilesObj[basename]
          filteredOutFilesObj=r.filteredOutFilesObj[basename]
          if filteredOutFilesObj.serial!=sourceObj.serial then throw new Error (" external files with same filename not supported yet")
        else
          r.filteredOutFilesObj[basename]={pathRel:_this.getNewRelativePathForFiltered(filePath)}
          _.extend(r.filteredOutFilesObj[basename],sourceObj)
      else
        #add wrapped version
        if sourceObj.serial>0
          sourceObj.sourceModWrapped=_this.addWrapper(sourceObj.sourceMod,sourceObj.serial)
        else
          sourceObj.sourceModWrapped=sourceObj.sourceMod
        r.source=r.source + sourceObj.sourceModWrapped



    recursiveSourceGrabber(@mainFileAbs)
    @lastResult=r
    return this

  toString:()->
    return @lastResult.source.toString()

  exportToFile:(file)->
    _this=@
    #write the new merged main file
    outFileAbs=path.resolve(file)
    fsExtra.ensureDirSync(path.dirname(outFileAbs))
    fs.writeFileSync(outFileAbs,@toString())
    outDirRoot=path.dirname(outFileAbs)
    _.keys(@lastResult.filteredOutFilesObj).each(
      (fileName)->
        copyObj=_this.lastResult.filteredOutFilesObj[fileName]
        newFile=path.resolve(outDirRoot,copyObj.pathRel)
        fsExtra.ensureDirSync(path.dirname(newFile))
        fs.writeFileSync(newFile,copyObj.sourceMod)
    )

  #both uglify and for modules
  exportSourceMaps:(file)->
    _this=@
    outFileAbs=path.resolve(file)
    sourceMapOutFileName=path.basename(outFileAbs) + ".map"
    sourceMapModulesOutFileName=path.basename(outFileAbs) + ".modules-map"
    dir=path.dirname(outFileAbs)
    fsExtra.ensureDirSync(dir)
    if @lastResult.sourceMapUglify? then fs.writeFileSync(path.join(dir,sourceMapOutFileName),@lastResult.sourceMapUglify.replace(UGLIFY_SOURCE_MAP_TOKEN,sourceMapOutFileName))
    fs.writeFileSync(path.join(dir,sourceMapModulesOutFileName),JSON.stringify(_this.lastResult.sourceMapModules))


  #pass in standard uglify options objects compress:{},output:null into oprions
  uglify:(optionsIn={})->
    if !@lastResult then @merge()

    options={mangle:true,compress:{drop_console:false,hoist_funs:true,loops:true,evaluate: true,conditionals:true},output:{comments:false},strProtectionLvl:0} #, reserved:"cachedModules"
    _.extend(options,optionsIn)
    if !@lastResult.source then return
    source=@toString()
    a=1+1
    res=UglifyJS.minify(source, _.extend({fromString: true,outSourceMap:UGLIFY_SOURCE_MAP_TOKEN},options));
    @lastResult.source=res.code
    @lastResult.sourceMapUglify=res.map

    switch options.strProtectionLvl
      when 1
        ast=packageUtils.getAst(@lastResult.source)
        @lastResult.source=packageUtils.getSourceHexified(ast)


    return this



module.exports=NodeUglifier










