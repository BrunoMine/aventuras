--[[
	Mod Aventuras Bob para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Bau do aventureiro Noob
  ]]

local S = aventuras_bob.S


-- Node
minetest.register_node("aventuras_bob:bau_labirinto_das_masmorras", {
	description = "Bau da Masmorra",
	tiles = {
		"default_chest_top.png", 
		"default_chest_top.png", 
		"default_chest_side.png",
		"default_chest_side.png", 
		"default_chest_side.png", 
		"default_chest_front.png"
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2,not_in_creative_inventory=1},
	sounds = default.node_sound_wood_defaults(),
	
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if not player then return end
		local name = player:get_player_name()
		
		-- Verifica se jogador está fazendo a missão
		if aventuras.pegar_tarefa(name, "aventuras_bob:caminho_da_forja") ~= 1 then
			return
		end
		
		-- Verifica distancia entre o jogador e o node
		local pp = player:getpos()
		if math.abs(pos.x - pp.x) > 1.2 or math.abs(pos.z - pp.z) > 1.2 then
			minetest.chat_send_player(name, S("Muito distante do baú"))
			return
		end
		
		-- Conclui tarefa
		
		-- Dropa item em cima do bau
		minetest.add_item({x=pos.x, y=pos.y+1, z=pos.z}, "default:paper")
		minetest.add_item({x=pos.x, y=pos.y+1, z=pos.z}, "aventuras_bob:mapa_bob")
		
		aventuras.salvar_tarefa(name, "aventuras_bob:caminho_da_forja", 2)
		aventuras.callbacks.concluiu(name, "aventuras_bob:caminho_da_forja", 2)
		minetest.sound_play("aventuras_concluir", {to_player = name, gain = 0.7})
		
		minetest.chat_send_player(name, S("Finalmente encontrei esse mapa. Preciso mostrar isso ao Tomas."))
	end,
})

