--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicializador de variaveis e scripts
  ]]

-- Notificador de Inicializador
local notificar = function(msg)
	if minetest.setting_get("log_mods") then
		minetest.debug("[AVENTURAS]"..msg)
	end
end

local modpath = minetest.get_modpath("aventuras")

-- Variavel global
aventuras = {}

-- Tabela de aventuras registradas
aventuras.tb = {}

-- Tabela de funções dos tipos de tarefas
aventuras.tarefas = {}

-- Carregar scripts
notificar("Carregando scripts...")
-- Scripts mod memor embarcado
dofile(modpath.."/memor/init.lua")
-- Criação do banco de dados
aventuras.bd = memor.montar_bd()
-- Funções comuns
dofile(modpath.."/trocar.lua")
dofile(modpath.."/npcs.lua")
-- Tarefas
dofile(modpath.."/tarefas/uninpc.lua")
-- API
dofile(modpath.."/api.lua")
dofile(modpath.."/teste.lua")
notificar("OK")

