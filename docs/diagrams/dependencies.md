```mermaid
flowchart LR
    %% ==========================================================
    %% Asteroids (Godot 4) - Diagrama de dependencias (mejorado)
    %% - Flecha solida: dependencia directa / llamada / senal
    %% - Flecha discontinua: wiring por Inspector / NodePath / opcional
    %% ==========================================================

    %% =======================
    %% Escenas raiz
    %% =======================
    MainMenuScene["Scene: MainMenu.tscn"] --> MainMenuScript["Script: MainMenu.gd"]

    MainScene["Scene: Main.tscn"] --> GMScript["Script: World/GameManager.gd<br/><i>class_name GameManager</i>"]
    MainScene --> SpawnerScript["Script: World/Spawner.gd<br/><i>class_name Spawner</i>"]
    MainScene --> HUDScript["Script: UI/hud.gd"]
    MainScene --> PauseControllerScript["Script: UI/PauseController.gd<br/><i>class_name PauseController</i>"]

    %% =======================
    %% GameManager (orquestacion)
    %% =======================
    GMScript -. "(@export) world_path: NodePath" .-> WorldNode["Node: World (Node2D)"]
    GMScript -. "(@export) spawner_path: NodePath" .-> SpawnerScript
    GMScript -. "(@export) ui_layer_path: NodePath" .-> HUDScript

    GMScript -. "(@export) player_scene: PackedScene" .-> PlayerScene["Scene: Player/Player.tscn"]
    GMScript -->|instantiate()| PlayerScene

    %% GameManager escucha senales del Player
    PlayerScript["Script: Player/Player.gd<br/><i>class_name Player</i>"] -->|"signal died"| GMScript

    %% GameManager integra Spawner: conecta el arma del Player al Spawner
    GMScript -->|"connect_weapon( player.Weapon )"| SpawnerScript

    %% GameManager actualiza HUD (llamadas directas)
    GMScript -->|"reset(score,lives,level) / set_score / set_lives / set_level"| HUDScript

    %% Pausa (opcional desde GameManager: en tu codigo esta comentado)
    GMScript -. "set_pause(is_paused) / notificacion UI (opcional)" .-> PauseControllerScript

    %% =======================
    %% Spawner (instanciacion de entidades)
    %% =======================
    SpawnerScript -. "(@export) bullet_scene: PackedScene" .-> BulletScene["Scene: Bullet/Bullet.tscn"]
    SpawnerScript -. "(@export) asteroid_large_scene: PackedScene" .-> AsteroidLargeScene["Scene: Asteroid/Asteroid.tscn"]
    SpawnerScript -. "(@export) asteroid_medium_scene: PackedScene" .-> AsteroidMedScene["Scene: Asteroid/Asteroid_MEDIUM.tscn"]
    SpawnerScript -. "(@export) asteroid_small_scene: PackedScene" .-> AsteroidSmallScene["Scene: Asteroid/Asteroid_SMALL.tscn"]
    SpawnerScript -. "(@export) ufo_scene: PackedScene (si se usa)" .-> UFOScene["Scene: (UFO).tscn ?"]

    %% Spawner usa el World (por NodePath) para add_child
    SpawnerScript -. "(@export_node_path) world_path: NodePath" .-> WorldNode
    SpawnerScript -->|"add_child( bullet / asteroid / ufo )"| WorldNode

    %% Conexion de Weapon -> Spawner (senal fire_requested)
    WeaponScript["Script: Player/Weapon.gd<br/><i>class_name Weapon</i>"] -->|"signal fire_requested(pos,dir)"| SpawnerScript

    %% Spawner cablea eventos de asteroide para split
    AsteroidScript["Script: Asteroid/Asteroid.gd<br/><i>class_name Asteroid</i>"] -->|"signal split_requested(pos,next_size)"| SpawnerScript
    SpawnerScript -->|"spawn_asteroid(next_size,...)"| AsteroidLargeScene
    SpawnerScript -->|"spawn_asteroid(next_size,...)"| AsteroidMedScene
    SpawnerScript -->|"spawn_asteroid(next_size,...)"| AsteroidSmallScene

    %% Spawner notifica al GameManager cuando spawnea un asteroide
    SpawnerScript -->|"signal asteroid_spawned(a: Asteroid)"| GMScript

    %% =======================
    %% Player (composicion por componentes)
    %% =======================
    PlayerScene --> PlayerScript
    PlayerScript -. "(@export) input: PlayerInput" .-> PlayerInputScript["Script: Player/PlayerInput.gd<br/><i>class_name PlayerInput</i>"]
    PlayerScript -. "(@export) physics: ShipPhysics" .-> ShipPhysicsScript["Script: Player/ShipPhysics.gd<br/><i>class_name ShipPhysics</i>"]
    PlayerScript -. "(@export) weapon: Weapon" .-> WeaponScript

    %% Player inyecta input en ShipPhysics y conecta Weapon con input
    PlayerScript -->|"physics.input = input"| ShipPhysicsScript
    PlayerScript -->|"weapon.connect_input(input)"| WeaponScript

    %% =======================
    %% Entidades: Asteroides
    %% =======================
    AsteroidLargeScene --> AsteroidScript
    AsteroidMedScene --> AsteroidScript
    AsteroidSmallScene --> AsteroidScript

    %% GameManager escucha destroyed para score / progreso de oleada
    AsteroidScript -->|"signal destroyed(pos,size)"| GMScript

    %% =======================
    %% Entidades: Bala
    %% =======================
    BulletScene --> BulletScript["Script: Bullet/Bullet.gd<br/><i>class_name Bullet</i>"]
    SpawnerScript -->|"bullet.setup(pos,dir)"| BulletScript
    BulletScript -->|"uses child node: Timer"| BulletTimer["Node: Bullet/Timer (Timer)"]

    %% =======================
    %% UI: Pausa y HUD
    %% =======================
    PauseControllerScript -. "(@export) pause_label: CanvasItem" .-> PauseLabel["UI Node: Pause Label (CanvasItem)"]
    PauseControllerScript -->|"Input action: pause"| InputMap["Project InputMap: 'pause'"]

    HUDScript --> HUDNodes["UI Nodes: labels/controles en HUD (score, lives, wave, etc.)"]

    %% =======================
    %% Utilidad: Screen wrap
    %% =======================
    ScreenWrapScript["Script: ScreenWrap2D.gd<br/><i>class_name ScreenWrap2D</i>"]
    %% ScreenWrap2D funciona como componente (habitualmente como hijo del Node2D/RigidBody2D)
    %% Si lo has anadido en las escenas, estas relaciones aplican:
    PlayerScene -. "si contiene ScreenWrap2D como child" .-> ScreenWrapScript
    AsteroidLargeScene -. "si contiene ScreenWrap2D como child" .-> ScreenWrapScript
    AsteroidMedScene -. "si contiene ScreenWrap2D como child" .-> ScreenWrapScript
    AsteroidSmallScene -. "si contiene ScreenWrap2D como child" .-> ScreenWrapScript
    BulletScene -. "si contiene ScreenWrap2D como child" .-> ScreenWrapScript
```