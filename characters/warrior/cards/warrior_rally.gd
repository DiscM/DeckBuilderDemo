extends Card

func apply_effects(targets: Array[Node]) -> void:
	var player: Player = null
	if not targets.is_empty():
		player = targets[0].get_tree().get_first_node_in_group("player") as Player
	var block_amount := 4
	var momentum_gain := 2
	if player and player.stats:
		block_amount += player.stats.get_block_bonus()
		momentum_gain += player.stats.get_momentum_bonus()

	var block_effect := BlockEffect.new()
	block_effect.amount = block_amount
	block_effect.execute(targets)

	if player and player.stats:
		player.stats.momentum += momentum_gain
		player.stats.stance = CharacterStats.Stance.GUARD
