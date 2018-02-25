
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
local HUDCommons = DLib.HUDCommons
local hook = hook
local MousePos = gui.MousePos
local team = team
local ScreenSize = ScreenScale
local color_white = color_white
local IsValid = FindMetaTable('Entity').IsValid

function FFGSHUD:HUDDrawTargetID()
	return false
end

local POS = FFGSHUD:DefinePosition('targetid', 0.5, 0.54)

function FFGSHUD:PaintTargetID(ply)
	local tr = ply:GetEyeTrace()

	if not tr.Hit then return end
	local ent = tr.Entity
	if not IsValid(ent) then return end
	if not ent:IsPlayer() then return end

	local name = ent:Nick()
	local health = ent:GetHealth()
	local maxHealth = ent:GetMaxHealth()
	local armor = ent:GetArmor()
	local maxArmor = ent:GetMaxArmor()
	local pteam = ent:Team()
	local color = Color(team.GetColor(pteam or 0) or color_white)

	local x, y = MousePos()

	if x == 0 and y == 0 then
		x, y = POS()
	else
		y = y + ScreenScale(8)
	end

	local w, h = self:DrawShadowedTextCentered(self.TargetID_Name, name, x, y, color)
	y = y + h * 0.89

	w, h = self:DrawShadowedTextCentered(self.TargetID_Health, ('%i / %i'):format(health, maxHealth), x, y, color)
	y = y + h * 0.95

	if armor ~= 0 then
		w, h = self:DrawShadowedTextCentered(self.TargetID_Armor, ('%i / %i'):format(armor, maxArmor), x, y, color)
		y = y + h * 0.95
	end
end

FFGSHUD:AddPaintHook('PaintTargetID')
