--[[
	Mod Aventuras_Masmorras para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Forja do Bob
  ]]

local S = aventuras_bob.S


-- Forja do Bob
aventuras.registrar_estrutura("aventuras_bob:forja_bob", {
	
	titulo = S("Forja do Bob"),
	versao = "1",
	protected_area_id = S("Aventuras_Bob:Forja"),
	
	aven_req = {["aventuras_bob:caminho_da_forja"]=3},
	
	altura = 20,
	largura = 31,
	filepath = minetest.get_modpath("aventuras_bob").."/schems/forja_bob.mts",
	
	mapgen = {
		tipo = "suspenso",
		bioma = "floresta",
	},
	
})

