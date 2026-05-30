extends Card

func apply_effects(targets: Array[Node]) -> void:
	if targets.is_empty():
		return

	var player := targets[0].get_tree().get_first_node_in_group("player") as Player
	var block_amount := 4
	var draw_amount := 0

	if player and player.stats:
		block_amount += player.stats.get_block_bonus()
		block_amount += player.stats.momentum
		if player.stats.stance == CharacterStats.Stance.FLOW:
			block_amount += 2
			draw_amount = 1

	var block_effect := BlockEffect.new()
	block_effect.amount = block_amount
	block_effect.execute(targets)

	if player and player.stats:
		var player_handler := player.get_tree().get_first_node_in_group("player_handler") as PlayerHandler
		if player_handler and draw_amount > 0:
			player_handler.draw_cards(draw_amount)

		player.stats.momentum += 1
		player.stats.stance = CharacterStats.Stance.FLOW
