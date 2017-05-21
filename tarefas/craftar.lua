--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Framework : Tarefa do tipo craftar
	
	Nessa tarefa o jogador precisa acessar um NPC e depois craftar algo para concluir (uma mensagem aparece no chat quando a aventura termina)
  ]]

-- Tabela de registros dessa tarefa
aventuras.tarefas.craftar = {}


-- Gerar um formspec de tarefa
local gerar_form = function(aventura, dados, npc)
	
	local arte_npc = aventuras.recursos.npc.arte[npc]
	
	local formspec = "size[7,7]"
		..arte_npc.bgcolor
		..arte_npc.bg_img1x1
		.."label[0,0;"..aventuras.tb[aventura].titulo.."]"
		.."label[0,0.5;"..dados.titulo.."]"
		.."image[0.65,1;3,3;"..arte_npc.face.."]"
		.."textarea[0.26,3.8;7,2.5;msg;;"..dados.msg.."]"
		-- Botao concluir
		.."button_exit[0,6;7,1;;Entendido]"
	
	if dados.img_node then
		formspec = formspec .. "image[3.65,1;3,3;"..dados.img_node.."]"
	else
		formspec = formspec .. "item_image_button[3.65,1;2.75,2.75;"..dados.node..";item;]"
	end
	
	return formspec
end

-- Adicionar tarefa à aventura
aventuras.tarefas.craftar.adicionar = function(aventura, def)

	-- Prepara tabela registros da tarefa
	local reg = {
		titulo = def.titulo,
		tipo = "craftar",
		
		aven_req = def.dados.aven_req or {},
		
		node = def.dados.item,
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
aventuras.tarefas.craftar.npcs = {}

-- Receber chamada de 'on_rightclick' de algum dos npcs acessados
aventuras.tarefas.craftar.npcs.on_rightclick = function(npc, clicker, aventura, tarefa)
	
	local name = clicker:get_player_name()
	
	if not aventuras.online[name].craftar then aventuras.online[name].craftar = {} end
	
	-- Pegar dados da tarefa atual
	local dados = aventuras.tb[aventura].tarefas[tarefa]
	
	-- Salva os dados da tarefa que estará sendo processada nos proximos momentos
	aventuras.online[name].craftar.aventura=aventura
	aventuras.online[name].craftar.dados=dados
	aventuras.online[name].craftar.tarefa=tarefa
	aventuras.online[name].craftar.npc=npc
	
	-- Exibir pedido de itens
	minetest.show_formspec(name, "aventuras:craftar", gerar_form(aventura, dados, npc))
	
	-- Habilitar tarefa para ser realizada a qualquer momento
	if not aventuras.online[name].craftar.aven then aventuras.online[name].craftar.aven = {} end
	if not aventuras.online[name].craftar.aven[dados.node] then aventuras.online[name].craftar.aven[dados.node] = {} end
	aventuras.online[name].craftar.aven[dados.node][aventura] = true
	aventuras.bd:salvar(name, "tarefa_craftar", aventuras.online[name].craftar.aven)
	
	return

end

-- Verificar ao craftar node
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	
	if aventuras.online[player:get_player_name()].craftar -- a maioria ja para aqui
		and aventuras.online[player:get_player_name()].craftar.aven[itemstack:get_name()]
	then
		local name = player:get_player_name()
		
		-- conclui todas as missoes que aguardavam essa tarefa
		for aventura,d in pairs(aventuras.online[name].craftar.aven[itemstack:get_name()]) do
			
			local tarefa = aventuras.bd:pegar(name, "aventura_"..aventura)+1
			local dados = aventuras.tb[aventura].tarefas[tarefa] 
			
			-- Salva a conclusao da missao
			aventuras.salvar_tarefa(name, aventura, tarefa)
			aventuras.callbacks.concluiu(name, aventura, tarefa)
			
			-- Envia mensagem final da tarefa
			minetest.chat_send_player(name, dados.msg_fim)
			
			-- Remove aventura pendente da tabela
			aventuras.online[name].craftar.aven[itemstack:get_name()][aventura] = nil
		end
		
		-- Toca o som de conclusao
		minetest.sound_play("aventuras_concluir", {to_player = name, gain = 0.7})
		
		-- Deleta dados temporarios desse tipo de tarefa caso nao tenha mais nenhum pendente
		if aventuras.comum.contar_tb(aventuras.online[name].craftar.aven[itemstack:get_name()]) == 0 then
			aventuras.online[name].craftar = nil
			aventuras.bd:remover(name, "tarefa_craftar")
		end
		
	end
	
end)


-- Mantem a tabela temporaria de dados enquanto o jogador estiver online
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if aventuras.bd:verif(name, "tarefa_craftar") == true then
		if not aventuras.online[name].craftar then aventuras.online[name].craftar = {} end
		aventuras.online[name].craftar.aven = aventuras.bd:pegar(name, "tarefa_craftar")
	end
end)







