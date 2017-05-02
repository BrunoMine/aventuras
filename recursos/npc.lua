--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Recurso utilizado em tarefas : NPCs
  ]]

-- Tabela de Recurso de NPCs
aventuras.recursos.npc = {}

-- Tabelas de aventuras NPCs registrados
aventuras.recursos.npc.reg = {}

-- Tabela de arte de NPCs registrados 
aventuras.recursos.npc.arte = {}

-- Verificar se ja foi criada a taela temporaria npcs
local verif_tb_temp = function(name)
	if not aventuras.online[name].npcs then
		aventuras.online[name].npcs = {}
	end	
end

-- Registrar arte de um NPC
aventuras.recursos.npc.registrar_arte = function(nome, def)
	-- Armazena dados sobre arte
	aventuras.recursos.npc.arte[nome] = {
		face = def.face,
		bgcolor = def.bgcolor,
		bg_img1x1 = def.bg_img1x1,
		bg_img10x3 = def.bg_img10x3,
	}
end

-- Registrar um NPC
aventuras.recursos.npc.registrar = function(nome, aventura)

	if not nome or not aventura then -- Verificar nome
		minetest.log("error", "[Sunos] Faltam dados em aventuras.recursos.npc.registrar")
		return false
	end
	
	-- Cria registro do npc caso nao exista
	if not aventuras.recursos.npc.reg[nome] then aventuras.recursos.npc.reg[nome] = {} end
	
	-- Cria arte caso nao exista
	if not aventuras.recursos.npc.arte[nome] then
		aventuras.recursos.npc.registrar_arte(nome, {
			face = "logo.png",
			bgcolor = "bgcolor[#080808BB;true]",
			bg_img1x1 = "background[5,5;1,1;gui_formbg.png;true]",
			bg_img10x3 = "background[5,5;1,1;gui_formbg.png;true]",
		})
	end
	
	-- Registra atribuição de aventura ao npc
	aventuras.recursos.npc.reg[nome][aventura] = {}
	
end

-- Recebe chamada 'on_rightclick' de um NPC
aventuras.recursos.npc.on_rightclick = function(self, clicker)
	
	if not aventuras.recursos.npc.reg[self.name] then -- Verificar registro do npc
		minetest.log("error", "[Sunos] NPC nao registrado (aventuras.recursos.npc.on_rightclick)")
		return false
	end 
	
	local name = clicker:get_player_name()
	
	-- Prepara tabela temporaria de npcs relacionados ao jogador
	verif_tb_temp(name)
	
	-- Salva o nome ultimo npc acessado
	aventuras.online[name].npc = self.name
	
	-- Verifica tarefas de aventuras relacionadas
	aventuras.online[name].tb_aventuras_ok = {} -- tabela de aventuras que aguardam a interação 'on_rightclick'
	for aventura,def in pairs(aventuras.recursos.npc.reg[self.name]) do
		
		-- Verifica se o jogador tem registro da aventura
		if aventuras.bd:verif(name, aventura) ~= true then
		
			-- Cria o registro do jogaor na aventura
			aventuras.bd:salvar(name, aventura, 0)
		
		end
		
		-- Tarefa do jogador nessa aventura
		local tarefa_atual = aventuras.bd:pegar(name, aventura) + 1
		
		-- Verificar se tarefa existe
		if aventuras.comum.verif_tarefa(aventura, tarefa_atual) == true then
		
			-- Verificar se a tarefa atual da aventura aguarda 'on_rightclick' do NPC
			if aventuras.tb[aventura].tarefas[tarefa_atual].npcs 
				and aventuras.tb[aventura].tarefas[tarefa_atual].npcs.on_rightclick 
				and aventuras.tb[aventura].tarefas[tarefa_atual].npcs.on_rightclick[self.name]
				and aventuras.tb[aventura].tarefas[tarefa_atual].npcs.on_rightclick[self.name]
				and aventuras.comum.check_aven_req(name, aventuras.tb[aventura].tarefas[tarefa_atual].aven_req) == true
			then
				-- Adiciona na tabela de aventuras que aguardam interação 
				aventuras.online[name].tb_aventuras_ok[aventura] = tarefa_atual -- Armazena respectiva tarefa
			end
		
		end
	end
	
	-- Verifica se encontrou alguma aventura aguardando 'on_rightclick'
	local qtd_tarefas = aventuras.comum.contar_tb(aventuras.online[name].tb_aventuras_ok)
	
	if qtd_tarefas > 1 then
		
		-- Tabela de aventuras
		local aven_tb = {}
		-- String de titulos de aventuras
		local titulos = ""
		for aventura,n in pairs(aventuras.online[name].tb_aventuras_ok) do
			if titulos ~= "" then titulos = titulos .. "," end
			table.insert(aven_tb, aventura)
			titulos = titulos .. aventuras.tb[aventura].titulo
		end
		aventuras.online[name].menu_aven_tb = minetest.deserialize(minetest.serialize(aven_tb))
		
		local arte_npc = aventuras.recursos.npc.arte[self.name]
		
		-- Pergunta a tarefa escolhida
		local formspec = "size[5,5]"
			..arte_npc.bgcolor
			..arte_npc.bg_img1x1
			.."label[0,0;Escolha uma aventura]"
			.."textlist[0,0.5;5,4.5;menu;"..titulos..";;true]"
		
		
		return minetest.show_formspec(clicker:get_player_name(), "aventuras:npc_menu_aventuras", formspec)
		
		
	elseif qtd_tarefas == 1 then
		
		local aventura = aventuras.comum.pegar_index(aventuras.online[name].tb_aventuras_ok)
		local tarefa = aventuras.online[name].tb_aventuras_ok[aventura]
		local npc = aventuras.online[name].npc
		
		local tipo_tarefa = aventuras.tb[aventura].tarefas[tarefa].tipo
		
		-- Direciona interação para a tarefa disponivel	
		return aventuras.tarefas[tipo_tarefa].npcs.on_rightclick(npc, clicker, aventura, tarefa)
		
	else
	
		-- Informa que nao existe tarefa disponivel no momento
		aventuras.comum.exibir_alerta(clicker:get_player_name(), "Nenhuma interacao disponivel")
		return true
	end
end


-- Receptor de botoes
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "aventuras:npc_menu_aventuras" then
		
		if fields.menu then
			
			local name = player:get_player_name()
			
			local escolha = tonumber(string.split(fields.menu, ":")[2])
			
			local aventura = aventuras.online[name].menu_aven_tb[escolha]
			local tarefa = aventuras.online[name].tb_aventuras_ok[aventura]
			local tipo_tarefa = aventuras.tb[aventura].tarefas[tarefa].tipo
			local npc = aventuras.online[name].npc
			
			-- Verifica se a tarefa ainda esta habilitada
			if aventuras.bd:pegar(name, aventura) ~= tarefa-1 then
				aventuras.comum.exibir_alerta(player:get_player_name(), "Tarefa invalida")
				return
			end
			
			-- Direciona interação para a tarefa disponivel
			return aventuras.tarefas[tipo_tarefa].npcs.on_rightclick(npc, player, aventura, tarefa)
			
		end
	end
end)
