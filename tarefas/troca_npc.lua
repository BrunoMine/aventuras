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

-- Gerar um formspec de tarefa
local gerar_form = function(aventura, dados, npc)
	
	local arte_npc = aventuras.recursos.npc.arte[npc]
	
	local formspec = "size[10,10]"
		..arte_npc.bgcolor
		..arte_npc.bg_img1x1
		.."label[0,0;"..aventuras.tb[aventura].titulo.."]"
		.."image[0,1;3,3;"..arte_npc.face.."]"
		.."label[3,1;"..dados.titulo.."]"
		.."textarea[3.1,1.5;7,2.5;msg;;"..dados.msg.."]"
		-- Itens Requisitados
		.."label[0,4;Requisitos]"
		-- Itens de Recompensa
		.."label[0,6.5;Recompensas]"
		-- Botao concluir
		.."button[0,9;10,1;concluir;Concluir]"
	
	-- Colocar itens requisitados
	if dados.item_rem then
		local ir = dados.item_rem -- diminuindo tamanho do nome da variavel
		if ir[1] then
			formspec = formspec .. "item_image_button[0,4.5;2,2;"..ir[1].name.." "..ir[1].count..";item1;]"
		end
		if ir[2] then
			formspec = formspec .. "item_image_button[2,4.5;2,2;"..ir[2].name.." "..ir[2].count..";item2;]"
		end
		if ir[3] then
			formspec = formspec .. "item_image_button[4,4.5;2,2;"..ir[3].name.." "..ir[3].count..";item3;]"
		end
		if ir[4] then
			formspec = formspec .. "item_image_button[6,4.5;2,2;"..ir[4].name.." "..ir[4].count..";item4;]"
		end
		if ir[5] then
			formspec = formspec .. "item_image_button[8,4.5;2,2;"..ir[5].name.." "..ir[5].count..";item5;]"
		end
	end
	
	-- Colocar itens de recompensa
	if dados.item_add then
		local ia = dados.item_add -- diminuindo tamanho do nome da variavel
		if ia[1] then
			formspec = formspec .. "item_image_button[0,7;2,2;"..ia[1].name.." "..ia[1].count..";item1;]"
		end
		if ia[2] then
			formspec = formspec .. "item_image_button[2,7;2,2;"..ia[2].name.." "..ia[2].count..";item2;]"
		end
		if ia[3] then
			formspec = formspec .. "item_image_button[4,7;2,2;"..ia[3].name.." "..ia[3].count..";item3;]"
		end
		if ia[4] then
			formspec = formspec .. "item_image_button[6,7;2,2;"..ia[4].name.." "..ia[4].count..";item4;]"
		end
		if ia[5] then
			formspec = formspec .. "item_image_button[8,7;2,2;"..ia[5].name.." "..ia[5].count..";item5;]"
		end
	end
		
	
	return formspec
end


-- Adicionar tarefa à aventura
aventuras.tarefas.troca_npc.adicionar = function(aventura, def)
	
	-- Prepara tabela registros da tarefa
	local reg = {
		titulo = def.titulo,
		tipo = "troca_npc",
		
		aven_req = def.dados.aven_req or {},
		
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
aventuras.tarefas.troca_npc.npcs.on_rightclick = function(npc, clicker, aventura, tarefa)
	
	-- Pegar dados da tarefa atual
	local dados = aventuras.tb[aventura].tarefas[tarefa]
	
	local name = clicker:get_player_name()
	
	-- Salva os dados da tarefa que estará sendo processada nos proximos momentos
	aventuras.online[name].troca_npc = {aventura=aventura, dados=dados, tarefa=tarefa, npc=npc}
	
	-- Exibir pedido de itens
	minetest.show_formspec(name, "aventuras:troca_npc", gerar_form(aventura, dados, npc))
	
	return

end

-- Receptor de botões
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "aventuras:troca_npc" then
		
		if fields.concluir then
			
			local name = player:get_player_name()
			
			-- Obter dados da tarefa que está sendo processada
			local dados = aventuras.online[name].troca_npc.dados
			
			-- Tenta realizar a troca
			if dados.item_rem or dados.item_add then
				if aventuras.comum.trocar_itens(player, dados.item_rem, dados.item_add) == false then
					aventuras.comum.exibir_alerta(name, "Precisa dos itens para a troca")
					return
				end
			end
			
			-- Pegar dados sobre arte do npc
			local arte_npc = aventuras.recursos.npc.arte[aventuras.online[name].troca_npc.npc]
			
			-- Informa a conclusao da tarefa
			minetest.show_formspec(name, "aventuras:troca_npc_fim", "size[10,3]"
				.."bgcolor["..arte_npc.bgcolor..";true]"
				..arte_npc.bg_img10x3
				.."image[0,0;3.3,3.3;"..arte_npc.face.."]"
				.."label[3,0;"..dados.titulo.."]"
				.."textarea[3.26,0.5;7,3;msg_fim;;"..dados.msg_fim.."]"
			)
			
			-- Salva a conclusao da missao
			aventuras.salvar_tarefa(name, aventuras.online[name].troca_npc.aventura, aventuras.online[name].troca_npc.tarefa)
			aventuras.callbacks.concluiu(name, aventuras.online[name].troca_npc.aventura, aventuras.online[name].troca_npc.tarefa)
			
			-- Toca o som de conclusao
			if arte_npc.sounds.concluir then
				minetest.sound_play(arte_npc.sounds.concluir.name, {to_player = name, gain = arte_npc.sounds.concluir.gain})
			else
				minetest.sound_play("aventuras_concluir", {to_player = name, gain = 0.7})
			end
			
		end
		
		
	end
end)






