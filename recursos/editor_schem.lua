--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Recurso para criação de estruturas no formato schematic
  ]]

local acessos = {}

if aventuras.bd.verif("aventuras", "editor_schem_acessos") == true then
	acessos = aventuras.bd.pegar("aventuras", "editor_schem_acessos")
end
minetest.register_on_shutdown(function()
	aventuras.bd.salvar("aventuras", "editor_schem_acessos", acessos)
end)
minetest.register_on_joinplayer(function(player)
	if aventuras.editor_mode ~= true then return end
	local name = player:get_player_name()
	
	if not acessos[name] then
		acessos[name] = {}
	end
end)


-- Gerar botoes do formspec
local get_form = function(player)
	local name = player:get_player_name()
	local dados = acessos[name]
	
	if not dados or not dados.pos then
		return "label[2,1;Coloque o bloco do editor \npara definir um local]"
	end
	
	if not dados.nome_estrutura then dados.nome_estrutura = "" end
	if not dados.nome_mod then dados.nome_mod = "" end
	if not dados.altura then dados.altura = "" end
	if not dados.dist then dados.dist = "" end
	
	local form = "field[0.325,0.5;4,1;nome_mod;Nome do Mod;"..dados.nome_mod.."]"
		.."field[0.325,1.65;4,1;nome_estrutura;Nome da Estrutura;"..dados.nome_estrutura.."]"
		.."button[0,2.9;4,1;carregar;Carregar]"
		.."button[0,3.7;4,1;marcar;Marcar]"
		.."image[4,0;3,4;aventuras_distancias_estrutura.png]"
		.."field[5,0.5;2,1;altura;Altura;"..dados.altura.."]"
		.."field[5.1,4;3,1;dist;Dist. centro a borda;"..dados.dist.."]"
		.."button[4.5,1.5;1,1;tp;TP]"
	
	-- Botao de salvar
	if (minetest.setting_getbool("secure.enable_security") or false) ~= true then
		
		form = form .. "button[0,2.1;4,1;salvar;Salvar]"
	else
		form = form .. "label[0,2.1;"..minetest.colorize("#FF0000", "Desabilite o modo seguro \npara poder salvar estruturas").."]"
	end
	
	return form
end

-- Marcar local
local marcar = function(pos, dist, altura)
	local minp = {x=pos.x-dist, y=pos.y, z=pos.z-dist}
	local maxp = {x=pos.x+dist, y=pos.y+altura, z=pos.z+dist}
	
	minetest.set_node({x=minp.x-1, y=minp.y, z=minp.z}, {name="default:fence_wood"})
	minetest.set_node({x=minp.x, y=minp.y, z=minp.z-1}, {name="default:fence_wood"})
	minetest.set_node({x=minp.x-1, y=minp.y, z=minp.z-1}, {name="default:fence_wood"})
	
	minetest.set_node({x=minp.x-1, y=minp.y, z=maxp.z}, {name="default:fence_wood"})
	minetest.set_node({x=minp.x, y=minp.y, z=maxp.z+1}, {name="default:fence_wood"})
	minetest.set_node({x=minp.x-1, y=minp.y, z=maxp.z+1}, {name="default:fence_wood"})
	
	minetest.set_node({x=maxp.x+1, y=minp.y, z=maxp.z}, {name="default:fence_wood"})
	minetest.set_node({x=maxp.x, y=minp.y, z=maxp.z+1}, {name="default:fence_wood"})
	minetest.set_node({x=maxp.x+1, y=minp.y, z=maxp.z+1}, {name="default:fence_wood"})
	
	minetest.set_node({x=maxp.x+1, y=minp.y, z=minp.z}, {name="default:fence_wood"})
	minetest.set_node({x=maxp.x, y=minp.y, z=minp.z-1}, {name="default:fence_wood"})
	minetest.set_node({x=maxp.x+1, y=minp.y, z=minp.z-1}, {name="default:fence_wood"})
	
	-- Parte superior
	minetest.set_node({x=minp.x-1, y=maxp.y, z=minp.z}, {name="aventuras:node_cloud"})
	minetest.set_node({x=minp.x, y=maxp.y, z=minp.z-1}, {name="aventuras:node_cloud"})
	minetest.set_node({x=minp.x, y=maxp.y+1, z=minp.z}, {name="aventuras:node_cloud"})
	
	minetest.set_node({x=minp.x-1, y=maxp.y, z=maxp.z}, {name="aventuras:node_cloud"})
	minetest.set_node({x=minp.x, y=maxp.y, z=maxp.z+1}, {name="aventuras:node_cloud"})
	minetest.set_node({x=minp.x, y=maxp.y+1, z=maxp.z}, {name="aventuras:node_cloud"})
	
	minetest.set_node({x=maxp.x+1, y=maxp.y, z=maxp.z}, {name="aventuras:node_cloud"})
	minetest.set_node({x=maxp.x, y=maxp.y, z=maxp.z+1}, {name="aventuras:node_cloud"})
	minetest.set_node({x=maxp.x, y=maxp.y+1, z=maxp.z}, {name="aventuras:node_cloud"})
	
	minetest.set_node({x=maxp.x+1, y=maxp.y, z=minp.z}, {name="aventuras:node_cloud"})
	minetest.set_node({x=maxp.x, y=maxp.y, z=minp.z-1}, {name="aventuras:node_cloud"})
	minetest.set_node({x=maxp.x, y=maxp.y+1, z=minp.z}, {name="aventuras:node_cloud"})
end

-- Registrar aba de editor
if aventuras.editor_mode == true then
	sfinv.register_page("aventuras:editor_schem", {
		title = "Editor Schem",
		get = function(self, player, context)
		
			return sfinv.make_formspec(player, context, 
				get_form(player) .. [[
				listring[current_player;main]
				listring[current_player;craft]
				image[0,4.75;1,1;gui_hb_bg.png]
				image[1,4.75;1,1;gui_hb_bg.png]
				image[2,4.75;1,1;gui_hb_bg.png]
				image[3,4.75;1,1;gui_hb_bg.png]
				image[4,4.75;1,1;gui_hb_bg.png]
				image[5,4.75;1,1;gui_hb_bg.png]
				image[6,4.75;1,1;gui_hb_bg.png]
				image[7,4.75;1,1;gui_hb_bg.png]
			]], true)
		end,
		on_player_receive_fields = function(self, player, context, fields)
			if context.page ~= "aventuras:editor_schem" then return end
			 
			local name = player:get_player_name()
			local dados = acessos[name]
			
			-- Atualiza dados
			if fields.altura then dados.altura = tonumber(fields.altura) end
			if fields.dist then dados.dist = tonumber(fields.dist) end
			if fields.nome_mod then dados.nome_mod = fields.nome_mod end
			if fields.nome_estrutura then dados.nome_estrutura = fields.nome_estrutura end
			
			-- Salvar
			if fields.salvar then
				
				-- Validar dados
				if not dados.nome_mod or dados.nome_mod == "" 
					or not dados.pos
					or not dados.dist or dados.dist == 0 
					or not dados.altura or dados.altura == 0 
				then
					minetest.chat_send_player(name, "Dados invalidos")
					return
				end
				
				local pos = dados.pos
				local dist = dados.dist
				local altura = dados.altura
				minetest.create_schematic(
					{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
					{x=pos.x+dist, y=pos.y+altura, z=pos.z+dist}, {}, 
					minetest.get_modpath(dados.nome_mod).."/schems/"..dados.nome_estrutura..".mts"
				)
				minetest.chat_send_player(name, "Estrutura salva. Para carregar essa estrutura novamente sera preciso reiniciar o jogo")
			end
			
			-- Carregar
			if fields.carregar then
				
				-- Validar dados
				if not dados.nome_mod or dados.nome_mod == "" 
					or not dados.pos or dados.pos == "" 
					or not dados.dist or dados.dist == 0 
					or not dados.altura or dados.altura == 0 
				then
					minetest.chat_send_player(name, "Dados invalidos")
					return
				end
				
				local pos = dados.pos
				local dist = dados.dist
				local altura = dados.altura
				minetest.place_schematic(
					{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
					minetest.get_modpath(dados.nome_mod).."/schems/"..dados.nome_estrutura..".mts", 0, nil, true)
				minetest.chat_send_player(name, "Estrutura Carregada")
			end
			
			-- Marcar area
			if fields.marcar then
				
				-- Validar dados
				if not dados.pos or dados.pos == "" 
					or not dados.dist or dados.dist == 0 
					or not dados.altura or dados.altura == 0 
				then
					minetest.chat_send_player(name, "Dados invalidos")
					return
				end
				
				local pos = dados.pos
				local dist = dados.dist
				local altura = dados.altura
				marcar(pos, dist, altura)
				minetest.chat_send_player(name, "Area Marcada")
			end
			
			
			-- Teleportar
			if fields.tp then
				player:setpos(acessos[name].pos)
			end
			
			sfinv.set_player_inventory_formspec(player)
		end,
	})
end

-- Node de Preparação
minetest.register_node("aventuras:editor_schem", {
	description = "Bloco para Preparar Editor",
	tiles = {"default_wood.png^aventuras_editor_schem.png"},
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	
	on_place = function(itemstack, placer, pointed_thing)
		if aventuras.editor_mode == true and pointed_thing.type == "node" then
			local name = placer:get_player_name()
			
			acessos[name].pos = pointed_thing.above
			sfinv.set_player_inventory_formspec(placer)
			minetest.chat_send_player(name, "Local preparado. Acesse seu inventario para continuar")
		end
	end,
})


-- Node decorativo para mostrar area superior
minetest.register_node("aventuras:node_cloud", {
	description = "Marcador de Area",
	tiles = {"default_cloud.png"},
	groups = {oddly_breakable_by_hand = 2},
	legacy_facedir_simple = true,
	sunlight_propagates = true,
	drop = "",
})

