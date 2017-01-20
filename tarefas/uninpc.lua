--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Tarefa 'uninpc'
  ]]

aventuras.tarefas.uninpc = {}

-- Tratativas de registro
--[[
	As os parametros/definições fornecidos são processados e armazenados.
	Dados relevantes são retornados
	Entende-se que os argumentos 1 e 2 já foram filtrados, bem como def.tipo
	Retorno:
		resultado | (booleano) resultado da operação
		dados | Dados resultantes do processamento
			^ dados (string) mensagem explicando a falha caso ocorra
			^ dados.npcs (tabela ordenada) tabela de strings dos IDs dos npcs que interagem na tarefa
  ]]
aventuras.tarefas.uninpc.registrar = function(aventura, numero, def)
	
	-- Verificar Titulo
	if not def.titulo then
		return false, "Nenhum Titulo definido ao registrar a tarefa "..numero.." da aventura "..aventura
	end
	
	-- Verificar registro de NPCs
	if not def.npc or not def.npc[1] then
		return false, "Nenhum NPC definido ao registrar a tarefa "..numero.." da aventura "..aventura
	end
	
	-- Verificar registros de falas
	if not def.fala1 then
		return false, "Faltou parametro 'fala1' ao registrar a tarefa "..numero.." da aventura "..aventura
	end
	if not def.fala2 then
		return false, "Faltou parametro 'fala2' ao registrar a tarefa "..numero.." da aventura "..aventura
	end
	
	-- Verificar se existe troca de itens
	if (not def.item_rem or not def.item_rem[1]) and (not def.item_add or not def.item_add[1]) then
		return false, "Nenhuma troca de itens definida ao registrar tarefa "..numero.." da aventura "..aventura
	end
	
	-- Verificar se existe excesso de itens para dar ou receber
	if def.item_rem and def.item_rem[5] then
		return false, "Excesso de itens exigidos na tarefa "..numero.." da aventura "..aventura
	end
	if def.item_add and def.item_add[5] then
		return false, "Excesso de itens exigidos na tarefa "..numero.." da aventura "..aventura
	end
	
	-- Salvar dados da tarefa registrada
	aventuras.tb[aventura].tarefas[numero] = {}
	
	-- Salva os NPC como tabela desordenada para encontrar facilmente pelo nome do npc
	aventuras.tb[aventura].tarefas[numero].npcs = {}
	for _,npc in ipairs(def.npc) do
		aventuras.tb[aventura].tarefas[numero].npcs[npc] = true
	end
	
	aventuras.tb[aventura].tarefas[numero].titulo = def.titulo
	aventuras.tb[aventura].tarefas[numero].tipo = def.tipo
	aventuras.tb[aventura].tarefas[numero].fala1 = def.fala1
	aventuras.tb[aventura].tarefas[numero].fala2 = def.fala2
	if def.item_rem and def.item_rem[1] then aventuras.tb[aventura].tarefas[numero].item_rem = def.item_rem end
	if def.item_add and def.item_add[1] then aventuras.tb[aventura].tarefas[numero].item_add = def.item_add end
	
	-- Tarefa registrada com sucesso
	return true, {npcs=def.npc}
end


-- Receber acesso em um NPC para
--[[
	Entende-se que já foi verificada a consistencia dos dados aventura, tarefa e name
  ]]
aventuras.tarefas.uninpc.acessar = function(name, aventura, numero)
	
	-- Pegar dados da tarefa
	local dados = aventuras.tb[aventura].tarefas[numero]
	
	local formspec = "size[8,9.2]"
		
		-- Título da aventura
		.."label[0,0;"..aventuras.tb[aventura].titulo.."]"
		
		-- Titulo da tarefa e Fala do NPC
		.."textarea[3,1;5.25,2.9;name;"..dados.titulo..";"..dados.fala1.."]"
		
		-- Requisitos
		.."label[0,3.5;Requisitos]"
		
		-- Recompensas
		.."label[0,6;Recompensas]"
		
		-- Botoes
		.."button_exit[0,8.5;4,1;sair;Entendido]"
		.."button[4,8.5;4,1;concluir;Concluir]"
	
	-- Colocar personalizações do NPC
	local custom_npc = aventuras.npcs.registros[aventuras.acessos[name].ent.name]
	-- Face do NPC
	if custom_npc.face then 
		formspec = formspec .. "image[0,0.8;3,3;"..custom_npc.face.."]"
	else
		formspec = formspec .. "label[0,1.7;Sem Foto]"
	end 
	-- Imagem de fundo
	if custom_npc.bg then 
		formspec = formspec .. "background[0,0;1,1;"..custom_npc.bg..";true]"
	else
		formspec = formspec .. default.gui_bg_img
	end 
	-- Cor de fundo
	if custom_npc.cor_bg then 
		formspec = formspec .. "bgcolor[".. custom_npc.cor_bg.."20;true]"
	end 
	
	
	-- Colocação dos itens de requisitos e recompensas
	if dados.item_rem then
		formspec = formspec .."item_image_button[0,4;2,2;"..dados.item_rem[1]..";item1;]"
		if dados.item_rem[2] then formspec = formspec .."item_image_button[2,4;2,2;"..dados.item_rem[2]..";item2;]" end
		if dados.item_rem[3] then formspec = formspec .."item_image_button[4,4;2,2;"..dados.item_rem[3]..";item3;]" end
		if dados.item_rem[4] then formspec = formspec .."item_image_button[6,4;2,2;"..dados.item_rem[4]..";item4;]" end
	else
		formspec = formspec .. "label[1,4.5;Nenhum]"
	end
	if dados.item_add then
		formspec = formspec .."item_image_button[0,6.5;2,2;"..dados.item_add[1]..";item5;]"
		if dados.item_add[2] then formspec = formspec .."item_image_button[2,6.5;2,2;"..dados.item_add[2]..";item6;]" end
		if dados.item_add[3] then formspec = formspec .."item_image_button[4,6.5;2,2;"..dados.item_add[3]..";item7;]" end
		if dados.item_add[4] then formspec = formspec .."item_image_button[6,6.5;2,2;"..dados.item_add[4]..";item8;]" end
	else
		formspec = formspec .. "label[1,7;Nenhum]"
	end
	
	-- Salvar a aventura e tarefa que o jogador está acessando
	aventuras.acessos[name].aven = aventura
	aventuras.acessos[name].tarefa = numero
	
	-- Mostrar formulario para escolher uma aventura
	return minetest.show_formspec(name, 
		"aventuras:uninpc_npc",
		formspec
	)
	
end

-- Botoes
minetest.register_on_player_receive_fields(function(player, formname, fields)
	
	-- Formularios de NPCs
	if formname == "aventuras:uninpc_npc" then
		if not player then return end
		
		-- Concluir tarefa
		if fields.concluir then
			
			-- Pegar nome do jogador
			local name = player:get_player_name()
			
			-- Verificar se o NPC ainda existe
			if not aventuras.acessos[name].ent then return end
			
			-- Pegar dados da tarefa
			local dados = aventuras.tb[aventuras.acessos[name].aven].tarefas[aventuras.acessos[name].tarefa]
			
			-- Tenta realizar a troca
			if aventuras.trocar(player, dados.item_rem, dados.item_add) ~= true then
				
				-- Jogador não tem os itens requisitados
				-- Seria interessante tocar um som para que o jogador saiba que ele nao te o item
				-- Permanece sem retorno
				return
			end
			
			-- Concluir tarefa
			
			-- Salvar tarefa concluida no banco de dados
			aventuras.bd:salvar(name, aventuras.acessos[name].aven, aventuras.acessos[name].tarefa)
			
			-- Exibir fala final da tarefa
			local formspec = "size[8,9.2]"
				
				-- Titulo da aventura
				.."label[0,0;"..aventuras.tb[aventuras.acessos[name].aven].titulo.."]"
		
				-- Titulo da tarefa e Fala do NPC
				.."textarea[0.85,5.5;7,3;name;"..dados.titulo..";"..dados.fala2.."]"
				
				-- Botoes
				.."button_exit[0,8.5;8,1;sair;Entendido]"
			
			-- Colocar personalizações do NPC
			local custom_npc = aventuras.npcs.registros[aventuras.acessos[name].ent.name]
			-- Face do NPC
			if custom_npc.face then 
				formspec = formspec .. "image[2.3,1;4,4;"..custom_npc.face.."]"
			else
				formspec = formspec .. "label[2.8,2.5;Sem Foto]"
			end 
			-- Imagem de fundo
			if custom_npc.bg then 
				formspec = formspec .. "background[0,0;1,1;"..custom_npc.bg..";true]"
			else
				formspec = formspec .. default.gui_bg_img
			end 
			-- Cor de fundo
			if custom_npc.cor_bg then 
				formspec = formspec .. "bgcolor[".. custom_npc.cor_bg.."20;true]"
			end 
			
			-- Mostrar formulario
			return minetest.show_formspec(name, 
				"aventuras:uninpc_fim",
				formspec
			)
		end	
		
	end
end)
