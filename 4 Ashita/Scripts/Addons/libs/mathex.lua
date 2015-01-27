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

local mathex = { };

__ashita_libs = __ashita_libs or { };
__ashita_libs.mathex = mathex;

----------------------------------------------------------------------
-- func : math.Distance2D
-- desc : Determines the 2D distance between two objects.
-- retn : 2D distance between the two objects.
----------------------------------------------------------------------
function math.Distance2D( x1, y1, x2, y2 )
    local x = x2 - x1;
    local y = y2 - y1;
    return math.sqrt( (x * x) + (y * y) );
end

----------------------------------------------------------------------
-- func : math.Distance3D
-- desc : Determines the 3D distance between two objects.
-- retn : 3D distance between the two objects.
----------------------------------------------------------------------
function math.Distance3D( x1, y1, z1, x2, y2, z2 )
    local x = x2 - x1;
    local y = y2 - y1;
    local z = z2 - z1;
    return math.sqrt( (x * x) + (y * y) + (z * z) );
end

----------------------------------------------------------------------
-- func : math.DegreeToRadian
-- desc : Converts the given FFXi Degree to a Radian.
-- retn : Radian of the given degree.
-- note : This function expects a FFXi base degree. FFXi does not
--        handle radians properly and instead of starting at 0 degrees
--        for north, FFXi starts at -90.
----------------------------------------------------------------------
function math.DegreeToRadian( deg )
    local pi = 3.14159265359;
    return deg * ( pi / 180 );
end

----------------------------------------------------------------------
-- func : math.RadianToDegree
-- desc : Converts the given FFXi Radian to a Degree.
-- retn : Degree of the given Radian.
-- note : This function expects a FFXi base radian. FFXi does not
--        handle radians properly and instead of starting at 0 degrees
--        for north, FFXi starts at -90.
----------------------------------------------------------------------
function math.RadianToDegree( rad )
    local pi = 3.14159265359;
    return rad * ( 180 / pi );
end

----------------------------------------------------------------------
-- func : math.Clamp
-- desc : Clamps a number to the given low and high bounds.
-- retn : Clamped result.
----------------------------------------------------------------------
function math.Clamp( num, l, h )
    if (num < l) then return l; end;
    if (num > h) then return h; end;
    return num;
end

----------------------------------------------------------------------
-- func : math.Round
-- desc : Rounds the given number to the given decimal places.
-- retn : Rounded result.
----------------------------------------------------------------------
function math.Round( num, dp )
    local mult = 10 ^ ( dp or 0 );
    return math.floor( num * mult + 0.5 ) / mult;
end

----------------------------------------------------------------------
-- func : math.ToD3DColor
-- desc : Converts the given arguments into a D3DCOLOR.
-- retn : Color.
----------------------------------------------------------------------
function math.ToD3DColor( a, r, g, b )
    local a = bit.lshift(bit.band(a, 0xFF), 24);
    local r = bit.lshift(bit.band(r, 0xFF), 16);
    local g = bit.lshift(bit.band(g, 0xFF), 08);
    local b = bit.band(b, 0xFF);
    
    return bit.bor(bit.bor(a, r), bit.bor(g, b));
end