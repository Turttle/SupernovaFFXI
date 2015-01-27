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

local stringex = { };

__ashita_libs = __ashita_libs or { };
__ashita_libs.stringex = stringex;

---------------------------------------------------------------------------------------------------
-- func : string.Contains
-- desc : Determines if the string contains the given string.
---------------------------------------------------------------------------------------------------
function string.contains( s, p )
    return s:find(p, nil, true) ~= nil;
end

---------------------------------------------------------------------------------------------------
-- func : string.startswith
-- desc : Determines if the string starts with the given second string.
---------------------------------------------------------------------------------------------------
function string.startswith( s, s2 )
    return s:sub( 1, #s2 ) == s2;
end

---------------------------------------------------------------------------------------------------
-- func : string.endswith
-- desc : Determines if the string ends with the given second string.
---------------------------------------------------------------------------------------------------
function string.endswith( s, s2 )
    return s:sub( -#s2 ) == s2;
end

---------------------------------------------------------------------------------------------------
-- func : string.upperfirst
-- desc : Capitalizes the first character of the given string.
---------------------------------------------------------------------------------------------------
function string.upperfirst( s )
    return s:sub(1, 1):upper() .. s:sub(2);
end

---------------------------------------------------------------------------------------------------
-- func : string.topropercase
-- desc : Converts the first character of every word to capital.
---------------------------------------------------------------------------------------------------
function string.topropercase( s )
    local ret = '';
    local t = { };
    for x = 1, s:len() do
        t[x] = s:sub(x, x);
        if (t[x-1] == ' ' or x == 1) then
            t[x] = t[x]:upperfirst();
        end
        ret = ret .. t[x];
    end
    return ret;
end

---------------------------------------------------------------------------------------------------
-- func : string.insert
-- desc : Inserts the given string into the given position.
---------------------------------------------------------------------------------------------------
function string.insert( s, p, s2 )
    local part1 = s:sub( 1, p - 1 );
    return part1 .. s2 .. s:sub( #part1 + 1);
end

---------------------------------------------------------------------------------------------------
-- func : string.remove
-- desc : Removes the character at the given index.
---------------------------------------------------------------------------------------------------
function string.remove(s, index)
    return s:sub(0, index - 1) .. s:sub(index + 1);
end

---------------------------------------------------------------------------------------------------
-- func : string.lpad
-- desc : Pads the first string with the second on the left til the length is met.
---------------------------------------------------------------------------------------------------
function string.lpad( s, s2, n )
    return (s2:rep(n) .. s):sub(-(n > #s and n or #s));
end

---------------------------------------------------------------------------------------------------
-- func : string.rpad
-- desc : Pads the first string with the second on the right til the length is met.
---------------------------------------------------------------------------------------------------
function string.rpad( s, s2, n )
    return (s .. s2:rep(n)):sub(1, -(n > #s and n or #s));
end

---------------------------------------------------------------------------------------------------
-- func : string.hex
-- desc : Converts the given string to a hex string of each character.
---------------------------------------------------------------------------------------------------
function string.hex( s, sep )
    sep = sep or ' ';
    local ret = '';
    for k, v in pairs(s:totable()) do
        ret = ret .. string.format('%02X', v) .. sep;
    end
    return ret:trim();
end

---------------------------------------------------------------------------------------------------
-- func : string.fromhex
-- desc : Converts the given hex string to its text format.
---------------------------------------------------------------------------------------------------
function string.fromhex(s)
    s = s:gsub('%s*0x', ''):gsub('[^%w]', '');
    return (s:gsub('%w%w', function(c) return string.char(tonumber(c, 16)); end));
end

---------------------------------------------------------------------------------------------------
-- func : string.ToTable
-- desc : Converts the string chars to a byte table.
---------------------------------------------------------------------------------------------------
function string.totable( s )
    local t = { };
    for x = 1, string.len( s ) do
        t[x] = string.byte( s, x );
    end
    return t
end

---------------------------------------------------------------------------------------------------
-- func : string.clean
-- desc : Cleans the whitespace of a string.
---------------------------------------------------------------------------------------------------
function string.clean( s, trimend )
    if trimend == nil then trimend = true; end

    if trimend then
        return s:gsub('%s+', ' '):trim();
    else
        return (s:gsub('%s+', ' '));
    end
end

---------------------------------------------------------------------------------------------------
-- func : string.TrimStart
-- desc : Trims whitespace from the left side of the string.
---------------------------------------------------------------------------------------------------
function string.trimstart( s, char )
    if (not char) then char = ' ' end
    s = string.reverse( s );
    s = string.trimend( s, char );
    return string.reverse( s );
end

---------------------------------------------------------------------------------------------------
-- func : string.TrimEnd
-- desc : Trims whitespace from the right side of the string.
---------------------------------------------------------------------------------------------------
function string.trimend( s, char )
    if (not char) then char = ' ' end
    if (string.sub( s, -1 ) == char) then
        s = string.sub( s, 0, -2 );
        s = string.trimend( s, char );
    end
    return s;
end

---------------------------------------------------------------------------------------------------
-- func : string.trim
-- desc : Trims whitespace from both sides of the given string.
---------------------------------------------------------------------------------------------------
function string.trim( s, char )
    if (not char) then char = ' ' end
    s = string.trimstart( s, char );
    s = string.trimend( s, char );
    return s;
end

---------------------------------------------------------------------------------------------------
-- func : string.GetArgs
-- desc : Parses the string for command arguments.
---------------------------------------------------------------------------------------------------
function string:GetArgs()
    local STATE_NONE 	= 0;
    local STATE_WORD 	= 1;
    local STATE_QUOTE 	= 2;

    local currentState 	= STATE_NONE;
    local currentChar 	= nil;
    local nextChar 		= nil;
    local stringStart 	= nil;
    local args 			= { };

    for x = 1, string.len(self) do
        -- Read the current character..
        currentChar = string.sub( self, x, x );
        nextChar 	= string.sub( self, x+1, x+1 );

        -- Current state is nothing..
        if currentState == STATE_NONE then
            if (currentChar == '"') then
                stringStart = x+1;
                currentState = STATE_QUOTE;
            else
                if (currentChar ~= ' ') then
                    stringStart = x;
                    currentState = STATE_WORD;
                end
            end

        -- Current state is a string..
        elseif currentState == STATE_QUOTE then
            if (currentChar == '"') then
                currentState = STATE_NONE;
                table.insert( args, #args+1, string.sub( self, stringStart, x - 1 ) );
            end

        -- Current state is a word..
        elseif currentState == STATE_WORD then
            if (currentChar == ' ' or nextChar == nil or nextChar == '\0') then
                currentState = STATE_NONE;
                table.insert( args, #args+1, string.sub( self, stringStart, x - 1 ) );
            end

        -- Current state is invalid..
        else
            print( "UNKNOWN ERROR" );
        end
    end

    -- Catch last word argument..
    if (currentState == STATE_WORD) then
        table.insert( args, #args+1, string.sub( self, stringStart, #self + 1 ) );
    end

    -- Return argument table..
    return args;
end

---------------------------------------------------------------------------------------------------
-- func : string:IsQuotedArg
-- desc : Determines if this is a quoted command argument.
-- retn : First value returned: True if this is a quoted argument, else False.
--        Second value returned: The text within quotes (including an empty string).
--        If it's not quoted text, the second value will be nil.
---------------------------------------------------------------------------------------------------
function string:IsQuotedArg()
    local arg = string.match( self, "^\"(.*)\"$" );
    return ( arg ~= nil ), arg
end

---------------------------------------------------------------------------------------------------
-- func : string.ParseArgs
-- desc : Parses the string for command arguments.
-- retn : Table of found arguments.
--
-- note : Modified version of GetArgs to read and parse non-standard
--        game cmomands.
---------------------------------------------------------------------------------------------------
function string:ParseArgs()
    local STATE_NONE    = 0;
    local STATE_WORD    = 1;
    local STATE_QUOTE   = 2;

    local currentState  = STATE_NONE;
    local currentChar   = nil;
    local nextChar      = nil;
    local stringStart   = nil;
    local prefix        = nil;
    local args          = { };

    for x = 1, string.len(self) do
        -- Read the current character..
        currentChar = string.sub( self, x, x );
        nextChar    = string.sub( self, x+1, x+1 );

        -- If the line doesn't start with a /, it's not a command to be parsed,
        -- but rather text that will be put into chat.
        -- Return nil.
        if (x == 1 and currentChar ~= '/') then
            return nil;
        end

        -- Current state is nothing..
        if currentState == STATE_NONE then
            if (currentChar == '"') then
                stringStart = x;
                currentState = STATE_QUOTE;
            elseif (currentChar ~= ' ') then
                stringStart = x;
                currentState = STATE_WORD;
            end

        -- Current state is a string..
        elseif currentState == STATE_QUOTE then
            if (currentChar == '"') then
                table.insert( args, #args+1, string.sub( self, stringStart, x ) );
                currentState = STATE_NONE;
            end

        -- Current state is a word..
        elseif currentState == STATE_WORD then
            if (currentChar == ' ') then
                table.insert( args, #args+1, string.sub( self, stringStart, x - 1 ) );
                if (prefix == nil) then
                    prefix = args[#args];
                end
                currentState = STATE_NONE;
            elseif (nextChar == nil or nextChar == '\0') then
                -- This section never actually seems to get hit during processing.
                -- Regardless, it needs to use a different endpoint than the block above.
                table.insert( args, #args+1, string.sub( self, stringStart, x ) );
                if (prefix == nil) then
                    prefix = args[#args];
                end
                currentState = STATE_NONE;
            elseif (prefix == nil and currentChar == '/' and x == (stringStart+1)) then
                -- If command line starts with //, put that in its own argument field
                table.insert( args, #args+1, string.sub( self, stringStart, x ) );
                prefix = args[#args];
                currentState = STATE_NONE;
            elseif (currentChar == '"') then
                -- A quote mark should start a new quote arg, even if there is no space delimiter.
                table.insert( args, #args+1, string.sub( self, stringStart, x - 1 ) );
                currentState = STATE_QUOTE;
                stringStart = x;
            end

        -- Current state is invalid..
        else
            print( "UNKNOWN ERROR" );
        end
    end

    -- Catch last word argument..
    if (currentState == STATE_WORD) then
        table.insert( args, #args+1, string.sub( self, stringStart, #self ) );
    end

    -- Any unclosed quote arg is discarded.

    -- Return argument table..
    return args;
end
