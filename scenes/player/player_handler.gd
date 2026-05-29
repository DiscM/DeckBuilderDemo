class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 0.25
const HAND_DISCARD_INTERVAL := 0.25

@export var hand: Hand

var character: CharacterStats

func _ready() -> void:
	add_to_group("player_handler")

func start_battle(char_stats: CharacterStats) -> void:
	character = char_stats
	character.draw_pile = character.deck.duplicate(true)
	character.draw_pile.shuffle()
	character.discard = CardPile.new()
	start_turn()
	
func start_turn() -> void:
	character.block = 0
	character.reset_mana()
	hand.reset_turn_state()
	draw_cards(character.cards_per_turn)
	
func end_turn() -> void:
	hand.disable_hand()
	discard_cards()
	
func draw_card() -> void:
	reshuffle_deck_from_discard()
	var drawn_card := character.draw_pile.draw_card()
	if drawn_card:
		hand.add_card(drawn_card)
	reshuffle_deck_from_discard()
func draw_cards(amount: int) -> void:
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card)
		tween.tween_interval(HAND_DRAW_INTERVAL)
	tween.finished.connect(func(): Events.player_hand_drawn.emit())

func discard_cards() -> void:
	if hand.get_child_count() == 0:
		call_deferred("_emit_player_hand_discarded")
		return

	var tween := create_tween()
	for card_ui in hand.get_children():
		tween.tween_callback(character.discard.add_card.bind(card_ui.card))
		tween.tween_callback(hand.discard_card.bind(card_ui))
		tween.tween_interval(HAND_DISCARD_INTERVAL)
		
	tween.finished.connect(func(): Events.player_hand_discarded.emit())

func _emit_player_hand_discarded() -> void:
	Events.player_hand_discarded.emit()

func reshuffle_deck_from_discard() -> void:
	if not character.draw_pile.empty():
		return
		
	while not character.discard.empty():
		character.draw_pile.add_card(character.discard.draw_card())
		
	character.draw_pile.shuffle()
