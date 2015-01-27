_addon.author   = 'bluekirby0';
_addon.name     = 'Repeater';
_addon.version  = '1.0';

require 'common'
local __go;
local __command;
local __timer;
local __cycle;

function read_fps_divisor() -- borrowed from fps addon
    local fpscap = { 0x81, 0xEC, 0x00, 0x01, 0x00, 0x00, 0x3B, 0xC1, 0x74, 0x21, 0x8B, 0x0D };
    local fpsaddr = mem:FindPattern('FFXiMain.dll', fpscap, #fpscap, 'xxxxxxxxxxxx');
    if (fpsaddr == 0) then
        print('[FPS] Could not locate required signature!');
        return true;
    end

    -- Read the address..
    local addr = mem:ReadULong(fpsaddr + 0x0C);
    addr = mem:ReadULong(addr);
    return mem:ReadULong(addr + 0x30);
end;

ashita.register_event('load', function(cmd, nType)
    __go = false;
    __command = "";
    __timer = 0;
    __cycle = 5;
end );

ashita.register_event('command', function(cmd, nType)
    -- Ensure we should handle this command..
    local args = cmd:GetArgs();
    if (args[1] ~= '/repeat') then
        return false;
    elseif (#args < 2) then
        return true;
    elseif ((args[2] == 'set') and (#args >= 3)) then
        __command = table.concat(args," ",3,#args);
        print ("Command to be repeated: " .. __command);
        return true;
    elseif (args[2] == 'start') then
        if(#__command > 1) then
            print("Starting cycle!")
            __go = true;
        else
            print("Set a command first!")
        end
        return true;
    elseif (args[2] == 'stop') then
        __go = false;
        print("Cycle Terminated!")
        return true;
    elseif ((args[2] == 'cycle') and (#args == 3)) then
        __cycle = tonumber(args[3]);
        if(__cycle < 1) then __cycle = 1 end
        __timer = 0;
        print("Commands will be executed every " .. __cycle .. " seconds!")
    elseif (args[2] == 'help') then
        print("Valid commands are set start stop and cycle")
    end
    return false;
end );

ashita.register_event('render', function()
    if(__go) then
        if(__timer == (60 / read_fps_divisor() * __cycle)) then
            AshitaCore:GetChatManager():QueueCommand(__command, 1);
            __timer = 0;
        else
            __timer = __timer + 1;
        end
    end
end );