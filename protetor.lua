--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Protetor
	
  ]]

-- Proteger uma area
return proteger_area = function(name, PlayerName, AreaName, pos1, pos2, silencio)
	if not tostring(PlayerName) or not tostring(AreaName) then return "Faltam argumentos ou estao incorretos" end
	if not areas or not areas.add then return "Faltou mod areas" end
	local param = tostring(PlayerName).." "..tostring(AreaName)
	local found, _, ownername, areaname = param:find('^([^ ]+) (.+)$')

	if not found then
		return "Incorrect usage, see /help set_owner"
	end

	if pos1 and pos2 then
		pos1, pos2 = areas:sortPos(pos1, pos2)
	else
		return "Você precisa selecionar a area primeiro"
	end

	if not areas:player_exists(ownername) then
		return "O jogador \""..ownername.."\" não existe."
	end

	minetest.log("action", name.." runs /set_owner. Owner = "..ownername..
			" AreaName = "..areaname..
			" StartPos = "..minetest.pos_to_string(pos1)..
			" EndPos = "  ..minetest.pos_to_string(pos2))

	local id = areas:add(ownername, areaname, pos1, pos2, nil)
	areas:save()
	
	if silencio == nil or silencio == false then 
		minetest.chat_send_player(ownername,
				"Voce registrou essa area para o jogador #"..
				id..". Use /lista para ver as areas.")
		minetest.chat_send_player(name, "Area protected. ID: "..id)
	end
	return true
end
