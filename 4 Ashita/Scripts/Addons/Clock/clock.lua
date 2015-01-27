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
_addon.name     = 'Clock';
_addon.version  = '1.0';

require 'common'
require 'date'

---------------------------------------------------------------------------------------------------
-- desc: Default Clock configuration table.
---------------------------------------------------------------------------------------------------
local default_config =
{
    color           = { 255, 255, 255, 255},
    format          = '[%I:%M:%S]',
    separator       = ' - ',

    clocks =
    {
    }
};
local clock_config = default_config;

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Attempt to load the timestamp configuration..
    clock_config = settings:load(_addon.path .. 'settings/clock.json') or default_config;
    clock_config = table.merge(default_config, clock_config);
    
    local c = clock_config.color;
    
    -- Create the clock font object..
    local f = AshitaCore:GetFontManager():CreateFontObject('__clock_addon');
    f:SetBold(false);
    f:SetColor(math.ToD3DColor(c[1], c[2], c[3], c[4]));
    f:SetFont('Tahoma', 10);
    f:SetPosition(700, 1);
    f:SetRightJustified(false);
    f:SetText('');
    f:SetVisibility( true );
    f:GetBackground():SetVisibility(true);
    f:GetBackground():SetColor(0x80000000);
end );

---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    -- Cleanup our font object..
    AshitaCore:GetFontManager():DeleteFontObject('__clock_addon');
    
    -- Save the configuration..
    settings:save(_addon.path .. 'settings/clock.json', clock_config);
end );

---------------------------------------------------------------------------------------------------
-- func: command
-- desc: Called when our addon receives a command.
---------------------------------------------------------------------------------------------------
ashita.register_event('command', function(cmd, nType)    
    -- Ensure we should handle this command..
    local args = cmd:GetArgs();
    if (args[1] ~= '/time') then
        return false;
    end
    
    -- Adds a new timer to the list..
    if (#args == 4 and args[2] == 'add') then
        local offset = tonumber(args[3]);
        local name = args[4];
        
        table.insert(clock_config.clocks, { offset, name });
        return true;
    end
    
    -- Deletes an existing timer from the list..
    if (#args == 3 and args[2] == 'delete') then
        local offset = tonumber(args[3]);
        
        -- Loop the current table and delete all matching offsets..
        for x = #clock_config.clocks, 1, -1 do
            if (clock_config.clocks[x][1] == offset) then
                table.remove(clock_config.clocks, x);
            end
        end
        return true;
    end
    
    -- Sets the separator for the timestamp objects..
    if (#args == 3 and args[2] == 'separator') then
        clock_config.separator = args[3];
        return true;
    end
    
    -- Sets the color for the timestamp objects..
    if (#args == 6 and args[2] == 'color') then
        clock_config.color[1] = tonumber(args[3]);
        clock_config.color[2] = tonumber(args[4]);
        clock_config.color[3] = tonumber(args[5]);
        clock_config.color[4] = tonumber(args[6]);
        local f = AshitaCore:GetFontManager():CreateFontObject('__clock_addon');
        local c = clock_config.color;
        f:SetColor(math.ToD3DColor(c[1], c[2], c[3], c[4]));
        return true;
    end
    
    -- Print out the addon usage..
    log_message('Invalid syntax for command: \'/time\'');
    log_message('/time add <offset> <name>');
    log_message('/time delete <offset>');
    log_message('/time separator <separator>');
    log_message('/time color a r g b');
    return true;
end );

---------------------------------------------------------------------------------------------------
-- func: render
-- desc: Called when our addon is rendered.
---------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    -- Obtain the font object..
    local f = AshitaCore:GetFontManager():CreateFontObject('__clock_addon');
    
    -- Ensure we have a clock table..
    if (clock_config.clocks == nil or type(clock_config.clocks) ~= 'table') then
        return;
    end

    -- Build the table of timestamps..
    local timestamps = { };
    for k, v in pairs(clock_config.clocks) do
        local offset = tonumber(v[1]);
        if (offset == 0) then
            table.insert(timestamps, os.date(date():toutc():fmt(string.format('%s %s', clock_config.format, v[2]))));
        else
            table.insert(timestamps, os.date(date():toutc():addhours(offset):fmt(string.format('%s %s', clock_config.format, v[2]))));
        end
    end

    f:SetText(table.concat(timestamps, clock_config.separator));
end );
