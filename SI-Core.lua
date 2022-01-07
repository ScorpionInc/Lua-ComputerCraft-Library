-- Created: 20211230
-- Purpose: Moved some common CC utility functions/methods into a module/library for code reusability
-- Author: ScorpionInc
-- Updated: 20211230
-- Version: 0.0.1b
-- CHANGELOG:
-- TODO:

--General LUA Code:
--OS
local _initializedOSSleep = false
function initializeSleep()
 -- Attempts to define once: os.sleep() in the "best way" possible with redundant methods
 -- Copyed then modified from: Somewhere(Citation needed 0.0)
 -- Returns void(Method)
 if _initializedOSSleep then
  return
 else
  _initializedOSSleep = true
 end
 -- we "pcall" (try/catch) the "ex", which had better include os.sleep
 -- it may be a part of the standard library in future Lua versions (past 5.2)
 local ok,ex = pcall(require,"ex")
 if ok then
  -- print("Ex")
  -- we need a hack now too? ex.install(), you say? okay
  pcall(ex.install)
  -- let's try something else. why not?
  if ex.sleep and not os.sleep then os.sleep = ex.sleep end
 else
  if not os.sleep then
   -- we make os.sleep
   -- first by trying ffi, which is part of LuaJIT, which lets us write C code
   local ok,ffi = pcall(require,"ffi")
   if ok then
    -- print("FFI")
    -- we can use FFI
    -- let's just check one more time to make sure we still don't have os.sleep
    if not os.sleep then
     -- okay, here is our custom C sleep code:
     ffi.cdef[[
     void Sleep(int ms);
     int poll(struct pollfd *fds,unsigned long nfds,int timeout);
     ]]
     if ffi.os == "Windows" then
      os.sleep = function(sec)
       ffi.C.Sleep(sec*1000)
      end
     else
      os.sleep = function(sec)
      ffi.C.poll(nil,0,sec*1000)
      end
     end
    end
   else
    -- if we can't use FFI, we try LuaSocket, which is just called "socket"
    -- I'm 99.99999999% sure of that
    local ok,socket = pcall(require,"socket")
    -- ...but I'm not 100% sure of that
    if not ok then local ok,socket = pcall(require,"luasocket") end
    -- so if we're really using socket...
    if ok then
     -- print("Socket")
     -- we might as well confirm there still is no os.sleep
     if not os.sleep then
      -- our custom socket.select to os.sleep code:
      os.sleep = function(sec)
       socket.select(nil,nil,sec)
      end
     end
    else
     -- now we're going to test "alien"
     local ok,alien = pcall(require,"alien")
     if ok then
      -- print("Alien")
      -- beam me up...
      if not os.sleep then
       -- if we still don't have os.sleep, that is
       -- now, I don't know what the hell the following code does
       if alien.platform == "windows" then
        kernel32 = alien.load("kernel32.dll")
        local slep = kernel32.Sleep
        slep:types{ret="void",abi="stdcall","uint"}
        os.sleep = function(sec)
         slep(sec*1000)
        end
       else
        local pol = alien.default.poll
        pol:types('struct', 'unsigned long', 'int')
         os.sleep = function(sec)
          pol(nil,0,sec*1000)
         end
       end
      end
     elseif package.config:match("^\\") then
      -- print("busywait")
      -- if the computer is politically opposed to NIXon, we do the busywait
      -- and shake it all about
      os.sleep = function(sec)
       local timr = os.time()
       repeat until os.time() > timr + sec
      end
     else
      -- print("NIX")
      -- or we get NIXed
      os.sleep = function(sec)
       os.execute("sleep " .. sec)
      end
     end
    end
   end
  end
 end
end
local function testSleep( n )
 -- Initializes the sleep function if needed, then shows printed text with a delay.
 -- Returns void(Method)
 print("[INFO]: Initializing os.sleep() function.")--Debugging
 initializeSleep()
 print("[INFO]: Defined os.sleep(). (Hopefully) Waiting for a (few) second(s)...")--Debugging
 os.sleep( n )
 print("[INFO]: Test Completed a (few) second(s) later.")--Debugging
end

--Modified from code sourced: https://stackoverflow.com/questions/25403979/lua-only-call-a-function-if-it-exists
function funcExists( nameOrFunc )
 -- Returns true if function is defined directly or by name.
 -- Returns false otherwise.
 if (type(nameOrFunc)=="string") then
  return _G[nameOrFunc]
 else
  return nameOrFunc~=nil
 end
end
function callFunc( nameOrFunc )
 -- Returns function call to function specified by parameter or name if defined.
 -- If invalid or undefined then fails silently
 if (type(nameOrFunc)=="string") then
  return function(...)
   ok, result = pcall(_G[nameOrFunc], ...)
   if ok then -- nameOrFunc exists and is callable
    return result
   end
   -- Otherwise there is nothing to do, fails silently
  end
 else
  return function(...)
   ok, result = pcall(nameOrFunc, ...)
   if ok then -- nameOrFunc exists and is callable
    return result
   end
   -- Otherwise there is nothing to do, fails silently
  end
 end
end

local _initializedOSBits = false
function initializeBits()
 -- TODO: add all other common bit32 external library implementations(and,or,xor,not,ror,rol,ect)
 -- Attempts to define bit32 library functions for older versions of LUA as needed.
 -- Returns void(Method)
 if _initializedOSBits then
  return
 else
  _initializedOSBits = true
 end
 --Try newer over older, C over LUA
 if (not funcExists(bit32.lshift)) then
  if funcExists(bit.lshift) then -- Covers BitOp and bitlib
   bit32.lshift = bit.lshift
  else
   if funcExists(bit.blshift) then -- Covers LuaBit
    bit32.lshift = bit.blshift
   end
  end
 end -- bit32.lshift
 if (not funcExists(bit32.rshift)) then
  if funcExists(bit.rshift) then -- Covers BitOp and bitlib
   bit32.rshift = bit.rshift
  else
   if funcExists(bit.brshift) then -- Covers LuaBit
    bit32.rshift = bit.brshift
   end
  end
 end -- bit32.rshift
end
function rshift_neg( value, amount )
 -- Binary-Right-Shift function using bit32.rshift that ignores negative signs in the shifting.
 -- Returns numerical value.
 initializeBits()
 if value >= 0 then
  return bit32.rshift(value, amount)
 else
  local tmp = bit32.rshift(-1 * value, amount)
  return -1 * tmp
 end
end

--I/O
function file_exists( name )
 -- Returns true if file can be opened for reading. Returns false otherwise.
 local f=io.open(name,"r")
 if f~=nil then io.close(f) return true else return false end
end

--Utility
function searchTable( T, needle)
 -- Searches table values for a matching needle and returns true,key
 -- Returns false,0 on fail
 for key,value in pairs( T ) do
  if value==needle then
   return true,key
  end
 end
 return false,0
end

--CC Lua Code:
--GLOBAL CC CONSTANTS
--GLOBAL CC Variables

function readSetting( varName )
 -- Returns persistent variable value saved in file specified with CONFIGURATION settings and varName.
 -- Returns nil on failure.
 local path = FILE_SETTINGS_PREFIX .. varName .. FILE_SETTINGS_SUFFIX
 return nil, "[ERROR]: Failed to read variable from: '" .. path .. "'"
end
function saveSetting( varName, var )
 -- Overwrites contents of file specified with CONFIGURATION and varName with the value of var
 -- Returns true on success, false on fail
 local path = FILE_SETTINGS_PREFIX .. varName .. FILE_SETTINGS_SUFFIX
 return false
end
function clearSetting( varName )
 -- Deletes file by varname
 -- returns true on success, false on fail
 return false
end

print("[INFO]: SI-Core Library/Module Loaded.")--Debugging
