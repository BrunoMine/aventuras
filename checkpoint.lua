--[[
	Mod aventuras para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Estrutura de checkpoint
  ]]

local S = aventuras.S

-- Checkpoint
aventuras.registrar_estrutura("aventuras:checkpoint", {
	
	titulo = S("Checkpoint"),
	versao = "1",
	protected_area_id = S("Aventuras:Checkpoint"),
	
	altura = 140,
	largura = 14,
	filepath = minetest.get_modpath("aventuras").."/schems/checkpoint.mts",
	
	mapgen = {
		tipo = "suspenso",
		bioma = "floresta",
	},
	
})
