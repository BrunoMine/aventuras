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

-- Item de troca por itens de aventuras estraviados
aventuras.moeda_bau_noob = minetest.setting_get("aventuras_moeda_bau_noob") or "default:gold_ingot"

-- Setup automatico de estruturas
aventuras.autosetup_estruturas = minetest.setting_getbool("aventuras_autosetup_estruturas") or true

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

-- Traduções
dofile(modpath.."/tradutor.lua")

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
dofile(modpath.."/recursos/personagem.lua")
dofile(modpath.."/recursos/editor_schem.lua")
dofile(modpath.."/recursos/estruturas/estruturas.lua")

-- Nodes
dofile(modpath.."/nodes/bau_aventureiro_noob.lua")
dofile(modpath.."/nodes/balao_aventureiro.lua")

-- Tarefas
dofile(modpath.."/tarefas/npc_troca.lua")
dofile(modpath.."/tarefas/npc_info.lua")
dofile(modpath.."/tarefas/npc_placenode.lua")
dofile(modpath.."/tarefas/npc_dignode.lua")
dofile(modpath.."/tarefas/npc_craft.lua")
dofile(modpath.."/tarefas/npc_alimento.lua")
notificar("OK")


