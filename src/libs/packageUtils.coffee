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
UglifyJS=require('uglify-js')
path = require('path')

packageUtils=module.exports

# Check if `module` is a native module (like `net` or `tty`).
packageUtils.isNative =(module)->
  try
    return require.resolve(module) == module;
  catch err
    return false;

packageUtils.readFile=(pathAbs,encoding='utf8')->
  options={encoding}
  return fs.readFileSync(pathAbs,options)

packageUtils.getAst=(code)->
  return UglifyJS.parse(code)

#absolulte file path
packageUtils.getMatchingFiles=(rootPath,dirAndFileArray)->
  r=[]

  rootDir=if fs.lstatSync(rootPath).isDirectory() then path.resolve(rootPath) else path.dirname(path.resolve(rootPath))
  for dirOrFile in dirAndFileArray
    destination=path.resolve(rootDir,dirOrFile)
    try
      filestats=fs.lstatSync(destination)
    catch me
      #probably missing extension, file not found
      filestats=null
    if filestats and filestats.isDirectory()
      #we have directory
      fs.readdirSync(destination).reduce(((prev,curr)->prev.push(path.join(destination,curr));return prev;),r)
    else
      if path.extname(destination)==""
        fileName=path.basename(destination)
        fs.readdirSync(path.dirname(destination)).filter((fileNameLoc)->fileNameLoc.indexOf(fileName)!=-1).reduce(((prev,curr)->prev.push(path.join(destination,curr));return prev;),r)
      else
        r.push(destination)
  return r


packageUtils.getIfNonNativeNotFilteredNonNpm=(fileAbs,filters,possibleExtensions)->
  #if path can be resolved and it is file than it is non native, non npm
  r=null
  if path.extname(fileAbs)==""
    existingExtensions=possibleExtensions.filter((ext)->return fs.existsSync(fileAbs + "." + ext))
    if existingExtensions.length>1 then throw new Error(" multiple matching extensions problem for " + fileAbs)
    r=if existingExtensions.length==1 then fileAbs + "." + existingExtensions[0] else null
  else
    r=if fs.existsSync(fileAbs) then fileAbs else null
  if r
    if filters.filter((fFile)->return path.normalize(fFile)==path.normalize(r)).length>0
      r=null;
      console.log(fileAbs + " was filtered ")

  return r


#assume no directory is native module
#returns the file path of modules if file exists
#if no extension specified first existing possibleExtensions is used
packageUtils.getRequireStatements=(ast,file,possibleExtensions=["js","coffee"],isOnlyNonNativeNonNpm=true)->
  handleRequireNode=(text,args)->
    if args.length!=1 then throw new Error ("in file: " + file + " require supposed to have 1 argument: " + text)
    pathOfModuleRaw=args[0].value

    pathOfModuleLoc=path.resolve(fileDir,pathOfModuleRaw)
    pathOfModuleLocStats=try fs.lstatSync(pathOfModuleLoc) catch me;

    if (pathOfModuleLocStats and pathOfModuleLocStats.isDirectory()) then throw new Error("in file: " + file + " require for a directory not supported " + text)

    #if path can be resolved and it is file than it is non native, non npm
    pathOfModule=packageUtils.getIfNonNativeNotFilteredNonNpm(pathOfModuleLoc,[],possibleExtensions)
    #        if path.extname(pathOfModuleLoc)==""
    #          existingExtensions=possibleExtensions.filter((ext)->return fs.existsSync(pathOfModuleLoc + "." + ext))
    #          if existingExtensions.length>1 then throw new Error("in file: " + file + " multiple matching extensions problem for " + text)
    #          pathOfModule=if existingExtensions.length==1 then pathOfModuleLoc + "." + existingExtensions[0] else null
    #        else
    #          pathOfModule=if fs.existsSync(pathOfModuleLoc) then pathOfModuleLoc else null

    rs={text,path:pathOfModule}
    if !isOnlyNonNativeNonNpm || pathOfModule
      r.push(rs)


  r=[]
  fileDir=path.dirname(file)
  ast.walk(new UglifyJS.TreeWalker(
    (node)->
      if (node instanceof UglifyJS.AST_Call) && (node.start.value == 'require' || (node.start.value == 'new' and node.expression.print_to_string()=="require"))
        text=node.print_to_string({ beautify: true })
#        console.log(text)
        args=node.args
        try
          handleRequireNode(text,args)
        catch me
          a=1+2
        return true
      else if  (node instanceof UglifyJS.AST_Call) && (node.start.value == 'new' and node.expression.start.value=="(" and node.expression.print_to_string().indexOf("require")!=-1)
        args=node.expression.args
        text="require" + "('" + args[0].value + "')"
      #        console.log(text)

        handleRequireNode(text,args)
        console.log("second " + text)
        return true
      else
        return
    )
  )
  return r

packageUtils.replaceRequireStatement=(textIn,orig,replacement)->
  text=textIn
  isReplaced=false
  text=text.replace(orig,(token)->(isReplaced=true;return replacement))
  if !isReplaced
    withTheOtherQuotation=orig
    if withTheOtherQuotation.indexOf("'")!=-1
      withTheOtherQuotation=withTheOtherQuotation.replace(/[']/ig,'"')
    else
      withTheOtherQuotation=withTheOtherQuotation.replace(/["]/ig,"'")
    text=text.replace(withTheOtherQuotation,(token)->(isReplaced=true;return replacement))
  if !isReplaced
    throw new Error(orig + " was not replaced with " + replacement)
  return text


#        console.log([text,path.resolve(fileDir,pathOfModule),packageUtils.isNative(pathOfModule)].join(" | "))

#print_to_string({ beautify: false }).replace(/-/g, "_")   AST_Assign node.left,right
# return true; no descend
