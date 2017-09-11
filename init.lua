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

-- Algoritimo da propria API
aventuras.S = dofile(modpath.."/lib/intllib.lua")

-- Item de troca por itens de aventuras estraviados
aventuras.moeda_bau_noob = minetest.setting_get("aventuras_moeda_bau_noob") or "default:gold_ingot"

-- Tabela de Recursos
aventuras.recursos = {}

-- Tabela de metodos comuns
aventuras.comum = {} 

-- Biblioteca para simplificação de trocas
aventuras.tror = dofile(modpath.."/lib/tror.lua")

-- Banco de dados
aventuras.bd = dofile(modpath.."/lib/memor.lua")

-- Verifica modo editor
aventuras.editor_mode = minetest.setting_getbool("aventuras_editor_mode") or false

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
dofile(modpath.."/comum/on_rightclick_npc.lua")
dofile(modpath.."/comum/verif_item_tarefa.lua")

-- API
dofile(modpath.."/api.lua")

-- Callbacks
dofile(modpath.."/callbacks.lua")

-- Craftitens
dofile(modpath.."/craftitens/livro_de_aventuras.lua")

-- Recursos
dofile(modpath.."/recursos/acesso_npc.lua")
dofile(modpath.."/recursos/register_character.lua")
dofile(modpath.."/recursos/editor_schem.lua")

-- Nodes
dofile(modpath.."/nodes/bau_aventureiro_noob.lua")

-- Tarefas
dofile(modpath.."/tarefas/troca_npc.lua")
dofile(modpath.."/tarefas/info_npc.lua")
dofile(modpath.."/tarefas/place_node.lua")
dofile(modpath.."/tarefas/dig_node.lua")
dofile(modpath.."/tarefas/craftar.lua")
dofile(modpath.."/tarefas/comer.lua")
notificar("OK")
