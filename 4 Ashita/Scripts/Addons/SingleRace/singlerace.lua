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
_addon.name     = 'SingleRace';
_addon.version  = '1.0';

require 'common'

---------------------------------------------------------------------------------------------------
-- desc: SingleRace Main Table
---------------------------------------------------------------------------------------------------
local SingleRace = 
{
    raceid = 5,
    hairid = 2,
};

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
end );

---------------------------------------------------------------------------------------------------
-- func: Command
-- desc: Called when our addon receives a command.
---------------------------------------------------------------------------------------------------
ashita.register_event('command', function(cmd, nType)
    -- Ensure we should handle this command..
    local args = cmd:GetArgs();
    if (args[1] ~= '/singlerace') then
        return false;
    end
    
    -- Set the desired race..
    if (#args >= 3 and args[2] == 'race') then
        SingleRace.raceid = tonumber(args[3]);
        print(string.format('[SingleRace] Set race id to: %d', SingleRace.raceid):color(12));
        return true;
    end
    
    -- Set the desired hair..
    if (#args >= 3 and args[2] == 'hair') then
        SingleRace.hairid = tonumber(args[3]);
        print(string.format('[SingleRace] Set hair id to: %d', SingleRace.hairid):color(12));
        return true;
    end
    
    -- Pull the filter from the command..
    return true;
end );

---------------------------------------------------------------------------------------------------
-- func: incoming_packet
-- desc: Called when our addon receives an incoming packet.
---------------------------------------------------------------------------------------------------
ashita.register_event('incoming_packet', function(id, size, packet)
    -- Check for incoming character update packets..
    if (id == 0x000D) then
        local p = packet:totable();
        if (p[0x0A + 1] == 0x1F) then
            p[0x44 + 1] = SingleRace.hairid;
            p[0x45 + 1] = SingleRace.raceid;    
            return false, p;
        end
    end
    return false;
end );
