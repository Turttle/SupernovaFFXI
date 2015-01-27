--[[
 *	The MIT License (MIT)
 *
 *	Copyright (c) 2014 MalRD
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

_addon.author   = 'MalRD';
_addon.name     = 'Find';
_addon.version  = '2.0.1';

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
end );

---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
end );

----------------------------------------------------------------------
-- func : printf
-- desc : Because printing without formatting is for the birds.
----------------------------------------------------------------------
function printf(s,...)
	print(s:format(...));
end;

------------------------------------------------------------------------------------------
-- func: getStorageString
-- desc: Converts a storage index into the name of the container.
-- args: storageIndex		-> the storage index to get the name of.
-- returns: a string representation of the storage location name.
------------------------------------------------------------------------------------------
local function getStorageString(storageIndex)
	if (storageIndex == 0) then
		return "Inventory";
	elseif (storageIndex == 1) then
		return "Safe";
	elseif (storageIndex == 2) then
		return "Storage";
	elseif (storageIndex == 3) then
		return "Temp";
	elseif (storageIndex == 4) then
		return "Locker";
	elseif (storageIndex == 5) then
		return "Satchel";
	elseif (storageIndex == 6) then
		return "Sack";
	elseif (storageIndex == 7) then
		return "Case";
	elseif (storageIndex == 8) then
		return "Wardrobe";
	end
	
	return "UNKNOWN";
end

------------------------------------------------------------------------------------------
-- func: find
-- desc: Attempts to match the supplied cleanString to the supplied item.
-- args: item 				-> the item being matched against.
--       cleanString 		-> the cleaned string being searched for.
--		 useDescription 	-> true if the item description should be searched.
-- returns: true if a match is found, otherwise false.
------------------------------------------------------------------------------------------
local function find(item, cleanString, useDescription)
	if (item == nil) then return false end;
	if (cleanString == nil) then return false end;

	if (string.lower(item.Name):find(cleanString)) then
		return true;
	elseif (useDescription and item.Description ~= nil) then
		return (string.lower(item.Description):find(cleanString));
	end
	
	return false;
end

------------------------------------------------------------------------------------------
-- func: search
-- desc: Searches the player's inventory for an item that matches the supplied string.
-- args: searchString		-> the string that is being searched for.
--		 useDescription 	-> true if the item description should be searched.
------------------------------------------------------------------------------------------
local function search(searchString, useDescription) 
	if (searchString == nil) then return; end
	local cleanString = ParseAutoTranslate(searchString, false);
	
	if (cleanString == nil) then return; end
	cleanString = string.lower(cleanString);
	
	printf("\30\08Finding \"%s\"...", cleanString);
	local inventory = AshitaCore:GetDataManager():GetInventory();
	local resources = AshitaCore:GetResourceManager();
	
	for i = 0, 8, 1 do
		for j = 0, inventory:GetInventoryMax(i), 1 do
			local itemEntry = inventory:GetInventoryItem(i, j);
			if (itemEntry.Id ~= 0 and itemEntry.Id ~= 65535) then
				local item = resources:GetItemByID(itemEntry.Id);
				
				if (item ~= nil) then
					if (find(item, cleanString, useDescription)) then
						if (itemEntry.Count ~= nil and item.StackSize > 1) then
							printf("%s: %s [%d]", getStorageString(i), item.Name, itemEntry.Count);
						else
							printf("%s: %s", getStorageString(i), item.Name)
						end
					end
				end
			end
		end
	end	
end

------------------------------------------------------------------------------------------
-- func: getFindArgs
-- desc: Gets args from incoming command lines, returning nil if the line is not a find
--		 line.
------------------------------------------------------------------------------------------
local function getFindArgs(cmd)
	if (not cmd:find('/find', 1, true)) then return nil; end
	
	local indexOf = cmd:find(' ', 1, true);
	if (indexOf == nil) then return nil; end
	
	return
	{ 
		[1] = cmd:sub(1,indexOf-1),  
		[2] = cmd:sub(indexOf+1)
	};
end

---------------------------------------------------------------------------------------------------
-- func: Command
-- desc: Called when our addon is commanded!
---------------------------------------------------------------------------------------------------
ashita.register_event('command', function(cmd, nType)
	local args = getFindArgs(cmd);
	if (args == nil or #args < 2) then return false; end
	
	if (args[1]:lower() == '/find') then
		search(args[2]:lower(), false);
		return true;
    elseif (args[1]:lower() == '/findmore') then
		search(args[2]:lower(), true);
		return true;
	end;
	
	return false;
end );