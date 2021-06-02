ESX = nil

local bones = {
	head = {
		SKEL_Neck_1 = 0x9995,
		SKEL_Head = 0x796E
	},
	
	body = {
	    SKEL_Spine_Root = 0xE0FD,
		SKEL_Spine0 = 0x5C01,
		SKEL_Spine1 = 0x60F0,
		SKEL_Spine2 = 0x60F1,
		SKEL_Spine3 = 0x60F2,
		SKEL_L_Clavicle = 0xFCD9,
		SKEL_R_Clavicle = 0x29D2,
	},
		
	leftarm = {
		SKEL_L_UpperArm = 0xB1C5,
		SKEL_L_Forearm = 0xEEEB,
		SKEL_L_Hand = 0x49D9,
	},
	
	rightarm = {
		SKEL_R_Thigh = 0xCA72,
		SKEL_R_Calf = 0x9000,
		SKEL_R_Foot = 0xCC4D,
	},
	
	leftleg = {
		SKEL_L_Thigh = 0xE39F,
		SKEL_L_Calf = 0xF9BB,
		SKEL_L_Foot = 0x3779,
	},
	
	rightleg = {
		SKEL_R_UpperArm = 0x9D4D,
		SKEL_R_Forearm = 0x6E5C,
		SKEL_R_Hand = 0xDEAD,
	},
	
    whole = {
		SKEL_ROOT = 0x0,
	}
}


local DMGSkel = {
	head = {},
	body = {},
	leftarm = {},
	rightarm = {},
	leftleg = {},
	rightleg = {}
}


Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
    end
end)

--[[Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local isdmg, bone = GetPedLastDamageBone(ped)
        if isdmg then
            print(bone)

            Citizen.Wait(1000)
        end
        Citizen.Wait(0)
    end
end)]]--

local prevHealth = 200
local comm = false

Citizen.CreateThread(function()
	while ESX ~= nil do
        local player = PlayerPedId()
        local _, bone = GetPedLastDamageBone(player)
		local curHealth = GetEntityHealth(player)
        if curHealth < prevHealth then
			GetDMG(bone)
            ClearPedLastDamageBone(player)
		end
		prevHealth = curHealth

        Citizen.Wait(0)
    end
end)

function GetDMG(bone)
	local player = PlayerPedId()
	local isWeaponDMG, hash = weaponDMG()

	if isWeaponDMG then
		local group = GetWeapontypeGroup(`weapons[i].label`)
		insertDMG(group)
		print('test1')
	elseif HasPedBeenDamagedByWeapon(player, 0, 1) then
		local group = "melee"
		insertDMG(group)
		print('test3')
	end

end

function weaponDMG()
	local player = PlayerPedId()
	local weapons = ESX.GetWeaponList()

	for i=1, #weapons do
		if HasPedBeenDamagedByWeapon(player, `weapons[i].label`, 0) then
			print('test2')
			return true, weapons[i].label
		end
	end

end

function insertDMG(group)
	for k,v in pairs(bones) do
		for b,h in pairs(v) do
			if b == bone then
				if DMGSkel[k].type ~= nil then
					if DMGSkel[k].type == group then
						local quantity = DMGSkel.count + 1
						DMGSkel[k].count = quantity
						print(DMGSkel[k].type)
						print(DMGSkel[k].count)
					else
						DMGSkel[k] = {type = group, count = 1}
						print(DMGSkel[k].type)
						print(DMGSkel[k].count)
					end
				else
					DMGSkel[k] = {type = group, count = 1}
					print(DMGSkel[k].type)
					print(DMGSkel[k].count)
				end
			end
		end
	end
end

Citizen.CreateThread(function()

	while ESX ~= nil do
		local ped = PlayerPedId()
		local pcoords = GetEntityCoords(ped, false)
		local ped2 = ESX.Game.GetClosestPed(pcoords)

		for n,t in pairs(bones) do

			for k,v in pairs(t) do

				local bindex = GetPedBoneIndex(ped2, t[k])
				local coords = GetWorldPositionOfEntityBone(ped2, bindex)
				local bool, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
				ReqDict("shared")
				ReqDict("helicopterhud")
				print(coords)
				SetDrawOrigin(coords, false)
				DrawSprite("shared", "menuplus_32", 0.0, 0.0, 0.050, 0.045, 90.0, 255, 255, 255, 255)
				ClearDrawOrigin()
				DrawSprite("helicopterhud", "hud_lock", 0.5, 0.5, 0.015, 0.015, 0.0, 255, 20, 20, 255)

			end
		end

		Citizen.Wait(0)

	end

end)

RegisterCommand('maths', function()
	local cx, cy, r = 0.5, 0.5, 0.005
	local px, py = 0.504, 0.503
	local prosta = math.pow((px - cx), 2) + math.pow((py - cy), 2)
	local result = math.sqrt(prosta)
end)

--[[Citizen.CreateThread(function()
	local object = CreateDui("https://i.imgur.com/k5QoyUd.png", 512, 1024)
	local handle = GetDuiHandle(object)
	local txt = CreateRuntimeTextureFromDuiHandle("cs4_12_hd_misc", "cs4_12_rsl_mr_billboards", handle)
end)]]--

function ReqDict(dict)
	RequestStreamedTextureDict(dict, false)

	while not HasStreamedTextureDictLoaded(dict) do
		Citizen.Wait(0)
	end
	
end

--[[Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        for k,v in pairs(bones) do
            local bindex = GetPedBoneIndex(ped, v)
            local coords = GetWorldPositionOfEntityBone(ped, bindex)
            DrawText3D(coords, k, 0.2)
        end
        Citizen.Wait(0)
    end
end)]]--

Citizen.CreateThread(function()
	local dict = "missminuteman_1ig_2"

	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(100)
	end
	local handsup = false

	while true do
		local ped = PlayerPedId()
		Citizen.Wait(10)
		if IsControlJustPressed(1, 243) and GetLastInputMethod(2) and IsPedOnFoot(ped) then
			if not handsup then
				local id = PlayerId()
				TaskPlayAnim(ped, dict, "handsup_enter", 8.0, 8.0, -1, 50, 0, false, false, false)
				handsup = true
			else
				handsup = false
				ClearPedTasks(ped)
			end
		end
	end
end)

RegisterCommand('bonedebug', function() 
    local ped = PlayerPedId()
    local i = 0
    for k,v in pairs(bones) do
        local bindex = GetPedBoneIndex(ped, v)
        local coords = GetWorldPositionOfEntityBone(ped, bindex)
        i = i + 1
        print(i .. " :" .. bindex)
    end
end)

function DrawText3D(coords, text, size)
	local camCoords = GetGameplayCamCoords()
	local dist = #(camCoords - coords)
	
	local scale = (size / dist)*20
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov
	
	SetTextScale(0.0*scale, 0.1*scale)
	
	SetTextFont(0)
	SetTextProportional(1)
	-- SetTextScale(0.0, 0.55)
	SetTextColour(255, 255, 255, 215)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	SetDrawOrigin(coords, 0)
	DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

local ped = nil

RegisterCommand('spawnped', function()
    local playped = PlayerPedId()
    local coords = GetEntityCoords(playped, true)

    RequestModel(`a_f_m_beach_01`)

    while not HasModelLoaded(`a_f_m_beach_01`) do
        Citizen.Wait(0)
    end

    ped = CreatePed(5, `a_f_m_beach_01`, (coords + 1.0), 0.0, true, true)
    SetEntityMaxSpeed(ped, 0.0)
end)

Citizen.CreateThread(function()
    while true do
        if ped ~= nil then
            SetEntityHealth(ped, 200)
        end
        Citizen.Wait(0)
    end
end)