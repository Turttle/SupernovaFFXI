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
_addon.name     = 'IME';
_addon.version  = '1.0';

require 'common'

---------------------------------------------------------------------------------------------------
-- desc: Main IME table to hold useful variables.
---------------------------------------------------------------------------------------------------
local ime = 
{
    -- Signature for the IME bar visibility..
    bar_visible_signature   = { 0x83, 0xEC, 0x08, 0xA1, 0xFF, 0xFF, 0xFF, 0xFF, 0x53, 0x33, 0xDB, 0x56 },
    bar_visible_mask        = 'xxxx????xxxx',
    bar_visible_offset      = 0x2F,
    bar_visible_ptr         = 0,

    -- Signature for the IME bar usage (green text adjustments etc.)..
    bar_usage_signature     = { 0x8B, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF, 0x81, 0xEC, 0x04, 0x01, 0x00, 0x00, 0x53, 0x56, 0x8B },
    bar_usage_mask          = 'xx????xxxxxxxxx',
    bar_usage_offset1       = 0xC11C,
    bar_usage_offset2       = 0xC13C,
    bar_usage_ptr           = 0,
    
    -- The last time our addon attempted to apply the IME fixes in case the game undoes our changes..
    last_update_check       = 0,
};

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Locate the IME bar visibility function..
    local bar_visible = mem:FindPattern('FFXiMain.dll', ime.bar_visible_signature, #ime.bar_visible_signature, ime.bar_visible_mask);
    if (bar_visible == nil or bar_visible == 0) then
        print('[IME] Failed to locate required function: IMEBarVisible');
        return false;
    end
    ime.bar_visible_ptr = bar_visible + ime.bar_visible_offset;
    
    -- Ensure we have the proper instruction to replace..
    if (mem:ReadUChar(ime.bar_visible_ptr) ~= 0x74) then
        print('[IME] Failed to locate required function: IMEBarVisible -- Offset appears wrong!');
        return false;
    end

    -- Locate the IME bar usage function..
    local bar_usage = mem:FindPattern('FFXiMain.dll', ime.bar_usage_signature, #ime.bar_usage_signature, ime.bar_usage_mask);
    if (bar_usage == nil or bar_usage == 0) then
        print('[IME] Failed to locate required function: IMEBarUsage');
        return false;
    end
    ime.bar_usage_ptr = bar_usage + 2;
    ime.bar_usage_ptr = mem:ReadULong(ime.bar_usage_ptr); 
end );

---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    -- Restore our patch for the IME visibility..
    if (ime.bar_visible_ptr ~= nil and ime.bar_visible_ptr ~= 0) then
        mem:WriteUChar(ime.bar_visible_ptr, 0x74);
    end
    
    -- Restore the IME usage variables..
    local ptr = mem:ReadULong(ime.bar_usage_ptr);
    if (ptr == nil or ptr == 0) then
        print('[IME] Failed to read bar usage pointer, cannot apply needed fixes! (1)');
    else
        ptr = mem:ReadULong(ime.bar_usage_ptr);
        if (ptr == nil or ptr == 0) then
            print('[IME] Failed to read bar usage pointer, cannot apply needed fixes! (2)');
        else
            mem:WriteUChar(ptr + ime.bar_usage_offset1, 1);
            mem:WriteUChar(ptr + ime.bar_usage_offset2, 1);
        end
    end
end );

---------------------------------------------------------------------------------------------------
-- func: render
-- desc: Called when our addon is rendered.
---------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    -- Ensure we have valid pointers..
    if (ime.bar_visible_ptr == 0 or ime.bar_visible_ptr == nil or
        ime.bar_usage_ptr == 0 or ime.bar_usage_ptr == nil) then
        return;
    end

    -- Ensure our patches are applied every 5 seconds..
    if (ime.last_update_check <= (os.clock() - 5)) then
        -- Store the current update check time..
        ime.last_update_check = os.clock();
        
        -- Ensure our patch for the IME visibility is set..
        -- Patch: JE -> JMP
        if (mem:ReadUChar(ime.bar_visible_ptr) == 0x74) then
            mem:WriteUChar(ime.bar_visible_ptr, 0xEB);
        end
        
        -- Ensure the game allows us to use the IME bar..
        local ptr = mem:ReadULong(ime.bar_usage_ptr);
        if (ptr == nil or ptr == 0) then
            print('[IME] Failed to read bar usage pointer, cannot apply needed fixes! (1)');
        else
            ptr = mem:ReadULong(ime.bar_usage_ptr);
            if (ptr == nil or ptr == 0) then
                print('[IME] Failed to read bar usage pointer, cannot apply needed fixes! (2)');
            else
                mem:WriteUChar(ptr + ime.bar_usage_offset1, 0);
                mem:WriteUChar(ptr + ime.bar_usage_offset2, 0);
            end
        end
    end
end );
