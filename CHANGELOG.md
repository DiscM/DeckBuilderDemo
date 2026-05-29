# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added
- Momentum-based cards that create a small combo loop: `Quick Jab`, `Rally`, `Cleave`, `Finisher`, and `Tactical Breath`.
- A stance layer with `Offense`, `Guard`, and `Flow` that changes damage, block, momentum, and draw bonuses.
- A second crab enemy variant to make multi-enemy turns and split target choices matter.
- A victory overlay with restart support so the battle ends cleanly in-game.
- README gameplay screenshots for opening battle, Flow/Offense, Guard, and victory.

### Changed
- Expanded the battle from a single-enemy feel into a more feature-complete vertical slice.
- Refined the card target resolution path so self-target, single-target, and area cards resolve reliably.
- Added momentum and stance stats to the combat UI so the new combat loop is visible while playing.
- Improved battle state handling with explicit active, victory, and defeat states.

### Fixed
- Card play now validates cost and target state before resolving.
- Shared combat stats stay synchronized across player, UI, and battle flow.
- End-turn, discard, and turn-reset handling are more robust.
- Enemy action selection and tooltip fade-out behavior are less flaky.
