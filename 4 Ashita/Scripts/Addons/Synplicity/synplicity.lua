_addon.author   = 'bluekirby0';
_addon.name     = 'Synplicity';
_addon.version  = '1.1';

require 'common'
require 'tablesave'
require 'bkutils'

local __debug = false;
local __savefile = "recipes.list"

-- tempstore layout: crystal,mats{1-8},results{1-4}
-- synthstore layout: index,tempstore{}
local synthstore = {};
local tempstore = {};
local temptier = 0;
local synthphase = 0;
local temp_index = 0;

-- invslots layout: slotid,qty
local invslots = {}

function debug_print(str)
    if(__debug) then
        print(C_AQUA .. "[DEBUG] " .. C_RESET .. str);
    end
end;

function synth_print(str)
    print(C_RED .. "[SYNTH] " .. C_RESET .. str);
end;

function debug_show_packet(packet)
    if(__debug) then
        local f = AshitaCore:GetFontManager():GetFontObject( '__debug1' );
        local temp = " 0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F\n";
        local idx = 0;

        for char in packet:gmatch('.') do
            temp = temp .. string.format("%02X ",char:byte());
            if (idx == 15) then
                temp = temp .. '\n';
                idx = 0;
            else
                idx = idx + 1;
            end
        end

        f:SetText(temp);
    end
end;

function item_name(id)
    local res = AshitaCore:GetResourceManager();
    if(__debug) then
        return C_ATOPEN .. res:GetItemByID(tonumber(id)).Name .. C_ATCLOSE .. "(" .. C_BLUE .. id .. C_RESET .. ")";
    else
        return C_ATOPEN .. res:GetItemByID(tonumber(id)).Name .. C_ATCLOSE;
    end
end;

function item_id(name)
    return AshitaCore:GetResourceManager():GetItemByName(name).Id;
end;

function find_item_by_id(itemid)
    local slot = -1;
    local inv = AshitaCore:GetDataManager():GetInventory();
    for idx=0,inv:GetInventoryMax(0) do
        local res = inv:GetInventoryItem(0,idx);
        if(res == nil) then
            break;
        end
        if(res.Id == itemid) then
            slot = res.Index;
            if(invslots[res.Index] == nil) then
                invslots[res.Index] = 1;
            else
                invslots[res.Index] = invslots[res.Index] + 1;
            end
            if(inv:GetInventoryItem(0,idx).Count < invslots[res.Index]) then
                slot = -1;
            else
                break;
            end
        end
    end
    return slot;
end;

ashita.register_event('load', function()
    -- Create our font object..
    if(__debug) then
        local f = AshitaCore:GetFontManager():CreateFontObject( '__debug1' );
        f:SetBold( true );
        f:SetFont("Consolas",14);
        f:SetPosition( 32,32 );
        f:SetText( '' );
        f:SetVisibility( true );
    end
    synthstore = table.load(__savefile);
end );

ashita.register_event('unload', function()
    if(__debug) then
        AshitaCore:GetFontManager():DeleteFontObject( '__debug1' );
    end
    table.save(synthstore,__savefile);
end );

ashita.register_event('outgoing_packet', function(id, size, packet)
    -- Capture outgoing synthesis packets
    if (id == 0x96 and synthphase == 0) then
        debug_show_packet(packet);
        -- Store the list of ingredients
        local newpacket = packet:totable();

        temp_index = newpacket[0x04+1] + bit.lshift(newpacket[0x05+1],8);
        local crystal = newpacket[0x06+1] + bit.lshift(newpacket[0x07+1],8);
        local slot = newpacket[0x08+1];
        local count = newpacket[0x09+1];

        local mats = {0,0,0,0,0,0,0,0};
        local slots = {};

        if(crystal >= 4238) then
            crystal = crystal - 142;
        end

        tempstore["crystal"] = crystal;

        debug_print("Crystal: " .. item_name(crystal) .. " # of ingredients: " .. count);

        local offset = 0x0A+1;
        local slotoffset = 0x1A+1;
        for idx=1,count do
            mats[idx] = newpacket[offset] + bit.lshift(newpacket[offset+1],8);
            slots[idx] = newpacket[slotoffset];
            offset = offset + 2;
            slotoffset = slotoffset + 1;
        end
        tempstore["mats"] = mats;

        if(__debug) then
            for idx=1,count do
                    debug_print("Material ID: " .. item_name(mats[idx]));
                    debug_print("Inventory Slot ID: " .. slots[idx]);
            end
        end

        synthphase = 1;
    end
end );

ashita.register_event('incoming_packet', function(id, size, packet)
    -- if we are receiving a synth result packet
    if (id == 0x6F and synthphase == 2) then

        local newpacket = packet:totable();
        local resultItem = newpacket[0x08+1] + bit.lshift(newpacket[0x09+1],8);

        debug_print("Result Item: " .. item_name(resultItem));

        tempstore["result"] = {0,0,0,0};
        tempstore["result"][temptier] = resultItem;

        if(synthstore[temp_index] == nil) then
            synthstore[temp_index] = tempstore;
        elseif(synthstore[temp_index]["result"][temptier] == nil) then
            synthstore[temp_index]["result"][temptier] = tempstore["result"][temptier];
        end
        tempstore = {};
        temp_index = 0;
        synthphase = 0;
    elseif(id == 0x30 and synthphase == 1) then
        local newpacket = packet:totable();

        local result = newpacket[0x0C+1];
        if (result == 1) then
            synth_print("Synthesis failed");
            tempstore = {};
            temp_index = 0;
            synthphase = 0;
            return false;
        elseif(result == 0) then
            result = result + 1;
        end
        synth_print("Result is tier " .. result);
        temptier = result;
        synthphase = 2;
    end
    return false;
end );

ashita.register_event('command', function(cmd, nType)
    -- Ensure we should handle this command..
    local args = cmd:GetArgs();
    if (args[1] ~= '/syn') then
        return false;
    end

    -- Ensure we have enough arguments..
    if (#args < 2) then
        return true;
    end

    if (args[2] == 'show') then
        local index = 0;
        local filter = "";
        
        if(#args > 2) then
            filter = table.concat(args, " ", 3,#args);
        end
        
        for k,val in pairs(synthstore) do
            local concat = C_BLUE .. "Index: " .. C_RESET .. k .. C_BLUE .. " Crystal: " .. C_RESET .. item_name(val["crystal"]) .. C_LINEBREAK .. " Materials: ";
            for i,v in ipairs(val["mats"]) do
                if(v ~= 0) then 
                    concat = concat .. " " .. item_name(v);
                end
            end
            concat = concat .. C_LINEBREAK .. C_BLUE .. " Results:" .. C_RESET
            for i,v in ipairs(val["result"]) do
                if(v ~= 0) then 
                    concat = concat .. C_YELLOW .. " Tier: " .. C_RESET .. i .. C_PURPLE .. " Item: " .. C_RESET .. item_name(v);
                end
            end
            if(string.find(concat,filter)) then
                synth_print(concat);
            end
        end
        return true;
    elseif (args[2] == 'do') then
        if (args[3] == nil) then
            return true;
        end

        local synth;
        for k,v in pairs(synthstore) do
            if(k == tonumber(args[3])) then
                synth = synthstore[k];
                break;
            end
        end

        local domat = synth["mats"];
        local count = 0;

        for idx=1,8 do
            if(domat[idx] == nil) then
                domat[idx] = 0;
            else
                count = idx;
            end
        end
        local matinv = {};
        invslots = {};
        for idx=1,8 do
            if(domat[idx] == 0) then
                matinv[idx] = 0;
            else
                local slot = find_item_by_id(domat[idx]);
                if(slot ~= -1) then
                    matinv[idx] = slot;
                else
                    synth_print("Missing item for synth: " .. item_name(domat[idx]));
                    return true;
                end
            end
            if(__debug and (domat[idx] ~= 0)) then
                debug_print("To Pack: " .. item_name(domat[idx]) .. " " .. matinv[idx]);
            end
        end
        invslots = {};
        local crystalinv = find_item_by_id(synth["crystal"]);
        if(crystalinv == -1) then
            synth_print("Missing crystal for synth: " .. item_name(synth["crystal"]));
            return true;
        end

        -- Build and send crafting packet

        local craft = struct.pack("bbbbhhbbhhhhhhhhbbbbbbbbbb", 0x96, 0x12, 0x00, 0x00, tonumber(args[3]),
            synth["crystal"], crystalinv,count,domat[1],domat[2],domat[3],domat[4],domat[5],domat[6],domat[7],domat[8],
            matinv[1],matinv[2],matinv[3],matinv[4],matinv[5],matinv[6],matinv[7],matinv[8],0x00,0x00):totable();
        AddOutgoingPacket(craft, 0x96, #craft);
        return true;
    end
    return false;
end );
