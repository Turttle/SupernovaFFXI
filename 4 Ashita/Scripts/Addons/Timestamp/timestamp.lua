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
_addon.name     = 'Timestamp';
_addon.version  = '1.0';

require 'common'

---------------------------------------------------------------------------------------------------
-- desc: Default Timestamp configuration table.
---------------------------------------------------------------------------------------------------
local default_config =
{
    color           = 200,
    format          = '%H:%M:%S',
    open_bracket    = '[',
    close_bracket   = ']'
};
local timestamp_config = default_config;

---------------------------------------------------------------------------------------------------
-- desc: Main Timestamp table.
---------------------------------------------------------------------------------------------------
local timestamp = 
{ 
    last_mode = 0,
};

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Attempt to load the timestamp configuration..
    timestamp_config = settings:load(_addon.path .. 'settings/timestamp.json') or default_config;
    timestamp_config = table.merge(default_config, timestamp_config);
end );

---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    -- Save the configuration..
    settings:save(_addon.path .. 'settings/timestamp.json', timestamp_config);
end );

---------------------------------------------------------------------------------------------------
-- func: newchat
-- desc: Called when our addon receives a chat line.
---------------------------------------------------------------------------------------------------
ashita.register_event('newchat', function(mode, chat)
    -- Prevent double injection on npc chat..
    if (chat:byte(1, 1) == 0x1E) then
        return false;
    end
    
    -- Skip linkshell messages and server messages..
    if (timestamp.last_mode == mode and (mode == 0x00C8 or mode == 0x03CD)) then
        timestamp.last_mode = -1;
        return false;
    end
    
    -- Modes to ignore..
    local ignoreModes = 
    {
        600, 702, 909, 919, -- Synergy..
    };
    
    for k, v in pairs(ignoreModes) do
        if (v == mode) then
            timestamp.last_mode = -1;
            return false;
        end
    end
    
    timestamp.last_mode = mode;

    -- Generate the timestamp..
    local timestamp = os.date(timestamp_config.open_bracket .. timestamp_config.format .. timestamp_config.close_bracket):color(timestamp_config.color);
    
    -- Create the new chat line..
    local newline = timestamp .. ' ' .. chat;

    -- Return the new chat line..
    return false, newline;
end );
