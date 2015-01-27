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
_addon.name     = 'Recast';
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
        size        = 10,
        color       = 0xFFFF0000,
        position    = { 50, 125 },
        bgcolor     = 0x80000000,
        bgvisible   = true
    }
};
local recast_config = default_config;

---------------------------------------------------------------------------------------------------
-- func: color_recast_entry
-- desc: Colors a recast entry based on the time left to use it..
---------------------------------------------------------------------------------------------------
local function color_recast_entry( s, t )
    if (t >= 1200) then
        return s;
    elseif (t < 1200 and t > 300) then
        return string.format( '\\cs(255,255,0)%s\\cr', s );
    else
        return string.format( '\\cs(0,255,0)%s\\cr', s );
    end
end

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Attempt to load the fps configuration..
    recast_config = settings:load(_addon.path .. 'settings/recast.json') or default_config;
    recast_config = table.merge(default_config, recast_config);

    -- Create our font object..
    local f = AshitaCore:GetFontManager():CreateFontObject( '__recast_addon' );
    f:SetBold( false );
    f:SetColor( recast_config.font.color );
    f:SetFont( recast_config.font.name, recast_config.font.size );
    f:SetPosition( recast_config.font.position[1], recast_config.font.position[2] );
    f:SetText( '' );
    f:SetVisibility( true );
    f:GetBackground():SetColor( recast_config.font.bgcolor );
    f:GetBackground():SetVisibility( recast_config.font.bgvisible );
end );

---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    local f = AshitaCore:GetFontManager():GetFontObject( '__recast_addon' );
    recast_config.font.position = { f:GetPositionX(), f:GetPositionY() };
    
    -- Ensure the settings folder exists..
    if (not file:dir_exists(_addon.path .. 'settings')) then
        file:create_dir(_addon.path .. 'settings');
    end
    
    -- Save the configuration..
    settings:save(_addon.path .. 'settings/recast.json', recast_config);
    
    -- Unload our font object..
    AshitaCore:GetFontManager():DeleteFontObject( '__recast_addon' );
end );

---------------------------------------------------------------------------------------------------
-- func: Render
-- desc: Called when our addon is rendered.
---------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    local f = AshitaCore:GetFontManager():GetFontObject( '__recast_addon' );
    local r = AshitaCore:GetResourceManager();
    local e = { }; -- Ability recast entries..
    
    -- Read the ability recasts..
    for x = 0, 32 do
        local r_id = recast.GetAbilityRecastIdFromIndex( x );
        local r_cd = recast.GetAbilityRecastByIndex( x );
        if ((r_id ~= 0 or x == 0) and r_cd > 0) then
            local r_an = r:GetAbilityByTimerID( r_id ).Name[0];
            if (x == 0) then 
                r_an = 'One Hour';
            end
            table.insert( e, color_recast_entry( string.format( ' %s : %s ', recast.FormatTimestamp( r_cd ), r_an ), r_cd ) );
        end
    end
    
    -- Read the spell recasts..
    for x = 1, 1025 do
        local r_id = x;
        local r_cd = recast.GetSpellRecastByIndex( x );
        if (r_cd > 0) then
            local r_an = r:GetSpellByID( r_id );
            if (r_an ~= nil) then r_an = r_an.Name[0]; end
            if (r_an == nil or string.len( r_an ) == 0) then
                r_an = string.format( 'Unknown Spell: %d', r_id );
            end
            table.insert( e, color_recast_entry( string.format( ' %s : %s ', recast.FormatTimestamp( r_cd ), r_an ), r_cd ) );
        end
    end
    
    -- Set the recast text..
    local output = table.concat( e, '\n' );
    f:SetText( output );
end );
