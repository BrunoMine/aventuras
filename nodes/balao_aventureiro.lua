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

-- Recupera dados de lugares registrados
if aventuras.bd.verif("lugares", "lugares_registrados") == true then
	aventuras.lugares = aventuras.bd.pegar("lugares", "lugares_registrados")
end

-- Salva lugares registrados
minetest.register_on_shutdown(function()
	aventuras.bd.salvar("lugares", "lugares_registrados", aventuras.lugares)
end)


-- Registrar um lugar
aventuras.registrar_lugar = function(nome, def)
	aventuras.lugares[nome] = {
		titulo = def.titulo,
		aven_req = def.aven_req,
		pos = def.pos,
	}
end

-- Exibir formspec
local show_formspec = function(name)
	
	local formspec = "size[7,5]"
		.."label[0,0;Aqui podes viajar para alguns lugares]"
		.."image[6,-0.2;1,1;aventuras_caixa_balao_mapa.png]"
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
			s = s .. d.titulo
		end
	end
	
	if s ~= "" then
		formspec = formspec.."textlist[0,0.75;6.8,3;menu;"..s..";;true]"
	else
		formspec = formspec .. "label[1,2;"..S("Nenhum destino conhecido").."]"
	end
	
	-- Coloca botao para viajar
	if acesso.lugar then
		formspec = formspec .. "button_exit[0,4.3;7,1;viajar;Viajar para "..aventuras.lugares[acesso.lugar].titulo.."]"
	end
	
	minetest.show_formspec(name, "aventuras:caixa_balao_aventureiro", formspec)
end


-- Node
minetest.register_node("aventuras:caixa_balao_aventureiro", {
	description = S("Caixa de Balao de Aventuras"),
	tiles = {
		"default_chest_top.png^aventuras_caixa_balao_cima.png", -- Cima
		"default_chest_top.png", -- Baixo
		"default_chest_side.png^aventuras_caixa_balao_direita.png", -- Direita
		"default_chest_side.png", -- Esquerda
		"default_chest_side.png^aventuras_caixa_balao_fundo.png", -- Fundo
		"default_chest_front.png^aventuras_caixa_balao_mapa.png" -- Frente
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
			acesso.lugar = nil
			
		end
		
		-- Mantem os dados limpos para evitar dados obsoletos em acesso futuro
		if fields.quit then
			acesso = nil
		else
			show_formspec(name)
		end
	end
end)


-- Pegar node distante nao carregado
local function pegar_node(pos)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(pos, pos)
		node = minetest.get_node(pos)
	end
	return node
end


-- Registro da entidade
minetest.register_entity("aventuras:balao", {
	hp_max = 1,
	physical = true,
	weight = 5,
	collisionbox = {-7,0,-7, 7,25,7},
	visual = "mesh",
	visual_size = {x=5, y=5},
	mesh = "aventuras_balao.b3d",
	textures = {"aventuras_balao.png"}, -- number of required textures depends on visual
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = false,
	on_step = function(self, dtime)
		self.timer = (self.timer or 0) + dtime
		
		if self.timer > 4 then
			self.timer = 0
			
			-- Pegar coordenada do balao
			local pos = self.object:getpos()
			
			-- Pegar coordenada do bau
			local bau_pos = {x=pos.x, y=pos.y-23, z=pos.z}
			
			-- Verifica se ainda tem o bau
			if pegar_node(bau_pos).name ~= "aventuras:caixa_balao_aventureiro" then
			
				-- Remover cordas
				do
					local y = -1
					while y <= 24 do
						if pegar_node({x=pos.x, y=pos.y-y, z=pos.z}).name == "aventuras:corda_balao" then
							minetest.remove_node({x=pos.x, y=pos.y-y, z=pos.z})
						end
						y = y + 1
					end
				end
			
				-- Remove o objeto pois nao encontrou o bau do dono
				self.object:remove()
				return
				
			end
		end
	end,
	
	on_activate = function(self, staticdata)
		if staticdata ~= "" then
			self.dono = minetest.serialize({dono=self.dono,name=self.name}).dono
			self.name = minetest.serialize({dono=self.dono,name=self.name}).name
		end
	end,
	
	get_staticdata = function(self)
		return minetest.serialize({dono=self.dono,name=self.name})
	end,
})

-- Criar um balao
local criar_balao = function(pos)
	
	-- Cria o objeto
	local obj = minetest.add_entity(pos, "aventuras:balao")
	
	-- Verifica se foi criado
	if not obj then
		minetest.log("error", "[Aventuras] Falha ao cria o objeto de balao")
		return false
	end
	
	-- Cria animação no objeto
	obj:set_animation({x=1,y=40}, 5, 0)
	
	-- Pega a entidade
	local ent = obj:get_luaentity()
	
	-- Cria o temporizador
	ent.timer = 0
	
	-- Salva o nome do dono
	ent.dono = name
	
	-- Salva nome da entidade
	ent.name = "aventuras:balao"
	
	return true
end


-- Variavel que impede que cordas sejam colocadas (ativa as verificações da fisica das cordas)
cordas_f = true

-- Node
minetest.register_node("aventuras:corda_balao", {
	description = "Corda de Balao",
	drawtype = "torchlike",
	tiles = {"aventuras_corda_balao.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {0, 0, 0, 0, 0, 0},
	},
	groups = {choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1},
	drop = "",
	
	-- Ao ser removido de uma pos
	after_destruct = function(pos)
		-- Remove corda abaixo
		if cordas_f == true and minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name == "aventuras:corda_balao" then
			minetest.remove_node({x=pos.x,y=pos.y-1,z=pos.z})
		end
	end,
	
	-- Ao ser colocado de uma pos
	on_construct = function(pos)
		-- Remove caso nao tenha corda em cima
		if cordas_f == true and minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name ~= "aventuras:corda_balao" then
			minetest.remove_node(pos)
		end
	end,
})

-- Criar balao e cordas para um bau de balao (ignora verificações)
montar_balao = function(pos)
	
	-- Colocar cordas
	do
		-- Desativa as verificações das cordas
		cordas_f = false
		
		local y = 1
		while y <= 24 do
			minetest.set_node({x=pos.x, y=pos.y+y, z=pos.z}, {name="aventuras:corda_balao"})
			y = y + 1
		end
		
		-- Reativa as verificações das cordas
		cordas_f = true
	end
	
	-- Colocar balao
	criar_balao({x=pos.x, y=pos.y+23, z=pos.z})
	
end

-- Atualização constante do balão
minetest.register_abm{
	nodenames = {"aventuras:caixa_balao_aventureiro"},
	interval = 2,
	chance = 1,
	action = function(pos)
		
		-- Verifica balao
		for  _,obj in ipairs(minetest.get_objects_inside_radius(pos, 30)) do
			local ent = obj:get_luaentity() or {}
			-- Verifica se eh o balao
			if ent and ent.name == "aventuras:balao" then
				return
			end
		end
		
		montar_balao(pos)
		
	end,
}
