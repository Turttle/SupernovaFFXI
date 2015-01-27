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
_addon.name     = 'ibar';
_addon.version  = '1.02';

require 'common'
require 'mathex'

	  mb_data = {};
	arraySize = 0;

	jobs = {
		[1]  = 'WAR',
		[2]  = 'MNK',
		[3]  = 'WHM',
		[4]  = 'BLM',
		[5]  = 'RDM',
		[6]  = 'THF',
		[7]  = 'PLD',
		[8]  = 'DRK',
		[9]  = 'BST',
		[10] = 'BRD',
		[11] = 'RNG',
		[12] = 'SAM',
		[13] = 'NIN',
		[14] = 'DRG',
		[15] = 'SMN',
		[16] = 'BLU',
		[17] = 'COR',
		[18] = 'PUP',
		[19] = 'DNC',
		[20] = 'SCH',
		[21] = 'GEO',
		[22] = 'RUN'
	};
	
---------------------------------------------------------------------------------------------------
-- desc: Default ibar configuration table.
---------------------------------------------------------------------------------------------------
local default_config =
{
    font =
    {
        name        = 'Arial',
        size        = 10,
        color		= '255,255,255,255',
        position    = { 130, 0 },
        bgcolor     = '204,0,0,0',
        bgvisible   = true,
		bold		= true
    },
	layout =
	{
		player = '$zone $name  [$level]  [$position]',
		target = '$target  [$job / $level / $aggro]  Weak[$weak]  [$position]',
		npc = '$target [$position] [ID: $id / Index: $m_index]'
	}
};
local ibar_config = default_config;

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
	
	ibar_config = settings:load(_addon.path .. 'settings/ibar.json') or default_config;
    ibar_config = table.merge(default_config, ibar_config);
	
	local a,r,g,b = ibar_config.font.color:match("([^,]+),([^,]+),([^,]+),([^,]+)");
	local fcolor = math.ToD3DColor(a,r,g,b);
	local a,r,g,b = ibar_config.font.bgcolor:match("([^,]+),([^,]+),([^,]+),([^,]+)");
	local bcolor = math.ToD3DColor(a,r,g,b);

	local f = AshitaCore:GetFontManager():CreateFontObject( '__ibar_addon' );
    f:SetBold( ibar_config.font.bold );
    f:SetColor( fcolor );
    f:SetFont( ibar_config.font.name, ibar_config.font.size );
    f:SetPosition( ibar_config.font.position[1], ibar_config.font.position[2] );
	f:SetText( '' );
    f:SetVisibility( false );
	f:GetBackground():SetColor( bcolor );
    f:GetBackground():SetVisibility( ibar_config.font.bgvisible );
	
	local ZoneID	= AshitaCore:GetDataManager():GetParty():GetPartyMemberZone(0);
	
	mb_data = require('data.' .. tostring(ZoneID));
    if (mb_data == nil or type(mb_data) ~= 'table') then
        mb_data = { };
    end
	
	arraySize = table.getn(mb_data);
end );

---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
	local f = AshitaCore:GetFontManager():GetFontObject( '__ibar_addon' );
	ibar_config.font.position = { f:GetPositionX(), f:GetPositionY() };

    if (not file:dir_exists(_addon.path .. 'settings')) then
        file:create_dir(_addon.path .. 'settings');
    end
	
	settings:save(_addon.path .. 'settings/ibar.json', ibar_config);
	
	AshitaCore:GetFontManager():DeleteFontObject( '__ibar_addon' );
end );

---------------------------------------------------------------------------------------------------
-- func: Render
-- desc: Called when our addon is rendered.
---------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    local f         = AshitaCore:GetFontManager():GetFontObject( '__ibar_addon' );
	local Entity	= AshitaCore:GetDataManager():GetEntity();
    local party     = AshitaCore:GetDataManager():GetParty();
	local player	= AshitaCore:GetDataManager():GetPlayer();
	local target    = AshitaCore:GetDataManager():GetTarget();
	local ZoneName	= AshitaCore:GetResourceManager():GetString('areas', party:GetPartyMemberZone(0));
	
	-- disable view if no player
	if (player:GetMainJobLevel() == 0) then
		f:SetVisibility(false);
		return;
	end
	
	f:SetVisibility(true);
	
	ibar_config = settings:load(_addon.path .. 'settings/ibar.json') or default_config;
    ibar_config = table.merge(default_config, ibar_config);
	
	-- obtain values from json configuration.
	
	local s_target = ibar_config.layout.player;
	
	local name = string.find(s_target,'$name');
	local zone = string.find(s_target,'$zone');
	local z_id = string.find(s_target,'$z_id');
	local mlvl = string.find(s_target,'$level');
	local gpos = string.find(s_target,'$position');
	local ecom = string.find(s_target,'$ecompass');
	local scom = string.find(s_target,'$scompass');
	local p_hp = string.find(s_target,'$hpp');
	local m_id = string.find(s_target,'$id');
	local m_ix = string.find(s_target,'$m_index');
	
	-- obtain player position.
	local pX = string.format('%2.3f',Entity:GetLocalX(party:GetPartyMemberTargetIndex(0)));
	local pY = string.format('%2.3f',Entity:GetLocalY(party:GetPartyMemberTargetIndex(0)));
	local pZ = string.format('%2.3f',Entity:GetLocalZ(party:GetPartyMemberTargetIndex(0)));
	local pH = string.format('%2.3f',Entity:GetLocalYaw(party:GetPartyMemberTargetIndex(0)));
	
	local sResult = '';
	local eResult = '';
	
	if (ecom ~= nil or scom ~= nil) then
		local degrees = pH * (180 / math.pi) + 90;
		
		if (degrees > 360) then
			degrees = degrees - 360;
		elseif (degrees < 0) then
			degrees = degrees + 360;
		end
		
		sResult = math.floor(degrees);
		
		if (337 < degrees or 23 >= degrees) then
            eResult = string.format('\\cs(120,120,120,120)N\\cr');
            sResult = 'N';
        elseif (23 < degrees and 68 >= degrees) then
            eResult = string.format('\\cs(255,255,255,255)NE\\cr');
            sResult = 'NE';
        elseif (68 < degrees and 113 >= degrees) then
            eResult = string.format('\\cs(44,240,232,255)E\\cr');
            sResult = 'E';
        elseif (113 < degrees and 158 >= degrees) then
            eResult = string.format('\\cs(73,255,73,200)SE\\cr');
            sResult = 'SE';
        elseif (158 < degrees and 203 >= degrees) then
            eResult = string.format('\\cs(255,201,0,198)S\\cr');
            sResult = 'S';
        elseif (203 < degrees and 248 >= degrees) then
            eResult = string.format('\\cs(205,24,205,200)SW\\cr');
            sResult = 'SW';
        elseif (248 < degrees and 293 >= degrees) then
            eResult = string.format('\\cs(73,73,255,255)W\\cr');
            sResult = 'W';
        elseif (293 < degrees and 337 >= degrees) then
            eResult = string.format('\\cs(255,25,0,255)NW\\cr');
            sResult = 'NW';
        end
	end
	
	-- attempt to display player information.
	-- check if player selected and or nothing selected.
	
	if (target:GetTargetEntity() == nil or target:GetTargetName() == '' or target:GetTargetID() == 0 or
		target:GetTargetID() == party:GetPartyMemberID(0)) then
		
		-- player does not have a sub-job unlocked.
		if (player:GetSubJobLevel() == 0) then
			
			if (name ~= nil) then s_target = string.gsub(s_target,'$name',party:GetPartyMemberName(0)); end
			if (z_id ~= nil) then s_target = string.gsub(s_target,'$z_id',party:GetPartyMemberZone(0)); end
			if (zone ~= nil) then s_target = string.gsub(s_target,'$zone',ZoneName); end
			if (p_hp ~= nil) then s_target = string.gsub(s_target,'$hpp',party:GetPartyMemberHPP(0)); end
			if (m_id ~= nil) then s_target = string.gsub(s_target,'$id',target:GetTargetID()); end
			if (m_ix ~= nil) then s_target = string.gsub(s_target,'$m_index',target:GetTargetIndex()); end
			
			if (mlvl ~= nil) then
				s_target = string.gsub(s_target,'$level',
				jobs[player:GetMainJob()] ..
				player:GetMainJobLevel());
			end
			
			if (gpos ~= nil) then s_target = string.gsub(s_target,'$position',pX .. ', ' .. pY .. ', ' .. pZ); end
			if (ecom ~= nil) then s_target = string.gsub(s_target,'$ecompass',eResult); end
			if (scom ~= nil) then s_target = string.gsub(s_target,'$scompass',sResult); end
			
			f:SetText(string.format(s_target));
			return;
		
		--	player has sub-job unlocked.
		elseif (player:GetSubJobLevel() > 0) then
			
			if (name ~= nil) then s_target = string.gsub(s_target,'$name',party:GetPartyMemberName(0)); end
			if (z_id ~= nil) then s_target = string.gsub(s_target,'$z_id',party:GetPartyMemberZone(0)); end
			if (zone ~= nil) then s_target = string.gsub(s_target,'$zone',ZoneName); end
			if (p_hp ~= nil) then s_target = string.gsub(s_target,'$hpp',party:GetPartyMemberHPP(0)); end
			if (m_id ~= nil) then s_target = string.gsub(s_target,'$id',target:GetTargetID()); end
			if (m_ix ~= nil) then s_target = string.gsub(s_target,'$m_index',target:GetTargetIndex()); end
			
			if (mlvl ~= nil) then
				s_target = string.gsub(s_target,'$level',
				jobs[player:GetMainJob()] ..
				player:GetMainJobLevel() .. '/' ..
				jobs[player:GetSubJob()] ..
				player:GetSubJobLevel());
			end
			
			if (gpos ~= nil) then s_target = string.gsub(s_target,'$position',pX .. ', ' .. pY .. ', ' .. pZ); end
			if (ecom ~= nil) then s_target = string.gsub(s_target,'$ecompass',eResult); end
			if (scom ~= nil) then s_target = string.gsub(s_target,'$scompass',sResult); end
			
			f:SetText(string.format(s_target));
			return;
		end
	end
	
	local m_target = ibar_config.layout.target;
	
		  name = string.find(m_target,'$target');
		  zone = string.find(m_target,'$zone');
		  mlvl = string.find(m_target,'$level');
		  gpos = string.find(m_target,'$position');
		  m_id = string.find(m_target,'$id');
		  m_ix = string.find(m_target,'$m_index');
	local flag = string.find(m_target,'$aggro');
	local mjob = string.find(m_target,'$job');
	local weak = string.find(m_target,'$weak');
	local m_hp = string.find(m_target,'$hpp');
	
	-- attempt to obtain target information.
	if (target:GetTargetID() ~= nil) then
		for i = 1, arraySize do
			if (tonumber(mb_data[i].id) == target:GetTargetID()) then
				if (mb_data[i].sj == mb_data[i].mj) then
					
					pX = string.format('%2.3f',target:GetTargetEntity().Movement.LocalPosition.X);
					pY = string.format('%2.3f',target:GetTargetEntity().Movement.LocalPosition.Y);
					pZ = string.format('%2.3f',target:GetTargetEntity().Movement.LocalPosition.Z);
					
					if (name ~= nil) then m_target = string.gsub(m_target,'$target',target:GetTargetEntity().Name); end
					if (zone ~= nil) then m_target = string.gsub(m_target,'$zone',ZoneName); end
					if (m_id ~= nil) then m_target = string.gsub(m_target,'$id',target:GetTargetID()); end
					if (m_ix ~= nil) then m_target = string.gsub(m_target,'$m_index',target:GetTargetIndex()); end
					if (mjob ~= nil) then m_target = string.gsub(m_target,'$job',jobs[tonumber(mb_data[i].mj)]); end
					if (mlvl ~= nil) then m_target = string.gsub(m_target,'$level',mb_data[i].mlvl); end
					if (gpos ~= nil) then m_target = string.gsub(m_target,'$position', pX .. ',' .. pY .. ',' .. pZ); end
					if (weak ~= nil) then m_target = string.gsub(m_target,'$weak',mb_data[i].weak); end
					if (m_hp ~= nil) then m_target = string.gsub(m_target,'$hpp',target:GetTargetEntity().HealthPercent); end
					
					if (flag ~= nil) then
						if (mb_data[i].links == 'Y') then
							m_target = string.gsub(m_target,'$aggro',mb_data[i].aggro .. ',L');
						else
							m_target = string.gsub(m_target,'$aggro',mb_data[i].aggro);
						end
					end
					
					f:SetText(string.format(m_target));
					return;
				
				else
				
					pX = string.format('%2.3f',target:GetTargetEntity().Movement.LocalPosition.X);
					pY = string.format('%2.3f',target:GetTargetEntity().Movement.LocalPosition.Y);
					pZ = string.format('%2.3f',target:GetTargetEntity().Movement.LocalPosition.Z);
					
					if (name ~= nil) then m_target = string.gsub(m_target,'$target',target:GetTargetEntity().Name); end
					if (zone ~= nil) then m_target = string.gsub(m_target,'$zone',ZoneName); end
					if (m_id ~= nil) then m_target = string.gsub(m_target,'$id',target:GetTargetID()); end
					if (m_ix ~= nil) then m_target = string.gsub(m_target,'$m_index',target:GetTargetIndex()); end
					if (mlvl ~= nil) then m_target = string.gsub(m_target,'$level',mb_data[i].mlvl); end
					if (gpos ~= nil) then m_target = string.gsub(m_target,'$position', pX .. ',' .. pY .. ',' .. pZ); end
					if (weak ~= nil) then m_target = string.gsub(m_target,'$weak',mb_data[i].weak); end
					if (m_hp ~= nil) then m_target = string.gsub(m_target,'$hpp',target:GetTargetEntity().HealthPercent);  end
					
					if (mjob ~= nil) then
						m_target = string.gsub(m_target,'$job',
						jobs[tonumber(mb_data[i].mj)] .. '/' ..
						jobs[tonumber(mb_data[i].sj)]);
					end
					
					if (flag ~= nil) then
						if (mb_data[i].links == 'Y') then
							m_target = string.gsub(m_target,'$aggro',mb_data[i].aggro .. ',L');
						else
							m_target = string.gsub(m_target,'$aggro',mb_data[i].aggro);
						end
					end
					
					f:SetText(string.format(m_target));
					return;
				
				end
			end
		end
		
		m_target = ibar_config.layout.npc;
		
		m_id = string.find(m_target,'$id');
		m_ix = string.find(m_target,'$m_index');
		gpos = string.find(m_target,'$position');
		n_hp = string.find(m_target,'$hpp');
		
		pX = string.format('%2.3f',target:GetTargetEntity().Movement.LocalPosition.X);
		pY = string.format('%2.3f',target:GetTargetEntity().Movement.LocalPosition.Y);
		pZ = string.format('%2.3f',target:GetTargetEntity().Movement.LocalPosition.Z);
		
		if (name ~= nil) then m_target = string.gsub(m_target,'$target',target:GetTargetEntity().Name); end
		if (m_id ~= nil) then m_target = string.gsub(m_target,'$id',target:GetTargetID()); end
		if (m_ix ~= nil) then m_target = string.gsub(m_target,'$m_index',target:GetTargetIndex()); end
		if (gpos ~= nil) then m_target = string.gsub(m_target,'$position', pX .. ',' .. pY .. ',' .. pZ); end
		if (n_hp ~= nil) then m_target = string.gsub(m_target,'$hpp',target:GetTargetEntity().HealthPercent); end
		
		f:SetText(string.format(m_target));
		return;
	end
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
        mb_data = require('data.' .. tostring(zoneId));
        if (mb_data == nil or type(mb_data) ~= 'table') then
            mb_data = { };
        end
		
		arraySize = table.getn(mb_data);
    end
	
    return false;
end );