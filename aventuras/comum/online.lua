--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Manipulação de variavel temporario de jogadores online
  ]]

-- Tabela de dados volateis para jogadores online
aventuras.online = {}

-- Adiciona o jogador em todas listas quando entrar no servidor
minetest.register_on_joinplayer(function(player)
	aventuras.online[player:get_player_name()] = {}
end)

-- Remove o jogador de todas listas quando entrar no servidor
minetest.register_on_leaveplayer(function(player)
	aventuras.online[player:get_player_name()] = nil
end)
