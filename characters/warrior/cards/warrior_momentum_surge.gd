extends Card

func apply_effects(targets: Array[Node]) -> void:
	if targets.is_empty():
		return

	var player := targets[0].get_tree().get_first_node_in_group("player") as Player
	var damage_amount := 4

	if player and player.stats:
		damage_amount += player.stats.get_attack_bonus()
		damage_amount += player.stats.momentum
		if player.stats.stance == CharacterStats.Stance.FLOW:
			damage_amount += 2

	var damage_effect := DamageEffect.new()
	damage_effect.amount = damage_amount
	damage_effect.execute(targets)

	if player and player.stats:
		player.stats.momentum = 0
		player.stats.stance = CharacterStats.Stance.OFFENSE
