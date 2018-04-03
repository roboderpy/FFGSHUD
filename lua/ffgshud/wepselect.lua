
-- Copyright (C) 2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local FFGSHUD = FFGSHUD
local NULL = NULL

FFGSHUD.DrawWepSelectionFadeOutStart = 0
FFGSHUD.DrawWepSelectionFadeOutEnd = 0
FFGSHUD.DrawWepSelection = false
FFGSHUD.HoldKeyTrap = false
FFGSHUD.SelectWeapon = NULL
FFGSHUD.SelectWeaponForce = NULL
FFGSHUD.SelectWeaponForceTime = 0
FFGSHUD.SelectWeaponPos = -1
FFGSHUD.LastSelectSlot = -1
FFGSHUD.WeaponListInSlot = {}
FFGSHUD.WeaponListInSlots = {}

local RealTimeL = RealTimeL
local ipairs = ipairs
local table = table
local HUDCommons = DLib.HUDCommons
local ScreenSize = ScreenSize
local LocalWeapon = LocalWeapon
local surface = surface
local LocalPlayer = LocalPlayer
local ScrWL, ScrHL = ScrWL, ScrHL
local language = language

local function sortTab(a, b)
	return a:GetSlotPos() < b:GetSlotPos()
end

local function getPrintName(self)
	local class = self:GetClass()
	local phrase = language.GetPhrase(class)
	return phrase ~= class and phrase or self:GetPrintName()
end

local function updateWeaponList(weapons)
	FFGSHUD.WeaponListInSlots[1] = {}
	FFGSHUD.WeaponListInSlots[2] = {}
	FFGSHUD.WeaponListInSlots[3] = {}
	FFGSHUD.WeaponListInSlots[4] = {}
	FFGSHUD.WeaponListInSlots[5] = {}
	FFGSHUD.WeaponListInSlots[6] = {}

	if #weapons == 0 then return end

	for i, weapon in ipairs(weapons) do
		local slot = weapon:GetSlot() + 1

		if FFGSHUD.WeaponListInSlots[slot] then
			table.insert(FFGSHUD.WeaponListInSlots[slot], weapon)
		end
	end

	for i = 1, 6 do
		table.sort(FFGSHUD.WeaponListInSlots[i], sortTab)
	end
end

local function getWeaponsInSlot(weapons, slotIn)
	if #weapons == 0 then return {} end

	local reply = {}
	slotIn = slotIn - 1

	for i, weapon in ipairs(weapons) do
		if weapon:GetSlot() == slotIn then
			table.insert(reply, weapon)
		end
	end

	table.sort(reply, sortTab)

	return reply
end

function FFGSHUD:ShouldDrawWeaponSelection(element)
	if element == 'CHudWeaponSelection' then
		return false
	end
end

local DRAWPOS = FFGSHUD:DefinePosition('wepselect', 0.2, 0.08)
local SLOT_ACTIVE = FFGSHUD:CreateColorN('wepselect_a', '', Color())
local SLOT_INACTIVE = FFGSHUD:CreateColorN('wepselect_i', '', Color(137, 137, 137))
local SLOT_INACTIVE_BOX = FFGSHUD:CreateColorN('wepselect_i', '', Color(80, 80, 80))
local WEAPON_SELECTED = FFGSHUD:CreateColorN('wepselect_s', '', Color(242, 210, 101))
local WEAPON_READY = FFGSHUD:CreateColorN('wepselect_r', '', Color(237, 89, 152))
local WEAPON_FOCUSED = FFGSHUD:CreateColorN('wepselect_f', '', Color())
local SLOT_BG = FFGSHUD:CreateColorN('wepselect_bg', '', Color(40, 40, 40))

function FFGSHUD:DrawWeaponSelection()
	if not FFGSHUD.DrawWepSelection then return end
	--local x, y = DRAWPOS()
	local x, y = ScrWL() * 0.2, ScrHL() * 0.08
	local spacing = ScreenSize(1.5)
	local alpha = (1 - RealTimeL():progression(FFGSHUD.DrawWepSelectionFadeOutStart, FFGSHUD.DrawWepSelectionFadeOutEnd)) * 255
	local inactive, bg, bgb = SLOT_INACTIVE(alpha), SLOT_BG(alpha * 0.75), SLOT_INACTIVE_BOX(alpha * 0.7)
	local activeWeapon = LocalWeapon()
	local boxSpacing = ScreenSize(3)
	local boxSpacing2 = ScreenSize(3) * 2
	local unshift = ScreenSize(1.5)

	for i = 1, 6 do
		if i ~= FFGSHUD.LastSelectSlot then
			local w, h = HUDCommons.WordBox(i, self.SelectionNumber.REGULAR, x, y, inactive, bg)

			for i = 1, #FFGSHUD.WeaponListInSlots[i] do
				HUDCommons.DrawBox(x - unshift, y + (i - 1) * (spacing + h * 0.35) + h, w, h * 0.35, bgb)
			end

			x = x + w + spacing
		else
			local w, h = HUDCommons.WordBox(i, self.SelectionNumberActive.REGULAR, x, y, SLOT_ACTIVE(alpha), bg)
			local Y = y + h + spacing
			local maxW = 0

			surface.SetFont(self.SelectionText.REGULAR)

			for i, weapon in ipairs(FFGSHUD.WeaponListInSlot) do
				if weapon:IsValid() then
					local name = getPrintName(weapon)
					local W, H = surface.GetTextSize(name)

					if weapon == FFGSHUD.SelectWeapon then
						if weapon ~= activeWeapon then
							maxW = maxW:max(W + boxSpacing2)
						else
							maxW = maxW:max(W + ScreenSize(4) + boxSpacing2)
						end
					elseif weapon == activeWeapon then
						maxW = maxW:max(W + ScreenSize(4) + boxSpacing2)
					else
						maxW = maxW:max(W + boxSpacing2)
					end
				end
			end

			for i, weapon in ipairs(FFGSHUD.WeaponListInSlot) do
				if weapon:IsValid() then
					local name = getPrintName(weapon)
					local W, H = surface.GetTextSize(name)
					local X = x - unshift

					if weapon == FFGSHUD.SelectWeapon then
						if weapon ~= activeWeapon then
							HUDCommons.DrawBox(X, Y, maxW, H, WEAPON_READY(alpha))
							HUDCommons.SimpleText(name, nil, X + boxSpacing, Y, WEAPON_FOCUSED(alpha))
						else
							W = W + ScreenSize(4)
							HUDCommons.DrawBox(X, Y, maxW, H, WEAPON_READY(alpha))
							local col = WEAPON_SELECTED(alpha)
							HUDCommons.DrawBox(X, Y, ScreenSize(4), H, col)
							HUDCommons.SimpleText(name, nil, X + ScreenSize(7), Y, col)
						end
					elseif weapon == activeWeapon then
						W = W + ScreenSize(4)
						HUDCommons.DrawBox(X, Y,maxW, H, bg)
						local col = WEAPON_SELECTED(alpha)
						HUDCommons.DrawBox(X, Y, ScreenSize(4), H, col)
						HUDCommons.SimpleText(name, nil, X + ScreenSize(7), Y, col)
					else
						HUDCommons.DrawBox(X, Y, maxW, H, bg)
						HUDCommons.SimpleText(name, nil, X + boxSpacing, Y, WEAPON_READY(alpha))
					end

					Y = Y + H + spacing
				end
			end

			x = x + w + maxW - ScreenSize(6)
		end
	end
end

function FFGSHUD:ThinkWeaponSelection()
	if FFGSHUD.DrawWepSelectionFadeOutEnd < RealTimeL() then
		FFGSHUD.DrawWepSelection = false
		FFGSHUD.SelectWeapon = NULL
		FFGSHUD.LastSelectSlot = -1
	end
end

local function BindSlot(self, ply, bind, pressed, weapons)
	if not bind:startsWith('slot') then return end
	local newslot = bind:sub(5):tonumber()
	if newslot < 1 or newslot > 6 then return end
	local getweapons = getWeaponsInSlot(weapons, newslot)
	if #getweapons == 0 then return end

	if newslot ~= FFGSHUD.LastSelectSlot or not FFGSHUD.SelectWeapon:IsValid() then
		FFGSHUD.LastSelectSlot = newslot
		FFGSHUD.SelectWeapon = getweapons[1]
		FFGSHUD.SelectWeaponPos = 1
	else
		FFGSHUD.SelectWeaponPos = FFGSHUD.SelectWeaponPos + 1

		if FFGSHUD.SelectWeaponPos > #getweapons then
			FFGSHUD.SelectWeaponPos = 1
		end

		FFGSHUD.SelectWeapon = getweapons[FFGSHUD.SelectWeaponPos]
	end

	if not FFGSHUD.DrawWepSelection then
		FFGSHUD.DrawWepSelection = true
		LocalPlayer():EmitSound('Player.WeaponSelectionOpen')
	else
		LocalPlayer():EmitSound('Player.WeaponSelectionMoveSlot')
	end

	FFGSHUD.WeaponListInSlot = getweapons
	FFGSHUD.DrawWepSelectionFadeOutStart = RealTimeL() + 2
	FFGSHUD.DrawWepSelectionFadeOutEnd = RealTimeL() + 2.5
	FFGSHUD.DrawWepSelection = true
	FFGSHUD.SelectWeaponForce = NULL
	FFGSHUD.SelectWeaponForceTime = 0

	return true
end

local function WheelBind(self, ply, bind, pressed, weapons)
	if bind ~= 'invprev' and bind ~= 'invnext' then return end

	local weapon = LocalWeapon()
	local slot

	if not FFGSHUD.DrawWepSelection then
		if weapon:IsValid() then
			slot = weapon:GetSlot() + 1
		else
			slot = 1
		end
	else
		slot = FFGSHUD.LastSelectSlot
	end

	local getweapons = getWeaponsInSlot(weapons, slot)
	if #getweapons == 0 then return end

	if not FFGSHUD.DrawWepSelection then
		local hit = false

		for i, wep in ipairs(getweapons) do
			if wep == weapon then
				FFGSHUD.SelectWeaponPos = i
				hit = true
				break
			end
		end

		if not hit then
			FFGSHUD.SelectWeaponPos = 0
		end
	end

	FFGSHUD.SelectWeaponPos = FFGSHUD.SelectWeaponPos + (bind == 'invnext' and 1 or -1)

	if FFGSHUD.SelectWeaponPos < 1 then
		for i = 1, 6 do
			slot = slot - 1

			if slot < 0 then
				slot = 6
			end

			getweapons = getWeaponsInSlot(weapons, slot)
			if #getweapons ~= 0 then break end
		end

		FFGSHUD.SelectWeaponPos = #getweapons
	elseif FFGSHUD.SelectWeaponPos > #getweapons then
		FFGSHUD.SelectWeaponPos = 1

		for i = 1, 6 do
			slot = slot + 1

			if slot > 6 then
				slot = 1
			end

			getweapons = getWeaponsInSlot(weapons, slot)
			if #getweapons ~= 0 then break end
		end
	end

	if #getweapons == 0 then return end
	FFGSHUD.SelectWeapon = getweapons[FFGSHUD.SelectWeaponPos]

	if slot ~= FFGSHUD.LastSelectSlot or not FFGSHUD.SelectWeapon:IsValid() then
		FFGSHUD.LastSelectSlot = slot
	end

	if not FFGSHUD.DrawWepSelection then
		FFGSHUD.DrawWepSelection = true
		LocalPlayer():EmitSound('Player.WeaponSelectionOpen')
	else
		LocalPlayer():EmitSound('Player.WeaponSelectionMoveSlot')
	end

	FFGSHUD.WeaponListInSlot = getweapons
	FFGSHUD.DrawWepSelectionFadeOutStart = RealTimeL() + 2
	FFGSHUD.DrawWepSelectionFadeOutEnd = RealTimeL() + 2.5
	FFGSHUD.DrawWepSelection = true
	FFGSHUD.SelectWeaponForce = NULL
	FFGSHUD.SelectWeaponForceTime = 0

	return true
end

function FFGSHUD:WeaponSelectionBind(ply, bind, pressed)
	if not pressed then return end
	if not self:GetVarAlive() then return end
	if ply:InVehicle() and not ply:GetAllowWeaponsInVehicle() then return end
	local weapons = ply:GetWeapons()
	if #weapons == 0 then return end

	updateWeaponList(weapons)
	local status = BindSlot(self, ply, bind, pressed, weapons)
	if status then return status end
	status = WheelBind(self, ply, bind, pressed, weapons)
	if status then return status end
end

local IN_ATTACK = IN_ATTACK
local IN_ATTACK2 = IN_ATTACK2

function FFGSHUD:TrapWeaponSelect(cmd)
	if FFGSHUD.SelectWeaponForce:IsValid() and FFGSHUD.SelectWeaponForceTime > RealTimeL() then
		cmd:SelectWeapon(FFGSHUD.SelectWeaponForce)

		if LocalWeapon() == FFGSHUD.SelectWeaponForce then
			FFGSHUD.SelectWeaponForce = NULL
			FFGSHUD.SelectWeaponForceTime = 0
		end
	end

	if not FFGSHUD.DrawWepSelection and not FFGSHUD.HoldKeyTrap then return end

	if cmd:KeyDown(IN_ATTACK) then
		cmd:SetButtons(cmd:GetButtons() - IN_ATTACK)

		if not FFGSHUD.HoldKeyTrap then
			FFGSHUD.DrawWepSelection = false
			FFGSHUD.HoldKeyTrap = true

			if FFGSHUD.SelectWeapon:IsValid() then
				cmd:SelectWeapon(FFGSHUD.SelectWeapon)
				FFGSHUD.SelectWeaponForce = FFGSHUD.SelectWeapon
				FFGSHUD.SelectWeaponForceTime = RealTimeL() + 2
				LocalPlayer():EmitSound('Player.WeaponSelected')
			end
		end
	elseif cmd:KeyDown(IN_ATTACK2) then
		cmd:SetButtons(cmd:GetButtons() - IN_ATTACK2)

		if not FFGSHUD.HoldKeyTrap then
			LocalPlayer():EmitSound('Player.WeaponSelectionClose')
			FFGSHUD.DrawWepSelection = false
			FFGSHUD.HoldKeyTrap = true
		end
	else
		FFGSHUD.HoldKeyTrap = false
	end
end

FFGSHUD:AddHookCustom('HUDShouldDraw', 'ShouldDrawWeaponSelection')
FFGSHUD:AddHookCustom('CreateMove', 'TrapWeaponSelect', nil, -2)
FFGSHUD:AddHookCustom('PlayerBindPress', 'WeaponSelectionBind')
FFGSHUD:AddPaintHook('DrawWeaponSelection')
FFGSHUD:AddThinkHook('ThinkWeaponSelection')