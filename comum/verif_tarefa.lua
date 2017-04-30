--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Metodo : Verificar se tarefa existe
  ]]

aventuras.comum.verif_tarefa = function(aventura, tarefa)
	if aventuras.tb[aventura].tarefas[tarefa] ~= nil then 
		return true
	else
		return false
	end
end
