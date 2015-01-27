--[[
 *
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
 *
]]--

local settings = { };

__ashita_libs = __ashita_libs or { };
__ashita_libs.settings = settings;
__ashita_libs.settings.JSON = __ashita_libs.settings.JSON or require 'JSON.json';

---------------------------------------------------------------------------------------------------
-- func: normalize_path
-- desc: Normalizes a path to use all-backslashes. (Removes double-slashes.)
---------------------------------------------------------------------------------------------------
function file.normalize_path(path)
    -- Convert all slashes to a normalized slash..
    local p = path:gsub('/', '\\');

    -- Locate all double slashes..
    local index = p:find('\\');
    while (index ~= nil) do
        if (p:sub(index+1, index+1) == '\\') then
            p = p:remove(index);
            index = p:find('\\');
        else
            index = p:find('\\', index + 1);
        end
    end
    return p;
end

---------------------------------------------------------------------------------------------------
-- func: path_from_dir
-- desc: Obtains a path from the file location.
---------------------------------------------------------------------------------------------------
function file.path_from_dir(dir)
    -- Ensure we have a file name..
    if (dir:find('%.') == nil) then
        return dir;
    end

    -- Find the location of the first slash..
    local slash = dir:find('\\');
    if (slash == nil) then
        return dir;
    end

    -- Find the location of the last slash..
    while (true) do
        local char = dir:find('\\', slash + 1);
        if (char == nil) then
            break;
        end
        slash = char;
    end
    
    -- Remove the ending file from the path..
    return dir:sub(0, slash - 1);
end

---------------------------------------------------------------------------------------------------
-- func : settings.save
-- desc : Saves a table as a JSON config file.
-- retn : True on success, false otherwise.
---------------------------------------------------------------------------------------------------
function settings:save(name, t)
    -- JSON encode the settings..
    local cfg = settings.JSON:encode_pretty(t);
    if (cfg == nil) then
        log_error('Failed to generate json configuration.');
        return false;
    end
    
    -- Normalize the path..
    local name = file.normalize_path(name);
    
    -- Ensure the path exists..
    local dir = file.path_from_dir(name);
    if (not file.dir_exists(dir)) then
        -- Create the directory..
        file.create_dir(dir);
    end
        
    -- Attempt to save the file..
    local f = io.open(name, 'w');
    if (f == nil) then
        log_error('Failed to save configuration.');
        return false;
    end

    -- Write the file data..
    f:write(cfg);
    f:close();

    return true;
end

---------------------------------------------------------------------------------------------------
-- func : settings.load
-- desc : Loads a json configuration file into a table.
-- retn : Table on success, nil otherwise.
---------------------------------------------------------------------------------------------------
function settings:load(name)
    -- Attempt to open the file..
    local f = io.open(name, 'r');
    if (f == nil) then
        return nil;
    end

    -- Read the file data..
    local raw_cfg = f:read('*a');
    f:close();

    -- Attempt to decode the file data..
    local cfg = settings.JSON:decode(raw_cfg);
    if (type(cfg) == 'table') then
        return cfg;
    end

    return nil;
end

return settings;
