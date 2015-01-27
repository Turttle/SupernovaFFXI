  _addon.author   = 'bope';
_addon.name     = 'hmp';
_addon.version  = '1';
require 'common'
require 'color'
local timer   = 0;
local tick    = 20;
---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    local hmpwindow_x      = config:get_int('boot_config', 'window_x', 800);
    local hmpwindow_y      = config:get_int('boot_config', 'window_y', 600);
    local hmpmenu_x        = config:get_int('boot_config', 'menu_x', 0);
    local hmpmenu_y        = config:get_int('boot_config', 'menu_y', 0);
    
    -- Validate the configuration data..
    if (hmpmenu_x <= 0) then
        hmpmenu_x = hmpwindow_x;
    end
    if (hmpmenu_y <= 0) then
        hmpmenu_y = hmpwindow_y;
    end
    
    -- Calculate the scaling..
    hmpscaleX = hmpwindow_x / hmpmenu_x;
    hmpscaleY = hmpwindow_y / hmpmenu_y;
    local posX  = hmpwindow_x - (110 * hmpscaleX);
    local posY  = hmpwindow_y - (034 * hmpscaleY);
    local currX = posX - 30;
    local currY = posY - 11 - ((AshitaCore:GetDataManager():GetParty():GetAllianceParty0Count() - 1 ) * (20 * hmpscaleY));
    local hmp = AshitaCore:GetFontManager():CreateFontObject( "__hmp_ticker" );
    hmp:SetFont('Arial', 10 * hmpscaleY);
    hmp:SetBold(true);
    hmp:SetRightJustified(true);
    hmp:SetText('98');
    hmp:SetPosition(currX,currY);
    hmp:SetVisibility(false);
    hmp:SetLockPosition(true);
end );

---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()    
end );

ashita.register_event('render', function()
    if (os.time() >= (timer + 1)) then
        timer = os.time();
        pindexz   =  AshitaCore:GetDataManager():GetParty():GetPartyMemberTargetIndex(0);
		player 	  =  AshitaCore:GetDataManager():GetEntity();
        if(player:GetStatus(pindexz) == 33) then
            local f = AshitaCore:GetFontManager():GetFontObject("__hmp_ticker");
            f:SetVisibility(true);
            f:SetText(tostring(tick));
            if(tick > 1) then
                tick = tick -1;
            else
                tick = 10;
            end
        else
            local f = AshitaCore:GetFontManager():GetFontObject("__hmp_ticker");
            f:SetVisibility(false);
            tick=20;
        end
        
    end
    end);

