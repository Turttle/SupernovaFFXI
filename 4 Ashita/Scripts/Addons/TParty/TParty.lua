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
_addon.name     = 'TParty';
_addon.version  = '1.0';

---------------------------------------------------------------------------------------------------
-- desc: Local TParty data.
---------------------------------------------------------------------------------------------------
local tparty_config = { };

local tparty_str_targethpp      = "__tparty_targethpp";
local tparty_str_partymember_tp = "__tparty_party_tpp";

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    tparty_config.window_x      = config:get_int('boot_config', 'window_x', 800);
    tparty_config.window_y      = config:get_int('boot_config', 'window_y', 600);
    tparty_config.menu_x        = config:get_int('boot_config', 'menu_x', 0);
    tparty_config.menu_y        = config:get_int('boot_config', 'menu_y', 0);
    
    -- Validate the configuration data..
    if (tparty_config.menu_x <= 0) then
        tparty_config.menu_x = tparty_config.window_x;
    end
    if (tparty_config.menu_y <= 0) then
        tparty_config.menu_y = tparty_config.window_y;
    end
    
    -- Calculate the scaling..
    tparty_config.scaleX = tparty_config.window_x / tparty_config.menu_x;
    tparty_config.scaleY = tparty_config.window_y / tparty_config.menu_y;
        
    -- Create the main target hp% text object..
    local targHP = AshitaCore:GetFontManager():CreateFontObject( tparty_str_targethpp );
    targHP:SetFont('Arial', 8 * tparty_config.scaleY);
    targHP:SetBold(true);
    targHP:SetRightJustified(true);
    targHP:SetText('98');
    targHP:SetPosition(0, 0);
    targHP:SetVisibility(true);
    targHP:SetLockPosition(true);
    
    -- Create the party member text objects..
    for x = 0, 17 do
        local f = AshitaCore:GetFontManager():CreateFontObject(string.format('%s%d', tparty_str_partymember_tp, x));
        f:SetFont('Arial', 8 * tparty_config.scaleY);
        f:SetBold(true);
        f:SetRightJustified(true);
        f:SetText(string.format('%s%d', tparty_str_partymember_tp, x));
        f:SetPosition(0, 0);
        f:SetVisibility(true);
        f:SetLockPosition(true);
    end
end );


---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    -- Cleanup our font objects..
    AshitaCore:GetFontManager():DeleteFontObject( tparty_str_targethpp );
    for x = 0, 18 do
        AshitaCore:GetFontManager():DeleteFontObject(string.format('%s%d', tparty_str_partymember_tp, x));
    end
end );

---------------------------------------------------------------------------------------------------
-- func: Render
-- desc: Called when our addon is rendered.
---------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    local party     = AshitaCore:GetDataManager():GetParty();
    local target    = AshitaCore:GetDataManager():GetTarget();

    -- Calculate offset positions..
    local posX  = tparty_config.window_x - (110 * tparty_config.scaleX);
    local posY  = tparty_config.window_y - (034 * tparty_config.scaleY);
    local currX = 0;
    local currY = 0;
    
    -- Obtain the local players zone..
    local myZone = party:GetPartyMemberZone(0);
    
    -- Prepare and display the party percentages..
    for x = 0, 5 do
        local f = AshitaCore:GetFontManager():GetFontObject(string.format('%s%d', tparty_str_partymember_tp, x));
        if (x ~= 0 and myZone ~= party:GetPartyMemberZone(x) or party:GetPartyMemberActive(x) == 0) then
            if (f ~= nil) then
                f:SetVisibility(false);
            end
        else
            local currX = posX;
            local currY = posY - ((party:GetAllianceParty0Count() - 1 - x) * (20 * tparty_config.scaleY));
            
            if (f ~= nil) then
                local tp = party:GetPartyMemberTP(x);
                f:SetPosition(currX, currY);
                f:SetText(tostring(tp));
                f:SetVisibility(true);
                
                -- Colorize the TP..
                if (tp >= 1000) then
                    f:SetColor(0xFF00FF00);
                else
                    f:SetColor(0xFFFFFFFF);
                end
            end
        end
    end
    
    -- Calculate alliance offsets..
    local posAllianceX0 = posX;
    local posAllianceY0 = tparty_config.window_y - (389 * tparty_config.scaleY);
    local posAllianceX1 = posX;
    local posAllianceY1 = tparty_config.window_y - (288 * tparty_config.scaleY);
    
    for x = 6, 17 do
        local currX = 0;
        local currY = 0;
        
        -- Calculate the alliance positions..
        if ((x >= 6) and (x < 12)) then
            currX = posAllianceX0;
            currY = posAllianceY0 + (((x - 6) * 16) * tparty_config.scaleY);
        else
            currX = posAllianceX1
            currY = posAllianceY1 + (((x - 12) * 16) * tparty_config.scaleY);
        end
        
        -- Adjust the label positions..
        local fTP = AshitaCore:GetFontManager():GetFontObject(string.format('%s%d', tparty_str_partymember_tp, x));
        if (fTP ~= nil) then
            local tp = party:GetPartyMemberTP(x);
            fTP:SetPosition(currX, currY);
            fTP:SetText(tostring(tp));
            
            -- Colorize the TP..
            if (tp >= 1000) then
                fTP:SetColor(0xFF00FF00);
            else
                fTP:SetColor(0xFFFFFFFF);
            end
        end
        
        -- Set the label visibility status..
        if (party:GetPartyMemberActive(x) ~= 0 and myZone == party:GetPartyMemberZone(x)) then
            fTP:SetVisibility(true);
        else
            fTP:SetVisibility(false);
        end
    end
    
    -- Ensure we have a valid target..
    local tHP = AshitaCore:GetFontManager():GetFontObject(tparty_str_targethpp);
    if (target:GetTargetEntity() == nil or target:GetTargetName() == '' or target:GetTargetID() == 0) then
        tHP:SetText('0');
        tHP:SetVisibility(false);
    else
        local targetX = posX;
        local targetY = posY - (((party:GetAllianceParty0Count() - 1 ) * 21 ) + 34) * tparty_config.scaleY;
    
        tHP:SetText(tostring(target:GetTargetEntity().HealthPercent));
        tHP:SetPosition(targetX, targetY);
        tHP:SetVisibility(true);
    end
end );