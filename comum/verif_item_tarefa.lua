--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Metodo : Verifica se uma tarefa esta aguardando o item ser usado e 
	conclui caso esteja aguardando
	
	Returna `true` caso alguma tarefa tenha sido concluida e `false` caso não tenha 
	
	Esse metodo nao verifica o que deve ser feito com o item, apenas se ele esta sendo aguardado.
	
	A tabela de itens aguardados para uma ação é `aventuras.online[tipo_aventura].aven` 
	(a qual armazena os nomes das aventuras que estao aguardando a ação)
	
  ]]

-- Verificar se uma tarefa esta aguardando um item ser usado
aventuras.comum.verif_item_tarefa = function(name, tipo_tarefa, item)
	
	if aventuras.online[name][tipo_tarefa] -- a maioria ja para aqui
		and aventuras.online[name][tipo_tarefa].aven[item]
	then
		
		-- conclui todas as missoes que aguardavam essa tarefa
		for aventura,d in pairs(aventuras.online[name][tipo_tarefa].aven[item]) do
			
			-- Numero da tarefa que esta sendo realizada (numero da ultima + 1)
			local tarefa = aventuras.bd.pegar("player_"..name, "aventura_"..aventura)+1
			
			-- Dados da tarefa na aventura
			local dados = aventuras.tb[aventura].tarefas[tarefa] 
			
			-- Salva a conclusao da missao
			aventuras.salvar_tarefa(name, aventura, tarefa)
			
			-- Informa conclusão ao núcleo da API
			aventuras.callbacks.concluiu(name, aventura, tarefa)
			
			-- Envia mensagem final da tarefa
			minetest.chat_send_player(name, S(dados.msg_fim))
			
			-- Remove aventura pendente da tabela
			aventuras.online[name][tipo_tarefa].aven[item][aventura] = nil
		end
		
		-- Toca o som de conclusao
		minetest.sound_play("aventuras_concluir", {to_player = name, gain = 0.7})
		
		-- Deleta dados temporarios desse tipo de tarefa caso nao tenha mais nenhum pendente
		if aventuras.comum.contar_tb(aventuras.online[name][tipo_tarefa].aven[item]) == 0 then
			aventuras.online[name][tipo_tarefa] = nil
			aventuras.bd.remover("player_"..name, "tarefa_"..tipo_tarefa)
		end
		
		return true
		
	end
	
	return true
	
end
