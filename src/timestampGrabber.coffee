sugar = require('sugar');
_ = require('underscore');
tz = require("timezone")
#europe = tz(new require("timezone/Europe"))

Timestamp = module.exports

ContinentsLoaded = {}
#continentTimeZones = tz(new require("timezone/" + "Europe"))

_MONTHS3_ENG=["jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"]

_patterns = {
  Y: "([0-9]{2,4})"
  M: "([0-9]{1,2})"
  MMM: "([\\w]{3})"
  D: "([0-9]{1,2})"
  H: "([0-9]{1,2})"
  m: "([0-9]{1,2})"
  s: "(?:[:]([0-9]{1,2}))?" #optional
  date_date: "[-|//|\\s|,]*"
  time_time: "[:]"
  date_time: "[T|\\s]"
  undefined: "[-|//|\\s|,]*"  #optional
  f: "(\.[0-9]{1,3})?" #optional
  t: "(?:[\\s])?([\\w]{2})?" #optional
  o: "([\-|\+][0-9]{1,4})"
  w: "([\\w]*)"
}
#patternConstucted=new RegExp(yearP+dateConnP+MDHmP+dateConnP+MDHmP+dateTimeConnP+MDHmP+timeConnP+MDHmP+secP+milliP+dayTimeP,"m")

#dateIsoishPattern = /([0-9]{2,4})[-|/]([0-9]{1,2})[-|/]([0-9]{1,2})[T|\s]([0-9]{1,2})[:]([0-9]{1,2})(?:[:]([0-9]{1,2}))?(\.[0-9]{1,3})?(?:[\s])?([\w]{2})?/m
#dateIsoishPattern = new RegExp(yearP+"[-|/]([0-9]{1,2})[-|/]([0-9]{1,2})[T|\s]([0-9]{1,2})[:]([0-9]{1,2})(?:[:]([0-9]{1,2}))?(\.[0-9]{1,3})?(?:[\s])?([\w]{2})?","m")

#[T]([0-9]{1,2})[:]([0-9]{1,2})[:]([0-9]{1,2})[.]([0-9]{1,2,3}) #([\w]{2})

#contains Y-year M-month D-day H-hour m-minute s-sec f-millis t-daytime
#in the default non strict mode number of characters not important YY for year will be 20YY
getPatternPositions = (pattern)->
  patternSplit = pattern.split(/[/ /]|[-]|[T]|[\s]+|[\.]|[\s]*[,][\s]*|[:]/) #(new RegExp("[/ /]|[-]|[T]|[\s]+|[\.]|[:]")) #
  positions = []
  for i in [0..patternSplit.length - 1]
#    console.log(patternSplit[i])
    group = undefined
    switch patternSplit[i].charAt(0)
      when "Y" then group = "date"
      when "M" then group = "date"
      when "D" then group = "date"
      when "H" then group = "time"
      when "m" then group = "time"
      when "s" then group = "time_optional"
      when "f" then group = "milli_optional"
      when "t" then group = "timeOfDay_optional"
      when "+","-" then group = "offset"
      when "w" then group = "word"
    if group is undefined
      positions[i] = {"type": patternSplit[i], "len": patternSplit[i].length, "group": group}
    else
      if patternSplit[i]=="MMM"
        positions[i] = {"type": patternSplit[i], "len": patternSplit[i].length, "group": group}
      else if patternSplit[i].charAt(0)=="+" || patternSplit[i].charAt(0)=="-"
        positions[i] = {"type": patternSplit[i].charAt(1), "len": patternSplit[i].length, "group": group}
      else
        positions[i] = {"type": patternSplit[i].charAt(0), "len": patternSplit[i].length, "group": group}
  return positions

#input like [{"type":Y,"len":4,"group":"date|time|milli|timeOfDay"},...]
constructPattern = (patternPositions)->
  rString = ""
  NEUTRAL=["offset","word"]
  for i in [0..patternPositions.length - 1]
    if  _.isUndefined(patternPositions[i].group)
      rString = rString + "(" + patternPositions[i].type + ")"
    else
      rString = rString + _patterns[patternPositions[i].type]
    if i < patternPositions.length - 1
      groupCurr = patternPositions[i].group
      groupNext = patternPositions[i + 1].group
      if _.isUndefined(groupCurr)||_.isUndefined(groupNext)||groupNext in NEUTRAL ||groupCurr in NEUTRAL
        rString = rString + _patterns["undefined"]
      else
        if _patterns[groupCurr + "_" + groupNext]
          rString = rString + _patterns[groupCurr + "_" + groupNext]
  return new RegExp(rString)


parseDate = (dateIsoish, pattern = "YYYY/MM/DD HH:mm:ss.fff tt", strictMode = false) ->
  paternPositions = getPatternPositions(pattern)
  #  console.log(paternPositions[1].type)
  constructed=constructPattern(paternPositions)
  dateIsoishCleanedArr = dateIsoish.match(constructed)
  if dateIsoishCleanedArr
    dateIsoishCleanedArr.removeAt(0)
  #find non ambigous parts
  isOptionalPattern = (patternString)->
    return _.isUndefined(patternString)||_.isEqual(patternString.charAt(patternString.length - 1), "?")||!_.isEqual(patternString.charAt(0), "(")

  r = {}
  #first is the full match
  j = 1
  #  console.log(dateIsoishCleanedArr)
  for i in [0..paternPositions.length - 1]
    typeShouldBe = paternPositions[i].type
    wasOptional = false
#    process.stderr.write(typeShouldBe)
    if !isOptionalPattern(_patterns[typeShouldBe])
      if dateIsoishCleanedArr[i] == undefined
        throw "datepattern #{pattern} does not match date #{dateIsoish}"

    amPm=""
    if dateIsoishCleanedArr[i] != undefined
      switch typeShouldBe
        when "f" then r[typeShouldBe] = parseFloat(dateIsoishCleanedArr[i]) * 1000
        when "t"
          if dateIsoishCleanedArr[i].toLowerCase() == "pm"
            amPm="pm"
          else
            amPm="am"
        when "Y"
          yearXDigits = parseInt(dateIsoishCleanedArr[i])
          if yearXDigits < 100
            yearXDigits = 2000 + yearXDigits
          r[typeShouldBe] = yearXDigits
        when "MMM"
          r[typeShouldBe] = _MONTHS3_ENG.indexOf(dateIsoishCleanedArr[i].toLowerCase())+1
        when "M"
          r[typeShouldBe] = parseInt(dateIsoishCleanedArr[i])
        when "o"
          r[typeShouldBe] = parseInt(dateIsoishCleanedArr[i])
        else
          r[typeShouldBe] = parseInt(dateIsoishCleanedArr[i])

  daytimeHoursToAdd=0
  if amPm=="pm"
    if r["H"]==12
      #do nothing
    else
      daytimeHoursToAdd=12
  else
    if r["H"]==12
      daytimeHoursToAdd=-12

  r["H"] = r["H"] + daytimeHoursToAdd

  return r

Timestamp.pad = (n, width, z="0")->
  n = n + ''
  return if n.length >= width then n else new Array(width - n.length + 1).join(z) + n


parse = (dateIsoish, pattern = "YYYY/MM/DD HH:mm:ss.fff tt", continentCitiy=null, strictMode = false)->

  dateParsed = parseDate(dateIsoish, pattern, strictMode)

  if !continentCitiy?
    if !dateParsed.o? then throw new TypeError "either offset or continent city must be defined for timezone"
    continent = "Etc"
    sign= if dateParsed.o>0 then "+" else ""
    city = "GMT" + sign + dateParsed.o.toString()
  else
    continentCities = continentCitiy.split((/[ \/]|[\s]+|[:]/))
    continent = continentCities[0].trim()
    city = if continentCities.length==2 then continentCities[1].trim() else continentCities[1].trim() + continentCities[2].trim()

  if ContinentsLoaded[continent] == undefined
    console.log("timestamp loded: "+continent)
    ContinentsLoaded[continent] = tz(new require("timezone/" + continent))



  monthRaw=dateParsed["M"]||dateParsed["MMM"]
  month = Timestamp.pad(monthRaw.toString(),2)

  day= Timestamp.pad(dateParsed["D"].toString(),2)
  minute="00"
  second="00"
  milliSecond="000"
  if dateParsed["m"]
    minute= Timestamp.pad(dateParsed["m"].toString(),2)
  hour=Timestamp.pad(dateParsed["H"].toString(),2)
  if dateParsed["s"]
    second= Timestamp.pad(dateParsed["s"].toString(),2)
  if dateParsed["f"]
    milliSecond= Timestamp.pad(dateParsed["f"].toString(),3)
  r = ContinentsLoaded[continent](dateParsed["Y"].toString()+ "-" + month + "-" + day + "T" + hour + ":" + minute+ ":" + second+ "." + milliSecond,continent + "/" + city)


  return r


Timestamp.parseDate=parseDate
Timestamp.parse=parse