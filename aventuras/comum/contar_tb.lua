--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Metodo : Contar tabela desordenada
  ]]

aventuras.comum.contar_tb = function(tb)
	local c = 0
	for _,n in pairs(tb) do
		c = c + 1
	end
	return c
end
