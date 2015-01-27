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

---------------------------------------------------------------------------------------------------
-- desc: Main target information table.
---------------------------------------------------------------------------------------------------
local target_info =
{
    ['lastst'] =
    {
        pattern     = { 0xA1, 0xFF, 0xFF, 0xFF, 0xFF, 0xBF, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0xFF, 0xB9 },
        mask        = "x????x????x?x",
        offset      = 1,
        pointer     = 0,
    },
    ['scan'] =
    {
        pattern     = { 0xA1, 0xFF, 0xFF, 0xFF, 0xFF, 0x85, 0xC0, 0x74, 0xFF, 0xF7 },
        mask        = "x????xxx?x",
        offset      = 1,
        offset2     = 0x2E5EC,
        pointer     = 0,
    },
    ['r'] =
    {
        pattern     = { 0x8B, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF, 0x85, 0xC9, 0x75, 0x03, 0x33, 0xC0, 0xC3, 0x6A, 0x00 },
        mask        = "xx????xxxxxxxxx",
        offset      = 2,
        offset2     = 0x11E,
        pointer     = 0,
    },
};

---------------------------------------------------------------------------------------------------
-- desc: Scans for the needed pointers for this library.
---------------------------------------------------------------------------------------------------
target_info.lastst.pointer  = mem:FindPattern('FFXiMain.dll', target_info.lastst.pattern, #target_info.lastst.pattern, target_info.lastst.mask);
target_info.scan.pointer    = mem:FindPattern('FFXiMain.dll', target_info.scan.pattern, #target_info.scan.pattern, target_info.scan.mask);
target_info.r.pointer    = mem:FindPattern('FFXiMain.dll', target_info.r.pattern, #target_info.r.pattern, target_info.r.mask);

---------------------------------------------------------------------------------------------------
-- func: get_target_lastst
-- desc: Obtains the 'lastst' target.
-- retn: An entity if found, nil otherwise.
---------------------------------------------------------------------------------------------------
local function get_target_lastst()
    -- Ensure the pointer is valid..
    if (target_info.lastst.pointer == 0) then
        return nil;
    end
    
    -- Read the pointer..
    local ptr = mem:ReadLong(target_info.lastst.pointer + target_info.lastst.offset);
    if (ptr == 0 or ptr == nil) then
        return nil;
    end
    
    -- Read the next pointer..
    ptr = mem:ReadLong(ptr);
    if (ptr == 0 or ptr == nil) then
        return nil;
    end

    -- Read the lastst index and obtain the entity..
    local entity = GetEntity(mem:ReadLong(ptr + 0x7C));
    return entity;
end

---------------------------------------------------------------------------------------------------
-- func: get_target_bt
-- desc: Obtains the 'bt' target.
-- retn: An entity if found, nil otherwise.
---------------------------------------------------------------------------------------------------
local function get_target_bt()
    local playerId = GetPlayerEntity().ServerID;
    for x = 0, 2048 do
        local entity = GetEntity(x);
        
        if (entity ~= nil and entity.WarpPtr ~= 0 and entity.ClaimID == playerId) then
            if (entity.StatusServer ~= 2 and entity.StatusServer ~= 3) then
                return entity;
            end
        end
    end    
    return nil;
end

---------------------------------------------------------------------------------------------------
-- func: get_target_pet
-- desc: Obtains the 'pet' target.
-- retn: An entity if found, nil otherwise.
---------------------------------------------------------------------------------------------------
local function get_target_pet()
    local player = GetPlayerEntity();
    if (player.PetIndex == 0) then
        return nil;
    end
    return GetEntity(player.PetIndex);
end

---------------------------------------------------------------------------------------------------
-- func: get_target_scan
-- desc: Obtains the 'scan' target.
-- retn: An entity if found, nil otherwise.
---------------------------------------------------------------------------------------------------
local function get_target_scan()
    -- Ensure the pointer is valid..
    if (target_info.scan.pointer == 0) then
        return nil;
    end
    
    -- Read the pointer..
    local ptr = mem:ReadLong(target_info.scan.pointer + target_info.scan.offset);
    if (ptr == 0 or ptr == nil) then
        return nil;
    end
    
    -- Read the next pointer..
    ptr = mem:ReadLong(ptr);
    if (ptr == 0 or ptr == nil) then
        return nil;
    end
    
    -- Adjust the pointer with the second offset..
    ptr = ptr + target_info.scan.offset2;

    -- Ensure we have a scan target set..
    if (mem:ReadLong(ptr) ~= 1) then
        return nil;
    end
    
    -- Read and obtain the entity..
    return GetEntity(bit.band(mem:ReadLong(ptr + 0x10), 0xFFFF));
end

---------------------------------------------------------------------------------------------------
-- func: get_target_ht
-- desc: Obtains the 'ht' target.
-- retn: An entity if found, nil otherwise.
---------------------------------------------------------------------------------------------------
local function get_target_ht()
    local entity = nil;

    for x = 0, 2048 do
        local ent = GetEntity(x);
        if (ent ~= nil and ent.WarpPtr ~= 0 and ent.StatusServer ~= 2 and ent.StatusServer ~= 3) then
            -- Ensure the entity is valid to be a help target..
            if (bit.band(bit.rshift(ent.Render.RenderFlag0000, 5), 1) == 1) then
                -- Determine if we are called for help..
                if (bit.band(bit.rshift(ent.Render.RenderFlag0001, 16), 1) == 1) then
                    if (entity == nil) then
                        entity = ent;
                    else
                        if (math.sqrt(ent.Distance) < math.sqrt(entity.Distance)) then
                            entity = ent;
                        end
                    end
                end
            end
        end
    end
    
    return entity;
end

---------------------------------------------------------------------------------------------------
-- func: get_target_ft
-- desc: Obtains the 'ft' target.
-- retn: An entity if found, nil otherwise.
---------------------------------------------------------------------------------------------------
local function get_target_ft()
    -- Obtain the entity array..
    local array = AshitaCore:GetPointerManager():GetPointer('entityarray');
    if (array == 0) then
        return nil;
    end
    
    -- Locate our own pointer..
    local player = mem:ReadLong(mem:ReadLong(array) + (4 * GetPlayerEntity().TargetID));
    
    -- Locate our follower index..
    local follower = mem:ReadShort(player + 0x264);
    if (follower == 0) then
        return nil;
    end
    
    -- Return our follower..
    return GetEntity(follower);
end

---------------------------------------------------------------------------------------------------
-- func: get_target_normal
-- desc: Obtains the 't' target.
-- retn: An entity if found, nil otherwise.
---------------------------------------------------------------------------------------------------
local function get_target_normal()
    return AshitaCore:GetDataManager():GetTarget():GetTargetEntity();
end

---------------------------------------------------------------------------------------------------
-- func: get_target_r
-- desc: Obtains the 'r' target.
-- retn: An entity if found, nil otherwise.
---------------------------------------------------------------------------------------------------
local function get_target_r()
    -- Ensure the pointer is valid..
    if (target_info.r.pointer == 0) then
        return nil;
    end
    
    -- Read the pointer..
    local ptr = mem:ReadLong(target_info.r.pointer + target_info.r.offset);
    if (ptr == 0 or ptr == nil) then
        return nil;
    end
    
    -- Read the next pointer..
    ptr = mem:ReadLong(ptr);
    if (ptr == 0 or ptr == nil) then
        return nil;
    end
    
    -- Adjust the pointer with the second offset..
    ptr = ptr + target_info.r.offset2;

    -- Read the last tell target name..
    local name = '';
    for x = 0, 255 do
        local data = mem:ReadChar(ptr + x);
        if (data == 0) then
            break;
        end
        name = name .. string.char(data);
    end
    
    -- Attempt to locate the entity with this same name..
    for x = 0, 2048 do
        local ent = GetEntity(x);
        if (ent ~= nil and ent.Name == name) then
            return ent;
        end
    end
    
    return nil;
end

---------------------------------------------------------------------------------------------------
-- func: get_target
-- desc: Obtains the given target type.
-- retn: Entity if found, nil otherwise.
---------------------------------------------------------------------------------------------------
function get_target(name)
    -- Lower-case the name for compare..
    name = string.lower(name);
    
    -- Attempt to locate the requested target..
    return switch(name) : caseof
    {
        ['lastst']  = function() return get_target_lastst() end,
        ['bt']      = function() return get_target_bt() end,
        ['me']      = function() return GetPlayerEntity() end,
        ['pet']     = function() return get_target_pet() end,
        ['scan']    = function() return get_target_scan() end,
        ['ht']      = function() return get_target_ht() end,
        ['ft']      = function() return get_target_ft() end,
        ['t']       = function() return get_target_normal() end,
        ['r']       = function() return get_target_r() end,
        ['default'] = function() return nil; end,
    };
end

---------------------------------------------------------------------------------------------------
-- func: get_last_teller
-- desc: Obtains the name of the person that last sent you a whisper.
-- retn: Name if found, empty string otherwise.
---------------------------------------------------------------------------------------------------
function get_last_teller()
    -- Ensure the pointer is valid..
    if (target_info.r.pointer == 0) then
        return nil;
    end
    
    -- Read the pointer..
    local ptr = mem:ReadLong(target_info.r.pointer + target_info.r.offset);
    if (ptr == 0 or ptr == nil) then
        return nil;
    end
    
    -- Read the next pointer..
    ptr = mem:ReadLong(ptr);
    if (ptr == 0 or ptr == nil) then
        return nil;
    end
    
    -- Adjust the pointer with the second offset..
    ptr = ptr + target_info.r.offset2;

    -- Read the last tell target name..
    local name = '';
    for x = 0, 255 do
        local data = mem:ReadChar(ptr + x);
        if (data == 0) then
            break;
        end
        name = name .. string.char(data);
    end
    
    return name;
end
