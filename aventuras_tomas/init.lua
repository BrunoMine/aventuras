--[[
	Mod Aventuras_Tomas para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicializador de variaveis e scripts
  ]]

-- Notificador de Inicializador
local notificar = function(msg)
	if minetest.setting_get("log_mods") then
		minetest.debug("[Aventuras_Tomas] "..msg)
	end
end

aventuras_tomas = {}

-- Versao do mod
aventuras_tomas.versao = "0.1.0"

local modpath = minetest.get_modpath("aventuras_tomas")

-- Carregar scripts
notificar("Carregando scripts...")
dofile(modpath.."/tradutor.lua")
dofile(modpath.."/npc_tomas.lua")
dofile(modpath.."/casa_tomas.lua")

-- Aventuras
dofile(modpath.."/aventuras/conhecendo_tomas.lua")
notificar("OK")

