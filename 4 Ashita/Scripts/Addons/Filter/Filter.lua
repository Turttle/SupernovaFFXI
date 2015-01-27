_addon.author   = 'bope';
_addon.name     = 'ChatFilter';
_addon.version  = '.2';
require 'common'
local config={
['say']=0,          --|Chat
['tell']=0,         --|*
['party']=0,        --|*
['linkshell']=0,    --|*
['emotes']=0,       --|*
['shout']=0,        --|*
['spells']=0,       --|Start of spells cast by you/mobs/others
['youabillity']=0,  --|Start of ability done by you
['youeffect']=0,    --|Effects done to you
['youattack']=0,    --|Damage you deal
['youmiss']=1,      --|Attacks you miss
['youevade']=1,     --|Attacks you evade
['youhurt']=0,      --|Damage you take
['partyspells']=1,  --|Spells cast by party
['partyabillity']=1,--|Start of ability done by party
['partyeffect']=1,  --|Effects done to party
['partyattack']=1,  --|Damage by party
['partymiss']=1,    --|Attacks missed by party
['partyevade']=1,   --|Attacks evaded by party
['partyhurt']=1,    --|Damage done to party
['allyspells']=1,   --|Spells cast by alliance
['allyabillity']=1, --|Start of ability done by alliance
['allyeffect']=1,   --|Effects done to alliance
['allyattack']=1,   --|Damage by alliance
['allymiss']=1,     --|Attacks missed by alliance
['allyevade']=1,    --|Attacks evaded by alliance
['allyhurt']=1,     --|Damage done to alliance
['otherabillity']=0,--|Start of ability done by players out of alliance
['othereffect']=1,  --|Effects done to mobs or players out of alliance       
['otherattack']=1,  --|Damage done to/or by mobs or players out of alliance
['othermisses']=1,  --|Attacks missed by mobs or players out of alliance
['mobabillity']=1,  --|mob/pet ability
['battlerelated']=0,--|Text related to battles,exe,defeat,unabletosee,para,waitlonger,death
['lootmisc']=0      --|Loot related messages and random like level up
}
local function cast(chat)
    if chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(0) .. ' casts.*')~= nil or chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(0) .. '.*effect.*')~= nil then
        return (config['youeffect'] ==1)
    end
    for i=1 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty0Count()-1,1 do
        if(chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. ' casts.*')~= nil or chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. '.*effect.*')~= nil )then
                return (config['partyeffect'] == 1)
        end
    end
    for i=6 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty1Count()-1,1 do
        if chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. ' casts.*')~= nil or chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. '.*effect.*')~= nil then
            return (config['allyeffect'] == 1)
        end
    end
    for i=12 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty1Count()-1,1 do
        if chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. ' casts.*')~= nil or chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. '.*effect.*')~= nil then
            return (config['allyeffect'] == 1)
        end
    end
    return (config['othereffect'] == 1)
end
local function damage(chat)
            if(chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(0) .. ' hits.*')~= nil or chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(0) .. ' scores.*')~= nil or chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(0) .. '\'s')~= nil)then
                return (config['youattack'] == 1)
            end
            for i=1 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty0Count()-1,1 do
                if(chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. ' hits.*')~= nil or chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. ' scores.*')~= nil or chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. '\'s')~= nil)then
                    return (config['partyattack'] == 1)
                end
            end
            for i=6 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty1Count()-1,1 do
                if(chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. ' hits.*')~= nil or chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. ' scores.*')~= nil or chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. '\'s')~= nil)then
                    return (config['allyattack'] == 1)
                end
            end
            for i=12 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty1Count()-1,1 do
                if(chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. ' hits.*')~= nil or chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. ' scores.*')~= nil or chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. '\'s')~= nil) then
                    return (config['allyattack'] == 1)
                end
            end
            if chat:match('.*hits ' .. AshitaCore:GetDataManager():GetParty():GetPartyMemberName(0)) ~= nil then
                return (config['youhurt'] == 1)
            end
            for i=1 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty0Count()-1,1 do
                if chat:match('.*hits ' .. AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i)) ~= nil then
                    return (config['partyhurt'] == 1)
                end
            end
            for i=6 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty1Count()-1,1 do
                if chat:match('.*hits ' .. AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i)) ~= nil then
                    return (config['allyhurt'] == 1)
                end
            end
            for i=12 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty1Count()-1,1 do
                if chat:match('.*hits ' .. AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i)) ~= nil  then
                    return (config['allyhurt'] == 1)
                end
            end
            return (config['otherattack'] == 1)
end
local function miss(chat)
            if( chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(0) .. ' parries.*')~= nil or chat:match('.*misses ' .. AshitaCore:GetDataManager():GetParty():GetPartyMemberName(0))~= nil)then
                return (config['youevade'] == 1)
            end
            for i=1 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty0Count()-1,1 do
                if( chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. ' parries.*')~= nil or chat:match('.*misses ' .. AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i))~= nil)then
                    return (config['partyevade'] == 1)
                end
            end
            for i=6 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty1Count()-1,1 do
                if( chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. ' parries.*')~= nil or chat:match('.*misses '..AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i))~= nil)then
                    return (config['allyevade'] == 1)
                end
            end
            for i=12 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty1Count()-1,1 do
                if(chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i) .. ' parries.*')~= nil or chat:match('.*misses ' .. AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i))~= nil) then
                    return (config['allyevade'] == 1)
                end
            end
            if( chat:match( AshitaCore:GetDataManager():GetParty():GetPartyMemberName(0)..' misses.*' )~= nil or AshitaCore:GetDataManager():GetParty():GetPartyMemberName(0)..'\'s.*' ~= nil)then
                return (config['youmiss'] == 1)
            end
            for i=1 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty0Count()-1,1 do
                if(chat:match( AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i)..' misses.*')~= nil or AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i)..'\'s.*' ~= nil)then
                    return (config['partymiss'] == 1)
                end
            end
            for i=6 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty1Count()-1,1 do
                if(chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i)..' misses.*')~= nil or AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i)..'\'s.*' ~= nil)then
                    return (config['allymiss'] == 1)
                end
            end
            for i=12 ,AshitaCore:GetDataManager():GetParty():GetAllianceParty1Count()-1,1 do
                if(chat:match(AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i)..' misses.*')~= nil or AshitaCore:GetDataManager():GetParty():GetPartyMemberName(i)..'\'s.*' ~= nil) then
                    return (config['allymiss'] == 1)
                end
            end
            return (config['othermisses'] == 1)
end
ashita.register_event('newchat', function(mode, chat)
    if(mode == 1 or mode == 9)then
        return (config['say'] ==1)
    elseif mode == 2 or mode == 10 then
        return (config['shout'] ==1)
    elseif mode == 12 or mode ==4 then
        return (config['tell'] ==1)
    elseif mode == 13 or mode ==5 then
        return (config['party'] ==1)
    elseif mode == 14 or mode ==6 then
        return (config['linkshell'] ==1)
    elseif mode == 52 then
        return (config['spells'] ==1)
    elseif mode == 51 then
        return (config['partyspells'] ==1)
    elseif mode == 168 then
        return (config['allyspells'] ==1)
    elseif mode == 7 or mode == 15 then
        return (config['emotes'] ==1)
    elseif mode == 29 then
        return (config['youevade'] ==1)
    elseif mode == 26 then
        return (config['partyevade'] ==1)
    elseif mode == 164 then
        return (config['allyevade'] ==1)
    elseif mode == 41 then
        return (config['othermisses'] ==1)                           
    elseif mode == 121 or mode == 127 then
        return (config['lootmisc'] ==1)
    elseif mode == 36 or mode == 44 or mode == 37 or mode == 166 or mode == 123 or mode == 131 or mode == 122 or mode == 38 then
        return (config['battlerelated'] ==1) 
    elseif chat:match('.*points of damage.') ~= nil then
        if(damage(chat))then
            return true
        end
    elseif chat:match('.* miss.*') ~= nil or chat:match('.*parries.*') ~= nil then
       if(miss(chat))then
            return true
       end
    elseif chat:match('.* casts.*') ~= nil or chat:match('.* effect.*') ~= nil then -- or chat:match('.* use.*') ~= nil
       if(cast(chat))then
            return true
       end   
    elseif(mode == 111 and config['otherabillity'] ==1 or ((mode == 110 or mode == 10) and config['mobabillity'] ==1 )or mode == 175 and config['allyabillity'] ==1 or mode == 106 and config['partyabillity'] ==1 or mode == 101 and config['youabillity'] ==1)then
        return true
    end
end);
ashita.register_event('command', function(cmd, nType)
    cmd = string.lower(cmd)
    local args = cmd:GetArgs();
    if args[1] == "/filter" or args[1]=="/fi" then
        if args[2] == nil or args[2]=="help" and args[3] == nil or args[2]=="?" and args[3] == nil then
            AshitaCore:GetChatManager():AddChatMessage( 12, "Valid Filter command /filter type option\nValid types me,party,alliance,other,system\nType /filter help type for options" );
        elseif args[2]=="help" or args[2]=="?" or args[3] == nil then
            if args[3] == "alliance" or args[3] == "party" or args[2] == "alliance" or args[2] == "party" then
            AshitaCore:GetChatManager():AddChatMessage( 12, "Valid Filter options for party/allaince\nspells,abillity,effect,attack,miss,evade,hurt" );
            end
            if args[3] == "me" or args[2] == "me" then
                 AshitaCore:GetChatManager():AddChatMessage( 12, "Valid Filter options for me\nabillity,effect,attack,miss,evade,hurt" );
            end
            if args[3] == "other" or args[2] == "other" then
                AshitaCore:GetChatManager():AddChatMessage( 12, "Valid Filter options for other\nabillity,effect,attack,missses" );
            end
            if args[3] == "system" or args[2] == "system" then
                AshitaCore:GetChatManager():AddChatMessage( 12, "Valid Filter options for system\nsay,tell,party,linkshell,emotes,spells,battlerelated,lootmisc,mobablillity" );
            end           
        elseif args[2] == "system" then
            config[args[3]] = math.abs(config[args[3]] - 1)
        end
    end
end); 