# 🪐 Asteroids Clone — Godot 4 (GDScript)

A classic **Asteroids** remake built with **Godot 4** using **GDScript** — created as a learning exercise and a foundation for future arcade prototypes.  
The project aims to stay **minimal, clean, and easily extensible**, following good practices in Godot scene and code architecture.

---

## 🎯 Project Goals

- Practice **GDScript** syntax and learn Godot’s full workflow.  
- Explore the **scene tree and signal system**.  
- Build a complete and functional game with a clean, modular structure.  

---

## 🧩 Project Structure (WIP)

```

/project_root
│
├─ scenes/
│   ├─ main.tscn             → Main game scene
│   ├─ player.tscn           → Player ship
│   ├─ asteroid.tscn         → Asteroids (large, medium, small)
│   ├─ bullet.tscn           → Player bullets
│   ├─ explosion.tscn        → Explosion effect
│   └─ ui.tscn               → HUD: score, lives, etc.
│
├─ scripts/
│   ├─ player.gd
│   ├─ asteroid.gd
│   ├─ bullet.gd
│   ├─ explosion.gd
│   └─ game_manager.gd
│
├─ assets/
│   ├─ sprites/              → Textures and sprites
│   ├─ sounds/               → Sound effects and music
│   └─ fonts/                → Fonts and UI assets
│
├─ autoload/
│   └─ game_manager.gd       → Global singleton (score, lives, etc.)
│
├─ export_presets.cfg        → Export configuration
├─ project.godot             → Godot project file
└─ README.md

````

---

## 🕹️ Game Controls

| Action | Key |
|:--------|:----|
| Thrust | W |
| Turn Left | A |
| Turn Right | D |
| Shoot | Space |
| Restart | R |
| Quit | Esc |

---

## ▶️ How to Run

1. Open Godot and select this project folder.
2. Run `Main.tscn` (`F5`) to start the game.
3. Have fun blasting asteroids 💥

---

## 🧠 Key Concepts Used

* **Nodes & sub-scenes** for modularity.
* **Signals** for event-driven communication.
* **Dynamic instantiation** of bullets, asteroids, and explosions.
* **Autoload (singleton)** for score and lives management.
* **Collision detection** using physics bodies and areas.

---

## 🌌 Roadmap

* [ ] Particle effects for thrust and explosions
* [ ] Improved explosion animation
* [ ] Game Over & Start menus
* [ ] Gamepad support
* [ ] Web (HTML5) export
* [ ] Endless mode with progressive waves

---

## 🖼️ Screenshots *(coming soon)*

*(Will be added once HUD and visual effects are implemented.)*

---

## 📜 License

This project is open for personal learning and experimentation.
Feel free to use the code as a starting point for your own Godot creations.

Author: **José Ignacio Yarza Vidal** — 2025

---

> *“Learn by creating. Create to learn.”* ✨
