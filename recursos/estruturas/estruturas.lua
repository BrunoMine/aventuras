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
	
	-- MapGen para montagem
	r.mapgen = def.mapgen
	
	aventuras.bd.salvar("estruturas", "estruturas_registradas", aventuras.estruturas.registradas)
end


-- Limite do mapa para tentar montar
local map_limit = tonumber(minetest.setting_get("mapgen_limit") or "31000")

-- Verifica se o limit de mapa é aceitavel
if map_limit < 25000 then
	minetest.log("error", "[Aventuras] Limite de mapa muito pequeno ("..map_limit.."). Pode causar problemas na montagem de estruturas.")
end

-- Pega ignore apenas se bloco nao foi gerado
local function pegar_node(pos)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(pos, pos)
		node = minetest.get_node(pos)
	end
	return node
end


-- Verificar area gerada e carregada
local verif_area_carregada = function(minp, maxp)
	if pegar_node({x=minp.x, y=minp.y, z=minp.z}).name == "ignore" 
		or pegar_node({x=minp.x, y=minp.y, z=maxp.z}).name == "ignore" 
		or pegar_node({x=maxp.x, y=minp.y, z=maxp.z}).name == "ignore" 
		or pegar_node({x=maxp.x, y=minp.y, z=minp.z}).name == "ignore" 
		or pegar_node({x=minp.x, y=maxp.y, z=minp.z}).name == "ignore" 
		or pegar_node({x=minp.x, y=maxp.y, z=maxp.z}).name == "ignore" 
		or pegar_node({x=maxp.x, y=maxp.y, z=maxp.z}).name == "ignore" 
		or pegar_node({x=maxp.x, y=maxp.y, z=minp.z}).name == "ignore" 
	then
		return false
	end
	minetest.get_voxel_manip():read_from_map(minp, maxp)
	return true
end

-- Verificar se uma area tem proteção alguma (retorna true se tem proteção)
local verif_area_protegida = function(minp, maxp)
	for x=minp.x , maxp.x , 7 do
		for y=minp.y , maxp.y , 7 do
			for z=minp.z , maxp.z , 7 do
				if minetest.is_protected({x=x, y=y, z=z}, "") then return true end
			end
		end
	end
	return false
end

-- Montagem de estruturas em mapgens especificos
local montar = {}
montar["suspenso"] = dofile(minetest.get_modpath("aventuras").."/recursos/estruturas/mapgen_suspenso.lua")


-- Informar jogadores online
local informe_geral = function(text)
	for _,player in ipairs(minetest.get_connected_players()) do
		-- Cobre a tela com formspec de carregamento
		minetest.show_formspec(player:get_player_name(), "aventuras:estruturas_load", "size[8,2]"
			.."bgcolor[#000000FF;true]"
			.."image[0,0;2,2;default_acacia_bush_sapling.png]"
			.."label[2,0;Preparando estruturas de aventuras\nIsso pode demorar algum tempo...\n\n"..text.."]")
	end
end

-- Informa depurador
local act_log = function(text)
	minetest.log("action", "[Aventuras] "..text)
end


-- Converter coordenada em string
local Spos = minetest.pos_to_string

-- Montar e atualizar lugares
local processo = nil
aventuras.estruturas.preparar_tudo = function(name)
	
	
	-- Dados do processo
	if not processo then
		minetest.log("action", "[Aventuras] Iniciando montagem de estruturas no mapa")
		informe_geral("Iniciando procedimentos")
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
				if largura_area+200 > map_limit*2 then
					minetest.log("error", "[Aventuras] Estrutura nao cabe no mapa (Largura do mapa = "..(map_limit*2).." | Largura da area necessaria = "..largura_area..")")
				end
				
				-- Escolhe uma coordenada de centro aleatoriamente
				if not proc.pos then
					proc.pos = {x=math.random(-limite,limite), y=1, z=math.random(-limite,limite)}
					proc.tentativas = 1
				end
				local pos = proc.pos
				
				-- Coordenadas limitrofes
				local minp = {x=pos.x-dist_area, y=-60, z=pos.z-dist_area}
				local maxp = {x=pos.x+dist_area, y=150, z=pos.z+dist_area}
				
				-- Verifica area protegida
				if not proc.prot_ok then
				
					informe_geral("Montando \""..dados_lugar.titulo.."\""
						.."\nTentativa "..proc.tentativas
						.."\nVerificando area protegida ...")
					
					act_log("Verificando area protegida ("..Spos(minp).." a "..Spos(maxp)..")")
					
					if verif_area_protegida({x=minp.x-200,y=minp.y-100,z=minp.z-200}, 
						{x=maxp.x+200,y=maxp.y+200,z=maxp.z+200}) == true
					then
						proc.pos = nil
						proc.prot_ok = nil
						proc.tentativas = proc.tentativas + 1
						act_log("Regiao ja protegida ("..Spos(minp).." a "..Spos(maxp)..")")
						minetest.after(0.1, aventuras.estruturas.preparar_tudo, name)
						return
					else
						proc.prot_ok = true
					end
				end
				
				-- Verifica se mapa foi completamente gerado e carregado nessa coordenada
				if verif_area_carregada(minp, maxp) == false then
					if proc.gerando ~= true then
						proc.gerando = true
						minetest.emerge_area(minp, maxp)
						act_log("Gerando e/ou carregando mapa ("..Spos(minp).." a "..Spos(maxp)..")...")
					end
					
					informe_geral("Montando \""..dados_lugar.titulo.."\""
						.."\nTentativa "..proc.tentativas
						.."\nGerando mapa ...")
					
					minetest.after(2, aventuras.estruturas.preparar_tudo, name)
					return
				else
					proc.gerando = false
				end
				
				-- Tenta montar estrutura
				local r_montagem, pos_montagem = montar[dados_lugar.mapgen.tipo](minp, maxp, dados_lugar)
				if r_montagem == true then
					
					local dist = dados_lugar.largura/2
					local estrut_minp = {x=pos_montagem.x-dist, y=pos_montagem.y, z=pos_montagem.z-dist}
					local estrut_maxp = {x=pos_montagem.x+dist, y=pos_montagem.y+dados_lugar.altura, z=pos_montagem.z+dist}
					
					-- Registra o lugar para teleporte
					if table.maxn(minetest.find_nodes_in_area(estrut_minp, estrut_maxp, {"aventuras:caixa_balao_aventureiro"})) > 0 then
						local tp_pos = minetest.find_nodes_in_area(estrut_minp, estrut_maxp, {"aventuras:caixa_balao_aventureiro"})[1]
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
					
					-- Cria area protegida
					local p = pos_montagem
					areas:add("Aventuras:Tomas", dados_lugar.titulo, {x=p.x-200, y=p.y-100, z=p.z-200}, {x=p.x+200, y=p.y+15000, z=p.z+200}, nil)
					
					-- estrutura criada
					processo.processadas[estrut] = 1
					
					act_log("Estrutura "..estrut.." montada em "..pos_montagem.x.." "..pos_montagem.y.." "..pos_montagem.z)
					informe_geral("Estrutura \""..dados_lugar.titulo.."\" construida")
					minetest.after(0.5, aventuras.estruturas.preparar_tudo, name)
					return
				else
					-- Falha na tentativa de montagem, reiniciar
					proc.pos = nil
					proc.prot_ok = nil
					proc.tentativas = (proc.tentativas or 0) + 1
					act_log("Regiao inapropriada para "..estrut.." (tentativa "..proc.tentativas..")")
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
				aventuras.bd.salvar("estruturas", "estruturas_montadas", aventuras.estruturas.montadas) -- Salva mudanças
				
				-- Estrutura atualizada
				processo.processadas[estrut] = 2
				
				informe_geral("Estrutura \""..dados_lugar.titulo.."\" atualizada")
				minetest.after(0.5, aventuras.estruturas.preparar_tudo, name)
				return
			else
				
				-- Estrutura verificada
				processo.processadas[estrut] = 3
				
				informe_geral("Estrutura \""..aventuras.estruturas.registradas[estrut].titulo.."\" verificada")
				minetest.after(0.5, aventuras.estruturas.preparar_tudo, name)
				return
			end
		end
	end
	
	
	-- Calculo de estatisticas
	local est = {}
	est.montadas = 0 -- Estruturas Montadas
	est.atualizadas = 0 -- Estruturas Atualizadas
	est.verificadas = 0 -- Estruturas verificadas mas que nao precisaram de alterações
	est.erros = 0 -- Estruturas que tiveram erros
	est.total = 0 -- Todas de estruturas
	for estrut,dados in pairs(aventuras.estruturas.registradas) do
		if processo.processadas[estrut] then
			if processo.processadas[estrut] == 1 then
				est.montadas = est.montadas + 1
			elseif processo.processadas[estrut] == 2 then
				est.atualizadas = est.atualizadas + 1
			elseif processo.processadas[estrut] == 3 then
				est.verificadas = est.verificadas + 1
			else
				est.erros = est.erros + 1
			end
		else
			est.erros = est.erros + 1
		end
		est.total = est.total + 1
	end
	
	-- Finalizando
	act_log("Montagem de estruturas concluida")
	act_log("Montadas: "..est.montadas)
	act_log("Atualizadas: "..est.atualizadas)
	act_log("Verificadas: "..est.verificadas)
	act_log("Erros: "..est.erros)
	act_log("Total: "..est.total)
	
	if name then 
		minetest.chat_send_player(name, "Montagem de estruturas concluida")
		minetest.chat_send_player(name, "Montadas: "..est.montadas)
		minetest.chat_send_player(name, "Atualizadas: "..est.atualizadas)
		minetest.chat_send_player(name, "Verificadas: "..est.verificadas)
		minetest.chat_send_player(name, "Erros: "..est.erros)
		minetest.chat_send_player(name, "Total: "..est.total)
	end
	
	-- Fecha formspec de carregamento
	for _,player in ipairs(minetest.get_connected_players()) do
		
		local pn = player:get_player_name()
		-- Cobre a tela com formspec de carregamento
		minetest.after(1, minetest.close_formspec, pn, "aventuras:estruturas_load")
		
	end
	
	processo = nil
	
end


-- Evita que novos jogadores conectem ao servidor enquanto monta estruturas
if minetest.is_singleplayer() == false then
	minetest.register_on_prejoinplayer(function(name)
		if processo -- Em processo
			and name ~= minetest.setting_get("name") -- Não é o cliente inicial
		then
			return "Servidor em processo de montagem. Retorne em instantes"
		end
	end)
else
	minetest.register_on_prejoinplayer(function(name)
		if processo -- Em processo
			and name ~= "singleplayer" -- Não é o singleplayer
		then
			return "Servidor em processo de montagem. Retorne em instantes"
		end
	end)
end


-- Comandos para iniciar montagem de lugares
minetest.register_chatcommand("aventuras_setup_estrut", {
	params = "",
	description = "Inicia montagem e atualização de lugares",
	privs = {server = true},
	func = function(name, param)
		minetest.chat_send_player(name, "Iniciando montagem de lugares. Isso pode demorar algum tempo ...")
		aventuras.estruturas.preparar_tudo(name)
	end,
})


-- Autosetup estruturas
if aventuras.autosetup_estruturas == true then
	minetest.after(0.1, aventuras.estruturas.preparar_tudo)
end


