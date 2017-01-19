--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	API Geral
  ]]

-- Tabela que relaciona os NPCs criados com as aventuras
local npcs_acessiveis = {}


-- Tabela que relaciona jogadores com npcs acessados
aventuras.acessos = memor.online()


-- Registrar uma aventura
aventuras.registrar_aventura = function(aventura, def)
	if not aventura then
		minetest.log("error", "[Aventuas] aventura == nil (em aventuras.registrar_aventura)")
		return false
	end
	
	if not def then
		minetest.log("error", "[Aventuas] def == nil (em aventuras.registrar_aventura)")
		return false
	end
	
	if aventuras.tb[aventura] then
		minetest.log("error", "[Aventuas] Aventura "..dump(aventura).." ja existente (em aventuras.registrar_aventura)")
		return false
	end
	
	aventuras.tb[aventura] = {
		titulo = def.titulo,
		desc = def.desc,
		tarefas = {} -- Tabeta ordenada de tarefas
	}
	
	return true
end


-- Registrar uma tarefa
aventuras.registrar_tarefa = function(aventura, numero, def)
	if not aventura then
		minetest.log("error", "[Aventuas] aventura == nil (em aventuras.registrar_tarefa)")
		return false
	end
	if not numero then
		minetest.log("error", "[Aventuas] numero == nil (em aventuras.registrar_tarefa)")
		return false
	end
	numero = tonumber(numero)
	
	-- Verifica se existem parametros
	if not def then
		minetest.log("error", "[Aventuas] def == nil (em aventuras.registrar_tarefa)")
		return false
	end
	-- Verifica se existe o parametro 'tipo' da tarefa
	if not def.tipo then
		minetest.log("error", "[Aventuas] tipo de aventura nulo (em aventuras.registrar_tarefa)")
		return false
	end
	-- Verifica se a aventura ja foi registrada
	if not aventuras.tb[aventura] then
		minetest.log("error", "[Aventuas] Aventura "..dump(aventura).." nao foi registrada (em aventuras.registrar_tarefa)")
		return false
	end
	-- Verifica se a tarefa está na sequencia correta de tarefas da aventura
	if numero ~= table.maxn(aventuras.tb[aventura].tarefas)+1 then
		minetest.log("error", "[Aventuas] Nao pode registrar tarefa numero "..numero.." pois existem "..table.maxn(aventuras.tb[aventura].tarefas).." (em aventuras.registrar_tarefa)")
		return false
	end
	
	-- Verifica se o tipo de aventura existe
	if not aventuras.tarefas[def.tipo] then
		minetest.log("error", "[Aventuas] Tipo de tarefa "..def.tipo.." inexistente (em aventuras.registrar_tarefa)")
		return false
	end
	
	-- Registra a tarefa
	local r, dados = aventuras.tarefas[def.tipo].registrar(aventura, numero, def)
	
	if r ~= true then
		return false
	end
	
	-- Registra os npcs em tabelas necessarias
	if dados.npcs then
		for _,n in ipairs(dados.npcs) do
			-- Salva as aventuras que cada npc pode interagir em algum momento
			if not npcs_acessiveis[n] then npcs_acessiveis[n] = {} end -- Caso ainda não tenha registrado o npc
			npcs_acessiveis[n][aventura] = true
			-- Salva um registro de caracteristicas (mesmo que vazio) para evitar erros ao gerar formularios
			if not aventuras.npcs.registros[n] then aventuras.npcs.registros[n] = {} end
		end
	end

	return true
end

-- Pegar numero da ultima tarefa realizada
local pegar_ultima_tarefa = function(name, aventura)
	if aventuras.bd:verif(name, aventura) == true then 
		return aventuras.bd:pegar(name, aventura)
	else
		return 0
	end
end


-- Acessar NPC
aventuras.acessar_npc = function(self, player, aventura)
	if not self then
		minetest.log("error", "[Aventuas] self == nil (em aventuras.acessar_npc)")
		return false
	end
	if not player then
		minetest.log("error", "[Aventuas] player == nil (em aventuras.acessar_npc)")
		return false
	end
	
	-- Verifica se consegue pegar o nome do npc
	if not self.name then
		minetest.log("error", "[Aventuas] Falha ao pegar o nome do npc (em aventuras.acessar_npc)")
		return false
	end
	
	-- Pega o nome do jogador
	local name = player:get_player_name()
	
	-- Salva a entidade acessada
	aventuras.acessos[name].ent = self
	
	-- Caso o acesso não tenha vindo já direcionado
	if not aventura then
		
		-- Certificasse de que existe uma aventura relacionada ao NPC
		if not npcs_acessiveis[self.name] then return end
		
		-- Lista de aventuras com ação disponivel para o jogador com o npc
		local aven_tb = {} -- Tabela ordenada
		
		-- Verificar em quais aventuras aquele npc pode interagir com o jogador na tarefa atual
		for aven,v in pairs(npcs_acessiveis[self.name]) do

			-- Pega a tarefa atual do jogador naquela aventura
			local tarefa = pegar_ultima_tarefa(name, aven) + 1
	
			-- Verifica se na tarefa atual o jogador pode interagir com o npc			
			if aventuras.tb[aven].tarefas[tarefa] then -- verifica se a tarefa existe
				if aventuras.tb[aven].tarefas[tarefa].npcs and aventuras.tb[aven].tarefas[tarefa].npcs[self.name] then
				
					table.insert(aven_tb, aven)
				end
			end
	
		end
		
		-- Verificar se existe mais de uma aventura com tarefa disponivel no npc
		if table.maxn(aven_tb) > 1 then
			
			-- Nomes das aventuras separadas por ',' na mesma string
			local titulos_aven = ""
			for _,n in ipairs(aven_tb) do
				if titulos_aven ~= "" then titulos_aven = titulos_aven.."," end
				
				-- Pega a tarefa atual do jogador
				local tarefa = pegar_ultima_tarefa(name, n) + 1
				
				if aventuras.tb[n].tarefas[tarefa] then -- verifica se a tarefa existe
					titulos_aven = titulos_aven .. aventuras.tb[n].tarefas[tarefa].titulo
				end
			end
			
			local formspec = "size[6,6]"
				..default.gui_bg
				..default.gui_bg_img
				.."label[0,0;Escolha uma Aventura]"
				.."textlist[0,1;5.78,5;aventura;"..titulos_aven.."]"
			
			-- Salva a tabela usada para gerar o formulario
			aventuras.acessos[name].aven_tb = aven_tb
			
			-- Mostrar formulario para escolher uma aventura
			return minetest.show_formspec(name, 
				"aventuras:escolher_aventura_npc",
				formspec
			)
		
		end
		
		-- Verifica se ao menos uma aventura tem tarefa disponivel
		if not aven_tb[1] then 
			-- Nenhuma tarefa para fazer
			return minetest.chat_send_all("Sem acoes disponiveis")
		end
		
		-- Inicia um acesso já direcionado (Impossivel que não exista nenhuma)
		return aventuras.acessar_npc(self, player, aven_tb[1])
		
	end
	
	-- Pega a tarefa atual do jogador naquela aventura
	local tarefa = pegar_ultima_tarefa(name, aventura) + 1
	
	-- Verifica se a tarefa existe
	if not aventuras.tb[aventura].tarefas[tarefa] then 
		
		-- Essa tarefa nao existe nessa aventura (sem ações disponiveis)
		return minetest.chat_send_all("Sem acoes disponiveis")
	end
	
	-- Direcionar o acesso para o script da tarefa correspondente
	return aventuras.tarefas[aventuras.tb[aventura].tarefas[tarefa].tipo].acessar(name, aventura, tarefa)

end

-- Botoes dos formularios
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "aventuras:escolher_aventura_npc" then
		if not player then return end
		
		-- Verificar se o NPC ainda existe
		if not aventuras.acessos[player:get_player_name()].ent then return end
		
		if fields.aventura and string.gsub(fields.aventura, "DCL:", "") ~= fields.aventura then
			-- Inicia um acesso direcionado
			return aventuras.acessar_npc(
				aventuras.acessos[player:get_player_name()].ent,
				player,
				aventuras.acessos[player:get_player_name()].aven_tb[tonumber(tostring(string.gsub(fields.aventura, "DCL:", "")))]
			)
		end
	end
end)

