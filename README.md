## Deck Builder Demo

A small turn-based deck builder prototype inspired by games like *Slay the Spire*.  
This project is a single-battle demo focused on core combat flow, card interactions, and reusable Godot scene structure.

### Screenshots

| Opening battle | Targeting | Resolved play |
| --- | --- | --- |
| ![Opening battle screenshot](README_assets/opening-battle.png) | ![Targeting screenshot](README_assets/attack-targeting.png) | ![Resolved play screenshot](README_assets/attack-resolved.png) |
| Starting hand, mana, and end-turn controls. | A card being aimed at a target. | The attack has resolved and the battle state has updated. |

### Game Mechanics

The battle loop is built around a few simple systems:

* **Turn-based combat** - the player and enemies take alternating turns.
* **Deck, draw pile, discard pile** - cards are drawn from a shuffled deck, played from hand, and discarded at the end of the turn.
* **Mana economy** - each turn restores mana, and every card has a cost.
* **Block and health** - block absorbs damage first, while health ends the run when it reaches zero.
* **Card targeting** - cards can target the player, one enemy, all enemies, or everyone depending on their card type.
* **Enemy intent** - enemies pick actions from a weighted action pool and can switch to conditional moves when their state changes.
* **Card state machine** - card UI uses a state machine for hovering, clicking, dragging, aiming, and releasing.

The current demo is intentionally scoped to one battle so the combat systems can be tested and refined before expanding into a larger game loop.

### Tech Stack

* **Game Engine:** Godot 4
* **Language:** GDScript
* **UI / Scene System:** Godot scenes, nodes, signals, and autoloads
* **Art:** Aseprite and pixel-art assets
* **Audio:** Lightweight sound effects and background music bundled with the project

### Project Structure

The codebase is organized around reusable battle components:

* **`scenes/battle/`** - battle scene root and turn flow coordination
* **`scenes/player/`** - player node, player stats, and turn handling
* **`scenes/ui/`** - hand, mana display, stats UI, and tooltip UI
* **`custom_resources/`** - shared data resources for cards, piles, stats, and effects
* **`enemy/` and `enemies/`** - enemy node logic and enemy-specific AI/actions

### Current Scope

This is a prototype and not a full roguelike yet. The focus is on:

* validating combat rules
* testing node-based architecture
* iterating on card and enemy behavior
* keeping the demo small enough to debug quickly
