var randomJson=require('./randomJsonFile.json');

if (randomJson.domain!=="www.example.com") {
    throw new Error("ups did not work we got: " + randomJson.domain + "  instead www.example.com ");
}




