extends Card

func apply_effects(targets: Array[Node]) -> void:
	if targets.is_empty():
		return

	var player := targets[0].get_tree().get_first_node_in_group("player") as Player
	var damage_amount := 3
	var draw_amount := 0

	if player and player.stats:
		damage_amount += player.stats.get_attack_bonus()
		damage_amount += player.stats.momentum
		if player.stats.stance == CharacterStats.Stance.FLOW:
			damage_amount += 2
			draw_amount = 1

	var damage_effect := DamageEffect.new()
	damage_effect.amount = damage_amount
	damage_effect.execute(targets)

	if player and player.stats:
		var player_handler := player.get_tree().get_first_node_in_group("player_handler") as PlayerHandler
		if player_handler and draw_amount > 0:
			player_handler.draw_cards(draw_amount)

		player.stats.momentum += 1
		player.stats.stance = CharacterStats.Stance.FLOW
