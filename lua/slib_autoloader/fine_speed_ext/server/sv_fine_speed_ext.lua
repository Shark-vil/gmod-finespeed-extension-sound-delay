local cvar_ext_finespeed_enable = GetConVar('ext_finespeed_enable')

local function IsEnabled()
	return cvar_ext_finespeed_enable and cvar_ext_finespeed_enable:GetBool()
end

local function RegisterNetworkCallbacks()
	local isnumber = isnumber

	snet.Callback('sv_fine_speed_ext_modify_speed_mult', function(ply, speed_mult)
		if not IsEnabled() then return end
		if not isnumber(speed_mult) then return end

		ply.FineSpeedExt = ply.FineSpeedExt or {}
		ply.FineSpeedExt.SpeedMult = speed_mult
	end)
end

local function PlayerFootstepHookInit()
	local table_RandomBySeq = table.RandomBySeq
	local math_Clamp = math.Clamp
	local RealTime = RealTime
	local slib_magnitude = slib.magnitude
	local shook = slib.Component('Hook')

	local function handler(ply, pos, foot, snd)
		if not IsEnabled() then return end
		if not ply.FineSpeedExt then return end
		if not ply.FineSpeedExt.MovementVector then return end
		if not ply.FineSpeedExt.BaseSpeed then return end

		ply.FineSpeedExt.LastStepTime = ply.FineSpeedExt.LastStepTime or 0
		if ply.FineSpeedExt.LastStepTime < RealTime() then
			local default = 1 / ply.FineSpeedExt.BaseSpeed
			local magnitude = slib_magnitude(ply.FineSpeedExt.MovementVector)
			local delay = math_Clamp(1 - (magnitude * default), 0, 1)
			ply.FineSpeedExt.LastStepTime = RealTime() + delay

			local vel = ply:GetVelocity():Length()
			local delta = math_Clamp(vel / 300, .5, 1)
			ply:EmitSound(table_RandomBySeq(FineSpeed.GearSounds), 90 * delta, 95 + (delta * 15), delta)
		end

		return true
	end

	shook.SetHandlerAll('PlayerFootstep', handler)
end

hook.Add('InitPostEntity', 'Ext.FineSpeed.Init.Server', function()
	if not FineSpeed then return end

	RegisterNetworkCallbacks()
	PlayerFootstepHookInit()
end)

do
	local Vector = Vector
	local IN_SPEED = IN_SPEED

	hook.Add('Move', 'Ext.FineSpeed.GetMoveData', function(ply, cmd)
		if not IsEnabled() then return end
		if not ply.FineSpeedExt or not ply.FineSpeedExt.SpeedMult then return end

		local base_speed = cmd:KeyDown(IN_SPEED) and ply:GetRunSpeed() or ply:GetWalkSpeed()
		local movement_vector = Vector(cmd:GetForwardSpeed(), cmd:GetSideSpeed(), cmd:GetUpSpeed())
		movement_vector = movement_vector:GetNormalized()
		movement_vector = movement_vector * ply.FineSpeedExt.SpeedMult * base_speed

		ply.FineSpeedExt.MovementVector = movement_vector
		ply.FineSpeedExt.BaseSpeed = base_speed
	end)
end