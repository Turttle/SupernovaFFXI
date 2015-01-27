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
_addon.name     = 'MapDot';
_addon.version  = '1.1';

---------------------------------------------------------------------------------------------------
-- desc: MapDot global table.
---------------------------------------------------------------------------------------------------
local mapdot    = { };

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Scan for the needed signature..
    local sig = { 0xA1, 0xFF, 0xFF, 0xFF, 0xFF, 0x85, 0xC0, 0x74, 0xFF, 0xD9, 0x44, 0x24, 0x04, 0xD8, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x4C, 0x24, 0x04 };
    local ptr = mem:FindPattern('FFXiMain.dll', sig, #sig, 'x????xxx?xxxxxx????xxxx');
    
    -- Ensure the pointer is valid..
    if (ptr == 0) then
        print('\30\105[MapDot] (ERROR) Failed to find required signature; cannot load!');
        return;
    end
    
    -- Store the map pointer..
    mapdot.main_ptr = ptr;
    
    -- Read the patch location memory for backup..
    mapdot.backup = mem:ReadArray(ptr + 0x34, 3);
    
    -- Patch the location..
    local data = { 0x90, 0x90, 0x90 };
    mem:WriteArray(ptr + 0x34, data);
    
    -- Set the map to always show dots..
    local map = mem:ReadLong(ptr + 1);
    if (map == 0) then
        return;
    end
    
    -- Ensure the pointer is valid..
    map = mem:ReadLong(map);
    if (map == 0) then
        return;
    end
    
    mem:WriteUChar(map + 0x2F, 1);
    mapdot.showdots = true;
end );

---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    -- Undo patch..
    if (mapdot.backup ~= nil) then
        mem:WriteArray(mapdot.main_ptr + 0x34, mapdot.backup);
        mapdot.main_ptr = 0;
    end
end );

---------------------------------------------------------------------------------------------------
-- func: render
-- desc: Called when our addon is told to render.
---------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    -- Ensure we have not already set the dot setting..
    if (mapdot.main_ptr == 0 or mapdot.showdots == true) then
        return;
    end

    -- Set the map to always show dots..
    local map = mem:ReadLong(mapdot.main_ptr + 1);
    if (map == 0) then
        return;
    end
    
    -- Ensure the pointer is valid..
    map = mem:ReadLong(map);
    if (map == 0) then
        return;
    end
    
    mem:WriteUChar(map + 0x2F, 1);
    mapdot.showdots = true;
end );
