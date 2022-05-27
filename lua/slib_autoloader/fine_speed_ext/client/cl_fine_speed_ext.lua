local cvar_ext_finespeed_enable = GetConVar('ext_finespeed_enable')

local function IsEnabled()
	return cvar_ext_finespeed_enable and cvar_ext_finespeed_enable:GetBool()
end

local function OverrideModifySpeedMult()
	local original_ModifySpeedMult = FineSpeed.ModifySpeedMult
	local isnumber = isnumber
	local invoke = snet.InvokeServer

	function FineSpeed.ModifySpeedMult(...)
		local result = { original_ModifySpeedMult(...) }
		local speed = FineSpeed.SpeedMult

		if IsEnabled() and isnumber(speed) then
			invoke('sv_fine_speed_ext_modify_speed_mult', speed)
		end

		return unpack(result)
	end
end

hook.Add('InitPostEntity', 'Ext.FineSpeed.Init.Client', function()
	if not FineSpeed or not FineSpeed.ModifySpeedMult then return end
	OverrideModifySpeedMult()
end)