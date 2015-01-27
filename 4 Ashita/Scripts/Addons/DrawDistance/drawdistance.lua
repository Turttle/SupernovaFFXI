--[[
* Copyright (c) 2011-2014 - Ashita Development Team
*
* Ashita is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Ashita is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Ashita.  If not, see <http://www.gnu.org/licenses/>.
]]--

_addon.author   = 'atom0s';
_addon.name     = 'DrawDistance';
_addon.version  = '1.0';

require 'common'

---------------------------------------------------------------------------------------------------
-- desc: DrawDistance global table.
---------------------------------------------------------------------------------------------------
local drawdistance = { };

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Scan for the draw distance pointer..
    local sig = { 0x8B, 0xC1, 0x48, 0x74, 0x08, 0xD8, 0x0D };
    local ptr = mem:FindPattern('FFXiMain.dll', sig, #sig, "xxxxxxx");
    
    -- Ensure we found a pointer..
    if (ptr == 0) then
        print('\30\105[DrawDistance] (ERROR) Failed to find required signature!');
        return;
    end
    drawdistance.ptr = ptr;
end );

---------------------------------------------------------------------------------------------------
-- func: command
-- desc: Called when our addon receives a command.
---------------------------------------------------------------------------------------------------
ashita.register_event('command', function(cmd, nType)    
    -- Ensure we should handle this command..
    local args = cmd:GetArgs();
    if (args[1] ~= '/drawdistance') then
        return false;
    end
    
    -- Does the user want to set the world distance..
    if (args[2] == 'setworld' and #args == 3) then
        local ptr = mem:ReadULong(drawdistance.ptr + 0x07);
        mem:WriteFloat(ptr, tonumber(args[3]));
        return true;
    end
    
    -- Does the user want to set the mob distance..
    if (args[2] == 'setmob' and #args == 3) then
        local ptr = mem:ReadULong(drawdistance.ptr + 0x0F);
        mem:WriteFloat(ptr, tonumber(args[3]));
        return true;
    end
    
    return true;
end );
