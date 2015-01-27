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

_addon.author   = 'atom0s (Originally by Sorien)';
_addon.name     = 'MacroFix';
_addon.version  = '1.0';

---------------------------------------------------------------------------------------------------
-- desc: MacroFix global table.
---------------------------------------------------------------------------------------------------
local macrofix  = 
{ 
    address1 = nil,
    address1_backup = nil,
    
    address2 = nil,
    address2_backup = nil,
    
    address3 = nil,
    address3_backup = nil,
    
    address4 = nil,
    address4_backup = nil,
    
    address5 = nil,
    address5_backup = nil,
    
    address6 = nil,
    address6_backup = nil,
};

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Local variables used for scanning..
    local sig = nil;
    local ptr = nil;
    local new = nil;
    
    -- Scan for the signatures..
    sig = { 0x83, 0xC4, 0x10, 0x84, 0xC0, 0x74, 0xFF, 0x8B, 0xCE, 0xE8, 0xFF, 0xFF, 0xFF, 0xFF, 0x84, 0xC0, 0x74, 0xFF, 0x8A, 0x46, 0x0C, 0xB9, 0xFF, 0xFF, 0xFF, 0xFF, 0x3A, 0xC3 };
    ptr = mem:FindPattern('FFXiMain.dll', sig, #sig, 'xxxxxx?xxx????xxx?xxxx????xx');
    if (ptr == 0) then error('Failed to locate critical signature #1!'); end
    macrofix.address1 = ptr + 5;
    macrofix.address1_backup = mem:ReadUChar(ptr + 5);
    mem:WriteUChar(ptr + 5, 0xEB);
 
    sig = { 0x83, 0xC4, 0x10, 0x84, 0xC0, 0x74, 0xFF, 0x8B, 0xCE, 0xE8, 0xFF, 0xFF, 0xFF, 0xFF, 0x84, 0xC0, 0x74, 0xFF, 0x80, 0x7E, 0x0C, 0x02 };
    ptr = mem:FindPattern('FFXiMain.dll', sig, #sig, 'xxxxxx?xxx????xxx?xxxx');
    if (ptr == 0) then error('Failed to locate critical signature #2!'); end
    macrofix.address2 = ptr + 5;
    macrofix.address2_backup = mem:ReadUChar(ptr + 5);
    mem:WriteUChar(ptr + 5, 0xEB);

    sig = { 0x2B, 0x46, 0x10, 0x3B, 0xC3, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x68, 0xFF, 0xFF, 0xFF, 0xFF, 0xB9 };
    ptr = mem:FindPattern('FFXiMain.dll', sig, #sig, 'xxxxx??????x????x');
    if (ptr == 0) then error('Failed to locate critical signature #3!'); end
    macrofix.address3 = ptr + 5;
    macrofix.address3_backup = mem:ReadArray(ptr + 5, 6);
    new = { 0x90, 0x90, 0x90, 0x90, 0x90, 0x90 };
    mem:WriteArray(ptr + 5, new);

    sig = { 0x2B, 0x46, 0x10, 0x3B, 0xC3, 0xFF, 0xFF, 0x68, 0xFF, 0xFF, 0xFF, 0xFF, 0xB9 };
    ptr = mem:FindPattern('FFXiMain.dll', sig, #sig, 'xxxxx??x????x');
    if (ptr == 0) then error('Failed to locate critical signature #4!'); end
    macrofix.address4 = ptr + 5;
    macrofix.address4_backup = mem:ReadArray(ptr + 5, 2);
    new = { 0x90, 0x90 };
    mem:WriteArray(ptr + 5, new);
    
    sig = { 0x83, 0xC4, 0x10, 0x84, 0xC0, 0xFF, 0xFF, 0x8B, 0xCE, 0xE8, 0xFF, 0xFF, 0xFF, 0xFF, 0x84, 0xC0, 0xFF, 0xFF, 0x8A, 0x46, 0x0C, 0x84, 0xC0, 0xFF, 0xFF, 0x8B, 0x46, 0x14, 0x85, 0xC0 };
    ptr = mem:FindPattern('FFXiMain.dll', sig, #sig, 'xxxxx??xxx????xx??xxxxx??xxxxx');
    if (ptr == 0) then error('Failed to locate critical signature #5!'); end
    macrofix.address5 = ptr + 7;
    macrofix.address5_backup = mem:ReadArray(ptr + 7, 7);
    new = { 0xE9, 0x9B, 0x00, 0x00, 0x00, 0xCC, 0xCC };
    mem:WriteArray(ptr + 7, new);
    
    -- Scan and patch last part, must be separated from the above!
    sig = { 0x83, 0xC4, 0x10, 0x84, 0xC0, 0xFF, 0xFF, 0x8B, 0xCE, 0xE8, 0xFF, 0xFF, 0xFF, 0xFF, 0x84, 0xC0, 0xFF, 0xFF, 0x8A, 0x46, 0x0C, 0x84, 0xC0, 0xFF, 0xFF, 0x8B, 0x46, 0x14, 0x85, 0xC0 };
    ptr = mem:FindPattern('FFXiMain.dll', sig, #sig, 'xxxxx??xxx????xx??xxxxx??xxxxx');
    if (ptr == 0) then error('Failed to locate critical signature #6!'); end
    macrofix.address6 = ptr + 7;
    macrofix.address6_backup = mem:ReadArray(ptr + 7, 7);
    new = { 0xE9, 0xCD, 0x00, 0x00, 0x00, 0xCC, 0xCC };
    mem:WriteArray(ptr + 7, new);
end );

---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    if (macrofix.address1 ~= nil and macrofix.address1_backup ~= nil) then
        mem:WriteUChar(macrofix.address1, macrofix.address1_backup);
    end
    if (macrofix.address2 ~= nil and macrofix.address2_backup ~= nil) then
        mem:WriteUChar(macrofix.address2, macrofix.address2_backup);
    end
    if (macrofix.address3 ~= nil and macrofix.address3_backup ~= nil) then
        mem:WriteArray(macrofix.address3, macrofix.address3_backup);
    end
    if (macrofix.address4 ~= nil and macrofix.address4_backup ~= nil) then
        mem:WriteArray(macrofix.address4, macrofix.address4_backup);
    end
    if (macrofix.address5 ~= nil and macrofix.address5_backup ~= nil) then
        mem:WriteArray(macrofix.address5, macrofix.address5_backup);
    end
    if (macrofix.address6 ~= nil and macrofix.address6_backup ~= nil) then
        mem:WriteArray(macrofix.address6, macrofix.address6_backup);
    end
end );
