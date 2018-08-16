--[[
	Mod Aventuras_Tomas para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Casa do Tomas
  ]]

local S = aventuras_tomas.S


-- Casa do Tomas
aventuras.registrar_estrutura("aventuras_tomas:casa_tomas", {
	
	titulo = S("Casa do Tomas"),
	versao = "1",
	
	protected_area_id = S("Aventuras_Tomas:Casa"),
	
	altura = 16,
	largura = 25,
	filepath = minetest.get_modpath("aventuras_tomas").."/schems/casa_tomas.mts",
	
	mapgen = {
		tipo = "suspenso",
		bioma = "floresta",
	},
	
})
