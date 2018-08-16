--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Nodes uteis para montagem de estruturas
  ]]

local S = aventuras.S

-- Replicador de blocos para baixo simples
minetest.register_node("aventuras:replicador_inferior_simples", {
	description = "Replicador para baixo ate encontrar algo (replica o que estiver acima)",
	tiles = {"default_cloud.png^aventuras_replicador_inferior.png"},
	is_ground_content = true,
	groups = {oddly_breakable_by_hand=1},
	sounds = default.node_sound_stone_defaults(),
})
-- Esconde node caso nao esteja no modo editor
if aventuras.editor_mode ~= true then
	minetest.override_item("aventuras:replicador_inferior_simples", {groups = {oddly_breakable_by_hand=1,not_in_creative_inventory=1}})
end

-- Replicador de blocos para baixo simples
minetest.register_node("aventuras:replicador_inferior_pedra", {
	description = "Replicador para baixo ate encontrar pedra (replica o que estiver acima)",
	tiles = {"default_stone.png^aventuras_replicador_inferior.png"},
	is_ground_content = true,
	groups = {oddly_breakable_by_hand=1},
	sounds = default.node_sound_stone_defaults(),
})
-- Esconde node caso nao esteja no modo editor
if aventuras.editor_mode ~= true then
	minetest.override_item("aventuras:replicador_inferior_pedra", {groups = {oddly_breakable_by_hand=1,not_in_creative_inventory=1}})
end

-- Executar algoritimos de ajuste nos blocos de uma area
aventuras.estruturas.ajustar_nodes = function(minp, maxp)

	-- Replicadores inferiores simples
	do
		local nodes = minetest.find_nodes_in_area(minp, maxp, {"aventuras:replicador_inferior_simples"})
		for _,pos in ipairs(nodes) do
			local node_replicado = minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z})
			minetest.set_node(pos, node_replicado) -- Coloca no proprio lugar
			local y = pos.y - 1
			while minetest.get_node({x=pos.x,y=y,z=pos.z}).name == "air"
				or minetest.registered_nodes[minetest.get_node({x=pos.x,y=y,z=pos.z}).name].groups.leaves
				or minetest.registered_nodes[minetest.get_node({x=pos.x,y=y,z=pos.z}).name].groups.tree
				or minetest.registered_nodes[minetest.get_node({x=pos.x,y=y,z=pos.z}).name].groups.flora do
				minetest.set_node({x=pos.x,y=y,z=pos.z}, node_replicado)
				y = y - 1
			end
		end
	end
	
	-- Replicadores inferiores pedra
	do
		local nodes = minetest.find_nodes_in_area(minp, maxp, {"aventuras:replicador_inferior_pedra"})
		for _,pos in ipairs(nodes) do
			local node_replicado = minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z})
			minetest.set_node(pos, node_replicado) -- Coloca no proprio lugar
			local y = pos.y - 1
			while minetest.get_node({x=pos.x,y=y,z=pos.z}).name ~= "default_stone"
				and minetest.get_node({x=pos.x,y=y,z=pos.z}).name ~= "ignore" do
				minetest.set_node({x=pos.x,y=y,z=pos.z}, node_replicado)
				y = y - 1
			end
		end
	end
end
