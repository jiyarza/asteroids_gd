# Signal Flow - Asteroids (Godot)

```mermaid
flowchart TD
    %% Signal Flow - Asteroids (Godot)
    %% Conventions:
    %% - signal: <name>(args...)  -> Godot signal emission / connection
    %% - call: <method>()         -> direct method call (not a signal)

    subgraph MainMenu
      MM[MainMenu.gd]
      ST[SceneTree]
      MM -->|"call: change_scene_to_file(...)"| ST
      MM -.->|"InputEvent (tecla)"| MM
    end

    subgraph Player
      PI[PlayerInput.gd]
      P[Player.gd]
      W[Weapon.gd]

      PI -->|signal: shoot_pressed| W
      P -->|signal: player_died| GM
    end

    subgraph WeaponToSpawner
      S[Spawner.gd]
      W -->|"signal: fire_requested(position, direction)"| S
    end

    subgraph Asteroids
      A[Asteroid.gd]
      A -->|"signal: asteroid_split_requested(position, next_size)"| S
      A -->|"signal: asteroid_destroyed(position, size)"| GM
    end

    subgraph Spawner
      S -->|"signal: asteroid_spawned(asteroid)"| GM
    end

    subgraph UI
      PC[PauseController.gd]
      Pause[Tree.paused = true/false]
      PC -->|call: set paused| Pause
      PC -.->|InputEvent pause| PC
    end

    subgraph WorldState
      GM[GameManager.gd "(Event Aggregator)"]
    end
```
