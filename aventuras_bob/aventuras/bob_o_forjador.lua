--[[
	Mod Aventuras_Masmorras para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Aventura : Bob o forjador
  ]]


local S = aventuras_bob.S

local aven_id = "aventuras_bob:bob_o_forjador"

-- Registrar aventura
aventuras.registrar_aventura(aven_id, {
	titulo = S("Bob o Forjador"),
	desc = S("Conhecendo o ferreiro Bob"),
	img = "aventuras_bob_rosto.png",
})

-- Adicionar tarefa 1
aventuras.adicionar_tarefa(aven_id, {
	titulo = S("Um Mercante de Ferro"),
	tipo = "npc_info",
	
	dados = {
		aven_req = {["aventuras_tomas:conhecendo_tomas"]=4},
		npcs = {"aventuras_bob:bob"},
		msg = S("Oi. Imagino que você tenha chegado aqui por um daqueles mapas que espalhei. Sou um ferreiro mercante e preciso receber visitas para obter meus recursos atravez de trocas comerciais."),
		msg_fim = S("Obrigado pela visita. Se precisar de ajuda com forjas estarei aqui."),
	},
})

-- Adicionar tarefa 2
aventuras.adicionar_tarefa(aven_id, {
	titulo = S("Sem Comida, Sem Forja"),
	tipo = "npc_troca",
	dados = {
		npcs = {"aventuras_bob:bob"},
		msg = S("Desde que abri meu negócio tenho dificuldades para encontrar novos clientes. Preciso que me ajudes com alguns recursos. Traga-me trigo eu garanto que lhe conseguirei uma bela troca."),
		msg_fim = S("Agora poderei me alimentar melhor e você poderá se defender melhor."),
		item_rem = {
			{name="farming:wheat", count=40, wear=0, metadata=""},
		},
		item_add = {
			{name="default:sword_steel", count=1, wear=0, metadata=""},
		},
	},
})

-- Adicionar tarefa 3
aventuras.adicionar_tarefa(aven_id, {
	titulo = S("Areia nos Ouvidos"),
	tipo = "npc_troca",
	dados = {
		npcs = {"aventuras_bob:bob"},
		msg = S("Você já deve ter percebido que eu trabalho com grandes quantias de material. Estou precisando de uma boa quantidade de areia. Se você conseguir me ajudar com isso, prometo que terás uma boa recompensa."),
		msg_fim = S("Muito obrigado. Tome aqui sua recompensa. Espero poder fazer mais trocas com você pois tenho muito trabalho pela frente."),
		item_rem = {
			{name="default:sand", count=100, wear=0, metadata=""},
		},
		item_add = {
			{name="3d_armor:boots_steel", count=1, wear=0, metadata=""},
		},
	},
})

-- Adicionar tarefa 4
aventuras.adicionar_tarefa(aven_id, {
	titulo = S("Frutas são Boas"),
	tipo = "npc_troca",
	dados = {
		npcs = {"aventuras_bob:bob"},
		msg = S("Um ferreiro habilidoso como eu precisa ter um bom estoque de frutas para se alimentar adequadamente. Consiga um bom punhado de frutas e te darei uma boa e pesada proteção."),
		msg_fim = S("Essas frutas estão ótimas! Tome aqui sua armadura."),
		item_rem = {
			{name="default:apple", count=50, wear=0, metadata=""},
		},
		item_add = {
			{name="3d_armor:chestplate_steel", count=1, wear=0, metadata=""},
		},
	},
})

-- Adicionar tarefa 5
aventuras.adicionar_tarefa(aven_id, {
	titulo = S("Terra para Ilhas"),
	tipo = "npc_troca",
	dados = {
		npcs = {"aventuras_bob:bob"},
		msg = S("Estou trabalhando em uma nova ilha para um projeto futuro e precisarei de bastante terra. Me traga uma boa quantia e lhe darei uma boa proteção para as pernas."),
		msg_fim = S("Perfeito! Aqui está sua recompensa."),
		item_rem = {
			{name="default:dirt", count=200, wear=0, metadata=""},
		},
		item_add = {
			{name="3d_armor:leggings_steel", count=1, wear=0, metadata=""},
		},
	},
})

-- Adicionar tarefa 6
aventuras.adicionar_tarefa(aven_id, {
	titulo = S("Fonte de Madeira"),
	tipo = "npc_troca",
	dados = {
		npcs = {"aventuras_bob:bob"},
		msg = S("Em minha ilha também vou precisar de mudas de árvore para completar minha ilha. Você poderia me dar algumas?"),
		msg_fim = S("Agora poderei ter uma boa fonte de madeira. Tome essa proteção para sua cabeça."),
		item_rem = {
			{name="default:sapling", count=20, wear=0, metadata=""},
		},
		item_add = {
			{name="3d_armor:helmet_steel", count=1, wear=0, metadata=""},
		},
	},
})

-- Adicionar tarefa 7
aventuras.adicionar_tarefa(aven_id, {
	titulo = S("Caminho pelo Mar"),
	tipo = "npc_troca",
	dados = {
		npcs = {"aventuras_bob:bob"},
		msg = S("Um ultimo detalhe para que eu possa chegar em minha ilha é um barco. Eu tenho habilidade com ferro, mas nem tanto com madeira. Podes vazer um Barco para mim?"),
		msg_fim = S("Ótimo! Tome uma recompensa para completar sua armadura."),
		item_rem = {
			{name="boats:boat", count=1, wear=0, metadata=""},
		},
		item_add = {
			{name="shields:shield_steel", count=1, wear=0, metadata=""},
		},
	},
})

