--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Framework : Tarefa do tipo npc_dignode
	
	Nessa tarefa o jogador precisa acessar um NPC e depois cavar um node para concluir (uma mensagem aparece no chat quando a aventura termina)
  ]]

-- Tabela de registros dessa tarefa
aventuras.tarefas.npc_dignode = {}

local S = aventuras.S

-- Gerar um formspec de tarefa
aventuras.tarefas.npc_dignode.gerar_form = function(aventura, dados, npc, name)
	
	local arte_npc = aventuras.recursos.npc.arte[npc]
	
	local formspec = "size[7,7]"
		..arte_npc.bgcolor
		..arte_npc.bg_img1x1
		.."label[0,0;"..aventuras.tb[aventura].titulo.."]"
		.."label[0,0.5;"..dados.titulo.."]"
		.."image[0.65,1;3,3;"..arte_npc.face.."]"
		.."textarea[0.26,3.8;7,2.5;;"..dados.msg..";]"
		-- Botao concluir
		.."button_exit[0,6;7,1;;"..S("Entendido").."]"
	
	if dados.img_node then
		formspec = formspec .. "image[3.65,1;3,3;"..dados.img_node.."]"
	else
		formspec = formspec .. "item_image_button[3.65,1;2.75,2.75;"..dados.item..";item;]"
	end
	
	return formspec
end


-- Adicionar tarefa à aventura
aventuras.tarefas.npc_dignode.adicionar = function(aventura, def)

	-- Prepara tabela registros da tarefa
	local reg = {
		mod = def.mod,
		titulo = def.titulo,
		tipo = "npc_dignode",
		
		aven_req = def.dados.aven_req or {},
		
		item = def.dados.item,
		img_node = def.dados.img_item,
		
		msg = def.dados.msg,
		msg_fim = def.dados.msg_fim,
		
		-- Permite receber 'on_rightclick' dos npcs informados 
		npcs = {
			on_rightclick = {}, -- será preenchido posteriormente
		},
		
	}
	
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
aventuras.tarefas.npc_dignode.npcs = {}

-- Receber chamada de 'on_rightclick' de algum dos npcs acessados
aventuras.tarefas.npc_dignode.npcs.on_rightclick = aventuras.comum.get_on_rightclick_npc("npc_dignode")
-- Verificar ao cavar node
minetest.register_on_dignode(function(pos, oldnode, digger)
	
	-- Realiza rotina padrão para itens aguardados por esse tipo de tarefa
	aventuras.comum.verif_item_tarefa(digger:get_player_name(), "npc_dignode", oldnode.name)
	
end)


-- Mantem a tabela temporaria de dados enquanto o jogador estiver online
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if aventuras.bd.verif("player_"..name, "tarefa_npc_dignode") == true then
		if not aventuras.online[name].npc_dignode then aventuras.online[name].npc_dignode = {} end
		aventuras.online[name].npc_dignode.aven = aventuras.bd.pegar("player_"..name, "tarefa_npc_dignode")
	end
end)







