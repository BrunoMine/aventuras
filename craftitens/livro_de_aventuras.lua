--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Livro de aventuras
  ]]


-- Deletar Registros do livro
aventuras.callbacks.registrar_ao_concluir(function(name)
	if aventuras.bd:verif(name, "livro_de_aventuras") == true then
		aventuras.bd:remover(name, "livro_de_aventuras")
	end
end)


-- Criar registros do livro
local criar_registro = function(name)
	local list = minetest.get_dir_list(minetest.get_worldpath().."/aventuras/"..name)
	
	local reg = {}
	
	for _,n in ipairs(list) do
		if string.sub(n, 1, 9) == "aventura_" then
			local aven = string.sub(n, 10, -1)
			reg[aven] = aventuras.pegar_tarefa(name, aven)
		end
	end
	
	if aventuras.comum.contar_tb(reg) > 0 then
		aventuras.bd:salvar(name, "livro_de_aventuras", reg)
	end
end


-- Livro de Aventuras
minetest.register_craftitem("aventuras:livro_de_aventuras", {
	description = "Livro de Aventuras",
	inventory_image = "aventuras_livro.png",
	stack_max = 1,
	
	on_use = function(itemstack, user, pointed_thing)
		
		local name = user:get_player_name()
		
		-- Tenta criar uma lista do livro
		if aventuras.bd:verif(name, "livro_de_aventuras") == false then
			criar_registro(name)
		end
		
		local formspec = "size[10,6]"
			..default.gui_bg
			..default.gui_bg_img
		
		if aventuras.bd:verif(name, "livro_de_aventuras") == true then
			local list = aventuras.bd:pegar(name, "livro_de_aventuras")
			local s = ""
			
			for n,t in pairs(list) do
				if aventuras.tb[n] then
					if s ~= "" then s = s .. "," end
					
					
					s = s .. aventuras.tb[n].titulo .. " ("..t.."/"..table.maxn(aventuras.tb[n].tarefas)..")"
				end
				
			end
			
			formspec = formspec
				.."label[0,0;Livro de Aventuras]"
				.."textlist[0,0.6;9.8,5.6;menu;"..s..";;true]"
			
		else
			formspec = formspec
				.."label[0,0;Livro de Aventuras]"
				.."textlist[0,0.6;9.8,5.6;menu;Nenhuma aventura descoberta ainda;;true]"
		end
		
		minetest.show_formspec(name, "aventuras:livro_de_aventuras", formspec)
		
	end,
})


-- Receber botoes
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "aventuras:livro_de_aventuras" then
		if fields.menu and string.sub(fields.menu, 1, 3) == "DCL" then
			
			local name = player:get_player_name()
			
			local list = aventuras.bd:pegar(name, "livro_de_aventuras")
			if not list then return end
			
			local aventura = ""
			local ultima_tarefa = 0
			local id = tonumber(string.sub(fields.menu, 5, -1))
			local i = 0
			for aven,t in pairs(list) do
				i = i + 1
				if i == id then
					aventura = aven
					ultima_tarefa = t
				end
			end
			
			-- Estado atual
			local estado = ultima_tarefa.."/"..table.maxn(aventuras.tb[aventura].tarefas)
			if ultima_tarefa == table.maxn(aventuras.tb[aventura].tarefas) then estado = estado .. core.colorize("#00FF00", " (Finalizado)") end
			
			local formspec = "size[6,7.2]"
				..default.gui_bg
				..default.gui_bg_img
				.."label[0,0;"..aventuras.tb[aventura].titulo.."]"
				.."image[0,0.5;3,3;"..(aventuras.tb[aventura].img or "logo.png").."]"
				.."label[2.5,0.5;Estado atual]"
				.."label[2.5,1;"..estado.."]"
				.."textarea[0.3,3.4;6,4.5;desc;;"..aventuras.tb[aventura].desc.."]"
				.."button[5,6.8;1.3,1;voltar;Voltar]"
			
			minetest.show_formspec(name, "aventuras:livro_de_aventuras_info", formspec)
		end
	elseif formname == "aventuras:livro_de_aventuras_info" then
		if fields.voltar then
			minetest.registered_craftitems["aventuras:livro_de_aventuras"].on_use(nil, player)
		end
	end
end)

minetest.register_craft({
	output = "aventuras:livro_de_aventuras",
	recipe = {
		{ "default:gold_ingot"},
		{ "wool:blue"},
		{ "default:book"}
	}
})
