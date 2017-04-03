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
UglifyJS = require('uglify-js-harmony')
path = require('path')
_ = require('underscore')

packageUtils = module.exports

# Check if `module` is a native module (like `net` or `tty`).
packageUtils.isNative = (module)->
    try
        return require.resolve(module) == module;
    catch err
        return false;

packageUtils.readFile = (pathAbs, encoding = 'utf8')->
    options = {encoding}
    return fs.readFileSync(pathAbs, options)

packageUtils.getAst = (code)->
    return UglifyJS.parse(code)

#absolulte file path
packageUtils.getMatchingFiles = (rootPath, dirAndFileArray)->
    r = []

    rootDir = if fs.lstatSync(rootPath).isDirectory() then path.resolve(rootPath) else path.dirname(path.resolve(rootPath))
    for dirOrFile in dirAndFileArray
        destination = path.resolve(rootDir, dirOrFile)
        try
            filestats = fs.lstatSync(destination)
        catch me
#probably missing extension, file not found
            filestats = null
        if filestats and filestats.isDirectory()
#we have directory
            fs.readdirSync(destination).reduce(((prev, curr)-> prev.push(path.join(destination, curr));return prev), r)
        else
            if path.extname(destination) == ""
                fileName = path.basename(destination)
                fs.readdirSync(path.dirname(destination)).filter((fileNameLoc)-> fileNameLoc.indexOf(fileName) != -1).reduce(((prev, curr)-> prev.push(path.join(destination,
                    curr)); return prev), r)
            else
                r.push(destination)
    return r


packageUtils.getIfNonNativeNotFilteredNonNpm = (fileAbs, filters, possibleExtensions)->
#if path can be resolved and it is file than it is non native, non npm
    r = null
    if path.extname(fileAbs) == ""
        existingExtensions = possibleExtensions.filter((ext)->return fs.existsSync(fileAbs + "." + ext))
        if existingExtensions.length > 1 then throw new Error(" multiple matching extensions problem for " + fileAbs)
        r = if existingExtensions.length == 1 then fileAbs + "." + existingExtensions[0] else null
    else
        r = if fs.existsSync(fileAbs) then fileAbs else null
    if r
        if filters.filter((fFile)->return path.normalize(fFile) == path.normalize(r)).length > 0
            r = null;
            console.log(fileAbs + " was filtered ")

    return r


packageUtils.walkExpressions=(astNode,parentNode,depth)->
        if depth>5 then return null
        if astNode.name=="require"
            return parentNode?.args || astNode.args
        else if astNode.expression?
            return packageUtils.walkExpressions(astNode.expression,astNode,depth+1)




#assume no directory is native module
#returns the file path of modules if file exists
#if no extension specified first existing possibleExtensions is used
packageUtils.getRequireStatements = (ast, file, possibleExtensions = ["js", "coffee"], packNodeModules = false)->
    r = []
    fileDir = path.dirname(file)

    handleRequireNode = (text, args)->

        pathOfModuleRaw = args[0].value

        if !pathOfModuleRaw? then   throw new Error("probably dynamic")

        #has / or \ in the string
        hasPathInIt = (!_.isEmpty(pathOfModuleRaw.match("/")) || !_.isEmpty(pathOfModuleRaw.match(/\\/)))

        if hasPathInIt
            #it is not a module, do nothing
        else if packNodeModules
            #find node_module directory, than main in package json if no index.js found
            pathOfModuleRaw=require.resolve(pathOfModuleRaw)
        else
            #it is module and not packed
            return false

        pathOfModuleLoc = path.resolve(fileDir, pathOfModuleRaw)
        try
            pathOfModuleLocStats =fs.lstatSync(pathOfModuleLoc)
        catch me;

        if (pathOfModuleLocStats and pathOfModuleLocStats.isDirectory())
            pathOfModuleLoc=path.resolve(pathOfModuleLoc, "index")


        #if path can be resolved and it is file than it is non native, non npm
        pathOfModule = packageUtils.getIfNonNativeNotFilteredNonNpm(pathOfModuleLoc, [], possibleExtensions)


        rs = {text, path: pathOfModule}
        if  pathOfModule
            r.push(rs)





    ast.walk(new UglifyJS.TreeWalker(
            (node)->
                if (node instanceof UglifyJS.AST_Call) && (node.start.value == 'require' || (node.start.value == 'new' and node.expression.print_to_string() == "require"))
                    text = node.print_to_string({beautify: false})
                    #        console.log(text)
                    #expression argument takes precedence over the first argument of require
                    requireArgs = node?.expression?.args

                    walkedArgs=packageUtils.walkExpressions(node,null,1)


                    if _.isEmpty(requireArgs)
                        requireArgs = node.args
                    try
#                        if args.length != 1 then
#                        throw new Error ("in file: " + file + " require supposed to have 1 argument: " + text)
                        if  requireArgs.length != 1 or !handleRequireNode(text, requireArgs) and !_.isEmpty(walkedArgs)
                            text2="require('#{walkedArgs[0].value}')"
                            handleRequireNode(text2, walkedArgs)

                    catch me
                        console.log("Warning!:")
                        console.log("unhandled require type in file: " + file + " the problematic statement: " + text + " probably something fancy going on! " + " the error: " + me.message)
                    return true
                else if  (node instanceof UglifyJS.AST_Call) && (node.start.value == 'new' and node.expression.start.value == "(" and node.expression.print_to_string().indexOf("require") != -1)
                    args = node.expression.args
                    text = "require" + "('" + args[0].value + "')"
                    #        console.log(text)

                    handleRequireNode(text, args)
                    console.log("second " + text)
                    return true
                else
                    return
        )
    )
    return r


strEscapeMap = {
    '\b': '\\b',
    '\f': '\\f',
    '\n': '\\n',
    '\r': '\\r',
    '\t': '\\t',
};

packageUtils.hexifyString = (str)->
    r = ""
    if !str.length > 0 then return r
    for i in [0..str.length - 1]
        char = str[i];
        if (strEscapeMap[char])
            r += r[char];
        else if ('\\' == char)
            r += '\\' + str[++i]
        else
            r += '\\x' + str.charCodeAt(i).toString(16);
    return r;

packageUtils.deHexifyString = (str)->
    return str.toString()


packageUtils.getSourceHexified = (ast)->
    hexify = (node)->
        if (node instanceof UglifyJS.AST_String)
            text = node.getValue()
            hex = packageUtils.hexifyString(text);
            obj = _.extend({}, node);
            obj.value = hex
            return new UglifyJS.AST_String(obj);
        else
            return

    transformer = new UglifyJS.TreeTransformer(null, hexify);
    stream = new UglifyJS.OutputStream;
    stream.print_string = (str)->
        return this.print('"' + str + '"')

    ast = ast.transform(transformer);
    ast.print(stream);

    return stream.toString()


#packageUtils.replaceAll=(find, replace, str)->
#    return str.replace(new RegExp(find, 'g'), replace);




packageUtils.replaceRequireStatement = (textIn, orig, replacement)->
    text = textIn
    isReplaced = false
    text = text.replace(orig, (token)-> (isReplaced = true;return replacement))
    if !isReplaced
        withTheOtherQuotation = orig
        if withTheOtherQuotation.indexOf("'") != -1
            withTheOtherQuotation = withTheOtherQuotation.replace(/[']/ig, '"')
        else
            withTheOtherQuotation = withTheOtherQuotation.replace(/["]/ig, "'")
        text = text.replace(withTheOtherQuotation, (token)-> (isReplaced = true;return replacement))
    if !isReplaced
        throw new Error(orig + " was not replaced with " + replacement)
    return text


packageUtils.countWords = (sentence)->
    index = {}
    words = sentence
    .replace(/[.,?!;()"'-]/g, " ")
    .replace(/\s+/g, " ")
    .toLowerCase()
    .split(" ");

    words.forEach((word)->
        if (!(index.hasOwnProperty(word)))
            index[word] = 0;
        index[word]++;
    )
    return index


#        console.log([text,path.resolve(fileDir,pathOfModule),packageUtils.isNative(pathOfModule)].join(" | "))

#print_to_string({ beautify: false }).replace(/-/g, "_")   AST_Assign node.left,right
# return true; no descend
