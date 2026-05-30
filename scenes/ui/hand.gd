class_name Hand
extends HBoxContainer

@export var char_stats: CharacterStats : set = _set_char_stats
@export var card_ui := preload("res://scenes/card_UI/card_ui.tscn")

var cards_played_this_turn := 0

func _ready() -> void:
	Events.card_played.connect(_on_card_played)
	if char_stats:
		_connect_char_stats()
		call_deferred("update_combo_hints")

func _set_char_stats(value: CharacterStats) -> void:
	if char_stats and char_stats.stats_changed.is_connected(_on_char_stats_changed):
		char_stats.stats_changed.disconnect(_on_char_stats_changed)

	char_stats = value
	_connect_char_stats()
	call_deferred("update_combo_hints")

func _connect_char_stats() -> void:
	if not char_stats:
		return

	if not char_stats.stats_changed.is_connected(_on_char_stats_changed):
		char_stats.stats_changed.connect(_on_char_stats_changed)
	
func add_card(card: Card) -> void:
	if not card:
		return

	var new_card_ui := card_ui.instantiate()
	add_child(new_card_ui)
	new_card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
	new_card_ui.card = card
	new_card_ui.parent = self
	new_card_ui.char_stats = char_stats
	call_deferred("update_combo_hints")

func reset_turn_state() -> void:
	cards_played_this_turn = 0
	call_deferred("update_combo_hints")
	
func discard_card(card: CardUI) -> void:
	card.queue_free()
	call_deferred("update_combo_hints")
	
func disable_hand() -> void:
	for child in get_children():
		var card_ui := child as CardUI
		if card_ui:
			card_ui.disabled = true
	
	#for child in get_children():
		#var card_ui := child as CardUI
		#card_ui.parent = self
		#card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)

func _on_card_played(_card: Card) -> void:
	cards_played_this_turn += 1
	call_deferred("update_combo_hints")

func update_combo_hints() -> void:
	if not is_inside_tree():
		return

	var active_tags := PackedStringArray()
	if char_stats:
		active_tags = char_stats.get_combo_hint_tags()

	for child in get_children():
		var card_ui := child as CardUI
		if not card_ui or not card_ui.card:
			continue

		var should_hint := false
		if char_stats and char_stats.can_play_card(card_ui.card):
			should_hint = card_ui.card.matches_combo_tags(active_tags)

		card_ui.combo_hint = should_hint

func _on_char_stats_changed() -> void:
	update_combo_hints()

func _on_card_ui_reparent_requested(child: CardUI) -> void:
	child.disabled = true
	child.reparent(self)
	var new_index := clampi(child.original_index - cards_played_this_turn, 0, get_child_count())
	move_child.call_deferred(child, new_index)
	child.set_deferred("disabled", false)
