class_name CharacterStats
extends Stats

enum Stance {NEUTRAL, OFFENSE, GUARD, FLOW}

@export var starting_deck : CardPile
@export var cards_per_turn : int
@export var max_mana : int

var mana: int : set = set_mana
var stance: Stance = Stance.NEUTRAL : set = set_stance
var deck: CardPile
var discard: CardPile
var draw_pile: CardPile

func set_mana(value: int) -> void:
	mana = value
	stats_changed.emit()

func set_stance(value: Stance) -> void:
	stance = value
	stats_changed.emit()
	
func reset_mana() -> void:
	self.mana = max_mana

func reset_stance() -> void:
	self.stance = Stance.NEUTRAL
	
func can_play_card(card: Card) -> bool:
	return mana >= card.cost

func get_stance_name() -> String:
	match stance:
		Stance.OFFENSE:
			return "Offense"
		Stance.GUARD:
			return "Guard"
		Stance.FLOW:
			return "Flow"
		_:
			return "Neutral"

func get_stance_color() -> Color:
	match stance:
		Stance.OFFENSE:
			return Color(1.0, 0.45, 0.35)
		Stance.GUARD:
			return Color(0.4, 0.65, 1.0)
		Stance.FLOW:
			return Color(0.55, 1.0, 0.6)
		_:
			return Color(0.85, 0.85, 0.85)

func get_attack_bonus() -> int:
	if stance == Stance.OFFENSE:
		return 2
	return 0

func get_block_bonus() -> int:
	if stance == Stance.GUARD:
		return 3
	return 0

func get_momentum_bonus() -> int:
	if stance == Stance.FLOW:
		return 1
	return 0

func get_combo_hint_tags() -> PackedStringArray:
	var tags := PackedStringArray()

	match stance:
		Stance.OFFENSE:
			tags.append("offense")
		Stance.GUARD:
			tags.append("guard")
		Stance.FLOW:
			tags.append("flow")
		_:
			tags.append("setup")

	if momentum > 0:
		tags.append("finisher")

	return tags

func get_draw_bonus() -> int:
	if stance == Stance.FLOW:
		return 1
	return 0

func create_instance() -> Resource:
	var instance: CharacterStats = self.duplicate()
	instance.health = max_health
	instance.block = 0
	instance.reset_mana()
	instance.reset_stance()
	instance.deck = instance.starting_deck.duplicate()
	instance.draw_pile = CardPile.new()
	instance.discard = CardPile.new()
	return instance
	
