--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Balao de aventureiro
  ]]

local S = aventuras.S

-- Tabela de viagens
aventuras.lugares = {}

-- Registrar um lugar
aventuras.registrar_lugar = function(nome, def)
	aventuras.lugares[nome] = {
		aven_req = def.aven_req,
		pos = def.pos,
	}
end

-- Exibir formspec
local show_formspec = function(name)
	
	local formspec = "size[7,5]"
		.."label[0,0;Aqui podes viajar para alguns lugares]"
		..default.gui_bg
		..default.gui_bg_img
	
	local s = ""
	
	-- Tabela temporaria de acesso
	if not aventuras.online[name].balao_aventureiro then
		aventuras.online[name].balao_aventureiro = {menu = {}}
	end
	local acesso = aventuras.online[name].balao_aventureiro
	
	for n,d in pairs(aventuras.lugares) do
		
		-- Verifica aventuras requeridas
		if d.aven_req == nil or aventuras.comum.check_aven_req(name, d.aven_req) == true then
			if s ~= "" then s = s .. "," end
	
			table.insert(acesso.menu, n)
			s = s .. n
		end
	end
	
	if s ~= "" then
		formspec = formspec.."textlist[0,0.75;6.8,3;menu;"..s..";;true]"
	else
		formspec = formspec .. "label[1,2;"..S("Nenhum destino conhecido").."]"
	end
	
	-- Coloca botao para viajar
	if acesso.lugar then
		formspec = formspec .. "button_exit[0,4.3;7,1;viajar;Viajar para "..acesso.lugar.."]"
	end
	
	minetest.show_formspec(name, "aventuras:caixa_balao_aventureiro", formspec)
end


-- Node
minetest.register_node("aventuras:caixa_balao_aventureiro", {
	description = S("Caixa de Balao de Aventuras"),
	tiles = {
		"default_chest_top.png", 
		"default_chest_top.png", 
		"default_chest_side.png",
		"default_chest_side.png", 
		"default_chest_side.png", 
		"default_chest_front.png"
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Balao de Aventuras"))
	end,
	
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		show_formspec(player:get_player_name())
	end,
})


-- Receptor de botoes
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "aventuras:caixa_balao_aventureiro" then
		local name = player:get_player_name()
		local acesso = aventuras.online[name].balao_aventureiro
		
		-- Escolher um item
		if fields.menu then
			
			acesso.lugar = acesso.menu[tonumber(string.sub(fields.menu, 5, -1))]
		
		elseif fields.viajar then
			
			player:setpos(aventuras.lugares[acesso.lugar].pos)
			
		end
		
		-- Mantem os dados limpos para evitar dados obsoletos em acesso futuro
		if fields.quit then
			acesso = nil
		else
			show_formspec(name)
		end
	end
end)

