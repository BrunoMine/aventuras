--[[
	Mod Aventuras_Masmorras para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Aventura : Caminho da Forja
  ]]


local S = aventuras_bob.S

local aven_id = "aventuras_bob:caminho_da_forja"

-- Registrar aventura
aventuras.registrar_aventura(aven_id, {
	titulo = S("Caminho da Forja"),
	desc = S("Tomas conhece um ferreiro chamado Bob"),
	img = "aventuras_tomas_rosto.png",
})

-- Adicionar tarefa 1
aventuras.adicionar_tarefa(aven_id, {
	titulo = S("Um Conhecido Distante"),
	tipo = "npc_info",
	
	dados = {
		aven_req = {["aventuras_tomas:conhecendo_tomas"]=4},
		npcs = {"aventuras_tomas:tomas"},
		msg = S("Eu tenho algumas demandas por trabalho com ferro e outros metais, no entanto vejo que precisarei de uma ajuda com ferramentas e utensilios mais modernos. Eu conheci um ferreiro chamado Bob que passou por aqui a um tempo. Não lembro muitas coisas sobre ele, mas lembro-me que ele estava a caminho do labirinto das masmorras, um velho ponto de encontro de exploradores. Eu não me dou bem com lugares fechados então preciso que você vá lá e procure por ele."),
		msg_fim = S("Estarei aguardando alguma notícia. Boa sorte."),
	},
})


-- Adicionar tarefa 2 (tarefa apenas ocupa o registro, mas é concluida de outra forma)
aventuras.adicionar_tarefa(aven_id, {
	titulo = S("Coletar mapa"),
	tipo = "npc_alimento",
	
	dados = {
		npcs = {},
		item = {name="aventuras_bob:mapa_bob", count=1, wear=0, metadata=""},
		msg_fim = "",
	},
})

minetest.register_craftitem("aventuras_bob:mapa_bob", {
	description = S("Mapa Secreto").."\n*"..S("Parece levar a uma forja"),
	inventory_image = "aventuras_bob_mapa_bob.png",
	groups = {},
	stack_max = 1,
})

aventuras.registrar_item_bau_noob("aventuras_bob:mapa_bob", {
	aventura = aven_id, -- Aventura relacionada
	
	tarefa = 2, -- Tarefa que o jogador deve ter realizado por ultimo (onde o mesmo recebe o item)
	
	desc_item = minetest.registered_craftitems["aventuras_bob:mapa_bob"].description, -- Descrição do item no menu
	
	custo = 30, --[[ OPCIONAL 
	^ Custo da compra 
	^ O item é definido com a definição aventuras_moeda_bau_noob
	^ Se nulo, é definido como 1 ]]
})


-- Adicionar tarefa 3
aventuras.adicionar_tarefa(aven_id, {
	titulo = S("Mapa encontrado"),
	tipo = "npc_troca",
	dados = {
		npcs = {"aventuras_tomas:tomas"},
		msg = S("Encontrou algo?"),
		msg_fim = S("Otimo. Esse mapa vai me ajudar a encontra-lo futuramente. Muito obrigado."),
		item_rem = {
			{name="aventuras_bob:mapa_bob", count=1, wear=0, metadata=""},
		},
	},
})


