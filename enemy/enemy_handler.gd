class_name EnemyHandler
extends Node2D

var battle_over := false

func _ready() -> void:
	Events.enemy_action_completed.connect(_on_enemy_action_completed)
	Events.battle_ended.connect(_on_battle_ended)
	
func reset_enemy_actions() -> void:
	if battle_over:
		return

	var enemy: Enemy
	for child in get_children():
		enemy = child as Enemy
		enemy.current_action = null
		enemy.update_action()

func start_turn() -> void:
	if battle_over or get_child_count() == 0:
		return
		
	var first_enemy: Enemy = get_child(0) as Enemy
	first_enemy.do_turn()

func _on_enemy_action_completed(enemy: Enemy) -> void:
	if battle_over:
		return

	if enemy.get_index() == get_child_count() -1:
		Events.enemy_turn_ended.emit()
		return
		
	var next_enemy: Enemy = get_child(enemy.get_index() + 1) as Enemy
	next_enemy.do_turn()

func _on_battle_ended(_victory: bool) -> void:
	battle_over = true
