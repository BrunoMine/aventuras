--[[
	Mod Aventuras para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Estatisticas
  ]]

local S = aventuras.S

-- Verifica se concluiu completamente a aventura
aventuras.callbacks.registrar_ao_concluir(function(name, aventura, tarefa) 
	-- Verifica se é a ultima tarefa da aventura
	if tarefa == table.maxn(aventuras.tb[aventura].tarefas) then
		-- Verifica se ja existe registro
		if aventuras.bd.verif("estatisticas", "aventura_"..aventura) == true then
			local n = aventuras.bd.pegar("estatisticas", "aventura_"..aventura)
			aventuras.bd.salvar("estatisticas", "aventura_"..aventura, n+1)
		else
			aventuras.bd.salvar("estatisticas", "aventura_"..aventura, 1)
		end
	end
end)


-- Comando para ver estatisticas
minetest.register_chatcommand("aventuras_estatisticas", {
	description = S("Ver estatísticas de aventuras"),
	privs = {server = true},
	func = function(name, param)
		local formspec = "size[10,6]"
			..default.gui_bg
			..default.gui_bg_img	
		
		local s = ""
		
		for aventura,d in pairs(aventuras.tb) do
			if s ~= "" then s = s .. "," end
			local t = 0
			if aventuras.bd.verif("estatisticas", "aventura_"..aventura) == true then
				local n = aventuras.bd.pegar("estatisticas", "aventura_"..aventura)
				t = aventuras.bd.pegar("estatisticas", "aventura_"..aventura)
			else
				t = 0
			end
			s = s .. aventuras.tb[aventura].titulo .. " ("..S("terminada @1 vezes", t)..")"
			
		end
		
		formspec = formspec
			.."label[0,0;"..S("Estatísticas das aventuras").."]"
			.."textlist[0,0.6;9.8,5.6;menu;"..s..";;true]"
		
		minetest.show_formspec(name, "aventuras:estatisticas", formspec)
	end,
})
