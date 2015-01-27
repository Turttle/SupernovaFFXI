_addon.author   = 'bope'
_addon.name     = 'xper'
_addon.version  = '1.0'
require 'events'
local default_config =
{
	font =
    {
        name        = 'Arial',
        size        = 11,
        color		= '255,255,255,255',
        position    = { 15, 50 },
        bgcolor     = '180,0,0,0',
        bgvisible   = true,
		bold		= false
    },
	expmode   = '$tnl $ratek/hr Chain $chain:$time Gained:$gain($last)', 
	limitmode = '$limit/10k($merit) $ratek/hr Chain $chain:$time Gained:$gain($last)'
}
----------------------------------------------------------------------
-- $tnl   = Experience/neededExperience                             --
-- $rate  = Experience per hour listed in thousands                 --
-- $chain = Chain number of last kill                               --
-- $time  = Time you need to kill EM+ to keep chain                 --
-- $s_time= Total time this session                                 --
-- $gain  = Total experience you have gained this session           --
-- $last  = Last amount of experience you have gotten               --
-- $limit = Limit points                                            --
-- $merit = Merits you have stored                                  --
----------------------------------------------------------------------
local xper_config = default_config
local chainlengh = { 
			  {50,100,150,200,250,300,360},
			  {40,80 ,120,160,200,240,300},
			  {30,60 ,90 ,120,150,180,240},
			  {20,40 ,60 ,80 ,100,120,165},
			  {10,20 ,30 ,40 ,50 ,90 ,105},
			  {6 ,8  ,10 ,40 ,50 ,60 ,60 },
			  {2 ,4  ,5  ,30 ,50 ,60 ,60 }
			}
local chaintime = 0			
local f = nil
local starttime = 0
local totalexp  = 0
local chainl = 0
local last = 0
local timer = 0
---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
	xper_config = settings:load(_addon.path .. 'settings/xper.json') or default_config;
    xper_config = table.merge(default_config, xper_config);
	local a,r,g,b = xper_config.font.color:match("([^,]+),([^,]+),([^,]+),([^,]+)")
	local fcolor = math.ToD3DColor(a,r,g,b)
	local a,r,g,b = xper_config.font.bgcolor:match("([^,]+),([^,]+),([^,]+),([^,]+)")
	local bcolor = math.ToD3DColor(a,r,g,b)
	f = AshitaCore:GetFontManager():CreateFontObject( '__xper_addon' )
    f:SetBold( xper_config.font.bold )
    f:SetColor( fcolor )
    f:SetFont( xper_config.font.name, xper_config.font.size )
    f:SetPosition( xper_config.font.position[1], xper_config.font.position[2] )
	f:SetText( '' )
    f:SetVisibility( true )
	f:GetBackground():SetColor( bcolor )
    f:GetBackground():SetVisibility( xper_config.font.bgvisible )
end )
---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
	xper_config.font.position = { f:GetPositionX(), f:GetPositionY() };
    if (not file:dir_exists(_addon.path .. 'settings')) then
        file:create_dir(_addon.path .. 'settings');
    end
	settings:save(_addon.path .. 'settings/xper.json', xper_config);
	AshitaCore:GetFontManager():DeleteFontObject( '__xper_addon' )    
end )
ashita.register_event('command', function(cmd, nType)
  local args = cmd:GetArgs()
  local player = AshitaCore:GetDataManager():GetPlayer()
  local exptnl = string.format( '%i/%i' ,player:GetExpCurrent(),player:GetExpNeeded())
  local exphour = string.format( '%0.1f',(totalexp / ((os.time() - starttime) / 3600) / 1000))
  local s_time = os.time() - starttime
  local falg = false
  if(s_time > 1000000000)then s_time = 0 end
  if(args[1] == "/xper")then
	if(args[2] == "reset")then
		starttime = 0
		totalexp  = 0
		chaintime = 0			
		chainl = 0
		last = 0
		return false
	end
  end
	if(string.find(cmd,'<tnl>')    ~= nil)then cmd =string.gsub(cmd,'<tnl>',  exptnl) falg=true end
	if(string.find(cmd,'<limit>')  ~= nil)then cmd =string.gsub(cmd,'<limit>',player:GetLimitPoints()) falg=true end
	if(string.find(cmd,'<merit>')  ~= nil)then cmd =string.gsub(cmd,'<merit>',player:GetMeritPoints()) falg=true end
	if(string.find(cmd,'<rate>')   ~= nil)then cmd =string.gsub(cmd,'<rate>', exphour) falg=true end
	if(string.find(cmd,'<chain>')  ~= nil)then cmd =string.gsub(cmd,'<chain>',chainl) falg=true end
	if(string.find(cmd,'<time>')   ~= nil)then cmd =string.gsub(cmd,'<time>',chaintime) falg=true end
	if(string.find(cmd,'<gain>')   ~= nil)then cmd =string.gsub(cmd,'<gain>', totalexp) falg=true end
	if(string.find(cmd,'<last>')   ~= nil)then cmd =string.gsub(cmd,'<last>', last) falg=true end
	if(string.find(cmd,'<s_time>') ~= nil)then cmd =string.gsub(cmd,'<s_time>', s_time) falg=true end
	if(falg) then AshitaCore:GetChatManager():ParseCommand(string.format(cmd), 1) return true end
	return false
end )  

ashita.register_event('render', function()
	local player = AshitaCore:GetDataManager():GetPlayer()
	local exptnl = string.format( '%i/%i' ,player:GetExpCurrent(),player:GetExpNeeded())
	local exphour = string.format( '%0.1f',(totalexp / ((os.time() - starttime) / 3600) / 1000))
	local s_time = os.time() - starttime
	if(s_time > 1000000000)then s_time = ' ' end
	if(player:GetLimitMode() == 224)then
		local text = xper_config.limitmode 
		if(string.find(xper_config.limitmode,'$tnl')    ~= nil)then text =string.gsub(text,'$tnl',  exptnl) end
		if(string.find(xper_config.limitmode,'$limit')  ~= nil)then text =string.gsub(text,'$limit',player:GetLimitPoints())end
		if(string.find(xper_config.limitmode,'$merit')  ~= nil)then text =string.gsub(text,'$merit',player:GetMeritPoints())end
		if(string.find(xper_config.limitmode,'$rate')   ~= nil)then text =string.gsub(text,'$rate', exphour) end
		if(string.find(xper_config.limitmode,'$chain')  ~= nil)then text =string.gsub(text,'$chain',chainl)end
		if(string.find(xper_config.limitmode,'$time')   ~= nil)then text =string.gsub(text,'$time',chaintime)end
		if(string.find(xper_config.limitmode,'$gain')   ~= nil)then text =string.gsub(text,'$gain', totalexp)end
		if(string.find(xper_config.limitmode,'$last')   ~= nil)then text =string.gsub(text,'$last', last) end
		if(string.find(xper_config.limitmode,'$s_time') ~= nil)then text =string.gsub(text,'$s_time', s_time) end
		f:SetText(string.format(text))
	else
		local text = xper_config.expmode
		if(string.find(xper_config.expmode,'$tnl')    ~= nil)then text =string.gsub(text,'$tnl',  exptnl) end
		if(string.find(xper_config.expmode,'$rate')   ~= nil)then text =string.gsub(text,'$rate', exphour) end
		if(string.find(xper_config.expmode,'$chain')  ~= nil)then text =string.gsub(text,'$chain',chainl)end
		if(string.find(xper_config.expmode,'$time')   ~= nil)then text =string.gsub(text,'$time',chaintime)end
		if(string.find(xper_config.expmode,'$gain')   ~= nil)then text =string.gsub(text,'$gain', totalexp) end
		if(string.find(xper_config.expmode,'$last')   ~= nil)then text =string.gsub(text,'$last', last) end
		if(string.find(xper_config.expmode,'$s_time') ~= nil)then text =string.gsub(text,'$s_time', s_time) end
		f:SetText(string.format(text))
	end
	if (os.time() >= (timer + 1)) then
		timer = os.time()
		chaintime = math.max(chaintime - 1 , 0)
	end
end )
ashita.register_event('exp_gain', function(exp, chain, meritmode)
	 if(starttime == 0) then
		starttime = os.time()
	 end
	 chaintime = chainlengh[math.min(chain + 1,7)][math.min(math.floor(AshitaCore:GetDataManager():GetPlayer():GetMainJobLevel()/10),7)]
	 chainl = chain
	 last = exp
	 totalexp = totalexp + exp
end )
ashita.register_event('incoming_packet', function(id, size, packet)
    -- Invoke the events library incoming packet handler..
    __events_incoming_packet(id, size, packet);
    return false;
end )
ashita.register_event('outgoing_packet', function(id, size, packet)
    -- Invoke the events library outgoing packet handler..
    __events_outgoing_packet(id, size, packet);
    return false;
end )
