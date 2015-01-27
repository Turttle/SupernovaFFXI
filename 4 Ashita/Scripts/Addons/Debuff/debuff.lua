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
_addon.name     = 'Debuff';
_addon.version  = '1.0';

require 'common'

---------------------------------------------------------------------------------------------------
-- func: command
-- desc: Called when our addon receives a command.
---------------------------------------------------------------------------------------------------
ashita.register_event('command', function(cmd, nType)    
    -- Ensure we should handle this command..
    local args = cmd:GetArgs();
    if (args[1] ~= '/debuff' and args[1] ~= '/cancel') then
        return false;
    end
    
    -- Ensure we have enough arguments..
    if (#args ~= 2) then
        return true;
    end
    
    -- Obtain the buff id..
    local buffid = tonumber(args[2]);
    
    -- Rebuild and send debuff packet..
    local debuff = struct.pack("bbbbhbb", 0xF1, 0x04, 0x00, 0x00, buffid, 0x00, 0x00):totable();
    AddOutgoingPacket(debuff, 0xF1, #debuff);
        
    return false;
end );
