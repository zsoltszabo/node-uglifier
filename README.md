timestamp-grabber
=========

Have you been searching the **NodeJS** scene everywhere for a simple date parser tool that can handle timezones too? Search no more, I present you the **timestamp-grabber**.
There are tons of modules to do whatever you want with timestamps, but to get to the timestamp timezone aware has been lacking.
Convert a very wide variety of human readable date/time formats to unix timestamp in millis. Supports all major timezones thanks to the **Timezone** module.


The code is very fogiving in terms of pattern definition. The code is easily extendable for even more cases.


how it works
--------

Here is how it works. There are 2 public methods as you can see in the following tests. You will most likely use parse, that gives you the unix timestamp in millis.

* ts = require("timestamp-grabber")
* console.log(ts.parse("1/22/14 10:23:01.001 PM *", "M D Y HH:mm:ss.fff tt", "America/New_York"))
* ->1390447381001

Note that the number of token letters is optional, you can write YYYY, YY, Y, it will recognize the 2 digit or 4 digit year anyways.
Currently there is no "strict mode" that throws error if digit counts do not match.
The only exception now from this rule is MMM which denotes the month when using 3 letter english month names instead of digits.

##Tests

`eq(ts.parse("Tue May 08 20:24:06 +0000 2014","w MMM DD HH:mm:ss +oooo YYYY","Etc/GMT-11"),ts.parse("Tue May 08 20:24:06 -0011 2014","w MMM DD HH:mm:ss +oooo YYYY"))`

`eq(ts.parse("1/22/14 10:23:01.001 PM *", "M D Y HH:mm:ss.fff tt", "Europe/Kiev"),ts.parse("1/22/14 10:23:01.001 PM *", "M D Y HH:mm:ss.fff tt", "Europe/Berlin")-1000*60*60)`

`eq(ts.parse("1/22/14 10:23:01.001 PM *", "M D Y HH:mm:ss.fff tt", "America/New_York")+3*1000*60*60,ts.parse("1/22/14 10:23:01.001 PM *", "M D Y HH:mm:ss.fff tt", "America/Los_Angeles"))`

`eq(ts.parse("1/22/14 10:23:01.001 PM *", "M D Y HH:mm:ss.fff tt", "Europe/Budapest")+9*1000*60*60,ts.parse("1/22/14 10:23:01.001 PM *", "M D Y HH:mm:ss.fff tt", "America/Los_Angeles"))`

`eq(ts.parse("Feb 19, 2014 at 01:52", "MMM DD, YYYY at HH:mm", "Etc/Greenwich"),1392774720000)`

#####result=ts.parseDate("2014-05-08 20:24:06.400","YYYY-MM-DD HH:mm:ss.fff",false)
* eq(result.Y,2014)
* eq(result.M,5)
* eq(result.D,8)
* eq(result.H,20)
* eq(result.m,24)
* eq(result.s,6)
* eq(result.f,400)


#####result = ts.parseDate("1994/01/02 11:03:04.6 PM", "YYYY MM DD HH:mm:ss.f tt") #T11:03:04.666 PM
* eq(result.Y,1994)
* eq(result.M,1)
* eq(result.D,2)
* eq(result.H,23)
* eq(result.m,3)
* eq(result.s,4)
* eq(result.f,600)


#####result=ts.parseDate("1994-1-2T11:3:4.600") #T11:03:04.666 PM
* eq(result.Y,1994)
* eq(result.t,undefined)

#####result=ts.parseDate("1994-1-2 11:03 AM") #T11:03:04.666 PM
* eq(result.Y,1994)
* eq(result.H,11)
* eq(result.s,undefined)
* eq(result.f,undefined)

#####result =ts.parseDate("1/15/14 10:23 PM *", "M D Y H:m tt") #T11:03:04.666 PM

* eq(result.Y,2014)
* eq(result.M,1)
* eq(result.D,15)
* eq(result.H,22)
* eq(result.m,23)

## License

* license.txt
