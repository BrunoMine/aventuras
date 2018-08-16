--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Metodo : Exibir um pequeno formspec de alerta
  ]]

aventuras.comum.exibir_alerta = function(name, msg)
	minetest.show_formspec(name, "aventuras:alerta", "size[6,1]"
		..default.gui_bg
		..default.gui_bg_img
		.."label[0.2,0.25;"..msg.."]")
end
