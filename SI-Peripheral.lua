-- Created: 20230703
-- Purpose: Moved some CC peripheral functions/methods into a module/library for code reusability.
-- Author: ScorpionInc
-- Updated: 20230703
-- Version: 0.0.1a
-- CHANGELOG:
-- TODO:
require("SI-Core") -- funcExists
require("SI-Print") -- printTable(Debugging)

--General LUA Code:
--CC Lua Code:
--GLOBAL CC CONSTANTS
RELATIVE_DIRECTIONS_6S = { "F", "L", "Ba", "R", "T", "Bo" }
RELATIVE_DIRECTIONS_6L = { "Front", "Left", "Back", "Right", "Top", "Bottom" }
--GLOBAL CC Variables
_siHandleModemMessages = false
siModemBuffer = {} -- Format: [[event, modemSide, senderChannel, replyChannel, message, senderDistance]:0,[event, modemSide, senderChannel, replyChannel, message, senderDistance]:1]
--GLOBAL CC functions/method
function getPeripheralDirections( )
 -- Returns the relative direction of all available peripheral interface(s)
 local p = {}
 for _, dir in ipairs(RELATIVE_DIRECTIONS_6L) do
  local periph = peripheral.wrap( dir )
  if not (periph == nil) then
   table.insert(p, dir)
  end
 end
 return p
end
function getModemDirections( )
 -- Returns the relative direction of all available modem interface(s)
 local p = getPeripheralDirections()
 local m = {}
 for _, dir in ipairs(p) do
  local modem = peripheral.wrap( dir )
  if funcExists(modem.transmit) then
   -- Has Modem Specific function(s)
   table.insert(m, dir)
  end
 end
 return m
end
function getWiredModemDirections( )
 -- Returns the relative direction of all available modem interface(s)
 local p = getModemDirections()
 local m = {}
 for _, dir in ipairs(p) do
  local modem = peripheral.wrap( dir )
  if funcExists(modem.isPresentRemote) then
   -- Has Wired Modem Specific function(s)
   table.insert(m, dir)
  end
 end
 return m
end
function getWirelessModemDirections( )
 -- Returns the relative direction of all available modem interface(s)
 local p = getModemDirections()
 local m = {}
 for _, dir in ipairs(p) do
  local modem = peripheral.wrap( dir )
  if modem.isWireless() then
   -- Has isWireless() Return value set to true.
   table.insert(m, dir)
  end
 end
 return m
end

function hasPeripheral()
 return (#getPeripheralDirections() > 0)
end
function hasModem()
 return (#getModemDirections() > 0)
end
function hasWiredModem()
 return (#getWiredModemDirections() > 0)
end
function hasWirelessModem()
 return (#getWirelessModemDirections() > 0)
end

function getPeripheral()
 -- Returns first available peripheral(Lua is not 0-Indexed)
 return peripheral.wrap( getPeripheralDirections()[1] )
end
function getModem()
 -- Returns first available modem(Lua is not 0-Indexed)
 return peripheral.find("modem")--peripheral.wrap( getModemDirections()[1] )
end
function getWiredModem()
 -- Returns first available wired modem(Lua is not 0-Indexed)
 return peripheral.wrap( getWiredModemDirections()[1] )
end
function getWirelessModem()
 -- Returns first available wireless modem(Lua is not 0-Indexed)
 return peripheral.wrap( getWirelessModemDirections()[1] )
end

function getMessageSync()
 -- Reads all values from a modem message into local variables.
 -- Only returns senderChannel, replyChannel, message, senderDistance.
 -- *WARNING* This function is blocking.
 local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
 return senderChannel, replyChannel, message, senderDistance
end
function _awaitMessageASync()
 -- Reads values from a modem message into local variables to return.
 -- *WARNING* This function is blocking.
 repeat
  local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
  table.insert(siModemBuffer, 0, {event, modemSide, senderChannel, replyChannel, message, senderDistance})
 until( not _siHandleModemMessages )
end
function hasMessageASync()
 -- Returns true if a message has been processed and is available to read.
 return (#siModemBuffer > 0)
end
function enableSIModemMessages( _mainFunction )
 -- Allows this library to handle modem messages.
 if _siHandleModemMessages then
  return
 end
 -- Attempt to find/validate main function to be parallized with
 if _mainFunction == nil then
  _mainFunction = debug.getinfo(2).name
 end
 if _mainFunction == nil or _mainFunction == '?' then
  print("[WARN]: Calling enableSIModemMessages without a main function results in blocking behavior.")-- Debugging
  _mainFunction = nil
 end
 _siHandleModemMessages = true
 parallel.waitForAny(_awaitMessageASync, _mainFunction)
end
function disableSIModemMessages()
 -- Disallows this library to handle modem messages.
 if not _siHandleModemMessages then
  return
 end
 _siHandleModemMessages = false
end
