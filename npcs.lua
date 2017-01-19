--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Controle de dados dos NPCs
  ]]

-- Variavel global dos npcs
aventuras.npcs = {}

-- Registros dos npcs (tabela desordenada)
aventuras.npcs.registros = {}

-- Salvar dados de um NPC
aventuras.npcs.registrar = function(npc, def)
	if not npc then
		minetest.log("error", "[Aventuas] Nenhum ID de NPC especificado (em aventuras.npcs.registrar)")
		return false
	end
	
	if not def then
		minetest.log("error", "[Aventuas] Nenhum parametro de NPC especificado (em aventuras.npcs.registrar)")
		return false
	end
	
	-- Criar registro
	aventuras.npcs.registros[npc] = {}
	
	-- Salvar textura da face para exibir em formspec
	if def.face then
		aventuras.npcs.registros[npc].face = def.face
	end
	
	-- Salvar textura de background para formspecs do npc
	if def.bg then
		aventuras.npcs.registros[npc].bg = def.bg
	end
	
	-- Salvar cor das formspecs do npc
	if def.cor_bg then
		aventuras.npcs.registros[npc].cor_bg = def.cor_bg
	end
	
end
