extends Card

func apply_effects(targets: Array[Node]) -> void:
	var player: Player = null
	if not targets.is_empty():
		player = targets[0].get_tree().get_first_node_in_group("player") as Player
	var damage_amount := 6
	if player and player.stats:
		damage_amount += player.stats.get_attack_bonus()

	var damage_effect := DamageEffect.new()
	damage_effect.amount = damage_amount
	damage_effect.execute(targets)
	
