--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Framework : Tarefa do tipo troca_npc
	
	Nessa tarefa o jogador deve realizar um troca com um ou mais npcs
  ]]

-- Tabela de registros dessa tarefa
aventuras.tarefas.troca_npc = {}

-- Adicionar tarefa à aventura
aventuras.tarefas.troca_npc.adicionar = function(aventura, def)
	
	-- Prepara tabela registros da tarefa
	local reg = {
		titulo = def.titulo,
		tipo = "troca_npc",
		
		msg = def.dados.msg,
		msg_fim = def.dados.msg_fim,
		item_rem = def.dados.item_rem,
		item_add = def.dados.item_add,
		
		-- Permite receber 'on_rightclick' dos npcs informados 
		npcs = {
			on_rightclick = {}, -- será preenchido posteriormente
		},
		
	}
	
	-- Verificar se tem tabelas varias
	if (not reg.item_rem or not reg.item_rem[1]) and (not reg.item_add or not reg.item_add[1]) then
		reg.item_rem = nil
		reg.item_add = nil
	end
	
	-- Registra os npcs para que sejam reconhecidos pela framework que controla esse recurso (NPCs)
	for _,n in ipairs(def.dados.npcs) do
		aventuras.recursos.npc.registrar(n, aventura)
		-- Permite receber 'on_rightclick' dos npcs informados
		reg.npcs.on_rightclick[n] = {}
	end
	
	
	
	
	-- Adiciona nova tarefa nas tarefas da aventura
	table.insert(aventuras.tb[aventura].tarefas, reg)
	
end

-- Interface com entidades/npcs
aventuras.tarefas.troca_npc.npcs = {}

-- Receber chamada de 'on_rightclick' de algum dos npcs acessados
aventuras.tarefas.troca_npc.npcs.on_rightclick = function(self, clicker, aventura, tarefa)
	
	-- Pegar dados da tarefa atual
	local dados = aventuras.tb[aventura].tarefas[tarefa]
	
	local name = clicker:get_player_name()
	
	-- Pedir itens
	minetest.chat_send_player(clicker:get_player_name(), dados.msg)
	
	-- Verificar se essa tarefa realiza uma troca
	if dados.item_rem or dados.item_add then
		if aventuras.comum.trocar_itens(clicker, dados.item_rem, dados.item_add) == false then
			minetest.chat_send_player(name, "Precisa dos itens para a troca")
			return
		end
	end
	
	-- Troca feita
	minetest.chat_send_player(name, dados.msg_fim)
	minetest.chat_send_player(name, "Missao contruida")
	
	-- Salva a conclusao da missao
	aventuras.bd:salvar(name, aventura, tarefa)
	
	return
	
end






