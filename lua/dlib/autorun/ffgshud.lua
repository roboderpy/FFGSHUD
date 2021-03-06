
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

if CLIENT then
	include('ffgshud/init.lua')
	return
end

AddCSLuaFile('ffgshud/init.lua')
AddCSLuaFile('ffgshud/vars.lua')
AddCSLuaFile('ffgshud/basicpaint.lua')
AddCSLuaFile('ffgshud/targetid.lua')
AddCSLuaFile('ffgshud/anims.lua')
AddCSLuaFile('ffgshud/functions.lua')
AddCSLuaFile('ffgshud/binfo.lua')
AddCSLuaFile('ffgshud/dmgtrack.lua')
AddCSLuaFile('ffgshud/glitch.lua')
AddCSLuaFile('ffgshud/vehicle.lua')
AddCSLuaFile('ffgshud/killfeed.lua')
AddCSLuaFile('ffgshud/compass.lua')
AddCSLuaFile('ffgshud/wepselect.lua')
AddCSLuaFile('ffgshud/history.lua')
AddCSLuaFile('ffgshud/crosshairs.lua')
AddCSLuaFile('ffgshud/tfacompat.lua')
include('ffgshud/sv/dmgtrack.lua')
