var dependencies = require("./dep");
if (dependencies.one.boothDeepAndShalow("_X")!="DEEP_TEST_X")
    throw new Error("ups did not work requiring a directory 1: " + dependencies.one.boothDeepAndShalow("_X"));

if (dependencies.two.boothDeepAndShalow("_X")!="TEST_X")
    throw new Error("ups did not work:  requiring a directory 2: " + dependencies.two.boothDeepAndShalow("_X"));