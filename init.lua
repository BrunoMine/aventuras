--[[
	Mod Aventuras para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Teste basico do mod aventuras
  ]]

--
-- Preparação das entidades
--

-- Alterar on_rigthclick do mob igor
minetest.registered_entities["mobs_npc:igor"].on_rightclick = function(self, clicker)
	aventuras.recursos.npc.on_rightclick(self, clicker)
end
-- Registrar arte do npc Igor
aventuras.recursos.npc.registrar_arte("mobs_npc:igor", {
	face = "default_stone.png",
	bgcolor = "bgcolor[#080808BB;true]",
	bg_img1x1 = "background[5,5;1,1;default_wood.png;true]",
	bg_img10x3 = "background[5,5;3,1;default_wood.png;true]",
})


-- Alterar on_rigthclick do mob trader
minetest.registered_entities["mobs_npc:trader"].on_rightclick = function(self, clicker)
	aventuras.recursos.npc.on_rightclick(self, clicker)
end

--
-- Criação de Aventura de Teste 1
-- e tarefas
--

-- Registrar aventura de teste 1
aventuras.registrar_aventura("aventura_de_teste_1", {
	titulo = "Aventura de Teste 1",
	desc = "Aventura feita para testar a Engine de aventuras"
})

-- Adicionar tarefa 1 na aventura 1
aventuras.adicionar_tarefa("aventura_de_teste_1", "troca_npc", {
	titulo = "Conhecendo o Igor",
	dados = {
		npcs = {"mobs_npc:igor"},
		msg = "Oi. Sou o Igor",
		msg_fim = "Prazer em conhecer",
	},
})

-- Adicionar tarefa 2 na aventura 1
aventuras.adicionar_tarefa("aventura_de_teste_1", "troca_npc", {
	titulo = "Conhecendo o amigo imaginario do igor",
	dados = {
		npcs = {"mobs_npc:trader"},
		msg = "Oi. Esse e meu amigo imaginario",
		msg_fim = "Ele disse prazer em conhecer voce",
	},
})

-- Adicionar tarefa 3 na aventura 1
aventuras.adicionar_tarefa("aventura_de_teste_1", "troca_npc", {
	titulo = "Oferencendo terra",
	dados = {
		npcs = {"mobs_npc:igor"},
		msg = "Oi. Preciso de terra",
		msg_fim = "Obrigado",
		item_rem = {
			{name="default:dirt", count=1, wear=0, metadata=""},
		},
	},
})

-- Adicionar tarefa 4 na aventura 1
aventuras.adicionar_tarefa("aventura_de_teste_1", "troca_npc", {
	titulo = "Recebendo terra",
	dados = {
		npcs = {"mobs_npc:igor"},
		msg = "Oi. Acho que nao preciso mais de terra",
		msg_fim = "Obrigado novamente",
		item_add = {
			{name="default:dirt", count=1, wear=0, metadata=""},
		},
	},
})

-- Adicionar tarefa 5 na aventura 1
aventuras.adicionar_tarefa("aventura_de_teste_1", "troca_npc", {
	titulo = "A troca",
	dados = {
		npcs = {"mobs_npc:igor"},
		msg = "Me de essa terra, tome esses pedregulhos",
		msg_fim = "Boa troca",
		item_add = {
			{name="default:cobble", count=1, wear=0, metadata=""},
			{name="default:cobble", count=2, wear=0, metadata=""},
			{name="default:cobble", count=5, wear=0, metadata=""},
			{name="default:cobble", count=55, wear=0, metadata=""},
			{name="default:wood", count=22, wear=0, metadata=""},
		},
		item_rem = {
			{name="default:dirt", count=1, wear=0, metadata=""},
		},
	},
})

--
-- Criação de Aventura de Teste 2
-- e tarefas
--


-- Registrar aventura de teste 2
aventuras.registrar_aventura("aventura_de_teste_2", {
	titulo = "Aventura de Teste 2",
	desc = "Aventura feita para testar a Engine de aventuras"
})

-- Adicionar tarefa 1 na aventura 2
aventuras.adicionar_tarefa("aventura_de_teste_2", "troca_npc", {
	titulo = "Conhecendo o Igor",
	dados = {
		npcs = {"mobs_npc:igor"},
		msg = "Oi. Sou o Rogi",
		msg_fim = "Prazer em conhecer",
	},
})




