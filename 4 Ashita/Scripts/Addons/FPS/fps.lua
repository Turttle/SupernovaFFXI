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
_addon.name     = 'FPS';
_addon.version  = '1.0';

require 'common'

---------------------------------------------------------------------------------------------------
-- desc: Default FPS configuration table.
---------------------------------------------------------------------------------------------------
local default_config =
{
    font =
    {
        name        = 'Arial',
        size        = 12,
        color       = 0xFFFF0000,
        position    = { 1, 1 },
    },
    format = 'FPS: %.1f'
};
local fps_config = default_config;

---------------------------------------------------------------------------------------------------
-- desc: Main FPS table to hold useful variables.
---------------------------------------------------------------------------------------------------
local fps = { };
fps.count = 0;
fps.timer = 0;
fps.frame = 0;
fps.show  = true;

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Attempt to load the fps configuration..
    fps_config = settings:load(_addon.path .. 'settings/fps.json') or default_config;
    fps_config = table.merge(default_config, fps_config);

    -- Create our font object..
    local f = AshitaCore:GetFontManager():CreateFontObject( '__fps_addon' );
    f:SetBold( false );
    f:SetColor( fps_config.font.color );
    f:SetFont( fps_config.font.name, fps_config.font.size );
    f:SetPosition( fps_config.font.position[1], fps_config.font.position[2] );
    f:SetText( '' );
    f:SetVisibility( fps.show );
end );

---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    -- Save the configuration..
    local f = AshitaCore:GetFontManager():GetFontObject( '__fps_addon' );
    fps_config.font.position = { f:GetPositionX(), f:GetPositionY() };
    settings:save(_addon.path .. 'settings/fps.json', fps_config);
    
    -- Cleanup our font object..
    AshitaCore:GetFontManager():DeleteFontObject( '__fps_addon' );
end );

---------------------------------------------------------------------------------------------------
-- func: Command
-- desc: Called when our addon receives a command.
---------------------------------------------------------------------------------------------------
ashita.register_event('command', function(cmd, nType)
    -- Pull the command args..
    local args = cmd:GetArgs();
    
    -- Ensure we got an fps command..
    if (args[1] ~= "/fps") then
        return false;
    end
    
    -- Toggle showing the fps string..
    if (#args == 1 or args[2] == 'show') then
        fps.show = not fps.show;
        return true;
    end
    
    -- Set the color of the object..
    if (args[2] == 'color') then
        if (#args ~= 6) then
            return true;
        end
        
        fps_config.font.color = math.ToD3DColor( tonumber(args[3]), tonumber(args[4]), tonumber(args[5]), tonumber(args[6]) );
        local f = AshitaCore:GetFontManager():GetFontObject( '__fps_addon' );
        f:SetColor( fps_config.font.color );
        return true;
    end
    
    -- Set the font of the object..
    if (args[2] == 'font') then
        if (#args ~= 4) then
            return true;
        end
        
        fps_config.font.name = args[3];
        fps_config.font.size = tonumber(args[4]);
        
        local f = AshitaCore:GetFontManager():GetFontObject( '__fps_addon' );
        f:SetFont(args[3], tonumber(args[4]));
        return true;
    end
    
    -- Do we want to set the fps limit..
    if (tonumber(args[2]) > 0) then
    
        -- Attempt to locate the FPS pattern..
        local fpscap = { 0x81, 0xEC, 0x00, 0x01, 0x00, 0x00, 0x3B, 0xC1, 0x74, 0x21, 0x8B, 0x0D };
        local fpsaddr = mem:FindPattern('FFXiMain.dll', fpscap, #fpscap, 'xxxxxxxxxxxx');
        if (fpsaddr == 0) then
            print('[FPS] Could not locate required signature!');
            return true;
        end

        -- Read the address..
        local addr = mem:ReadULong(fpsaddr + 0x0C);
        addr = mem:ReadULong(addr);
        mem:WriteULong(addr + 0x30, tonumber(args[2]));
        print(string.format('\30\02[\30\01FPS\30\02] \30\06Set FPS divisor to: \30\02%d', tonumber(args[2])));
        return true;
    end
    
    return true;
end );

---------------------------------------------------------------------------------------------------
-- func: Render
-- desc: Called when our addon is rendered.
---------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    local f = AshitaCore:GetFontManager():GetFontObject( '__fps_addon' );
    f:SetVisibility(fps.show);
    
    -- Don't continue if we have nothing to draw..
    if (fps.show == false) then
        return;
    end
    
    -- Calculate the frames..
    fps.count = fps.count + 1;
    if (os.time() >= (fps.timer + 1)) then
        fps.frame = fps.count;
        fps.count = 0;
        fps.timer = os.time();
    end
    
    f:SetText(string.format(fps_config.format, fps.frame));
end );
