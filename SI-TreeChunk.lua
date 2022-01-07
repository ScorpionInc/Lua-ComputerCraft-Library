-- Created: 20211212
-- Purpose: My own stab at a Tree Farming Program in CC
-- Author: ScorpionInc
-- Updated: 20211230
-- Version: 0.0.1b
-- CHANGELOG:
-- TODO:

require("SI-Core")
require("SI-Print")
require("SI-Inventory")
require("SI-Move")

-- ComputerCraft CONFIGURATION:
SCRIPT_NAME = "TreeChunk"
FILE_SETTINGS_PREFIX = ""
FILE_SETTINGS_SUFFIX = ".var"
FILE_LOG_FULL_PATH = "" .. SCRIPT_NAME .. ".log"
-- GLOBAL CC CONSTANTS:
INVENTORY_SLOTS = 9
-- GLOBAL CC VARIABLES:
fuelStart = 0
fuelStop = 0
fuelCap = turtle.getFuelLimit()
fuelDelta = 0
initializeMove(223, 81, -2480, "W")

-- Turtle Specific
local function printUsage()
 -- Print out script usage to terminal output
 printHeaderBar()
 printCentered("This script requires an action parameter to specify requested operations.", "|", "|")
 printCentered("Available Actions are(is):", "|", "|")
 printCentered("", "|", "|")
 printCentered("RunOnce", "|", "|")
 printCentered("Run", "|", "|")
 printHeaderBar()
end
local function noisyExit()
 -- Stop execution with a goodbye message, after saving persistent settings
 saveSetting( "posX", posX )
 saveSetting( "posY", posY )
 saveSetting( "posZ", posZ )
 printCentered("{EXITING} See you next time!!! o/")
 os.exit() -- Stop Program Execution
end

-- HANDLE SCRIPT PARAMETERS:
--term.clear() term.setCursorPos(1,1) --Reset Terminal Display
local tArgs = {...}
if (#tArgs >= 1) then
 -- Has parameter(s)
 print(tArgs)
else
 -- Missing parameter(s)
 --printUsage()
 printCentered("Please specify a parameter...")
 --noisyExit()
end
-- START:
--term.clear() term.setCursorPos(1,1) --Reset Terminal Display
fuelStart = turtle.getFuelLevel()
print("[INFO]: Initial Fuel amount: " .. tostring(fuelStart) .. ".")
print(""..getFullPositionString().."")
fuelStop = turtle.getFuelLevel()
fuelDelta = (fuelStart - fuelStop)
print("Fuel Changed by: '" .. tostring(fuelDelta) .. "' this cycle. New fuel: " .. tostring(fuelStop) .. ".")
