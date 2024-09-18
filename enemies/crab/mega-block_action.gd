extends EnemyAction

@export var block := 15
@export var hp_threshold := 6

var already_used := false

func is_performable() -> bool:
	if not enemy or already_used:
		return false
		
#The next two lines of code evaluate inline with the variable declaration
	var is_low := enemy.stats.health <= hp_threshold
#The enemy health is compared to the hp_threshold (6) and used as a flag setter for already_used
	already_used = is_low
	return is_low
	
func perform_action() -> void:
	if not enemy or not target:
		return
		
	var block_effect := BlockEffect.new()
	block_effect.amount = block
	block_effect.execute([enemy])
	
	get_tree().create_timer(0.6, false).timeout.connect(func(): Events.enemy_action_completed.emit(enemy))
