--[[
	Mod Aventuras_Tomas para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	NPC Tomas
  ]]

local S = aventuras_tomas.S

-- Node de spawn do Tomas
minetest.register_node("aventuras_tomas:bau", {
	description = S("Bau do Tomas"),
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
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("versao", aventuras_tomas.versao)
		meta:set_string("infotext", S("Bau do Tomas"))
	end,
	on_place = minetest.rotate_node
})

aventuras.registrar_personagem("aventuras_tomas:tomas", {
	
	type = "npc",
	
	npc_preset = "human",
	npc = {
		textures = {
			{"aventuras_tomas_npc.png"}, 
			{"aventuras_tomas_npc.1.png"}, 
		},
	},
	
	arte_npc = {
		face = "aventuras_tomas_rosto.png",
		bgcolor = "bgcolor[#080808BB;true]",
		bg_img1x1 = "background[5,5;1,1;aventuras_tomas_bg1x1.png;true]",
		bg_img10x3 = "background[5,5;3,1;aventuras_tomas_bg10x3.png;true]",
	},
	
	spawner_node = {
		["aventuras_tomas:bau"] = {
			spawn_mode = "front",
		},
	},
	
})

