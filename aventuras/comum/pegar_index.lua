--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Metodo : Pegar primeira index da tabela
  ]]

aventuras.comum.pegar_index = function(tb)
	for i,n in pairs(tb) do
		return i
	end
end
