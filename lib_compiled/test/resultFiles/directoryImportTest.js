var cachedModules=[];
cachedModules[3565]={exports:{}};
(function(module,exports) {(function() {
    module.exports.boothDeepAndShalow = function(strIn) {
        return "DEEP_TEST" + strIn;
    };

}).call(this);}).call(this,cachedModules[3565],cachedModules[3565].exports);
cachedModules[4077]={exports:{}};
(function(module,exports) {(function() {
    module.exports.boothDeepAndShalow = function(strIn) {
        return "TEST" + strIn;
    };

}).call(this);}).call(this,cachedModules[4077],cachedModules[4077].exports);
cachedModules[7624]={exports:{}};
(function(module,exports) {exports.one = cachedModules[3565].exports;
exports.two = cachedModules[4077].exports;}).call(this,cachedModules[7624],cachedModules[7624].exports);var dependencies = cachedModules[7624].exports;
if (dependencies.one.boothDeepAndShalow("_X")!="DEEP_TEST_X")
    throw new Error("ups did not work requiring a directory 1: " + dependencies.one.boothDeepAndShalow("_X"));

if (dependencies.two.boothDeepAndShalow("_X")!="TEST_X")
    throw new Error("ups did not work:  requiring a directory 2: " + dependencies.two.boothDeepAndShalow("_X"));