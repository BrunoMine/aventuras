--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Callbacks : Chamadas do sistema de aventuras
  ]]

-- Variavel global
aventuras.callbacks = {}

-- Chamada de tarefa concluida
-- Funções armazenadas
aventuras.callbacks.ao_concluir_f = {}
-- Registrar nova função para a chamada
aventuras.callbacks.registrar_ao_concluir = function(func)
	if func then
		table.insert(aventuras.callbacks.ao_concluir_f, func)
	end
end
-- Informa uma conclusão
aventuras.callbacks.concluiu = function(name, aventura, tarefa)
	for _,func in ipairs(aventuras.callbacks.ao_concluir_f) do
		func(name, aventura, tarefa)
	end
end

