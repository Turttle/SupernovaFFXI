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

local packet = { };

__ashita_libs = __ashita_libs or { };
__ashita_libs.packet = packet;

---------------------------------------------------------------------------------------------------
-- desc: Main packetgen table.
---------------------------------------------------------------------------------------------------
local packetgen = { };
packetgen.__index = packetgen;

---------------------------------------------------------------------------------------------------
-- func: Packet.new
-- desc: Creates a new packet object.
---------------------------------------------------------------------------------------------------
function packetgen.new()
    -- Adjust the metatable of this new object..
    local self = setmetatable({}, packetgen);

    -- Set some default variables..
    self._packet_id     = 0x00;
    self._packet_size   = nil;
    self._packet        = '';

    -- Return the object..
    return self;
end

---------------------------------------------------------------------------------------------------
-- func: get_id
-- desc: Gets the packet id of this packet.
---------------------------------------------------------------------------------------------------
function packetgen:get_id()
    return self._packet_id;
end

---------------------------------------------------------------------------------------------------
-- func: set_id
-- desc: Sets the packet id of this packet.
---------------------------------------------------------------------------------------------------
function packetgen:get_id(id)
    self._packet_id = id;
end

---------------------------------------------------------------------------------------------------
-- func: get_size
-- desc: Gets the packet size of this packet. (Use to hard-set the size.)
---------------------------------------------------------------------------------------------------
function packetgen:get_size()
    return self._packet_size;
end

---------------------------------------------------------------------------------------------------
-- func: set_size
-- desc: Sets the packet size of this packet. (Use to hard-set the size.)
---------------------------------------------------------------------------------------------------
function packetgen:set_size(size)
    self._packet_size = size;
end

---------------------------------------------------------------------------------------------------
-- func: push_char
-- desc: Adds a char to the packet.
---------------------------------------------------------------------------------------------------
function packetgen:push_char(value)
    self._packet = self._packet .. struct.pack('b', value);
end

---------------------------------------------------------------------------------------------------
-- func: push_uchar
-- desc: Adds a uchar to the packet.
---------------------------------------------------------------------------------------------------
function packetgen:push_uchar(value)
    self._packet = self._packet .. struct.pack('B', value);
end

---------------------------------------------------------------------------------------------------
-- func: push_short
-- desc: Adds a short to the packet.
---------------------------------------------------------------------------------------------------
function packetgen:push_short(value)
    self._packet = self._packet .. struct.pack('h', value);
end

---------------------------------------------------------------------------------------------------
-- func: push_ushort
-- desc: Adds a ushort to the packet.
---------------------------------------------------------------------------------------------------
function packetgen:push_ushort(value)
    self._packet = self._packet .. struct.pack('H', value);
end

---------------------------------------------------------------------------------------------------
-- func: push_long
-- desc: Adds a long to the packet.
---------------------------------------------------------------------------------------------------
function packetgen:push_long(value)
    self._packet = self._packet .. struct.pack('l', value);
end

---------------------------------------------------------------------------------------------------
-- func: push_ulong
-- desc: Adds a ulong to the packet.
---------------------------------------------------------------------------------------------------
function packetgen:push_ulong(value)
    self._packet = self._packet .. struct.pack('L', value);
end

---------------------------------------------------------------------------------------------------
-- func: push_float
-- desc: Adds a float to the packet.
---------------------------------------------------------------------------------------------------
function packetgen:push_float(value)
    self._packet = self._packet .. struct.pack('f', value);
end

---------------------------------------------------------------------------------------------------
-- func: push_double
-- desc: Adds a double to the packet.
---------------------------------------------------------------------------------------------------
function packetgen:push_double(value)
    self._packet = self._packet .. struct.pack('d', value);
end

---------------------------------------------------------------------------------------------------
-- func: push_string
-- desc: Adds a string to the packet.
---------------------------------------------------------------------------------------------------
function packetgen:push_string(value, size)
    -- Pack the string with 0s if needed..
    if (#value < size) then
        for x = 1, (size - #value) do
            value = value .. string.char(0);
        end
    end
    self._packet = self._packet .. struct.pack(string.format('c%d', size), value);
end

---------------------------------------------------------------------------------------------------
-- func: get_packet
-- desc: Converts the current packet data to a table.
---------------------------------------------------------------------------------------------------
function packetgen:get_packet()
    -- Generate the packet header..
    local packet_id = self._packet_id;
    local packet_size = self._packet_size or #self._packet + 4;
    local header = struct.pack('bbh', packet_id, packet_size / 2, 0);

    -- Append the packet data..
    header = header .. self._packet;

    -- Are we the proper size.. if not pack with 0's..
    if (#header < packet_size) then
        for x = 1, packet_size - #header do
            header = header .. string.char(0);
        end
    end

    -- Return the new packet table..
    return header:totable();
end

---------------------------------------------------------------------------------------------------
-- Returns the packet function table.
---------------------------------------------------------------------------------------------------
return packetgen;
