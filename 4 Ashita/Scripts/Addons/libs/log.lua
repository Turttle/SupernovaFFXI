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

local log = { };

__ashita_libs = __ashita_libs or { };
__ashita_libs.log = log;

require 'stringex'

---------------------------------------------------------------------------------------------------
-- func: log_string
-- desc: Prints the given string to the chat log in the given color.
---------------------------------------------------------------------------------------------------
function log_string(color, type, ...)
    local t = table.concat({table.concat({color, '[ADDON] ', type, '(', _addon.name, ') '}, ''), unpack({...})}, ' '):trim();
    AshitaCore:GetChatManager():AddChatMessage(200, t:clean());
end

---------------------------------------------------------------------------------------------------
-- func: log_message
-- desc: Prints a normal log message to the chat log.
---------------------------------------------------------------------------------------------------
function log_message(...)
    log_string('', '', ...);
end

---------------------------------------------------------------------------------------------------
-- func: log_error
-- desc: Prints an error message to the chat log.
---------------------------------------------------------------------------------------------------
function log_error(...)
    log_string('\31\167', 'Error: ', ...);
end

---------------------------------------------------------------------------------------------------
-- func: log_warning
-- desc: Prints a warning message to the chat log.
---------------------------------------------------------------------------------------------------
function log_warning(...)
    log_string('\30\207', 'Warning: ', ...);
end
