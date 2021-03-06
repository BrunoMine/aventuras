--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	API Geral
  ]]


-- Tabela global de aventuras
aventuras.tb = {}

-- Tabela global de tarefas
aventuras.tarefas = {}


-- Registrar uma Aventura
aventuras.registrar_aventura = function(nome, def)
	if not nome or not def then
		minetest.log("error", "[Aventuras] dados faltantes em registrar_aventura")
		return false
	end
	
	local mod = minetest.get_current_modname() -- mod que registrou
	def.mod = mod
	
	aventuras.tb[nome] = def
	aventuras.tb[nome].tarefas = {}
	
end

-- Adicionar uma Tarefa para uma aventura
aventuras.adicionar_tarefa = function(aventura, def)
	if not aventura or not aventuras.tb[aventura] then -- Verifica se a aventura ja foi registrada
		minetest.log("error", "[Aventuras] aventura inexistente ou nulo (em aventuras.adicionar_tarefa)")
		return false
	end
	
	-- Requisita a adição da nova tarefa pela framework da tarefa solicidada
	def.mod = minetest.get_current_modname() -- mod que registrou
	aventuras.tarefas[def.tipo].adicionar(aventura, def)
	
end

-- Verifica qual a ultima tarefa concluida de um jogador
aventuras.pegar_tarefa = function(nome, aventura)
	if not nome or not aventura then
		minetest.log("error", "[Aventuras] dados faltantes em aventuras.pegar_tarefa")
		return false
	end
	
	if aventuras.bd.verif("player_"..nome, "aventura_"..aventura) ~= true then
		return 0
	else
		return aventuras.bd.pegar("player_"..nome, "aventura_"..aventura)
	end
end

-- Salvar a ultima tarefa feita por um jogador
aventuras.salvar_tarefa = function(nome, aventura, tarefa)
	if not nome or not aventura or not tarefa then
		minetest.log("error", "[Aventuras] dados faltantes em aventuras.salvar_tarefa")
		return false
	end
	
	if aventuras.bd.verif("player_"..nome, "aventura_"..aventura) ~= true then
		return false
	else
		return aventuras.bd.salvar("player_"..nome, "aventura_"..aventura, tarefa)
	end
end
