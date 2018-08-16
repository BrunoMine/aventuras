--[[
	Mod Aventuras_Masmorras para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicializador de variaveis e scripts
  ]]

-- Notificador de Inicializador
local notificar = function(msg)
	if minetest.setting_get("log_mods") then
		minetest.debug("[Aventuras_Bob] "..msg)
	end
end

local modpath = minetest.get_modpath("aventuras_bob")

-- Tabela Global
aventuras_bob = {}

-- Carregar scripts
notificar("Carregando scripts...")
dofile(modpath.."/tradutor.lua")
dofile(modpath.."/bau_labirinto_das_masmorras.lua")
dofile(modpath.."/craftitems.lua")
dofile(modpath.."/npc_bob.lua")
dofile(modpath.."/forja_bob.lua")
dofile(modpath.."/mazenode.lua")

-- Aventuras
dofile(modpath.."/aventuras/caminho_da_forja.lua")
dofile(modpath.."/aventuras/bob_o_forjador.lua")

-- Lugar 
dofile(modpath.."/labirinto_das_masmorras.lua")

notificar("OK")

