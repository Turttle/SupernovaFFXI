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
_addon.name     = 'Distance';
_addon.version  = '1.0';

require 'common'

---------------------------------------------------------------------------------------------------
-- desc: Default Recast configuration table.
---------------------------------------------------------------------------------------------------
local default_config = 
{
    font =
    {
        name        = 'Arial',
        size        = 16,
        color       = 0xFFFFFFFF,
        position    = { -180, 20 },
    },
    show_name   = false,
    show_id     = false,
    show_id_hex = false
};
local distance_config = default_config;

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Attempt to load the configuration..
    distance_config = settings:load(_addon.path .. 'settings/settings.json') or default_config;
    distance_config = table.merge(default_config, distance_config);

    -- Create our font object..
    local f = AshitaCore:GetFontManager():CreateFontObject( '__distance_addon' );
    f:SetBold( true );
    f:SetColor( distance_config.font.color );
    f:SetFont( distance_config.font.name, distance_config.font.size );
    f:SetPosition( distance_config.font.position[1], distance_config.font.position[2] );
    f:SetText( '0.0' );
    f:SetVisibility( true );
end );

---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    -- Obtain the font position..
    local f = AshitaCore:GetFontManager():GetFontObject( '__distance_addon' );
    distance_config.font.position = { f:GetPositionX(), f:GetPositionY() };

    -- Save the configuration..
    settings:save(_addon.path .. 'settings/settings.json', distance_config);

    -- Cleanup our font object..
    AshitaCore:GetFontManager():DeleteFontObject( '__distance_addon' );
end );

---------------------------------------------------------------------------------------------------
-- func: Render
-- desc: Called when our addon is rendered.
---------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    local f = AshitaCore:GetFontManager():CreateFontObject( '__distance_addon' );
    
    -- Ensure we have a valid player..
    local party = AshitaCore:GetDataManager():GetParty();
    if (party:GetPartyMemberActive(0) == false or party:GetPartyMemberID(0) == 0) then
        f:SetText( '0.0' );
        return;
    end
    
    -- Ensure we have a valid target..
    local target = AshitaCore:GetDataManager():GetTarget():GetTargetEntity();
    if (target == nil or target.Name == '' or target.TargetID == 0) then
        f:SetText( '0.0' );
        return;
    end
    
    local str = string.format( '%.1f', math.sqrt( target.Distance ) );
    
    -- Append the name..
    if (distance_config.show_name == true) then
        str = str .. ' ' .. target.Name;
    end
    
    -- Append the server id (decimal)..
    if (distance_config.show_id == true) then
        str = string.format( '%s [%d]', str, target.ServerID );
    end
    
    -- Append the server id (hex)..
    if (distance_config.show_id_hex == true) then
        str = string.format( '%s [%08X]', str, target.ServerID );
    end
    
    -- Set the distance text..
    f:SetText( str );
end );
