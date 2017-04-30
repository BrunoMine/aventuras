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

-- Tabela de Recursos
aventuras.recursos = {}

-- Tabela de metodos comuns
aventuras.comum = {} 

-- Carregar scripts
notificar("Carregando...")

-- Bibliotecas
dofile(modpath.."/lib/memor/init.lua")

-- Metodos comuns
dofile(modpath.."/comum/verif_tarefa.lua")
dofile(modpath.."/comum/contar_tb.lua")
dofile(modpath.."/comum/pegar_index.lua")
dofile(modpath.."/comum/trocar_itens.lua")

-- API
dofile(modpath.."/api.lua")

-- Recursos
dofile(modpath.."/recursos/npc.lua")

-- Tarefas
dofile(modpath.."/tarefas/troca_npc.lua")
notificar("OK")
