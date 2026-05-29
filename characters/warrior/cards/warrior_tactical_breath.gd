extends Card

func apply_effects(targets: Array[Node]) -> void:
	if targets.is_empty():
		return

	var player := targets[0] as Player
	if not player:
		return

	var draw_amount := 1
	var momentum_gain := 1
	if player.stats:
		draw_amount += player.stats.get_draw_bonus()
		momentum_gain += player.stats.get_momentum_bonus()

	var player_handler := player.get_tree().get_first_node_in_group("player_handler") as PlayerHandler
	if player_handler:
		player_handler.draw_cards(draw_amount)

	player.stats.momentum += momentum_gain
	player.stats.stance = CharacterStats.Stance.FLOW
