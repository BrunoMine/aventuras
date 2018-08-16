--[[
	Mod Aventuras_Masmorras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Labirinto das Masmorras
  ]]

local S = aventuras_bob.S


-- Masmorras do Esquecimento
aventuras.registrar_estrutura("aventuras_bob:labirinto_das_masmorras", {
	
	titulo = S("Labirinto das Masmorras"),
	versao = "2",
	protected_area_id = S("Aventuras_Bob:Labirinto"),
	
	aven_req = {["aventuras_bob:caminho_da_forja"]=1},
	req_exato = true,
	
	altura = 17,
	largura = 29,
	filepath = minetest.get_modpath("aventuras_bob").."/schems/labirinto_das_masmorras.mts",
	
	mapgen = {
		tipo = "suspenso",
		bioma = "floresta",
	},
	
})

