--[[
 *
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
 *
]]--

local color = { };

__ashita_libs = __ashita_libs or { };
__ashita_libs.color = color;

---------------------------------------------------------------------------------------------------
-- func: get_ffxi_color
-- desc: Converts the given number to its proper FFXI color code.
---------------------------------------------------------------------------------------------------
function get_ffxi_color(color)
    if ((type(color) ~= 'number') or color <= 0 or color > 0x1FF) then
        return color;
    elseif color <= 0xFF then
        return string.char(0x1F) .. string.char(color);
    else
        return string.char(0x1E) .. string.char(color);
    end
end

---------------------------------------------------------------------------------------------------
-- func: string.color
-- desc: Creates a colored string for the FFXI chat log.
---------------------------------------------------------------------------------------------------
function string.color( s, c, r )
    r = r or string.char(0x1E) .. string.char(0x01);
    r = get_ffxi_color(r);
    c = get_ffxi_color(c);
    
    if (c == '') then
        return s;
    end
    
    return c .. s .. r;
end

---------------------------------------------------------------------------------------------------
-- func: string.stripcolor
-- desc: Strips FFXI color tags from a string.
---------------------------------------------------------------------------------------------------
function string.stripcolor( s )
    return (s:gsub('[\30\31].', ''));
end

---------------------------------------------------------------------------------------------------
-- func: string.stripautotrans
-- desc: Strips FFXI auto-translaate tags from a string.
---------------------------------------------------------------------------------------------------
function string.stripautotrans( s )
    s = (s:gsub(string.char(0xEF)..'['..string.char(0x27, 0x28)..']', ''));
    return (s:gsub(string.char(0xFD)..'....'..string.char(0xFD), ''));
end
