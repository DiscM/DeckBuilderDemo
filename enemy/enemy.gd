class_name Enemy
extends Area2D

const ARROW_OFFSET := 5

@export var stats : EnemyStats : set = set_enemy_stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var arrow: Sprite2D = $Arrow
@onready var stats_ui: StatsUI = $StatsUI as StatsUI

var enemy_action_picker: EnemyActionPicker
var current_action: EnemyAction : set = set_current_action
var reaction_tween: Tween
var sprite_base_position: Vector2
var sprite_base_scale: Vector2
var sprite_base_modulate: Color = Color.WHITE

func _ready() -> void:
	sprite_base_position = sprite_2d.position
	sprite_base_scale = sprite_2d.scale
	sprite_base_modulate = sprite_2d.modulate

func set_current_action(value: EnemyAction) -> void:
	current_action = value

func set_enemy_stats(value: EnemyStats) -> void:
	stats = value.create_instance()
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
		stats.stats_changed.connect(update_action)
		
	update_enemy()
	
func setup_ai() -> void:
	if enemy_action_picker:
		enemy_action_picker.queue_free()
		
	var new_action_picker: EnemyActionPicker = stats.ai.instantiate()
	add_child(new_action_picker)
	enemy_action_picker = new_action_picker
	enemy_action_picker.enemy = self
	
func update_stats() -> void:
	stats_ui.update_stats(stats)
	
	
func update_action() -> void:
	if not enemy_action_picker:
		return
		
	if not current_action:
		current_action = enemy_action_picker.get_action()
		return
		
	var new_conditional_action := enemy_action_picker.get_first_conditional_action()
	if new_conditional_action and current_action != new_conditional_action:
		current_action = new_conditional_action
		
func update_enemy() -> void:
	if not stats is Stats:
		return
	if not is_inside_tree():
		await ready
		
	sprite_2d.texture = stats.art
	_update_facing_toward_player()
	arrow.position = Vector2.RIGHT * (sprite_2d.get_rect().size.x / 2 + ARROW_OFFSET)
	setup_ai()
	update_stats()
	
func do_turn() -> void:
	stats.block = 0
	if not current_action:
		return
	_update_facing_toward_player()
	play_action_animation()
	current_action.perform_action()
	
func take_damage(damage: int) -> void:
	if stats.health <= 0:
		return 
	stats.take_damage(damage)
	play_damage_animation()
	if stats.health <= 0:
		_queue_free_after_delay()

func play_action_animation() -> void:
	_update_facing_toward_player()
	_play_pop_reaction(Vector2(-2, -1), Vector2(1.06, 0.96), Color(1.0, 1.0, 1.0, 1.0))

func play_damage_animation() -> void:
	_play_shake_reaction(Vector2(0.95, 1.05), Color(1.0, 0.72, 0.72, 1.0))

func _reset_sprite_transform() -> void:
	if reaction_tween:
		reaction_tween.kill()
		reaction_tween = null

	sprite_2d.position = sprite_base_position
	sprite_2d.scale = sprite_base_scale
	sprite_2d.modulate = sprite_base_modulate

func _play_pop_reaction(position_offset: Vector2, scale_target: Vector2, tint: Color) -> void:
	_reset_sprite_transform()
	reaction_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	reaction_tween.tween_property(sprite_2d, "position", sprite_base_position + position_offset, 0.06)
	reaction_tween.parallel().tween_property(sprite_2d, "scale", sprite_base_scale * scale_target, 0.06)
	reaction_tween.parallel().tween_property(sprite_2d, "modulate", tint, 0.06)
	reaction_tween.tween_property(sprite_2d, "position", sprite_base_position, 0.12)
	reaction_tween.parallel().tween_property(sprite_2d, "scale", sprite_base_scale, 0.12)
	reaction_tween.parallel().tween_property(sprite_2d, "modulate", sprite_base_modulate, 0.12)

func _play_shake_reaction(scale_target: Vector2, tint: Color) -> void:
	_reset_sprite_transform()
	reaction_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	reaction_tween.tween_property(sprite_2d, "position", sprite_base_position + Vector2(-3, 0), 0.03)
	reaction_tween.tween_property(sprite_2d, "position", sprite_base_position + Vector2(3, 0), 0.03)
	reaction_tween.tween_property(sprite_2d, "position", sprite_base_position + Vector2(-2, 0), 0.03)
	reaction_tween.tween_property(sprite_2d, "position", sprite_base_position + Vector2(1, 0), 0.03)
	reaction_tween.parallel().tween_property(sprite_2d, "scale", sprite_base_scale * scale_target, 0.04)
	reaction_tween.parallel().tween_property(sprite_2d, "modulate", tint, 0.04)
	reaction_tween.tween_property(sprite_2d, "position", sprite_base_position, 0.08)
	reaction_tween.parallel().tween_property(sprite_2d, "scale", sprite_base_scale, 0.08)
	reaction_tween.parallel().tween_property(sprite_2d, "modulate", sprite_base_modulate, 0.08)

func _update_facing_toward_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return

	sprite_2d.flip_h = player.global_position.x < global_position.x

func _queue_free_after_delay() -> void:
	get_tree().create_timer(0.15, false).timeout.connect(_free_if_alive)

func _free_if_alive() -> void:
	if is_inside_tree():
		queue_free()


func _on_area_entered(_area: Area2D) -> void:
	arrow.show()


func _on_area_exited(_area: Area2D) -> void:
	arrow.hide()
