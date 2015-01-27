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

--
-- Includes commonly used Lua files for an addon.
--

require 'color'
require 'log'
require 'mathex'
settings = require 'settings'
require 'stringex'
require 'tableex'

---------------------------------------------------------------------------------------------------
-- FFXI Specific Requires
---------------------------------------------------------------------------------------------------
require 'ffxi.common'
recast      = require 'ffxi.recast'
vanatime    = require 'ffxi.vanatime'
weather     = require 'ffxi.weather'

---------------------------------------------------------------------------------------------------
-- desc: Switch Case for Lua (Credits: Unknown Author)
---------------------------------------------------------------------------------------------------
function switch(c)
    local switch_table = 
    {
        casevar = c,
        caseof = function(self,code)
            local f;
            if (self.casevar) then
                f = code[self.casevar] or code.default;
            else
                f = code.missing or code.default;
            end
            if f then
                if (type(f) == 'function') then
                    return f(self.casevar,self);
                else
                    error('case: ' .. tostring(self.casevar) .. ' is not a function!');
                end
            end
        end
    };
    return switch_table
end
