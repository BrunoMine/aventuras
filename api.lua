--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	API Geral
  ]]


-- Tabela temporaria de jogador online
aventuras.online = memor.online()

-- Tabela global de aventuras
aventuras.tb = {}

-- Tabela global de tarefas
aventuras.tarefas = {}

-- Montar banco de dados
aventuras.bd = memor.montar_bd(minetest.get_current_modname())

-- Registrar uma Aventura
aventuras.registrar_aventura = function(nome, def)
	if not nome or not def then
		minetest.log("error", "[Sunos] dados faltantes em registrar_aventura")
		return false
	end
	
	aventuras.tb[nome] = def
	aventuras.tb[nome].tarefas = {}
	
end

-- Adicionar uma Tarefa para uma aventura
aventuras.adicionar_tarefa = function(aventura, tipo, def)
	if not aventura or not aventuras.tb[aventura] then -- Verifica se a aventura ja foi registrada
		minetest.log("error", "[Sunos] aventura inexistente ou nulo (em aventuras.adicionar_tarefa)")
		return false
	end
	
	-- Requisita a adição da nova tarefa pela framework da tarefa solicidada
	aventuras.tarefas[tipo].adicionar(aventura, def)
	
end

