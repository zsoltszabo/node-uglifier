var that = this;
var cachedModules=[];
var getCachedModule = function(index) {
  if (cachedModules[index].builder!=null) {
    cachedModules[index].builder.call(that,cachedModules[index],cachedModules[index].exports);
    delete cachedModules[index].builder;
  }
  return cachedModules[index].exports;
};
cachedModules[7624] = {
  exports: {},
  builder: (function(module,exports) {module.exports=({
    "domain": "www.example.com",
    "mongodb": {
        "host": "localhost",
        "port": 27017
    }
});})
};var randomJson=getCachedModule(7624);

if (randomJson.domain!=="www.example.com") {
    throw new Error("ups did not work we got: " + randomJson.domain + "  instead www.example.com ");
}




