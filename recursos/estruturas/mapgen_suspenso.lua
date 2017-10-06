--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Montar estrutura em planicie
  ]]

-- Pega ignore apenas se bloco nao foi gerado
local function pegar_node(pos)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(pos, pos)
		node = minetest.get_node(pos)
	end
	return node
end


-- Encontrar solo
local function pegar_solo(pos, ymin, ymax)
	local y = ymax
	local r = nil
	while y >= ymin do
		local node = pegar_node({x=pos.x, y=y, z=pos.z})
		if string.match(node.name, "default:dirt_with") then
			r = {x=pos.x, y=y, z=pos.z}
			break
		end
		y = y - 1
	end
	return r
end

-- Verificar proteção em uma coluna (retorna true se estiver protegida)
local verir_coluna_protegida = function(pos, ymin, ymax)
	for y=ymin, ymax do
		if minetest.is_protected({x=pos.x, y=pos.y, z=pos.z}, "") then
			return true
		end
	end
	return false
end

-- Verifica se um ponto existe na malha
local function verificar_ponto(x, z, lim)
	if x < 1 or x > lim or z < 1 or z > lim then 
		return false
	else
		return true
	end
end

-- Comparar valor max
local function comparar_max(max, n)
	if max == nil then
		return n
	elseif max < n then
		return n
	else
		return max
	end
end

-- Comparar valor min
local function comparar_min(min, n)
	if min == nil then
		return n
	elseif min > n then
		return n
	else
		return min
	end
end

-- Montar malha e coletar dados nos pontos
--[[
	`dist_var` é a distancia centro-borda para os pontos 
	analizados ao calcular a variação nas proximidades
  ]]
local pegar_malha = function(minp, maxp, dist_var)	
	local vetor = {}
	
	-- Numero de pontos em cada direção
	local pts = math.floor(math.abs(minp.x-maxp.x)/5 - 1)
	
	-- Vetor de dados
	for x=1, pts do
		vetor[x] = {}
		for z=1, pts do
			vetor[x][z] = {}
		end
	end
	
	-- Pegando dados para cada posicao
	for x,_ in ipairs(vetor) do
		for z,_ in ipairs(vetor[x]) do
		
			-- Pegar solo
			vetor[x][z].p = pegar_solo({x=minp.x+(5*x), y=maxp.y, z=minp.z+(5*z)}, minp.y, maxp.y)
			
			-- Calcular variacao dos pontos adjacentes
			local max, min = nil, nil
			local div = 0
			for xi=-dist_var, dist_var do
				for zi=-dist_var, dist_var do
					local xn, zn = x+xi, z+zi
					if verificar_ponto(xn, zn, pts) then
						if vetor[xn][zn].p then
							max = comparar_max(max, vetor[xn][zn].p.y)
							min = comparar_min(min, vetor[xn][zn].p.y)
							div = div + 1
						end
					end
				end
			end
			if div >= 1 then
				vetor[x][z].var = max - min -- variação nas proximidades
				vetor[x][z].ymax = max -- altura maxima nas proximidades
				vetor[x][z].ymin = min -- altura minima nas proximidades
				vetor[x][z].div = div -- pontos validos da malha
			else
				vetor[x][z].var = nil
			end
		end
	end
	
	return vetor, pts
end


-- Verificar se area atende aos criterios
return function(minp, maxp, def)
	
	-- Pontos de centro a borda na malha para a area desejada para a estrutura
	local dist_pts = math.ceil((def.largura/2)/5) + 1
	
	-- Tolerancia de inclinação (variação vertical) - 80% da largura
	local var_max = math.floor(def.largura*0.8)
	
	-- Pegar malha
	local malha, lim_malha = pegar_malha(minp, maxp, dist_pts)
	
	-- Verificar quantidade de pontos em areas planas
	--[[
		Isso é uma analize de pontos da malha
	  ]]
	local rel = {nul=0,bom=0,ruim=0}
	local min = nil
	local vpos = {}
	local pt_malha = nil
	for x,_ in ipairs(malha) do
		for z,_ in ipairs(malha[x]) do
			local po = malha[x][z]
			if po.var == nil then
				rel.nul = rel.nul + 1
				
			-- Descarta pontos protegidos
			elseif po.p and verir_coluna_protegida(po.p, minp.y, maxp.y) == true then
				rel.nul = rel.nul + 1
			
			-- Descartas pontos proximos dos limites
			elseif x <= dist_pts or x >= (lim_malha-dist_pts) 
				or z <= dist_pts or z >= (lim_malha-dist_pts) then
				rel.nul = rel.nul + 1
				
			-- Descartas pontos proximos de arvores para campos
			elseif def.mapgen.bioma == "campo" and po.p 
				and minetest.find_node_near(po.p, 4, {"group:tree"}) then
				rel.nul = rel.nul + 1
			
			-- Certifica que tenha arvores
			elseif def.mapgen.bioma == "floresta" and po.p 
				and not minetest.find_node_near(po.p, 4, {"default:leaves"}) then
				rel.nul = rel.nul + 1
				
			-- Filtra a variação (70% da largura)
			elseif po.var > var_max then
				
				rel.ruim = rel.ruim + 1
			
			-- Passou por todos os filtros
			else
			
				rel.bom = rel.bom + 1
				
				if malha[x][z].p then 
					table.insert(vpos, malha[x][z].p) 
				end
				
				-- Atualiza melhor ponto encontrado
				if po.p then
					if po.var and min ~= comparar_min(min, po.var) then
						min = comparar_min(min, po.var)
						pt_malha = po
					elseif pt_malha == nil then
						pt_malha = po
					end
				end
			end
			
			
		
		end
	end
	
	-- Verifica quantidade aceitavel de areas planas
	if rel.bom < 7 or not pt_malha then 
		return false 
	end
	
	local pos = pt_malha.p
	
	local dist = def.largura/2
	local y = pos.y
	do -- Calcula altura y com ar
		local c_air = minetest.get_content_id"air"
	 
		-- Pegar VoxelManip
		local pemin = {x=pos.x-dist-5, y=minp.y, z=pos.z-dist-5}
		local pemax = {x=pos.x+dist+5, y=maxp.y, z=pos.z+dist+5}
		local vm = minetest.get_voxel_manip()
		local emin, emax = vm:read_from_map(pemin, pemax)
		local data = vm:get_data()
		local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	 	
		while y < maxp.y do
			
			local c = 0 -- contador de ar
			for i in area:iter( -- analiza faixa por faixa indo para cima
				pemin.x, y, pemin.z,
				pemax.x, y, pemax.z
			) do
				if data[i] == c_air then
					c = c + 1
				end
			end
			if c == (math.abs(pemax.x-pemin.x)+1)^2 then
				break
			else
				y = y + 1
			end
		end
		
	end
	
	-- Coloca estrutura no mapa
	minetest.place_schematic(
			{x=pos.x-dist, y=y+3, z=pos.z-dist}, 
			def.filepath, 0, nil, true)
			
	-- Executa ajustes dos blocos especiais
	aventuras.estruturas.ajustar_nodes(minp, maxp)
	
	return true, {x=pos.x, y=y+3, z=pos.z}
end

