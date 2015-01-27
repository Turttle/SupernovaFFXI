--[[
 *	The MIT License (MIT)
 *
 *	Copyright (c) 2014 Vicrelant
 *	
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to 
 *	deal in the Software without restriction, including without limitation the 
 *	rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
 *	sell copies of the Software, and to permit persons to whom the Software is 
 *	furnished to do so, subject to the following conditions:
 *	
 *	The above copyright notice and this permission notice shall be included in 
 *	all copies or substantial portions of the Software.
 *	
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 *	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 *	DEALINGS IN THE SOFTWARE.
]]--

_addon.author   = 'Vicrelant';
_addon.name     = 'pbar';
_addon.version  = '1.0';

require 'common'
require 'math'

---------------------------------------------------------------------------------------------------
-- desc: Default iBar configuration table.
---------------------------------------------------------------------------------------------------
local default_config =
{
    font =
    {
        name        = 'Arial',
        size        = 10,
        color       = 0xFFFFFFFF,
        position    = { 7, 120 },
        bgcolor     = 0x80000000,
        bgvisible   = true,
		bold		= true
    },
	color =
	{
		hp_color	= '255,255,255',
		tp_color	= '255,255,255',
		
		tp_color_99	= '255,0,0',
		hp_color_75	= '255,255,0',
		hp_color_50	= '255,165,0',
		hp_color_25	= '255,0,0',
	}
};
local pbar_config = default_config;

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    
	pbar_config = settings:load(_addon.path .. 'settings/pbar.json') or default_config;
    pbar_config = table.merge(default_config, pbar_config);

	-- Create our font object..
	local f = AshitaCore:GetFontManager():CreateFontObject( '__pbar_addon' );
    f:SetBold( pbar_config.font.bold );
    f:SetColor( pbar_config.font.color );
    f:SetFont( pbar_config.font.name, pbar_config.font.size );
    f:SetPosition( pbar_config.font.position[1], pbar_config.font.position[2] );
	f:SetText( '' );
    f:SetVisibility( false );
	f:GetBackground():SetColor( pbar_config.font.bgcolor );
    f:GetBackground():SetVisibility( pbar_config.font.bgvisible );
end );

---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
	 -- Ensure the settings folder exists..
    if (not file:dir_exists(_addon.path .. 'settings')) then
        file:create_dir(_addon.path .. 'settings');
    end
    
    -- Save the configuration..
    settings:save(_addon.path .. 'settings/pbar.json', pbar_config);
    
    -- Unload our font object..
    AshitaCore:GetFontManager():DeleteFontObject( '__pbar_addon' );
end );

---------------------------------------------------------------------------------------------------
-- func: Render
-- desc: Called when our addon is rendered.
---------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    
	local f     	= AshitaCore:GetFontManager():CreateFontObject( '__pbar_addon' );
	local party     = AshitaCore:GetDataManager():GetParty();
	local player	= AshitaCore:GetDataManager():GetPlayer();
	local me 		= GetPlayerEntity();
	
	-- Ensure we have a valid player..
    if (party:GetPartyMemberActive(0) == false or party:GetPartyMemberID(0) == 0) then
        return;
    end
	
	if (me == nil) then
		return;
	end
	
	local pet		= GetEntity(me.PetIndex);
	
	if (pet == nil) then
		return;
	end
	
	if (me.PetIndex == 0) then
		f:SetVisibility( false );
		return;
	end
	
	local pettp		= pet.PetTP/10;
	
	------------------------------------
	-- change color when TP is above 99%
	------------------------------------
	if (pettp > 99) then
		tp_color = pbar_config.color.tp_color_99;
	else
		tp_color = pbar_config.color.tp_color;
	end
	
	------------------------------------
	-- change color when HP is below 75%
	------------------------------------
	if (pet.HealthPercent < 25) then
		hp_color = pbar_config.color.hp_color_25;
	elseif (pet.HealthPercent < 50) then
		hp_color = pbar_config.color.hp_color_50;
	elseif (pet.HealthPercent < 75) then
		hp_color = pbar_config.color.hp_color_75;
	else
		hp_color = pbar_config.color.hp_color;
	end
	
	f:SetVisibility( true );
	
	-----------------------------------
	-- Format and output to the screen.
	-----------------------------------
	f:SetText(string.format('%s HP:[\\cs(255,%s)%d%%\\cr] TP:[\\cs(255,%s)%d%%\\cr]', 
	pet.Name, hp_color, pet.HealthPercent, tp_color, pet.PetTP/10));
	
end );
