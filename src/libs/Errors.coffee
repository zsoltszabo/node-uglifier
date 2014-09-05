#so far not all errors are here

util=require("util")

class CyclicDependencies extends Error
  constructor: (cyclesArrOfArr)->
    @name = 'CyclicDependencies'
    @cycles=cyclesArrOfArr
#    console.log(util.inspect(cyclesArrOfArr,{ showHidden: true, depth: null }))
    msg="There has been " + cyclesArrOfArr.length + " cycles in the dependency tree: \n" + util.inspect(cyclesArrOfArr,{ showHidden: true, depth: null })
    return super msg


module.exports.CyclicDependencies =CyclicDependencies