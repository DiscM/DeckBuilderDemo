extends Card

func apply_effects(targets: Array[Node]) -> void:
	if targets.is_empty():
		return

	var player := targets[0].get_tree().get_first_node_in_group("player") as Player
	var momentum_bonus := 0
	if player:
		momentum_bonus = player.stats.momentum

	var damage_effect := DamageEffect.new()
	damage_effect.amount = 4 + momentum_bonus
	if player and player.stats:
		damage_effect.amount += player.stats.get_attack_bonus()
	damage_effect.execute(targets)

	if player and player.stats:
		player.stats.momentum = 0
		player.stats.stance = CharacterStats.Stance.OFFENSE
