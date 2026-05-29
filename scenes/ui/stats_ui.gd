class_name StatsUI
extends HBoxContainer

@onready var block: HBoxContainer = $Block
@onready var block_label: Label = %BlockLabel

@onready var health: HBoxContainer = $Health
@onready var health_label: Label = %HealthLabel

@onready var momentum: HBoxContainer = $Momentum
@onready var momentum_label: Label = %MomentumLabel

@onready var stance: HBoxContainer = $Stance
@onready var stance_label: Label = %StanceLabel

func update_stats(stats: Stats) -> void:
	block_label.text = str(stats.block)
	health_label.text = str(stats.health)
	momentum_label.text = str(stats.momentum)
	
	block.visible = stats.block > 0
	health.visible = stats.health > 0
	momentum.visible = stats.momentum > 0

	if stats is CharacterStats:
		var char_stats := stats as CharacterStats
		stance.visible = true
		stance_label.text = char_stats.get_stance_name()
		stance_label.add_theme_color_override("font_color", char_stats.get_stance_color())
	else:
		stance.visible = false
