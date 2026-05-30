extends CardState

var played: bool

func enter() -> void:
	played = false
	card_ui.set_held(false)
	
	if card_ui.card.target != Card.Target.SINGLE_ENEMY or not card_ui.targets.is_empty():
		Events.tooltip_hide_requested.emit()
		played = card_ui.play()
		if not played:
			transition_requested.emit(self, CardState.State.BASE)
		
func on_input(_event: InputEvent) -> void:
	if played:
		return
		
	transition_requested.emit(self, CardState.State.BASE)
	
