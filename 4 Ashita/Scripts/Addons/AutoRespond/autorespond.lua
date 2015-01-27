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
_addon.name     = 'AutoRespond';
_addon.version  = '1.0';

require 'common'

---------------------------------------------------------------------------------------------------
-- desc: Local Auto Respond data.
---------------------------------------------------------------------------------------------------
local autorespond_data = 
{
    isafk   = false,
    message = "I'm currently AFK!"
};

---------------------------------------------------------------------------------------------------
-- func: get_tell_name
-- desc: Gets the sender name from the packet.
---------------------------------------------------------------------------------------------------
local function get_tell_name(packet)
    local str = '';
    for x = 9, 30 do
        if (packet[x] == 0) then
            break;
        end
        str = str .. string.char(packet[x]);
    end
    return str;
end


---------------------------------------------------------------------------------------------------
-- func: command
-- desc: Called when our addon receives a command.
---------------------------------------------------------------------------------------------------
ashita.register_event('command', function(cmd, nType)
    local args = cmd:GetArgs();
    
    -- Handle the afk command..
    if (#args > 2 and args[1] == '/afk' and args[2] == 'message')  then
        autorespond_data.message = cmd:sub(cmd:find(" ", cmd:find(" ") + 1) + 1);
        return true;
    end
    if (args[1] == '/afk') then
        autorespond_data.isafk = not autorespond_data.isafk;
        print(string.format('[AutoRespond] Auto-afk status: %s', tostring(autorespond_data.isafk)));
        return true;
    end
    
    return false;
end);

---------------------------------------------------------------------------------------------------
-- func: Render
-- desc: Called when our addon is rendered.
---------------------------------------------------------------------------------------------------
ashita.register_event('incoming_packet', function(id, size, packet)
    if (id == 0x17) then
        local p = packet:totable();
        if (p[5] == 0x03 and autorespond_data.isafk == true) then
            AshitaCore:GetChatManager():ParseCommand(string.format('/tell %s %s', get_tell_name(p), autorespond_data.message), 1);
        end
    end
    return false;
end);
