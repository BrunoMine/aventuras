--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Metodo : Trocar itens do jogador
	
  ]]

-- Realizar uma troca com um jogador
aventuras.comum.trocar_itens = function(player, item_rem, item_add)
	
	if not player then
		minetest.log("error", "[Aventuras] Faltou player (em aventuras.comum.trocar_itens)")
		return false
	end
	
	-- verifica se vai remover itens do jogador
	local rem = true
	if not item_rem then
		rem = false
	elseif not item_rem[1] then
		rem = false
	end
	
	-- verifica se vai adicionar itens ao jogador
	local add = true
	if not item_add then
		add = false
	elseif not item_add[1] then
		add = false
	end
	
	if rem == false and add == false then
		minetest.log("error", "[Aventuras] Nenhum item para adicionar e nem para remover (em aventuras.comum.trocar_itens)")
		return false
	end
	
	local pos = player:getpos()
	
	local inv = player:get_inventory()
	
	-- Retirar itens
	if rem == true then
		-- Verificar se o jogador possui os itens requisitados
		local possui = true
		for _,item in ipairs(item_rem) do
			if not inv:contains_item("main", item) then
				possui = false
				break
			end
		end
	
		-- Retorna false por jogador não ter os itens requisitados
		if possui == false then
			return false
		end
	
		-- Retira itens do jogador
		for _,item in ipairs(item_rem) do
			for r=1, item.count do
				inv:remove_item("main", item.name) -- tira 1 por vez
			end
		end
	end
	
	-- Transfere todos os itens ao jogador (e dropa os que nao couberem no inventario)
	if add == true then
		for _,item in ipairs(item_add) do
			if inv:room_for_item("main", item) then
				inv:add_item("main", item)
			else
				dropou = true
				minetest.env:add_item({x = pos.x + math.random() * 2 - 1, y = pos.y+1, z = pos.z + math.random() * 2 - 1}, item)
			end
		end
	end
	
	return true
	
end
