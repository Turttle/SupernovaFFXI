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

require 'common'

---------------------------------------------------------------------------------------------------
-- desc: Main Events table for storing local information of a player.
---------------------------------------------------------------------------------------------------
local __events =
{
    player_buffs        = { },  -- The players current buffs..
    player_name         = '',   -- The players current name..
    player_linkshell    = '',   -- The players current linkshell..
    player_status       = 0,    -- The players current status..
    player_target       = 0,    -- The players current target..
    player_zone         = 0,    -- The players current zone..
    
    player_mjob_id      = 0,    -- The players current main job id..
    player_mjob_level   = 0,    -- The players current main job level..
    player_sjob_id      = 0,    -- The players current sub job id..
    player_sjob_level   = 0,    -- The players current sub job level..
    
    player_hp           = 0,    -- The players current hp..
    player_mp           = 0,    -- The players current mp..
    player_tp           = 0,    -- The players current tp..
    player_hp_max       = 0,    -- The players current max hp..
    player_mp_max       = 0,    -- The players current max mp..
};

---------------------------------------------------------------------------------------------------
-- func: MAKEWORD
-- desc: Microsoft MAKEWORD macro converted to Lua.
---------------------------------------------------------------------------------------------------
local function MAKEWORD(a, b)
    return bit.bor(bit.band(a, 0xFF), bit.lshift(bit.band(b, 0xFF), 8));
end

---------------------------------------------------------------------------------------------------
-- func: decode_signature
-- desc: Decodes a signed item (crafted / linkshell) name.
---------------------------------------------------------------------------------------------------
local function decode_signature(input)
    local ret = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    local x = 0;
    local y = 0;

    while (true) do
        -- Flag to determine if we handled the current character..
        local handled = false;

        -- Calculate the current character data..
        local data = 0x00;
        if ((y % 0x08) > 0x02) then
            data = bit.band(bit.rshift(MAKEWORD(input[math.floor(((y / 0x08) + 0x01) + 0x01)], input[math.floor((y / 0x08) + 0x01)]), (0x0A - (y % 0x08))), 0x3F);
        else
            data = bit.band(bit.rshift(input[math.floor((y / 0x08) + 0x01)], (0x02 - (y % 0x08))), 0x3F);
        end

        ret[x + 1] = data;

        -- Handle line ending and spaces..
        if (handled == false and data == 0x003F) then
            ret[x + 1] = 0x20;
        elseif (handled == false and data == 0x003E) then
            ret[x + 1] = 0x20;
        end

        -- Handle characters..
        if (handled == false and data < 0x001B) then
            ret[x + 1] = data + 0x60;
        elseif (handled == false and data >= 0x0035) then
            ret[x + 1] = 0x00;
        else
            if (handled == false) then
                ret[x + 1] = data + 0x26;
            end
        end

        -- Step our variables..
        x = x + 1;
        y = y + 6;

        -- Break if we have reached the input size limit..
        if (x > #input) then
            break;
        end
    end

    -- Build the return string..
    local str = ''
    for _, v in pairs(ret) do
        if (v == 0) then
            break;
        end
        str = str .. string.char(v);
    end

    return str;
end

---------------------------------------------------------------------------------------------------
-- func: __events_fire 
-- desc: Fires the given event with the given arguments.
---------------------------------------------------------------------------------------------------
local function __events_fire(name, ...)
    -- Ensure we have an event table..
    if (__ashita_addon_events == nil or type(__ashita_addon_events) ~= 'table') then
        return false;
    end

    -- Ensure we have an event with the given name..
    if (__ashita_addon_events[name] == nil or type(__ashita_addon_events[name]) ~= 'function') then
        return false;
    end
    
    -- Fire the event..
    __ashita_addon_events[name](...);
    return true;
end

---------------------------------------------------------------------------------------------------
-- func: __events_incoming_packet
-- desc: Incoming packet handler.
---------------------------------------------------------------------------------------------------
function __events_incoming_packet(id, size, packet)
    -- Incoming message standard packet..
    if (id == 0x0009) then
        -- Check for examines..
        if (struct.unpack('H', packet, 0x0A + 1) == 0x59) then
            local senderName = struct.unpack('s', packet, 0x0D + 1 + string.len('string2 '));
            local senderIndex = struct.unpack('H', packet, 0x08 + 1);
            __events_fire('examined', senderName, senderIndex);
        end
        return false;
    end
    
    -- Incoming zone packet..
    if (id == 0x000A) then
        -- Check for status change..
        local status = struct.unpack('b', packet, 0x1F + 1);
        if (status ~= __events.player_status) then
            __events_fire('status_change', __events.player_status, status);
            __events.player_status = status;
        end
        -- Check for zone change..
        local zoneId = struct.unpack('H', packet, 0x30 + 1);
        if (zoneId == 0) then
            zoneId = struct.unpack('H', packet, 0x42 + 1);
        end
        if (zoneId ~= __events.player_zone) then
            __events_fire('zone_change', __events.player_zone, zoneId);
            __events.player_zone = zoneId;
        end
        -- Check for login..
        local playerName = struct.unpack('s', packet, 0x84 + 1);
        if(playerName ~= __events.player_name) then
            __events_fire('login', playerName);
            __events.player_name = playerName;
        end
        -- Check for weather..
        local weather = struct.unpack('H', packet, 0x68 + 1);
        __events_fire('weather_change', weather);
        return false;
    end
    
    -- Incoming zone change / logout packet..
    if (id == 0x000B) then
        local pType = struct.unpack('b', packet, 0x04 + 1);
        if (pType == 1) then
            __events_fire('logout', __events.player_name);
            __events.player_name = '';
        end
        return false;
    end
    
    -- Incoming character update packet..
    if (id == 0x000D and struct.unpack('b', packet, 0x0A + 1) == 0x1F) then
        -- Ensure this update is for us..
        local ptid = struct.unpack('H', packet, 0x08 + 1);
        if (ptid ~= AshitaCore:GetDataManager():GetParty():GetPartyMemberTargetIndex(0)) then
            return false;
        end
    
        -- Check for status change..
        local status = struct.unpack('b', packet, 0x1F + 1);
        if (status ~= __events.player_status) then
            __events_fire('status_change', __events.player_status, status);
            __events.player_status = status;
        end
        return false;
    end
    
    -- Incoming item update packet..
    if (id == 0x0020) then
        local itemId = struct.unpack('H', packet, 0x0C + 1);
        
        -- Ensure the item is a linkshell..
        if (itemId ~= 513 and itemId ~= 514 and itemId ~= 515 and itemId ~= 516 and itemId ~= 517) then
            return false;
        end
        
        local linkshellStatus = struct.unpack('b', packet, 0x010 + 1);
        local linkshellName = decode_signature(struct.unpack('c18', packet, 0x1A + 1):totable());
        if (linkshellStatus == 0x13) then
            -- User equipped a linkshell item..
            if (__events.player_linkshell ~= linkshellName) then
                __events_fire('linkshell_change', __events.player_linkshell, linkshellName);
                __events.player_linkshell = linkshellName;
            end
        else
            -- Use unequipped a linkshell item..
            __events_fire('linkshell_change', __events.player_linkshell, '');
            __events.player_linkshell = '';
        end        
        return false;
    end
    
    -- Incoming message debug packet..
    if (id == 0x002D) then
        -- Obtain the message info..
        local p1, p2, msgId = struct.unpack('LLH', packet, 0x10 + 1);
        
        -- Ensure this is an exp / limit point update..
        if (msgId == 372 or msgId == 371 or msgId == 253 or msgId == 8) then
            local isMerits = (msgId == 372 or msgId == 371);
            __events_fire('exp_gain', p1, p2, isMerits);
        end
        
        return false;
    end
    
    -- Incoming synth animation packet..
    if (id == 0x0030) then
        -- Ensure this update is for us..
        local ptid = struct.unpack('H', packet, 0x08 + 1);
        if (ptid ~= AshitaCore:GetDataManager():GetParty():GetPartyMemberTargetIndex(0)) then
            return false;
        end
        
        -- Check for status change..
        local status = struct.unpack('b', packet, 0x1F + 1);
        if (status ~= __events.player_status) then
            __events_fire('status_change', __events.player_status, status);
            __events.player_status = status;
        end
        return false;
    end
    
    -- Incoming character sync packet..
    if (id == 0x0037) then
        -- Check for status change..
        local status = struct.unpack('b', packet, 0x30 + 1);
        if (status ~= __events.player_status) then
            __events_fire('status_change', __events.player_status, status);
            __events.player_status = status;
        end
        
        -- Read the current buffs..
        local buffs = { };
        for x = 0, 31 do
            local mask = bit.band(bit.rshift(struct.unpack('b', packet, bit.rshift(x, 2) + 0x4C + 1), 2 * (x % 4)), 3);
            if (struct.unpack('b', packet, (4 + x) + 1) ~= -1 or mask > 0) then
                table.insert(buffs, bit.bor(struct.unpack('B', packet, (4 + x) + 1), bit.lshift(mask, 8)));
            end
        end
        
        -- Determine if we lost a buff..
        for _, v in pairs(__events.player_buffs) do
            local found = false;
            for _, vv in pairs(buffs) do
                if (vv == v) then
                    found = true;
                end
            end
            -- Did we lose this buff..
            if (found == false) then
                __events_fire('lose_buff', v);
            end
        end
        
        -- Determine if we gained a buff..
        for _, v in pairs(buffs) do
            local found = false;
            for _, vv in pairs(__events.player_buffs) do
                if (vv == v) then
                    found = true;
                end
            end
            -- Did we gain this buff..
            if (found == false) then
                __events_fire('gain_buff', v);
            end
        end
        
        -- Set the players current buffs..
        __events.player_buffs = buffs;        
        return false;
    end
    
    -- Incoming weather update packet..
    if (id == 0x0057) then
        -- Check for weather..
        local weather = struct.unpack('H', packet, 0x08 + 1);
        __events_fire('weather_change', weather);
        return false;
    end
    
    -- Incoming emote packet..
    if (id == 0x005A) then
        local senderIndex = struct.unpack('H', packet, 0x0C + 1);
        local targetIndex = struct.unpack('H', packet, 0x0E + 1);
        local emoteId = struct.unpack('b', packet, 0x10 + 1);
        local emoteFlag = (struct.unpack('b', packet, 0x16 + 1) == 2);
        __events_fire('emote', emoteId, senderIndex, targetIndex, emoteFlag);
        return false;
    end
    
    -- Incoming character stats packet..
    if (id == 0x0061) then
        -- Read the players job information..
        local mjob, mjoblvl, sjob, sjoblvl = struct.unpack('bbbb', packet, 0x0C + 1);
        
        -- Determine if we gained or lost a level....
        if (mjob == __events.player_mjob_id and mjoblvl ~= __events.player_mjob_level) then
            if (mjoblvl > __events.player_mjob_level) then
                __events_fire('level_up', mjob, mjoblvl);
            else
                __events_fire('level_down', mjob, mjoblvl);
            end
        end
        
        -- Determine if we changed jobs..
        if (mjob ~= __events.player_mjob_id or sjob ~= __events.player_sjob_id) then
            __events_fire('job_change', mjob, mjoblvl, sjob, sjoblvl);
        end
        
        -- Read the players max hp and max mp..
        local hpmax, mpmax = struct.unpack('LL', packet, 0x04 + 1);
        if (hpmax ~= __events.player_hp_max) then
            __events_fire('hpmax_change', __events.player_hp_max, hpmax);
        end
        if (mpmax ~= __events.player_mp_max) then
            __events_fire('mpmax_change', __events.player_mp_max, mpmax);
        end
        
        -- Store the job information..
        __events.player_mjob_id     = mjob;
        __events.player_mjob_level  = mjoblvl;
        __events.player_sjob_id     = sjob;
        __events.player_sjob_level  = sjoblvl;
        __events.player_hp_max      = hpmax;
        __events.player_mp_max      = mpmax;
        return false;
    end
    
    -- Incoming party invite packet..
    if (id == 0x00DC) then
        local senderName = struct.unpack('s', packet, 0x0D + 1 + string.len('string2 '));
        __events_fire('party_invite', senderName);
        return false;
    end
    
    -- Incoming player update packet..
    if (id == 0x00DF) then
        -- Ensure this update is for our player..
        local playerId = struct.unpack('L', packet, 0x04 + 1);
        if (playerId == AshitaCore:GetDataManager():GetParty():GetPartyMemberID(0)) then
            local hp, mp, tp = struct.unpack('LLL', packet, 0x08 + 1);
            if (hp ~= __events.player_hp) then
                __events_fire('hp_change', __events.player_hp, hp);
            end
            if (mp ~= __events.player_mp) then
                __events_fire('mp_change', __events.player_mp, mp);
            end
            if (tp ~= __events.player_tp) then
                __events_fire('tp_change', __events.player_tp, tp);
            end
            
            -- Store the new data..
            __events.player_hp = hp;
            __events.player_mp = mp;
            __events.player_tp = tp;
        end
        return false;
    end
        
    return false;
end

---------------------------------------------------------------------------------------------------
-- func: __events_outgoing_packet
-- desc: Outgoing packet handler.
---------------------------------------------------------------------------------------------------
function __events_outgoing_packet(id, size, packet)
    -- Outgoing player sync packet..
    if (id == 0x0015) then
        local targetIndex = struct.unpack('H', packet, 0x016 + 1);
        if (__events.player_target == targetId) then
            __events_fire('target_change', targetIndex);
            __events.player_target = targetId;
        end
        return false;
    end
    return false;
end

--[[ Populate player information on load if we are already logged in.. ]]--

    -- Locate the scene management id..
    local loggedin = false;
    local pattern = { 0x66, 0x05, 0xFF, 0xFF, 0x66, 0x85, 0xC0, 0x74, 0xFF, 0x8B, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF, 0x25, 0xFF, 0xFF, 0x00, 0x00, 0x50, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x85, 0xC0 };
    local pointer = mem:FindPattern('FFXiMain.dll', pattern, #pattern, 'xx??xxxx?xx????x??xxx?????xx');
    if (pointer ~= 0 and pointer ~= nil) then
        pointer = mem:ReadULong(pointer + 0x0B);
        pointer = mem:ReadUChar(pointer + 0x94);
        if (pointer == 0x60) then
            loggedin = true;
        end
    end
    
    -- Populate the current data with the players information..
    if (loggedin == true and GetPlayerEntity() ~= nil) then       
        local party = AshitaCore:GetDataManager():GetParty();
        local player = AshitaCore:GetDataManager():GetPlayer();
        -- Populate the players current info..
        __events.player_buffs           = { };
        __events.player_name            = GetPlayerEntity().Name;
        __events.player_linkshell       = '';
        __events.player_status          = GetPlayerEntity().Status;
        __events.player_target          = AshitaCore:GetDataManager():GetTarget():GetTargetIndex();
        __events.player_zone            = party:GetPartyMemberZone(0);
        
        
        __events.player_mjob_id         = player:GetMainJob();
        __events.player_mjob_level      = player:GetMainJobLevel();
        __events.player_sjob_id         = player:GetSubJob();
        __events.player_sjob_level      = player:GetSubJobLevel();
        
        __events.player_hp              = party:GetPartyMemberHP(0);
        __events.player_mp              = party:GetPartyMemberMP(0);
        __events.player_tp              = party:GetPartyMemberTP(0);
        __events.player_hp_max          = player:GetHPMax();
        __events.player_mp_max          = player:GetMPMax();

        -- Read the players current buffs..
        for k, v in pairs(player.GetBuffs) do
            if (v ~= -1) then
                table.insert(__events.player_buffs, v);
            end
        end
        
        -- Attempt to locate a linkshell we have equipped..
        local inventory = AshitaCore:GetDataManager():GetInventory();
        for x = 0, 80 do
            local item = inventory:GetInventoryItem(0, x);
            if (item.Id == 513 or item.Id == 514 or item.Id == 515 or item.Id == 516 or item.Id == 517) then
                if (item.Flag == 0x13) then
                    -- Pull the linkshell name from the item..
                    __events.player_linkshell = decode_signature({unpack(item.Extra, 9, 9 + 18)});
                end
            end
        end
    end


--[[
Implemented Events
----------------------------------------------------------
    emote(emoteId, senderIndex, targetIndex, emoteFlag)
    examined(name, index)
    gain_buff(id)
    job_change(mjob, mjoblvl, sjob, sjoblvl)
    level_down(job, level)
    level_up(job, level)
    linkshell_change(old, new)
    login(name)
    logout(name)
    lose_buff(id)
    party_invite(name)
    status_change(old, new)
    target_change(index)
    zone_change(old, new)
    
    hp_change(old, new)
    mp_change(old, new)
    tp_change(old, new)
    hpmax_change(old, new)
    mpmax_change(old, new)
    
    exp_gain(exp, chain, meritmode)
    
    weather_change(weather)
]]--