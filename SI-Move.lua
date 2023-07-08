-- Created: 20211230
-- Purpose: Moved some common CC movement functions/methods into a module/library for code reusability
-- Author: ScorpionInc
-- Updated: 20230703
-- Version: 0.0.1c
-- CHANGELOG:
-- TODO:

require("SI-Core")--Dances

require("SI-Print")--digArea
require("SI-Inventory")--digArea

--General LUA Code:

--CC Lua Code:
--GLOBAL CC CONSTANTS
CHUNK_SIZE = 16
CARDINAL_DIRECTIONS_4S = { "N", "E", "S", "W" }
CARDINAL_DIRECTIONS_4L = { "North", "East", "South", "West" }
CARDINAL_DIRECTIONS_6S = { "N", "E", "S", "W", "U", "D" }
CARDINAL_DIRECTIONS_6L = { "North", "East", "South", "West", "Up", "Down" }
--GLOBAL CC Variables
dirInit = false
posInit = false
posX = 0
posY = 0
posZ = 0
chunkX = 0
chunkY = 0
chunkZ = 0
regionX = 0
regionZ = 0
-- Positive X,Z is SE
-- Thus:
-- 1 = N = -Z; 2 = E = +X; 3 = S = +Z; 4 = W = -X;
facingDir = 1

function getPositionString()
 -- Returns string value of current turtle position in (x,y,z) format.
 return "("..posX..", "..posY..", "..posZ..")"
end
--Reference: https://dinnerbone.com/static/js/angular/coordinate_tools.js
function getMinBlockFromChunk( chunkX, chunkY, chunkZ )
 -- Returns minimum block(X,Y,Z) within a chunk specified by its chunk index(X,Y,Z)
 initializeBits()
 return bit32.lshift(chunkX, 4), bit32.lshift(chunkY, 4), bit32.lshift(chunkZ, 4)
end
function getMaxBlockFromChunk( chunkX, chunkY, chunkZ )
 -- Returns maximum block(X,Y,Z) within a chunk specified by its chunk index(X,Y,Z)
 local x,y,z = getMinBlockFromChunk( chunkX + 1, chunkY + 1, chunkZ + 1 )
 return x-1,y-1,z-1
end
function getMinChunkFromRegion( regionX, regionZ )
 -- Returns minimum chunk(X,Y,Z) within a region specified by its region index(X,Z)
 initializeBits()
 return bit32.lshift(regionX, 5), 0, bit32.lshift(regionZ, 5)
end
function getMaxChunkFromRegion( regionX, regionZ )
 -- Returns maximum chunk(X,Y,Z) within a region specified by its region index(X,Z)
 local x,_,z = getMinChunkFromRegion( regionX + 1, regionZ + 1 )
 return x - 1, 15, z - 1
end
function getChunkFromBlock( blockX, blockY, blockZ )
 --Returns chunk containing block specified by position(X, Y, Z)
 return rshift_neg(blockX, 4),rshift_neg(blockY, 4),rshift_neg(blockZ, 4)
end
function getRegionFromChunk( chunkX, chunkZ )
 -- Returns region index(X,Z) containing chunk index(X,_,Z)
 return rshift_neg(chunkX,5),rshift_neg(chunkZ,5)
end
function getChunkString()
 -- Returns string value of current turtle chunk in (x,y,z) format.
 return "("..chunkX..", "..chunkY..", "..chunkZ..")"
end
function getRegionString()
 -- Returns string value of current turtle region file in r.x.z.mca format.
 return "r."..regionX.."."..regionZ..".mca"
end
function getFullPositionString()
 -- Returns a concatenated string representing the turtle position in block position, chunk, and region.
 return "P:"..getPositionString()..";C:"..getChunkString()..";"..getRegionString()..""
end

local function _OnPositionChanged()
 -- Updates values of chunk and region coords. To be called whenever positionX, positionY, or positionZ are changed.
 -- Ignores initialized status in case we need to initialize partially without knowing the facing direction for some reason...
 -- Returns void(Method)
 local x,y,z = getChunkFromBlock( posX, posY, posZ )
 chunkX = x
 chunkY = y
 chunkZ = z
 x,z = getRegionFromChunk( chunkX, chunkZ )
 regionX = x
 regionZ = z
end
function isDirectionInitialized()
 return dirInit
end
function isPositionInitialized()
 return posInit
end
function setPosition( newX, newY, newZ )
 -- Sets position to a new location, then updates chunk and region.
 -- Ignores initialized status in case we need to initialize partially without knowing the facing direction for some reason...
 -- Returns void(Method)
 posX = newX
 posY = newY
 posZ = newZ
 _OnPositionChanged()
end
function initializeMove( x, y, z, dir )
 -- Should be called once on startup
 -- Initializes turtle position values to track movement in the world space.
 -- Returns void(Method)
 setPosition(x, y, z)
 if(type(dir)=="string") then
  -- Search for a matching string value for directions
  ok,index = searchTable(CARDINAL_DIRECTIONS_4S, dir)
  if (not ok) then
   ok,index = searchTable(CARDINAL_DIRECTIONS_4L, dir)
  end
  if ok then
   facingDir = index
  else
   print("[ERROR]: initializeMove couldn't find direction: '"..dir.."'.")--Debugging
   return
  end
 else
  --Assume it's an index(?)
  facingDir = dir
 end
 posInit = true
 print("[INFO]: Initialized position and direction for the Move Module.")--Debugging
end

local function _OnMovedFB( value )
 -- Helper Function used by mf, dmf, amf, fmf, mb to update internal position tracking by value in the 'forward/backward' relative direction
 -- Returns void(method)
 -- Handle Default value(s)
 value = value or 1
 if not posInit then
  -- We don't know where we are so can't update...
  return
 end
 if (CARDINAL_DIRECTIONS_4S[facingDir]=="N") then
  posZ = posZ - value
 else
  if (CARDINAL_DIRECTIONS_4S[facingDir]=="S") then
   posZ = posZ + value
  end
 end
 if (CARDINAL_DIRECTIONS_4S[facingDir]=="E") then
  posZ = posX + value
 else
  if (CARDINAL_DIRECTIONS_4S[facingDir]=="W") then
   posZ = posX - value
  end
 end
 _OnPositionChanged()
end
function mf( n )
 -- Moves turtle forward n blocks(if possible) returns true on success or false on fail
 -- Handle Default Parameters:
 n = n or 1
 -- Loop movement
 for i = 1, n, 1 do
  if not turtle.forward() then
   return false
  end
  _OnMovedFB( 1 )
 end
 return true
end
function df()
 -- Dig in the forward direction so long as there is something to dig.
 -- returns void(Method)
 -- Requires Tool(s)
 while turtle.detect() do -- Helps handle falling entities. e.g. sand
  turtle.dig()
 end
end
function dmf( n )
 -- Dig as needed then move forward, n times returns true on success or false on fail
 -- Requires Tool(s)
 -- Handle Default Parameters:
 n = n or 1
 -- Loop movement
 for i = 1, n, 1 do
  df()
  if not turtle.forward() then
   -- Probably an entity of some kind...
   return false
  end
  _OnMovedFB( 1 )
 end
 return true
end
function fmf( n )
 -- Dig or attack as needed to clear a space to move forward. Do this n times return true on success, false on fail
 -- Requires Tool(s)
 -- Handle Default Parameters:
 n = n or 1
 -- Loop movement
 for i = 1, n, 1 do
  df()
  if not turtle.forward() then
   -- Probably an entity of some kind...
   turtle.attack()
   if not turtle.forward() then
    return false
   end
  end
  _OnMovedFB( 1 )
 end
 return true
end
function mb( n )
 -- Move backward, n times returns true on success or false on fail
 -- Requires Tool(s)
 -- Handle Default Parameters:
 n = n or 1
 -- Loop movement
 for i = 1, n, 1 do
  if not turtle.back() then
   return false
  end
  _OnMovedFB( -1 )
 end
 return true
end

local function _OnMovedUD( value )
 -- Helper Function used by mu, dmu, fmu, md, dmd, fmd to update internal position tracking by value in the 'upward/downward' direction
 -- Returns void(method)
 -- Handle default value(s)
 value = value or 1
 if not posInit then
  -- We don't know where we are so can't update...
  return
 end
 posY = posY + value
 _OnPositionChanged()
end
function mu( n )
 -- Moves turtle up n blocks(if possible) returns true on success or false on fail
 -- Handle Default Parameters:
 n = n or 1
 -- Loop movement
 for i = 1, n, 1 do
  if not turtle.up() then
   return false
  end
  _OnMovedUD( 1 )
 end
 return true
end
function du()
 -- Dig in the upward direction so long as there is something to dig.
 -- returns void(Method)
 -- Requires Tool(s)
 while turtle.detectUp() do -- Helps handle falling entities. e.g. sand
  turtle.digUp()
 end
end
function dmu( n )
 -- Dig as needed then move upward, n times returns true on success or false on fail
 -- Requires Tool(s)
 -- Handle Default Parameters:
 n = n or 1
 -- Loop movement
 for i = 1, n, 1 do
  du()
  if not turtle.up() then
   -- Probably an entity of some kind...
   return false
  end
  _OnMovedUD( 1 )
 end
 return true
end
function fmu( n )
 -- Dig/Attack as needed then move upward, n times returns true on success or false on fail
 -- Requires Tool(s)
 -- Handle Default Parameters:
 n = n or 1
 -- Loop movement
 for i = 1, n, 1 do
  du()
  if not turtle.up() then
   -- Probably an entity of some kind...
   turtle.attackUp()
   if not turtle.up() then
    return false
   end
  end
  _OnMovedUD( 1 )
 end
 return true
end
function md( n )
 -- Moves turtle down n blocks(if possible) returns true on success or false on fail
 -- Requires Tool(s)
 -- Handle Default Parameters:
 n = n or 1
 -- Loop movement
 for i = 1, n, 1 do
  if not turtle.down() then
   return false
  end
  _OnMovedUD( -1 )
 end
 return true
end
function dd()
 -- Dig in the downward direction so long as there is something to dig.
 -- returns void(Method)
 -- Requires Tool(s)
 while turtle.detectDown() do -- Helps handle falling entities. e.g. sand
  turtle.digDown()
 end
end
function dmd( n )
 -- Dig as needed then move downward, n times returns true on success or false on fail
 -- Requires Tool(s)
 -- Handle Default Parameters:
 n = n or 1
 -- Loop movement
 for i = 1, n, 1 do
  dd()
  if not turtle.down() then
   -- Probably an entity of some kind...
   return false
  end
  _OnMovedUD( -1 )
 end
 return true
end
function fmd( n )
 -- Dig/Attack as needed then move downward, n times returns true on success or false on fail
 -- Requires Tool(s)
 -- Handle Default Parameters:
 n = n or 1
 -- Loop movement
 for i = 1, n, 1 do
  dd()
  if not turtle.down() then
   -- Probably an entity of some kind...
   turtle.attackDown()
   if not turtle.down() then
    return false
   end
  end
  _OnMovedUD( -1 )
 end
 return true
end

local function _OnTurnRL( value )
 -- Helper function used by tl and tr to update the facingDir value
 -- Right: N -> E; E -> S; S -> W; W -> N;
 -- Left : N -> W; E -> N; S -> E; W -> S;
 -- Returns void(Method)
 -- Handle Default value(s)
 value = value or 1
 value = math.fmod(value, #CARDINAL_DIRECTIONS_4S) -- Handle value wrapping over direction size
 if (facingDir+value) > #CARDINAL_DIRECTIONS_4S then
  facingDir = facingDir + value - #CARDINAL_DIRECTIONS_4S
 else
  if (facingDir+value) <= 0 then
   facingDir = facingDir + value + #CARDINAL_DIRECTIONS_4S
  else
   facingDir = facingDir + value
  end
 end
 --print("[INFO]: New Facing Direction: " .. tostring(CARDINAL_DIRECTIONS_4L[facingDir]) .. ".") -- Debugging
end
function tl( n )
 -- Turns to face an equivilent direction with minimal movement specified by name(Not best for dancing)
 -- e.g. tl(4) = NOP; tl(3) = tr(1);
 -- Returns true on success, false otherwise. (When would this ever fail?)
 -- Handle Default Parameters:
 n = n or 1
 n = math.fmod(n, #CARDINAL_DIRECTIONS_4S) -- Handle multiple rotations
 if n==3 then
  return tr(1)-- Handle other turning direction
 end
 for i = 1, n, 1 do
  if not turtle.turnLeft() then
   return false
  end
  _OnTurnRL( -1 )
 end
 return true
end
function tr( n )
 -- Turns to face an equivilent direction with minimal movement specified by name(Not best for dancing)
 -- e.g. tr(4) = NOP; tr(3) = tl(1);
 -- Returns true on success, false otherwise. (When would this ever fail?)
 -- Handle Default Parameters:
 n = n or 1
 n = math.fmod(n, #CARDINAL_DIRECTIONS_4S) -- Handle multiple rotations
 if n==3 then
  return tl(1)-- Handle other turning direction
 end
 for i = 1, n, 1 do
  if not turtle.turnRight() then
   return false
  end
  _OnTurnRL( 1 )
 end
 return true
end

function sf( n )
 -- Sucks items from in front n times, into current selected slot. Defaults to n = 1.
 -- Returns true on success or false on fail.
 -- Handle Default Parameters:
 n = n or 1
 for i = 1, n, 1 do
  if not turtle.suck() then
   return false
  end
 end
 return true
end
function su( n )
 -- Sucks items from above n times, into current selected slot. Defaults to n = 1.
 -- Returns true on success or false on fail.
 -- Handle Default Parameters:
 n = n or 1
 for i = 1, n, 1 do
  if not turtle.suckUp() then
   return false
  end
 end
 return true
end
function sd( n )
 -- Sucks items from below n times, into current selected slot. Defaults to n = 1.
 -- Returns true on success or false on fail.
 -- Handle Default Parameters:
 n = n or 1
 for i = 1, n, 1 do
  if not turtle.suckDown() then
   return false
  end
 end
 return true
end
function sa()
 -- Attempts to suck items in all directions, into current selected slot
 -- Returns true if any items picked up, false otherwise.
 return sf() or su() or sd()
end
function wsa()
 -- Continues to suck items in all available directions as long as it is successful in at least one.
 -- Returns void(Method)
 while sa() do end
end

-- More Advanced Movement functions
function turnToFace( targetDir )
 -- Turns turtle to face cardinal direction specified by targetDir parameter.
 -- Returns void(Method)
 -- Handle Default Parameters:
 if (targetDir==nil) then
  print("[ERROR]: turnToFace() Requires parameter 'targetDir' to be defined.")--Debugging
  return
 end
 if ((type(targetDir) == "string")) then
  local ok,index = searchTable( CARDINAL_DIRECTIONS_4L, targetDir )
  if not ok then
   ok,index = searchTable( CARDINAL_DIRECTIONS_4S, targetDir )
  end
  if ok then
   --print("[INFO]: turnToFace() Found direction at index: " .. index .. ".")--Debugging
   targetDir = index
  else
   print("[ERROR]: turnToFace() couldn't find direction: '" .. targetDir .. "'.")--Debugging
   return
  end
 else
  --Assume it's an index/key type(?)
  --print("[INFO]: turnToFace() Target Direction Type: '" .. type(targetDir) .. "'.")--Debugging
 end
 -- At this point targetDir should be an index
 local turnDelta = targetDir - facingDir
 if turnDelta == 0 then
  return
 else
  --print("[INFO]: turnToFace() Turn delta: " .. turnDelta .. ".")--Debugging
 end
 --Do the turning
 if turnDelta > 0 then
  tr(turnDelta)
 else
  tl(turnDelta * -1)
 end
end
function goto_coord_yxz_f( destX, destY, destZ )
 -- TODO
 -- Moves turtle to global xyz coordinate from y->x->z, attacks or digs anything that gets in its way.
 -- Returns true on success, false on fail
 -- Requires Tool(s), Initialization
 -- Could use less fuel, to go straight to the point but it complicates the code more... TODO
 if( not posInit ) then
  -- Don't know where we are so we can't determine how to get to a coord.
  return false
 end
 local currentDirection = facingDir -- Hold onto current direction to be restored after movements
 local delta = 0
 -- Determine direction to move(y)
 delta = destY - posY
 if delta < 0 then
  fmd( -1 * delta )
 else
  fmu( delta )
 end
 -- Determine direction to move(x)
 delta = destX - posX
 if delta < 0 then
 else
 end
 -- Determine direction to move(z)
 delta = destZ - posZ
 if delta < 0 then
 else
 end
 turnToFace( currentDirection ) -- Restore original facing direction
 return true
end
function goto_chunk_xz_f( chunkX, chunkZ )
 -- TODO
end

function digArea( xDistance, yDistance, zDistance )
 -- Removes any blocks in an area.
 -- Returns void(Method)
 local volume = xDistance * zDistance * yDistance
 requireFuelAmount( (volume * 2) + yDistance + (zDistance * yDistance) )
 for i = 1, yDistance, 1 do
  for ii = 1, zDistance, 1 do
   for iii = 1, xDistance, 1 do
    wsa()
    while not hasEmptySlot() do
	 print("[ERROR]: Help! Inventory is full!")
	end
    while turtle.detect() do
     turtle.dig()
    end
    while not mf() do
	 print("[ERROR]: Help! I can't move forward!")
	end
   end -- iii
   -- If has next x row setup for next line
   if ((ii) < zDistance) then
    if (math.fmod(ii, 2) == 1) then
     turtle.turnRight()
    else
     turtle.turnLeft()
    end
	wsa()
	while not hasEmptySlot() do
	 print("[ERROR]: Help! Inventory is full!")
	end
    while turtle.detect() do
     turtle.dig()
    end
    while not mf() do
	 print("[ERROR]: Help! I can't move forward!")
	end
    if (math.fmod(ii, 2) == 1) then
     turtle.turnRight()
    else
     turtle.turnLeft()
    end
   else
    -- Return to start
    if (math.fmod(ii, 2) == 1) then
     turtle.turnLeft()
    else
     turtle.turnRight()
    end
	mf(zDistance - 1)
	if (math.fmod(ii, 2) == 1) then
     turtle.turnLeft()
    else
     turtle.turnRight()
    end
   end
  end -- ii
  refuelAll()
  print("[INFO]: Current Fuel Level: " .. getFuelString() .. ".")
  if ((i) < yDistance) then
   if not dmu() then
    return
   end
  end
 end -- i
 fmd(yDistance - 1)
end

--Dances (For testing of course >.> <.<)
function hourglassDance( loops )
 -- Performs an "Hourglass" turtle stationary dance loops times
 -- Returns void(Method)
 initializeSleep()
 for i = 1, loops, 1 do
  tl(1)
  os.sleep(1)
  tr(2)
  os.sleep(1)
  tr(1)
  os.sleep(1)
  tl(2)
  os.sleep(1)
 end
end

print("[INFO]: SI-Move Library/Module Loaded.")--Debugging
