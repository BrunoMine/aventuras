--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Framework : Tarefa do tipo npc_info
	
	Nessa tarefa o jogador apenas precisa acessar o npc e clicar em concluir
  ]]

-- Tabela de registros dessa tarefa
aventuras.tarefas.npc_info = {}

local S = aventuras.S

-- Gerar um formspec de tarefa
local gerar_form = function(aventura, dados, npc, name)
	
	local arte_npc = aventuras.recursos.npc.arte[npc]
	
	local formspec = "size[7,7]"
		..arte_npc.bgcolor
		..arte_npc.bg_img1x1
		.."label[0,0;"..aventuras.tb[aventura].titulo.."]"
		.."label[0,0.5;"..dados.titulo.."]"
		.."image[2.15,1;3,3;"..arte_npc.face.."]"
		.."textarea[0.26,3.8;7,2.5;;"..dados.msg..";]"
		-- Botao concluir
		.."button[0,6;7,1;concluir;"..S("Concluir").."]"
	
	return formspec
end

-- Adicionar tarefa à aventura
aventuras.tarefas.npc_info.adicionar = function(aventura, def)
	
	-- Prepara tabela registros da tarefa
	local reg = {
		mod = def.mod,
		titulo = def.titulo,
		tipo = "npc_info",
		
		aven_req = def.dados.aven_req or {},
		
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
aventuras.tarefas.npc_info.npcs = {}

-- Receber chamada de 'on_rightclick' de algum dos npcs acessados
aventuras.tarefas.npc_info.npcs.on_rightclick = function(npc, clicker, aventura, tarefa)
	
	-- Pegar dados da tarefa atual
	local dados = aventuras.tb[aventura].tarefas[tarefa]
	
	local name = clicker:get_player_name()
	
	-- Salva os dados da tarefa que estará sendo processada nos proximos momentos
	aventuras.online[name].npc_info = {aventura=aventura, dados=dados, tarefa=tarefa, npc=npc}
	
	-- Exibir pedido de itens
	minetest.show_formspec(name, "aventuras:npc_info", gerar_form(aventura, dados, npc, clicker:get_player_name()))
	
	return

end

-- Receptor de botões
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "aventuras:npc_info" then
		
		if fields.concluir then
			
			local name = player:get_player_name()
			
			-- Obter dados da tarefa que está sendo processada
			local dados = aventuras.online[name].npc_info.dados
			
			-- Pegar dados sobre arte do npc
			local arte_npc = aventuras.recursos.npc.arte[aventuras.online[name].npc_info.npc]
			
			-- Informa a conclusao da tarefa
			minetest.show_formspec(name, "aventuras:npc_info_fim", "size[10,3]"
				.."bgcolor["..arte_npc.bgcolor..";true]"
				..arte_npc.bg_img10x3
				.."image[0,0;3.3,3.3;"..arte_npc.face.."]"
				.."label[3,0;"..dados.titulo.."]"
				.."textarea[3.26,0.5;7,3;;"..dados.msg_fim..";]"
			)
			
			-- Salva a conclusao da missao
			aventuras.salvar_tarefa(name, aventuras.online[name].npc_info.aventura, aventuras.online[name].npc_info.tarefa)
			aventuras.callbacks.concluiu(name, aventuras.online[name].npc_info.aventura, aventuras.online[name].npc_info.tarefa)
			
			-- Toca o som de conclusao
			if arte_npc.sounds.concluir then
				minetest.sound_play(arte_npc.sounds.concluir.name, {to_player = name, gain = arte_npc.sounds.concluir.gain})
			else
				minetest.sound_play("aventuras_concluir", {to_player = name, gain = 0.7})
			end
			
		end
		
		
	end
end)






