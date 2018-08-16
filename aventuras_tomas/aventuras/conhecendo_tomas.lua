--[[
	Mod Aventuras_Tomas para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Aventura : Conhecendo Tomas
  ]]


local S = aventuras_tomas.S

local aven_id = "aventuras_tomas:conhecendo_tomas"

-- Registrar aventura
aventuras.registrar_aventura(aven_id, {
	titulo = S("Conhecendo Tomas"),
	desc = S("Esse parece ser um bom homem. Receptivo e ajudador. Dono de uma bela e grande casa onde sobreviventes sao sempre bem vindos."),
	img = "aventuras_tomas_rosto.png",
})



-- Adicionar tarefa 1
aventuras.adicionar_tarefa(aven_id, {
	titulo = S("Boas Vindas"),
	tipo = "npc_info",
	dados = {
		npcs = {"aventuras_tomas:tomas"},
		msg = S("Ola. Prazer e conhecer-te. Sempre gosto de conhecer pessoas novas. Frequentemente vejo sobreviventes pela regiao. Espero que sinta-se bem em minha casa."),
		msg_fim = S("Se precisar de ajuda estarei por aqui."),
	},
})


-- Adicionar tarefa 2
aventuras.adicionar_tarefa(aven_id, {
	titulo = S("Uma ajuda com a fazendinha"),
	tipo = "npc_troca",
	dados = {
		npcs = {"aventuras_tomas:tomas"},
		msg = S("Bom... Gostaria de falar mais sobre essas terras, mas estou atarefado com uma pequena fazenda que estou tentando criar. Poderia me ajudar com alguma quantia de sementes. Essa bela e rustica casa foi feita com a ajuda de meus amigos. Voce e bem vindo, mas precisa ajudar tambem."),
		msg_fim = S("Obrigado, parece que te devo uma."),
		item_rem = {
			{name="farming:seed_wheat", count=20, wear=0, metadata=""},
		},
	},
})


-- Adicionar tarefa 3
aventuras.adicionar_tarefa(aven_id, {
	titulo = S("Alimento para sobreviver"),
	tipo = "npc_troca",
	dados = {
		npcs = {"aventuras_tomas:tomas"},
		msg = S("Estamos com dificuldades no estoque de lenha. Traga madeira para que possamos assar mais alimento."),
		msg_fim = S("Sua ajuda foi valiosa para essa casa. Tome esses pães."),
		item_rem = {
			{name="default:tree", count=25, wear=0, metadata=""},
		},
		item_add = {
			{name="farming:bread", count=10, wear=0, metadata=""},
		},
	},
})


-- Adicionar tarefa 4
aventuras.adicionar_tarefa(aven_id, {
	titulo = S("Combustível Vital"),
	tipo = "npc_troca",
	dados = {
		npcs = {"aventuras_tomas:tomas"},
		msg = S("Mesmo usando Madeira em meu forno, eu preciso muito de carvão para boas tochas e como eu não sou muito habilidoso em mineração."),
		msg_fim = S("Sua ajuda foi valiosa. Sempre vai ser bem vindo aqui."),
		item_rem = {
			{name="default:coal_lump", count=15, wear=0, metadata=""},
		},
		item_add = {
			{name="aventuras:livro_de_aventuras", count=1, wear=0, metadata=""},
		},
	},
})
