-- Created: 20211230
-- Purpose: Moved some common CC printing functions/methods into a module/library for code reusability
-- Author: ScorpionInc
-- Updated: 20211230
-- Version: 0.0.1b
-- CHANGELOG:
-- TODO:

require("SI-Core")
require("SI-Print")

--General LUA Code:

--CC Lua Code:
--GLOBAL CC CONSTANTS
--GLOBAL CC Variables

local function hasEmptySlot()
 -- Returns true if has an empty slot, false otherwise
 for i = 1, INVENTORY_SLOTS, 1 do
  if turtle.getItemCount( i )==0 then
   return true
  end
 end
 return false
end
local function findFuelSlot()
 -- TODO
 -- Returns index of slot containing valid turtle food(fuel).
 -- Returns 0 on fail.
 for i = 1, INVENTORY_SLOTS, 1 do
  local nextSlot = turtle.getItemDetail( i )
  printTable( nextSlot )--Debugging
 end
 return 0
end
local function findSwordSlot()
 -- TODO
 -- Returns index of slot containing valid tool(sword).
 -- Returns 0 on fail.
 return 0
end
local function findAxSlot()
 -- TODO
 -- Returns index of slot containing valid tool(ax).
 -- Returns 0 on fail.
 return 0
end
local function findPickaxSlot()
 -- TODO
 -- Returns index of slot containing valid tool(ax).
 -- Returns 0 on fail.
 return 0
end
local function findShovelSlot()
 -- TODO
 -- Returns index of slot containing valid tool(shovel).
 -- Returns 0 on fail.
 return 0
end
local function findBucketSlot()
 -- TODO
 -- Returns index of slot containing valid tool(sword).
 -- Returns 0 on fail.
 return 0
end

local function refuelAll()
 -- Attempts to refuel from all slots
 -- Returns void(Method)
 local currentSelectedSlot = turtle.getSelectedSlot()
 for i = 1, INVENTORY_SLOTS, 1 do
  turtle.select( i )
  turtle.refuel()
 end
 turtle.select( currentSelectedSlot )
end
local function requireFuelAmount( amount )
 -- NOP(Loop) Until enough fuel is added to inventory
 local currentSelectedSlot = turtle.getSelectedSlot() --To be restored if changed in this non-thread safe section
 if (fuelCap=="unlimited") then
  return -- Should only occur when no fuel is needed so we are g2g
 end
 if ( amount > fuelCap ) then
  -- Prevent an infinite loop but print a warning
  print("[WARN]: Required fuel amount is beyond turtle capacity!")
  return
 end
 local lastFuelLevel = turtle.getFuelLevel()
 local nextFuelSlot = 0
 while lastFuelLevel < amount do
  print("[WARN]: NOT ENOUGH FUEL! [" .. lastFuelLevel .. "/" .. amount .. "]") -- Debugging
  nextFuelSlot = findFuelSlot()
  if (nextFuelSlot==0) then
   -- Couldn't find specific fuel slot. Try all.
   refuelAll()
   lastFuelLevel = turtle.getFuelLevel()
  else
   -- Refuel from return fuel slot
   refuelAll()
   lastFuelLevel = turtle.getFuelLevel()
  end
 end
 -- Restore original selected slot
 turtle.select(currentSelectedSlot)
end

print("[INFO]: SI-Inventory Library/Module Loaded.")--Debugging
