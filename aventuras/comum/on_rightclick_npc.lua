--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Metodo : Mostra uma janela de acesso simples e registra o inicio na aventura
	
	Insere o itemstring informado no indice `item` dos registros da aventura
	na tabela de itens esperados para realização da tarefa em `aventuras.online[tipo_aventura].aven`
	
  ]]

-- Retorna uma função de acesso simples a um NPC
aventuras.comum.get_on_rightclick_npc = function(tipo_tarefa)
	
	return function(npc, clicker, aventura, tarefa)
	
		local name = clicker:get_player_name()
	
		if not aventuras.online[name][tipo_tarefa] then aventuras.online[name][tipo_tarefa] = {} end
	
		-- Pegar dados da tarefa atual
		local dados = aventuras.tb[aventura].tarefas[tarefa]
		
		-- Salva os dados da tarefa que estará sendo processada nos proximos momentos
		local dados_temp = aventuras.online[name][tipo_tarefa]
		dados_temp.aventura=aventura
		dados_temp.dados=dados
		dados_temp.tarefa=tarefa
		dados_temp.npc=npc
	
		-- Exibir pedido de itens
		minetest.show_formspec(name, "aventuras:"..tipo_tarefa, aventuras.tarefas[tipo_tarefa].gerar_form(aventura, dados, npc, clicker:get_player_name()))
	
		-- Habilitar tarefa para ser realizada a qualquer momento
		if not dados_temp.aven then dados_temp.aven = {} end
		if not dados_temp.aven[dados.item] then dados_temp.aven[dados.item] = {} end
		dados_temp.aven[dados.item][aventura] = true
		aventuras.bd.salvar("player_"..name, "tarefa_"..tipo_tarefa, dados_temp.aven)
	
		return
	end
	
end


