--[[
	Mod Aventuras para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	CraftItems
  ]]

local S = aventuras_bob.S

minetest.register_node("aventuras_bob:mazenode", {
	tile_images = {"default_cobble.png"},
	inventory_image = minetest.inventorycube("default_cobble.png"),
	dug_item = '',
	material = { diggability = "not"},
	description = "Pedregulho de Labirinto",
})
