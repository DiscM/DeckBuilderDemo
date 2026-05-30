class_name Card
extends Resource

enum Type {ATTACK, DEFEND, POWER}
enum Target {SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE}

@export_group("Card Attributes")
@export var id: String
@export var type: Type
@export var target: Target
@export var cost: int

@export_group("Card Visuals")
@export var icon: Texture
@export_multiline var tooltip_text: String
@export var combo_tags: PackedStringArray = []

func is_single_targeted() -> bool:
	return target == Target.SINGLE_ENEMY

func matches_combo_tags(active_tags: PackedStringArray) -> bool:
	for tag in combo_tags:
		if active_tags.has(tag):
			return true
	return false

func is_flow_card() -> bool:
	return combo_tags.has("flow")

func play(targets: Array[Node], char_stats: CharacterStats, origin: Node = null) -> bool:
	if not char_stats or not char_stats.can_play_card(self):
		return false

	var resolved_targets := _get_resolved_targets(targets, origin)
	if resolved_targets.is_empty():
		return false

	Events.card_played.emit(self)
	char_stats.mana -= cost

	if type == Type.ATTACK:
		var tree: SceneTree = null
		if origin:
			tree = origin.get_tree()
		elif not resolved_targets.is_empty():
			tree = resolved_targets[0].get_tree()

		if tree:
			var player := tree.get_first_node_in_group("player") as Player
			if player:
				player.play_card_use_animation(self, resolved_targets)

	apply_effects(resolved_targets)
	if char_stats.stance == CharacterStats.Stance.FLOW and not is_flow_card():
		char_stats.stance = CharacterStats.Stance.NEUTRAL
	return true

func _get_resolved_targets(targets: Array[Node], origin: Node = null) -> Array[Node]:
	if is_single_targeted():
		return targets

	var tree: SceneTree
	if origin:
		tree = origin.get_tree()
	elif not targets.is_empty():
		tree = targets[0].get_tree()

	if not tree:
		return []

	match target:
		Target.SELF:
			return tree.get_nodes_in_group("player")
		Target.ALL_ENEMIES:
			return tree.get_nodes_in_group("enemies")
		Target.EVERYONE:
			return tree.get_nodes_in_group("player") + tree.get_nodes_in_group("enemies")
		_:
			return targets

func apply_effects(_targets: Array[Node]) -> void:
	pass
