class_name Player
extends Node2D

@export var stats: CharacterStats : set = set_character_stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var stats_ui: StatsUI = $StatsUI as StatsUI

var reaction_tween: Tween
var sprite_base_position: Vector2
var sprite_base_scale: Vector2
var sprite_base_modulate: Color = Color.WHITE

func _ready() -> void:
	sprite_base_position = sprite_2d.position
	sprite_base_scale = sprite_2d.scale
	sprite_base_modulate = sprite_2d.modulate

func set_character_stats(value: CharacterStats) -> void:
	if not value:
		return

	stats = value
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
	
	update_player()
	
func update_player() -> void:
	if not stats is CharacterStats:
		return
	if not is_inside_tree():
		await ready
		
	sprite_2d.texture = stats.art
	update_stats()
	
func update_stats() -> void:
	stats_ui.update_stats(stats)
	
func play_card_use_animation(card: Card = null, targets: Array[Node] = []) -> void:
	var position_offset := Vector2(0, -2)
	var scale_target := Vector2(1.08, 1.08)
	var tint := Color(1.0, 1.0, 1.0, 1.0)

	if card and card.type == Card.Type.ATTACK:
		var target_position: Variant = _get_attack_focus_position(targets)
		if target_position != null:
			_play_lunge_reaction(target_position as Vector2, Vector2(1.08, 0.96), Color(1.0, 0.95, 0.9, 1.0))
			return

	if card:
		match card.type:
			Card.Type.ATTACK:
				position_offset = Vector2(2, -1)
				scale_target = Vector2(1.1, 0.95)
				tint = Color(1.0, 0.95, 0.9, 1.0)
			Card.Type.DEFEND:
				position_offset = Vector2(0, -2)
				scale_target = Vector2(1.04, 1.08)
				tint = Color(0.9, 0.95, 1.0, 1.0)
			Card.Type.POWER:
				position_offset = Vector2(0, -3)
				scale_target = Vector2(1.06, 1.06)
				tint = Color(0.9, 1.0, 0.95, 1.0)

	_play_pop_reaction(position_offset, scale_target, tint)

func play_damage_animation() -> void:
	_play_shake_reaction(Vector2(0.95, 1.05), Color(1.0, 0.72, 0.72, 1.0))

func take_damage(damage: int) -> void:
	if stats.health <= 0:
		return
		
	stats.take_damage(damage)
	play_damage_animation()
	
	if stats.health <= 0:
		Events.player_died.emit()
		_queue_free_after_delay()

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

func _play_lunge_reaction(target_global_position: Vector2, scale_target: Vector2, tint: Color) -> void:
	_reset_sprite_transform()
	var direction: float = sign(target_global_position.x - global_position.x)
	if direction == 0:
		direction = 1

	var target_local_position := to_local(target_global_position)
	var lunge_position := target_local_position + Vector2(-direction * 24.0, -2.0)
	reaction_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	reaction_tween.tween_property(sprite_2d, "position", lunge_position, 0.08)
	reaction_tween.parallel().tween_property(sprite_2d, "scale", sprite_base_scale * scale_target, 0.08)
	reaction_tween.parallel().tween_property(sprite_2d, "modulate", tint, 0.08)
	reaction_tween.tween_property(sprite_2d, "position", sprite_base_position, 0.12)
	reaction_tween.parallel().tween_property(sprite_2d, "scale", sprite_base_scale, 0.12)
	reaction_tween.parallel().tween_property(sprite_2d, "modulate", sprite_base_modulate, 0.12)

func _get_attack_focus_position(targets: Array[Node]) -> Variant:
	var total_position := Vector2.ZERO
	var valid_target_count := 0

	for target in targets:
		var target_node: Node2D = target as Node2D
		if not target_node:
			continue

		total_position += target_node.global_position
		valid_target_count += 1

	if valid_target_count == 0:
		return null

	return total_position / valid_target_count

func _queue_free_after_delay() -> void:
	get_tree().create_timer(0.15, false).timeout.connect(_free_if_alive)

func _free_if_alive() -> void:
	if is_inside_tree():
		queue_free()
