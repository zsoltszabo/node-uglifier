sugar = require('sugar');
_ = require('underscore');
ok = require("assert")
eq = require("assert").equal
tz = require("timezone")
ts = require("../lib_compiled/timestampGrabber")

test=()->

  result=ts.parseDate("1994-1-2T11:3:4.600 PM") #T11:03:04.666 PM
  eq(result.Y,1994)
  eq(result.M,1)
  eq(result.D,2)
  eq(result.H,23)
  eq(result.m,3)
  eq(result.s,4)
  eq(result.f,600)

  console.log(ts.parse("1/22/14 10:23:01.001 PM *", "M D Y HH:mm:ss.fff tt", "America/New_York"))

  eq(ts.parse("1/22/14 10:23:01.001 PM *", "M D Y HH:mm:ss.fff tt", "Europe/Kiev"),ts.parse("1/22/14 10:23:01.001 PM *", "M D Y HH:mm:ss.fff tt", "Europe/Berlin")-1000*60*60)
  eq(ts.parse("1/22/14 10:23:01.001 PM *", "M D Y HH:mm:ss.fff tt", "America/New_York")+3*1000*60*60,ts.parse("1/22/14 10:23:01.001 PM *", "M D Y HH:mm:ss.fff tt", "America/Los_Angeles"))
  eq(ts.parse("1/22/14 10:23:01.001 PM *", "M D Y HH:mm:ss.fff tt", "Europe/Budapest")+9*1000*60*60,ts.parse("1/22/14 10:23:01.001 PM *", "M D Y HH:mm:ss.fff tt", "America/Los_Angeles"))
  eq(ts.parse("Feb 19, 2014 at 01:52", "MMM D, Y at H:m", "Etc/Greenwich"),1392774720000)


  result = ts.parseDate("1994/01/02 11:03:04.6 PM", "YYYY MM DD HH:mm:ss.f tt") #T11:03:04.666 PM
  #  console.log(result)
  eq(result.Y,1994)
  eq(result.M,1)
  eq(result.D,2)
  eq(result.H,23)
  eq(result.m,3)
  eq(result.s,4)
  eq(result.f,600)

  result=ts.parseDate("1994-1-2T11:3:4.600") #T11:03:04.666 PM
  #console.log(result)
  eq(result.Y,1994)
  eq(result.t,undefined)

  result=ts.parseDate("1994-1-2 11:03 AM") #T11:03:04.666 PM
  #console.log(result)
  eq(result.Y,1994)
  eq(result.H,11)
  eq(result.s,undefined)
  eq(result.f,undefined)


  result =ts.parseDate("1/15/14 10:23 PM *", "M D Y HH:mm tt") #T11:03:04.666 PM
  #console.log(result)
  eq(result.Y,2014)
  eq(result.M,1)
  eq(result.D,15)
  eq(result.H,22)
  eq(result.m,23)



test()
setTimeout((->
  process.exit()), 3000)