class_name BattleUI
extends CanvasLayer

@export var char_stats: CharacterStats : set = _set_char_stats

@onready var hand: Hand = $Hand as Hand
@onready var mana_ui: ManaUI = $ManaUI as ManaUI
@onready var end_turn_button: Button = %EndTurnButton
@onready var battle_end_panel: Control = %BattleEndPanel
@onready var battle_end_label: Label = %BattleEndLabel
@onready var restart_button: Button = %RestartButton

var battle_over := false

func _ready() -> void:
	Events.player_hand_drawn.connect(_on_player_hand_drawn)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	end_turn_button.disabled = true
	hide_battle_end()

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	mana_ui.char_stats = char_stats
	hand.char_stats = char_stats

func _on_player_hand_drawn() -> void:
	if battle_over:
		return
	end_turn_button.disabled = false
	
func _on_end_turn_button_pressed() -> void:
	if battle_over:
		return
	end_turn_button.disabled = true
	Events.player_turn_ended.emit()

func show_victory() -> void:
	battle_end_label.add_theme_color_override("font_color", Color(0.55, 1.0, 0.55))
	_show_battle_end("Victory!")

func show_defeat() -> void:
	battle_end_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
	_show_battle_end("Defeat")

func hide_battle_end() -> void:
	battle_over = false
	battle_end_label.remove_theme_color_override("font_color")
	battle_end_panel.hide()

func _show_battle_end(message: String) -> void:
	battle_over = true
	end_turn_button.disabled = true
	hand.disable_hand()
	battle_end_label.text = message
	battle_end_panel.show()

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
