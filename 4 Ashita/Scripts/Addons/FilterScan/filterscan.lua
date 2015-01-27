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
_addon.name     = 'FilterScan';
_addon.version  = '1.0';

require 'common'
require 'mobparse'

---------------------------------------------------------------------------------------------------
-- desc: Filter Scan Main Table
---------------------------------------------------------------------------------------------------
local FilterScan = 
{
    FFXiPath    = [[C:\\Program Files (x86)\\Steam\\steamapps\\common\\ffxi\\SquareEnix\\FINAL FANTASY XI\\]],
    MobList     = { },
    ZoneDatList = require('zonemoblist'),
    Filter      = ''
};

---------------------------------------------------------------------------------------------------
-- func: UpdateZoneMobList
-- desc: Updates the zone mob list.
---------------------------------------------------------------------------------------------------
local function UpdateZoneMobList(zoneId)
    -- Attempt to get the dat file for this entry..
    local dat = FilterScan.ZoneDatList[zoneId];
    if (dat == nil) then
        FilterScan.MobList = { };
        return false;
    end

    -- Attempt to parse the dat file..
    FilterScan.MobList = ParseZoneMobDat(FilterScan.FFXiPath .. dat);
    return true;
end

---------------------------------------------------------------------------------------------------
-- func: MobNameFromTargetId
-- desc: Returns the mob name from the given target id.
---------------------------------------------------------------------------------------------------
local function MobNameFromTargetId(targId)
    for _, v in pairs(FilterScan.MobList) do
        if (v[1] == targId) then
            return v[2];
        end
    end
    return nil;
end

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Parse the players current zone if we are in-game..
    if (AshitaCore:GetDataManager():GetParty():GetPartyMemberActive(0)) then
        local zoneId = AshitaCore:GetDataManager():GetParty():GetPartyMemberZone(0);
        UpdateZoneMobList(zoneId);
    end    
end );

---------------------------------------------------------------------------------------------------
-- func: Command
-- desc: Called when our addon receives a command.
---------------------------------------------------------------------------------------------------
ashita.register_event('command', function(cmd, nType)
    -- Ensure we should handle this command..
    local args = cmd:GetArgs();
    if (args[1] ~= '/filterscan') then
        return false;
    end
    
    -- Pull the filter from the command..
    FilterScan.Filter = (string.gsub(cmd, '/filterscan', '')):trim()
    print(string.format('[FilterScan] set new filter to: %s', FilterScan.Filter));
    return true;
end );

---------------------------------------------------------------------------------------------------
-- func: incoming_packet
-- desc: Called when our addon receives an incoming packet.
---------------------------------------------------------------------------------------------------
ashita.register_event('incoming_packet', function(id, size, packet)
    -- Check for zone-in packets..
    if (id == 0x0A) then
        -- Are we zoning into a mog house..
        if (struct.unpack('b', packet, 0x80 + 1) == 1) then
            return false;
        end
    
        -- Pull the zone id from the packet..
        local zoneId = struct.unpack('H', packet, 0x30 + 1);
        if (zoneId == 0) then
            zoneId = struct.unpack('H', packet, 0x42 + 1);
        end
        
        -- Update our mob list..
        UpdateZoneMobList(zoneId);
    end
    
    -- Check for widescan packets..
    if (id == 0x00F4) then
        local mobTargId = struct.unpack('H', packet, 0x04 + 1);
        local mobName   = MobNameFromTargetId(mobTargId);
        
        -- Skip the packet if the name was not found..
        if (mobName == nil) then
            return true;
        else
            if ((mobName:find(FilterScan.Filter)) ~= nil) then
                return false;
            else
                return true;
            end
        end
            
        -- We shouldn't make it here..
        return true;
    end
    
    return false;
end );
