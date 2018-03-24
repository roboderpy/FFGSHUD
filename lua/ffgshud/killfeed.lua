
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
local language = language
local Color = Color
local RealTime = RealTime
local table = table

local notices = {}
local function npcColor(npc)
	local crc = tonumber(util.CRC(npc))
	local r = crc % 255
	crc = crc - r
	local g = (crc / 255) % 255
	crc = crc / 255 - g
	local b = (crc / 255) % 255
	return Color(r:abs(), g:abs(), b:abs())
end

function FFGSHUD:AddDeathNotice(attacker, attackerTeam, inflictor, victim, victimTeam)
	local validWeapon = inflictor ~= nil and inflictor ~= 'suicide'
	local validAttacker = attacker ~= nil and attacker ~= victim
	local worldspawn = attacker == '#world'

	local isSuicide = not validWeapon and not validAttacker
	local weapon = worldspawn and 'fall damage' or isSuicide and language.GetPhrase('suicide') or (inflictor and language.GetPhrase(inflictor)) or '???'
	weapon = weapon:upper()

	local entry = {}

	entry.weaponColor = Color(255, 255, 255)
	entry.isFallDamage = worldspawn
	entry.isSuicide = isSuicide
	entry.weapon = '[' .. weapon .. ']'
	entry.validAttacker = validAttacker
	entry.ttl = RealTime() + 4

	entry.victim = victim
	entry.attacker = attacker

	if validAttacker then
		if attackerTeam and attackerTeam ~= 0 and attackerTeam ~= -1 and attackerTeam ~= 1000 then
			entry.attackerColor = team.GetColor(attackerTeam)
		else
			entry.attackerColor = npcColor(attacker)
		end
	else
		entry.attackerColor = Color(67, 158, 184)
	end

	if victimTeam and victimTeam ~= 0 and victimTeam ~= -1 and victimTeam ~= 1000 then
		entry.victimColor = team.GetColor(victimTeam)
	else
		entry.victimColor = npcColor(victim)
	end

	table.insert(notices, entry)

	return true
end

local DRAW_POS = FFGSHUD:DefinePosition('killfeed', 0.85, 0.12)
local surface = surface
local ScreenSize = ScreenSize

function FFGSHUD:DrawDeathNotice()
	local x, y = DRAW_POS()
	x = x - self.BATTLE_STATS_WIDE
	local space = ScreenSize(3)

	for i, entry in ipairs(notices) do
		local x = x
		local w, h = self:DrawShadowedTextAligned(self.KillfeedFont, entry.victim, x, y, entry.victimColor)
		x = x - w - ScreenSize(5)
		w, h = self:DrawShadowedTextAligned(self.KillfeedFont, entry.weapon, x, y, entry.weaponColor)

		if entry.validAttacker then
			x = x - w - ScreenSize(5)
			self:DrawShadowedTextAligned(self.KillfeedFont, entry.attacker, x, y, entry.attackerColor)
		end

		y = y + h + space
	end
end

function FFGSHUD:ThinkDeathNotice()
	local toRemove
	local time = RealTime()

	for i, entry in ipairs(notices) do
		if entry.ttl < time then
			toRemove = toRemove or {}
			table.insert(toRemove, i)
		end
	end

	if toRemove then
		table.removeValues(notices, toRemove)
	end
end

FFGSHUD:AddHookCustom('AddDeathNotice', 'AddDeathNotice')
FFGSHUD:AddPaintHook('DrawDeathNotice')
FFGSHUD:AddThinkHook('ThinkDeathNotice')