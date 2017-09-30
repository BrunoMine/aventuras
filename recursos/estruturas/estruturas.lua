--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Recurso para Estruturas de aventuras
  ]]

-- Tabela global de lugares
aventuras.estruturas = {}

-- Nodes especiais para montagem
dofile(minetest.get_modpath("aventuras").."/recursos/estruturas/nodes.lua")

-- Estruturas registradas
aventuras.estruturas.registradas = {}

-- Recupera dados de estruturas registradas
if aventuras.bd.verif("estruturas", "estruturas_registradas") == true then
	aventuras.estruturas.registradas = aventuras.bd.pegar("estruturas", "estruturas_registradas")
end

-- Salva estruturas registradas
minetest.register_on_shutdown(function()
	aventuras.bd.salvar("estruturas", "estruturas_registradas", aventuras.estruturas.registradas)
end)

-- Estruturas ja montados
aventuras.estruturas.montadas = {}

-- Recupera dados de estruturas montadas
if aventuras.bd.verif("estruturas", "estruturas_montadas") == true then
	aventuras.estruturas.montadas = aventuras.bd.pegar("estruturas", "estruturas_montadas")
end

-- Salva estruturas montadas
minetest.register_on_shutdown(function()
	aventuras.bd.salvar("estruturas", "estruturas_montadas", aventuras.estruturas.montadas)
end)


-- Registrar lugar
aventuras.registrar_estrutura = function(name, def)
	aventuras.estruturas.registradas[name] = aventuras.estruturas.registradas[name] or {}
	local r = aventuras.estruturas.registradas[name]
	
	-- Reescreve dados novos
	
	-- Versão
	r.versao = def.versao
	
	-- Estrutura
	r.titulo = def.titulo
	r.largura = def.largura
	r.altura = def.altura
	r.filepath = def.filepath
	r.aven_req = def.aven_req
	
	-- MapGen para montagem (não pode ser reescrito)
	r.mapgen = r.mapgen or def.mapgen
end


-- Limite do mapa para tentar montar
local map_limit = 25000


-- Verificar area gerada e carregada
local verif_area_carregada = function(minp, maxp)
	if minetest.get_node({x=minp.x, y=minp.y, z=minp.z}).name == "ignore" 
		or minetest.get_node({x=minp.x, y=minp.y, z=maxp.z}).name == "ignore" 
		or minetest.get_node({x=maxp.x, y=minp.y, z=maxp.z}).name == "ignore" 
		or minetest.get_node({x=maxp.x, y=minp.y, z=minp.z}).name == "ignore" 
		or minetest.get_node({x=minp.x, y=maxp.y, z=minp.z}).name == "ignore" 
		or minetest.get_node({x=minp.x, y=maxp.y, z=maxp.z}).name == "ignore" 
		or minetest.get_node({x=maxp.x, y=maxp.y, z=maxp.z}).name == "ignore" 
		or minetest.get_node({x=maxp.x, y=maxp.y, z=minp.z}).name == "ignore" 
	then
		return false
	end
	return true
end

-- Montagem de estruturas em mapgens especificos
local montar = {}
montar["suspenso"] = dofile(minetest.get_modpath("aventuras").."/recursos/estruturas/mapgen_suspenso.lua")


-- Montar e atualizar lugares
local processo = nil
aventuras.estruturas.preparar_tudo = function(name)
	
	-- Dados do processo
	if not processo then
		processo = {
			-- Estruturas já processadas
			processadas = {},
			
			-- Dados da estrutura que está sendo processada
			em_curso = {},
		}
	end
	
	for estrut,dados in pairs(aventuras.estruturas.registradas) do
		
		if not processo.processadas[estrut] then
			
			if not aventuras.estruturas.montadas[estrut] then
				
				local proc = processo.em_curso
				local dados_lugar = aventuras.estruturas.registradas[estrut]
				local largura_area = dados_lugar.largura * 15
				local limite = map_limit - largura_area - 100
				local dist_area = largura_area/2
	
				-- Verifica se ja está tentando montar em algum lugar
				if not proc.pos then
					proc.pos = {x=math.random(-limite,limite), y=1, z=math.random(-limite,limite)}
				end
				local pos = proc.pos
	
				-- Coordenadas limitrofes
				local minp = {x=pos.x-dist_area, y=-60, z=pos.z-dist_area}
				local maxp = {x=pos.x+dist_area, y=150, z=pos.z+dist_area}
	
				-- Verifica se mapa foi completamente gerado e carregado nessa coordenada
				if verif_area_carregada(minp, maxp) == false then
					minetest.emerge_area(minp, maxp)
					minetest.log("action", "Gerando e/ou carregando mapa ...")
					minetest.after(4, aventuras.estruturas.preparar_tudo, name)
					return
				end
				
				-- Tenta montar estrutura
				local r_montagem, pos_montagem = montar[dados_lugar.mapgen.tipo](minp, maxp, dados_lugar)
				if r_montagem == true then
					
					-- Registra o lugar para teleporte
					if table.maxn(minetest.find_nodes_in_area(minp, maxp, {"aventuras:caixa_balao_aventureiro"})) > 0 then
						local tp_pos = minetest.find_nodes_in_area(minp, maxp, {"aventuras:caixa_balao_aventureiro"})[1]
						tp_pos.y = tp_pos.y + 3
						aventuras.registrar_lugar(estrut, {
							titulo = dados_lugar.titulo,
							aven_req = dados_lugar.aven_req,
							pos = minetest.deserialize(minetest.serialize(tp_pos)),
						})
					end
					
					-- Salva dados de estrutura montada
					aventuras.estruturas.montadas[estrut] = {
						pos = minetest.deserialize(minetest.serialize(pos_montagem)),
						versao = dados_lugar.versao,
					}
					
					-- estrutura criada
					processo.processadas[estrut] = 1
					
					minetest.after(0.1, aventuras.estruturas.preparar_tudo, name)
					return
				else
					-- Falha na tentativa de montagem, reiniciar
					minetest.get_player_by_name(name):setpos(proc.pos)
					proc.pos = nil
					proc.tentativas = (proc.tentativas or 0) + 1
					minetest.log("action", "Regiao inapropriada para "..estrut.." (tentativa "..proc.tentativas..")")
					minetest.after(0.1, aventuras.estruturas.preparar_tudo, name)
					return
				end
			
			elseif aventuras.estruturas.montadas[estrut].versao ~= aventuras.estruturas.registradas[estrut].versao then
				
				local dados_lugar = aventuras.estruturas.registradas[estrut]
				local dist = dados_lugar.largura/2
				local pos = aventuras.estruturas.montadas[estrut].pos
				local minp = {x=pos.x-dist, y=pos.y, z=pos.z-dist}
				local maxp = {x=pos.x+dist, y=pos.y+dados_lugar.altura, z=pos.z+dist}
				
				
				-- Recoloca estrutura no mapa
				minetest.place_schematic(
						{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
						dados_lugar.filepath, 0, nil, true)
			
				-- Executa ajustes dos blocos especiais
				aventuras.estruturas.ajustar_nodes(minp, maxp)
				
				-- Atualiza registro do lugar para teleporte
				if table.maxn(minetest.find_nodes_in_area(minp, maxp, {"aventuras:caixa_balao_aventureiro"})) > 0 then
					local tp_pos = minetest.find_nodes_in_area(minp, maxp, {"aventuras:caixa_balao_aventureiro"})[1]
					tp_pos.y = tp_pos.y + 3
					aventuras.registrar_lugar(estrut, {
						titulo = dados_lugar.titulo,
						aven_req = dados_lugar.aven_req,
						pos = minetest.deserialize(minetest.serialize(tp_pos)),
					})
				end
				
				-- Atualiza versao
				aventuras.estruturas.montadas[estrut].versao = dados_lugar.versao
				
				-- Estrutura atualizada
				processo.processadas[estrut] = 2
				
				minetest.after(0.1, aventuras.estruturas.preparar_tudo, name)
				return
			else
				
				-- Estrutura verificada
				processo.processadas[estrut] = 3
				
				minetest.after(0.1, aventuras.estruturas.preparar_tudo, name)
				return
			end
		end
	end
	
	-- Finalizando
	minetest.log("action", "Montagem de estruturas concluida")
	if name then minetest.chat_send_player(name, "Concluido") end
	processo = nil
	
end

-- Comandos para iniciar montagem de lugares
minetest.register_chatcommand("aventuras_lugares", {
	params = "",
	description = "Inicia montagem e atualização de lugares",
	privs = {server = true},
	func = function(name, param)
		minetest.chat_send_player(name, "Iniciando montagem de lugares. Isso pode demorar algum tempo ...")
		aventuras.estruturas.preparar_tudo(name)
	end,
})



