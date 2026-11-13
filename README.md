# Sixty monsters down

![Watch the video](sixty_monsters_down_demo.gif)

## Description

This is a game jam project from the VGA[^1] game jam of March 2026.
The game jam lasted for 2 days or 54h on the theme **Arcade**: all games submited would later be playable on arcade machines at the university's library.

We choose to develop a turn-based roguelike where the player is fighting monsters one after the other. The particularity is that instead of losing life when hit, the player is pushed towards a cliff so that the goal is to catch good buffs only present near the edge while comming back to safety before the monster pushes.
The only way to damage the monster is to grab *attack buffs* that deals more damage the closer they are to the edge.

We choose to use the Godot engine for this project. At the start of the project only Armand Guillet had experience in Godot, he helped the rest of the group to get used to Godot.

### Disclamer

This repo is not acctually the original developped game but a cleaner remade version with almost only new code by me (assets were reused).

The purpose of this repo is to show how the game looked like, it does not track the whole history of the project.

## Contributors

- [Nils Desbois-Renaudin] - Almost everything from this version; game mechanics and UI in the base game.
- [Armand Guillet] - Guidance over the Godot engine, overall code structure and some game mechanics in the base game as well as designing and balancing tokens.
- [Bastien Brogliato--Martin] - Probabilistic distribution of tokens (also in this version), design and balancing of tokens, token assets.
- [Anthony Ruberti] - All character sprites and animations and the interface background.
- [Garance Baylac] - The main background artwork.

## Playing the game

The game was originally made for arcade machine inputs (with joystick and buttons) but when re-making this version, I choose to use more computer-friendly inputs.

#### Gameplay loop

- Select an action to do with your mouse on the buttons on the bottom:

| move back 1 | don't move | move forward 1 | move forward 2 | move forward 3 |
| --- | --- | --- | --- | --- |
- The number of moves you can perform before resolving combat is on the top-left of the screen.
- Combat resolving: You deal damage to the monster depending on the tokens you picked up this turn, then the monster pushes you by the amont displayed on its arrow.

- The buff tokens have many various effects. The most important ones are attack tokens (red with a number), they dictate how much damage you will do to the monster the next time you hit it.

## Requirements

- Godot engine 4.6+

## Building & Running

The whole purpose of this project was to clean and finish properly the code developed during the game jam, I do not intend to publish this game but if you have godot you can open the project and test it.

## License

All content in this repo is strictly for exhibition only,
you may take a look at the contents, share them with a copy of this license and play the game using the Godot engine.
Any other use is forbidden.
Training any artificial intelligence on the content of this repository is forbidden.



[^1]: Video Games Alps is a student association in Grenoble (France) that organise events about video games.
