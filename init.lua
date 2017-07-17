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

-- Banco de dados
aventuras.bd = dofile(modpath.."/lib/memor.lua")

-- Carregar scripts
notificar("Carregando...")

-- Metodos comuns
dofile(modpath.."/comum/online.lua")
dofile(modpath.."/comum/verif_tarefa.lua")
dofile(modpath.."/comum/contar_tb.lua")
dofile(modpath.."/comum/pegar_index.lua")
dofile(modpath.."/comum/trocar_itens.lua")
dofile(modpath.."/comum/exibir_alerta.lua")
dofile(modpath.."/comum/check_aven_req.lua")

-- API
dofile(modpath.."/api.lua")

-- Callbacks
dofile(modpath.."/callbacks.lua")

-- Craftitens
dofile(modpath.."/craftitens/livro_de_aventuras.lua")

-- Recursos
dofile(modpath.."/recursos/npc.lua")

-- Tarefas
dofile(modpath.."/tarefas/troca_npc.lua")
dofile(modpath.."/tarefas/info_npc.lua")
dofile(modpath.."/tarefas/place_node.lua")
dofile(modpath.."/tarefas/dig_node.lua")
dofile(modpath.."/tarefas/craftar.lua")
dofile(modpath.."/tarefas/comer.lua")
notificar("OK")
