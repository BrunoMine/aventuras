--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Bau do aventureiro Noob
  ]]

local S = aventuras.S

-- Iten que podem aparecer
local registros = {}

-- Aventuras que podem disponibilizar itens
local aventuras_com_itens = {}

-- Registra um item para ser disponibilizado quando o jogador estivar em determinada aventura
aventuras.registrar_item_bau_noob = function(item, def)
	registros[item] = {
		desc_item = def.desc_item,
		aven = def.aventura,
		tarefa = tonumber(def.tarefa),
		custo = tonumber(def.custo or 1),
		give_item = def.give_item,
	}
	
	if not aventuras_com_itens[def.aventura] then aventuras_com_itens[def.aventura] = {} end
	
	aventuras_com_itens[def.aventura][item] = tonumber(def.tarefa)
end


local show_formspec = function(name)
	
	local formspec = "size[8,9]"
		.."label[0,0;"..S("Aqui podes recuperar itens perdidos").."]"
		..default.gui_bg
		..default.gui_bg_img
		..default.gui_slots
		.."list[current_player;main;0,4.85;8,1;]"
		.."list[current_player;main;0,6.08;8,3;8]"
		.."listring[current_player;main]"
		..default.get_hotbar_bg(0,4.85)
	
	-- Verifica quais item estao disponiveis de acordo com a ultima aventura realizada
	if aventuras.bd.verif("player_"..name, "livro_de_aventuras") == true then
		local list = aventuras.bd.pegar("player_"..name, "livro_de_aventuras")
		local s = ""
		
		-- Tabela temporaria de acesso
		if not aventuras.online[name].bau_aventureiro_noob then
			aventuras.online[name].bau_aventureiro_noob = {menu = {}}
		end
		local acesso = aventuras.online[name].bau_aventureiro_noob
		
		for n,ut in pairs(list) do
		
			if aventuras.tb[n] then
				for aven, items in pairs(aventuras_com_itens) do
					for item, t in pairs(items) do
						if aven == n and ut == t then
							if s ~= "" then s = s .. "," end
						
							table.insert(acesso.menu, item)
							s = s .. registros[item].desc_item
						end
					end
				end
			end
			
		end
		
		if s ~= "" then
			formspec = formspec.."textlist[0,1;4.7,3.5;menu;"..s..";;true]"
		else
			formspec = formspec .. "label[1,2;"..S("Nenhum item disponível").."]"
		end
		
		-- Coloca item selecionado
		if acesso.selected_item then
			formspec = formspec .. "item_image_button[5,0.8;3,3;"..acesso.selected_item..";item;]"
				.. "button_exit[5,3.8;2,1;comprar;"..S("Comprar").."]"
				.. "item_image_button[7,3.8;1,1;"..aventuras.moeda_bau_noob.." "..registros[acesso.selected_item].custo..";custo;]"
		end
		
	else
		formspec = formspec .. "label[1,2;"..S("Nenhum item disponível").."]"
	end
	
	minetest.show_formspec(name, "aventuras:bau_aventureiro_noob", formspec)
end


-- Node
minetest.register_node("aventuras:bau_aventureiro_noob", {
	description = S("Bau do Aventureiro Noob"),
	tiles = {
		"aventuras_item_checkpoint_top.png", 
		"aventuras_item_checkpoint_top.png", 
		"aventuras_item_checkpoint_side.png",
		"aventuras_item_checkpoint_side.png", 
		"aventuras_item_checkpoint_side.png", 
		"aventuras_item_checkpoint_front.png"
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy=2,oddly_breakable_by_hand=1},
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Bau do Aventureiro Noob"))
	end,
	
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		show_formspec(player:get_player_name())
	end,
})

-- Receptor de botoes
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "aventuras:bau_aventureiro_noob" then
		local name = player:get_player_name()
		local acesso = aventuras.online[name].bau_aventureiro_noob
		
		-- Escolher um item
		if fields.menu then
			
			acesso.selected_item = acesso.menu[tonumber(string.sub(fields.menu, 5, -1))]
		
		elseif fields.comprar then
			
			if not registros[acesso.selected_item].give_item then
				if aventuras.tror.trocar(player, 
					{aventuras.moeda_bau_noob.." "..registros[acesso.selected_item].custo}, 
					{acesso.selected_item}) ~= true 
				then
					minetest.chat_send_player(name, S("Precisa pagar @1 para comprar", registros[acesso.selected_item].custo))
				end
			else
				if aventuras.tror.trocar(player, {aventuras.moeda_bau_noob.." "..registros[acesso.selected_item].custo}, {}) == true then
					registros[acesso.selected_item].give_item(player)
				else
					minetest.chat_send_player(name, S("Precisa pagar @1 para comprar", registros[acesso.selected_item].custo))
				end
			end
			
		end
		
		-- Mantem os dados limpos para evitar dados obsoletos em acesso futuro
		if fields.quit then
			acesso = nil
		else
			show_formspec(name)
		end
	end
end)

