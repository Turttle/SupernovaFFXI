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

local tableex = { };

__ashita_libs = __ashita_libs or { };
__ashita_libs.tableex = tableex;

---------------------------------------------------------------------------------------------------
-- func : table.copy
-- desc : Creates a deep copy of a table.
---------------------------------------------------------------------------------------------------
function table.copy( t )
    if type( t ) ~= 'table' then return t; end
    
    local t_mt = getmetatable( t );
    local copy = { };
    
    for k, v in pairs( t ) do
        if type( v ) == 'table' then
            v = table.copy( t );
        end
        copy[ k ] = v;
    end

    setmetatable( copy, t_mt );
    return copy;
end

---------------------------------------------------------------------------------------------------
-- func : table.count
-- desc : Counts the number of entries in a table.
---------------------------------------------------------------------------------------------------
function table.count( t )
    local x = 0;
    for k, _ in pairs( t ) do
        x = x + 1;
    end
    return x;
end

---------------------------------------------------------------------------------------------------
-- func : table.haskey
-- desc : Determines if a table has the given key.
---------------------------------------------------------------------------------------------------
function table.haskey( t, key )
    for k, v in pairs( t ) do
        if k == key then return true; end
    end
    return false;
end

---------------------------------------------------------------------------------------------------
-- func : table.hasvalue
-- desc : Determines if a table has the given value.
---------------------------------------------------------------------------------------------------
function table.hasvalue( t, val )
    for k, v in pairs( t ) do
        if v == val then return true; end
    end
    return false;
end

---------------------------------------------------------------------------------------------------
-- func : table.merge
-- desc : Merges two tables together.
---------------------------------------------------------------------------------------------------
function table.merge(src, dest)
    for k, v in pairs(src) do
        if (type(v) == 'table') then
            if (dest[k] == nil) then
                dest[k] = v;
            else
                table.merge(v, dest[k]);
            end
        else
            if (dest[k] == nil) then
                dest[k] = v;
            end
        end
    end
    return dest;
end

---------------------------------------------------------------------------------------------------
-- func : table.nil
-- desc : Terminate all values in a table.
---------------------------------------------------------------------------------------------------
function table.Nil( t )
    for k, v in pairs( t ) do
        t[ k ] = nil;
    end
end

---------------------------------------------------------------------------------------------------
-- func : table.Reverse
-- desc : Reverses a table.
---------------------------------------------------------------------------------------------------
function table.reverse( t )
    local len = #t;
    local ret = { };
    
    for x = len, 1, -1 do
        ret[ len - x + 1 ] = t[ x ];
    end
    return ret;
end

---------------------------------------------------------------------------------------------------
-- func : table.sortbykey
-- desc : Sorts a table by its keys, in the given order.
---------------------------------------------------------------------------------------------------
function table.sortbykey( t, desc )
    local temp = { };
    for k, _ in pairs( t ) do table.insert( temp, k ); end
    
    if desc then 
        table.sort( temp, function( a, b ) return t[ a ] < t[ b ] end );
    else 
        table.sort( temp, function( a, b ) return t[ a ] > t[ b ] end ); 
    end
    
    return temp;    
end

---------------------------------------------------------------------------------------------------
-- func : table.sum
-- desc : Adds all numerical values found in the table together and returns the result.
---------------------------------------------------------------------------------------------------
function table.sum( t )
    local ret = 0;
    for k, v in ipairs(t) do
        if (type(v) == 'number') then
            ret = ret + v;
        end
    end
    return ret;
end

---------------------------------------------------------------------------------------------------
-- func : table.mult
-- desc : Multiplies all numerical values found in the table together and returns the result.
---------------------------------------------------------------------------------------------------
function table.mult( t )
    local ret = 1;
    for k, v in ipairs(t) do
        if (type(v) == 'number') then
            ret = ret * v;
        end
    end
    return ret;
end

---------------------------------------------------------------------------------------------------
-- func : table.min
-- desc : Returns the lowest found numerical value in the main table.
---------------------------------------------------------------------------------------------------
function table.min( t )
    local ret = nil;
    for k, v in ipairs(t) do
        if (type(v) == 'number') then
            if (ret == nil) then
                ret = v;
            else
                if (v < ret) then
                    ret = v;
                end
            end
        end
    end
    return ret;
end

---------------------------------------------------------------------------------------------------
-- func : table.max
-- desc : Returns the highest found numerical value in the main table.
---------------------------------------------------------------------------------------------------
function table.max( t )
    local ret = nil;
    for k, v in ipairs(t) do
        if (type(v) == 'number') then
            if (ret == nil) then
                ret = v;
            else
                if (v > ret) then
                    ret = v;
                end
            end
        end
    end
    return ret;
end
