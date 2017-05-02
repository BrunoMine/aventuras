--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Metodo : Verifica se uma tarefa pode ser realizada pelo jogador conforme aventuras requeridas para tal
	
  ]]

-- Verificar aventuras requeridas
aventuras.comum.check_aven_req = function(name, aven_req)
	
	for aven,tarefa in pairs(aven_req) do
		if aventuras.bd:verif(name, aven) ~= true
			or aventuras.bd:pegar(name, aven) < tarefa 
		then
			return false
		end
	end
	
	return true
	
end
