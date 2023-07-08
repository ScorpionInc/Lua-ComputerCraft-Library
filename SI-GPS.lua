-- Created: 20230703
-- Purpose: Moved some CC GPS functions/methods into a module/library for code reusability.
-- Author: ScorpionInc
-- Updated: 20230703
-- Version: 0.0.1a
-- CHANGELOG:
-- TODO:
require("SI-Core")--split
require("SI-Move")--isPositionInitialized
require("SI-Peripheral")--getWirelessModem

--General LUA Code:
--CC Lua Code:
--GLOBAL CC CONSTANTS
GPS_BROADCAST_VERSION_ID = 0
GPS_BROADCAST_CHANNEL_ID = 9278
--GLOBAL CC Variables
_gpsBroadcastEnabled = false
gpsModem = nil
gpsBroadcastRate = 1000
--GLOBAL CC functions/method
function initializeGPS()
 if gpsModem == nil then
  gpsModem = getWirelessModem()
  gpsModem.open(GPS_BROADCAST_CHANNEL_ID)
 end
end
function broadcastGPS()
 initializeGPS()
 if not isPositionInitialized() then
  print("[WARN]: broadcastGPS() Didn't broadcast an unknown position.") -- Debugging
  return
 end
 local broadcastMessage = ""-- Format: VersionID x y z
 broadcastMessage = broadcastMessage .. GPS_BROADCAST_VERSION_ID .. " "
 broadcastMessage = broadcastMessage .. posX .. " "
 broadcastMessage = broadcastMessage .. posY .. " "
 broadcastMessage = broadcastMessage .. posZ
 gpsModem.transmit(GPS_BROADCAST_CHANNEL_ID, GPS_BROADCAST_CHANNEL_ID, broadcastMessage)-- (SendChannel, ReceiveChannel, Message)
end
function enableGPSBroadcast()
 -- TODO
 -- Enables the periodic broadcasting of position over GPS channel.
 initializeGPS()
 if not isPositionInitialized() then
  print("[WARN]: enableGPSBroadcast() Failed to start due to having an unknown position.") -- Debugging
  return
 end
end
function disableGPSBroadcast()
 -- TODO
end

function trilateration_4P(p1, p2, p3, p4)
 -- TODO Maybe move to a math module(?)
 -- Uses four(4) known points with distances to calculate position in 3D.
end
function trilateration_3P(p1, p2, p3)
 -- TODO Maybe move to a math module(?)
 -- Uses three(4) known points with distances to calculate possible positions in 3D.
end
function parseGPSMessage(message)
 --Returns x,y,z coordinates from a GPS message.
 local ssv = split(message)
 if #ssv <= 0 then
  return nil
 end
 local VersionID = ssv[1]-- Not 0-Indexed
 --Version Specific handle
 if VersionID == 0 then
  if not #ssv == 4 then
   return nil
  end
  return ssv[2],ssv[3],ssv[4]
 end
 return nil
end
function awaitGPSCoords()
 -- TODO
 -- Returns calculated position based upon output from the gps broadcast channel using trilateration.
 -- *WARNING* This is a blocking function.
 -- Data needed for triangulation:
 local posAX = 0, posAY = 0, posAZ = 0, distA = 0.0, readyA = false
 local posBX = 0, posBY = 0, posBZ = 0, distB = 0.0, readyB = false
 local posCX = 0, posCY = 0, posCZ = 0, distC = 0.0, readyC = false
 local posDX = 0, posDY = 0, posDZ = 0, distD = 0.0, readyD = false
 while(not readyA or not readyB or not readyC or not readyD) do
  local senderChannel, replyChannel, message, senderDistance = getMessageSync()
  -- Begin Message Parsing
  local posTX, posTY, posTZ = parseGPSMessage(message)
  -- Do we already have this data already(?)
  -- TODO: I could make this point information into an array to reduce repeated statements.
  local isRedundant = false
  if readyA and posAX == posTX and posAY == posTY and posAZ == posTZ then
   isRedundant = true
  end
  if readyB and posBX == posTX and posBY == posTY and posBZ == posTZ then
   isRedundant = true
  end
  if readyC and posCX == posTX and posCY == posTY and posCZ == posTZ then
   isRedundant = true
  end
  if readyD and posDX == posTX and posDY == posTY and posDZ == posTZ then
   isRedundant = true
  end
  if isRedundant then
   goto continue
  end
  -- Data is unique.
  -- TODO: I should test if the coordinates share a plane with already known points. Ignored for now.
 ::continue::
 end
 -- Begin calculation(s)
 -- Return result(s)
end