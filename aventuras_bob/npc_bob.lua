--[[
	Mod Aventuras_Tomas para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	NPC Tomas
  ]]

local S = aventuras_bob.S

-- Node de spawn do Tomas
minetest.register_node("aventuras_bob:bau", {
	description = S("Bau do Bob"),
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
	groups = {choppy=2,oddly_breakable_by_hand=1},
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("versao", aventuras_tomas.versao)
		meta:set_string("infotext", S("Bau do Bob"))
	end,
	on_place = minetest.rotate_node
})

aventuras.registrar_personagem("aventuras_bob:bob", {
	
	type = "npc",
	
	npc_preset = "human",
	npc = {
		textures = {
			{"aventuras_bob_npc.png"}, 
		},
	},
	
	arte_npc = {
		face = "aventuras_bob_rosto.png",
		bgcolor = "bgcolor[#080808BB;true]",
		bg_img1x1 = "background[5,5;1,1;aventuras_bob_bg1x1.png;true]",
		bg_img10x3 = "background[5,5;3,1;aventuras_bob_bg10x3.png;true]",
	},
	
	spawner_node = {
		["aventuras_bob:bau"] = {
			spawn_mode = "front",
		},
	},
	
})

