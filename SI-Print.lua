-- Created: 20211230
-- Purpose: Moved some common CC printing functions/methods into a module/library for code reusability
-- Author: ScorpionInc
-- Updated: 20211230
-- Version: 0.0.1b
-- CHANGELOG:
-- TODO:

require("SI-Core")

--General LUA Code:

--CC Lua Code:
--GLOBAL CC CONSTANTS
TERMINAL_WIDTH = 39
TERMINAL_HEIGHT = 13
--GLOBAL CC Variables

function printTable( T )
 -- Prints table contents to stdout
 -- Returns void(Method)
 local stringBuffer = tostring(#T) .. ":{"
 for key,value in pairs( T ) do
  stringBuffer = stringBuffer .. "["..tostring(key).."]:"..tostring(value)..";"
 end
 stringBuffer = stringBuffer .. "}"
 print(stringBuffer)
end

function getFuelString()
 -- Used for fuel levels script debugging and statistics output
 -- Returns a formatted string: fuel/max or unlimited
 local lMax = turtle.getFuelLimit()
 if lMax=="unlimited" then
  return lMax
 end
 return tostring(turtle.getFuelLevel()) .. "/" .. tostring(lMax)
end

local _headerBarString = ""
local _headerBarStringInit = false
function printHeaderBar( barChar )
 -- Prints a bar of ASCII characters to fill one full line of the Terminal
 -- Handle Default Parameters:
 barChar = barChar or "="
 if not (type(barChar) == "string") then
  --Something weird is happenin here... There may be dragons best to leave.
  return nil, "[ERROR]: printHeaderBar() Argument expected type of String, got " .. type(name)
 end
 if _headerBarStringInit then
  -- Already generated String value.
  print(_headerBarString)
 else
  --Generate string once on first call.
  for i = 1, TERMINAL_WIDTH, 1 do
   _headerBarString = _headerBarString .. "="
  end
  _headerBarStringInit = true
  print(_headerBarString)
 end
end
function printCentered( str, prefix, suffix, padChar )
 -- Prints a string centered on a CC Turtle terminal
 -- Returns void(Method)
 -- Handle Default Parameters:
 prefix = prefix or ""
 suffix = suffix or ""
 padChar = padChar or " "
 if (not (type(str) == "string")) or (not (type(prefix) == "string")) or (not (type(suffix) == "string")) or (not (type(padChar) == "string")) then
  return nil, "[ERROR]: printCentered() Arguments are expected to be of type of String!"
 end
 -- Validate edge strings don't overflow.
 local psLen = string.len(prefix) + string.len(suffix) -- Length of Prefix and Suffix together
 local uLen = TERMINAL_WIDTH - psLen -- Maximum usable number of characters for both padding and string content.
 if uLen <= 0 then
  --No way to fix this, Fails silently
  return
 end
 -- Handle str text overflow:
 local sLen = string.len(str) -- Length of the content string
 local tcLen = (psLen + sLen) -- Total charcters used that are non-padding
 if tcLen > TERMINAL_WIDTH then
  --Balance character count between lines method, Handles Recursively
  local lineCount = 1 --Number of total lines needed for str content
  lineCount = math.ceil( sLen / uLen )
  local charsPerLine = math.floor( sLen / lineCount )
  for i = 1, lineCount, 1 do
   printCentered( string.sub( str, ((i - 1) * (i + charsPerLine)) + 1, (charsPerLine + 1) * i ), prefix, suffix )
  end
  -- Fill first lines method, Handles Recursively
  --printCentered( string.sub(str, 1, TERMINAL_WIDTH - psLen), prefix, suffix )
  --printCentered( string.sub(str, TERMINAL_WIDTH - psLen + 1), prefix, suffix )
  return
 end
 -- If we are here then we should be all good on parameters
 -- Calculate padding amounts
 local paddingCount = TERMINAL_WIDTH - tcLen
 local padLeft = math.floor(paddingCount / 2.0)
 local padRight = math.ceil(paddingCount / 2.0) -- Favor right padding
 -- Build String
 local line = prefix
 for i = 1, padLeft, 1 do
  line = line .. padChar
 end
 line = line .. str
 for i = 1, padRight, 1 do
  line = line .. padChar
 end
 line = line .. suffix
 -- Output Result
 print(line)
end

print("[INFO]: SI-Print Library/Module Loaded.")--Debugging
