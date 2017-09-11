--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Recurso para criação de Personagens
  ]]


-- Verificador do Bau de Sovagxas
-- Tempo (em segundos) que demora para um bau verificar se tem um sovagxa dele por perto
local tempo_verif_npc = 60
-- Distancia (om blocos) que um bau verifica em sua volta para encontrar seu proprio npc
local dist_verif_npc = 100

-- Tempo para verificar se tem outro npc igual por perto
local tempo_verif_duplicado = 8
-- Verificador do npc sovagxa
-- Tempo (em segundos) que um npc demora para verificar se esta perto da pos de seu bau
local tempo_verif_bau = 20

-- Verificar distancia entre duas pos
local verif_dist_pos = function(pos1, pos2)
	local x = math.abs(math.abs(pos1.x)-math.abs(pos2.x))
	local y = math.abs(math.abs(pos1.y)-math.abs(pos2.y))
	local z = math.abs(math.abs(pos1.z)-math.abs(pos2.z))
	if x > z and x > y then return x end
	if y > x and y > z then return y end
	if z > x and z > y then return z end
	return x or y or z
end


-- Verifica se o npc está perto do spawner
local check_spawner_node = function(charname, pos)
	
	local spawnerdef = aventuras.registered_characteres[charname].spawner_node[minetest.get_node(pos).name]
	
	-- Verifica se ja tem npc
	for  n,obj in ipairs(minetest.get_objects_inside_radius(pos, dist_verif_npc)) do
		local ent = obj:get_luaentity() or {}
		if ent.name == charname then -- Verifica se é o mesmo npc
			return
		end
	end
	
	-- Coloca novo npc
	local node = minetest.get_node(pos)
	local p = minetest.facedir_to_dir(node.param2)
	local spos = {x=pos.x,y=pos.y,z=pos.z}
	
	-- Ajusta posição
	if spawnerdef.spawn_mode == "front" then
		local p = minetest.facedir_to_dir(node.param2)
		spos = {x=pos.x-p.x,y=pos.y+1.5,z=pos.z-p.z}
	end
	
	-- Cria a entidade
	local obj = minetest.add_entity(spos, charname) 
	
	-- Salva alguns dados na entidade inicialmente
	if obj then
		local ent = obj:get_luaentity()
		ent.spawn_type = 1 -- Spawnou pelo spawner
		ent.temp = 0 -- Temporizador
		ent.pos_bau = pos -- Pos do bau
	end
	
end


-- Personagens registrados
aventuras.registered_characteres = {}


-- Registrar Personagem
aventuras.register_character = function(charname, def)
	
	-- Salva dados
	aventuras.registered_characteres[charname] = minetest.deserialize(minetest.serialize(def))
	def = aventuras.registered_characteres[charname]
	
	-- Registrar mobs
	if def.type == "npc" then
		
		-- Configurações pré-feitas
		if def.npc_preset == "human" then -- Humano
			def.npc.collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35}
			def.npc.visual = "mesh"
			def.npc.mesh = "character.b3d"
			def.npc.animation = {
				speed_normal = 30,
				speed_run = 30,
				stand_start = 0,
				stand_end = 79,
				walk_start = 168,
				walk_end = 187,
				run_start = 168,
				run_end = 187,
				punch_start = 200,
				punch_end = 219,
			}
		end
		
		-- Registrar entidade npc
		mobs:register_mob(charname, {
			type = "npc",
			passive = true,
			hp_min = 12,
			hp_max = 12,
			armor = 100,
			collisionbox = def.npc.collisionbox,
			visual = def.npc.visual,
			mesh = def.npc.mesh,
			textures = def.npc.textures,
			makes_footstep_sound = true,
			sounds = {},
			walk_velocity = 1,
			run_velocity = 2,
			stepheight = 1.1,
			fear_height = 2,
			jump = true,
			knock_back = 0,
			water_damage = 1,
			lava_damage = 3,
			light_damage = 0,
			view_range = 5,
			
			sounds = def.npc.sounds,
			
			animation = def.npc.animation,
	
			on_rightclick = function(self, clicker)
				aventuras.recursos.npc.on_rightclick(self, clicker)
			end,
	
			do_custom = function(self, dtime)
				
				-- Caso seja um npc perto do spawner
				if self.spawn_type == 1 then
					self.temp = self.temp + dtime -- conta temporizador do loop
					
					-- Verifica se esta perto do bau de origem
					if self.temp >= tempo_verif_bau then
						self.temp = 0
			
						-- Verificar se os dados ianda existem 
						if not self.pos_bau then
							self.object:remove()
							return
						end
			
						-- Verificar se esta perto do bau
						if verif_dist_pos(self.object:getpos(), self.pos_bau) > dist_verif_npc then
							self.object:remove()
							return
						end
			
						-- Verifica o se o bau de origem ainda existe
						local node = minetest.get_node(self.pos_bau)
						if node.name ~= charname then
							self.object:remove()
							return
						end
					end
				
				
				-- Se for um npc spawnado aleatoriamente
				elseif self.spawn_type == 2 then
					self.temp = self.temp + dtime
					
					if self.temp >= tempo_verif_duplicado then
						self.life_time = self.life_time - self.temp
						self.temp = 0
						
						local pos = self.object:getpos()
						for  n,obj in ipairs(minetest.get_objects_inside_radius(pos, dist_verif_npc)) do
							local ent = obj:get_luaentity() or {}
							if ent.name == charname 
								and tostring(ent.object) ~= tostring(self.object)
							then -- Verifica se é o mesmo npc
								self.object:remove()
								return
							end
						end
						
						-- Verifica se tem um outro duplicado
						if self.life_time < 0 then
							self.object:remove()
							return
						end
					end
					
				-- Nenhuma origem encontrada
				else
					-- Considera spawnado pela API Mobs_Redo (spawn aleatorio)
					self.spawn_type = 2
					self.temp = 0
					self.life_time = 300
				end
		
			end,
		})
		
		-- Registrar arte do npc
		if def.arte_npc then
			aventuras.recursos.npc.registrar_arte(charname, {
				face = def.arte_npc.face,
				bgcolor = def.arte_npc.bgcolor,
				bg_img1x1 = def.arte_npc.bg_img1x1,
				bg_img10x3 = def.arte_npc.bg_img10x3,
			})
		end
	end
	
	-- Configurar Nodes de spawn
	if def.spawner_node then
		
		local nodestb = {}
		for nodename, spawnerdef in pairs(def.spawner_node) do
			table.insert(nodestb, nodename)
		end
		
		-- Verifica periodicamente o spawnador para spawnar personagem
		minetest.register_abm({
			label = "check_spawner_node:"..charname,
			nodenames = minetest.deserialize(minetest.serialize(nodestb)),
			interval = tempo_verif_npc,
			chance = 1,
			action = function(pos)
				minetest.after(2, check_spawner_node, charname, pos)
			end,
		})
		
	end
	
	-- Configurar Spawn aleatorio
	if def.random_spawn then
		mobs:spawn({
			name = charname,
			nodes = def.random_spawn.nodes,
			min_light = def.random_spawn.min_light or 10,
			chance = def.random_spawn.chance or 15000,
			active_object_count = def.random_spawn.active_object_count or 1,
			min_height = def.random_spawn.min_height or 0,
			day_toggle = def.random_spawn.day_toggle,
		})
	end
	
end
