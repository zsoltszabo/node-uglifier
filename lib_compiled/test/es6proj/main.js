//import {port, getDepA} from 'esDepA/depa'
//
//if (port!==888) {
//    throw new Error("import did not work:");
//}
//
//if (getDepA("ok")!=="") {
//    throw new Error("import did not work:"+getDepA("ok"));
//}

//destructuring
var obj={str1:'test1',
        str2:'test2'};

var { str1, str2}=obj;


var arr=['test3','test4'];

var [str3, str4]=arr;



if (str1!=="test1") {
    throw new Error("ups obj destructuring did not work");
}
if (str2!=="test2") {
    throw new Error("ups obj destructuring did not work");
}
if (str3!=="test3") {
    throw new Error("ups array destructuring did not work");
}
if (str4!=="test4") {
    throw new Error("ups array destructuring did not work");
}

//class, default input, string interpolation
class Greeter {
    sayHi(name = 'Anonymous') {
        return (`Hi ${name}!`);
    }
}

var greeter = new Greeter();

if (greeter.sayHi()!=="Hi Anonymous!") {
    throw new Error("ups class, default input, string interpolation did not work");
}

var result='';
this.greeter=greeter;

var indirectFn=(ret) =>{
    result=(this.greeter.sayHi(ret));
};

indirectFn("Justin");

if (result!=="Hi Justin!") {
    throw new Error("ups arrow function did not work:");
}

//let and const is flakey in Uglify-Harmony atm
//function calculateTotalAmount (fl) {
//    var amount = 0;
//    if (fl) {
//        let amount = 1;
//    }
//    {
//        let amount = 2 ;
//    }
//    return amount;
//}
//
//if (calculateTotalAmount(true)!==0) {
//    throw new Error("let word did not work:");
//}




