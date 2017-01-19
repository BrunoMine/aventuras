--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Realizar troca de itens
	Script original do mod tror
  ]]

-- Realizar uma troca com um jogador
--[[
	Retorna false caso o jogador nao tenha os itens requisitados
	e dropa no local todos os itens que não couberem no inventario
  ]]
aventuras.trocar = function(player, item_rem, item_add)
	
	if not player then
		minetest.log("error", "[Tror] Faltou player (em tror.trocar_plus)")
		return false
	end
	
	if item_rem and not item_rem[1] then
		minetest.log("error", "[Tror] argumento item_rem invalido (em tror.trocar_plus)")
		return false
	end
	
	if item_add and not item_add[1] then
		minetest.log("error", "[Tror] argumento item_add invalido (em tror.trocar_plus)")
		return false
	end
	
	local pos = player:getpos()
	
	local inv = player:get_inventory()
	
	-- Verificar se o jogador possui os itens requisitados
	local possui = true
	if item_rem then
		for _,item in ipairs(item_rem) do
			if not inv:contains_item("main", item) then
				possui = false
				break
			end
		end
	end
	
	-- Retorna false por jogador não ter os itens requisitados
	if possui == false then
		return false
	end
	
	-- Retira itens do jogador
	if item_rem then
		for _,item in ipairs(item_rem) do
			local i = string.split(item, " ")
			local n = i[2] or 1
			i = i[1]
			for r=1, tonumber(n) do -- 1 eh o tanto que quero tirar
				inv:remove_item("main", i) -- tira 1 por vez
			end
		end
	end
	
	-- Transfere todos os itens ao jogador (e dropa os que nao couberem no inventario)
	local dropou = false
	if item_add then
		for _,item in ipairs(item_add) do
			if inv:room_for_item("main", item) then
				inv:add_item("main", item)
			else
				dropou = true
				minetest.env:add_item({x = pos.x + math.random() * 2 - 1, y = pos.y, z = pos.z + math.random() * 2 - 1}, item)
			end
		end
	end
	
	if dropou == true then
		minetest.chat_send_all("Transbordou o inventario.")
	end
	
	return true
	
end
