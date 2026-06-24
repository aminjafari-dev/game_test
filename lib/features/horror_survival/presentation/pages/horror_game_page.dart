import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_test/core/audio/audio_manager.dart';
import 'package:game_test/core/input/input_state.dart';
import 'package:game_test/core/widgets/g_scaffold.dart';
import 'package:game_test/core/widgets/g_text.dart';
import 'package:game_test/features/horror_survival/presentation/game/horror_game_loop.dart';
import 'package:game_test/features/horror_survival/presentation/game/monsters/chase_ai.dart';
import 'package:game_test/features/horror_survival/presentation/game/monsters/monster_entity.dart';
import 'package:game_test/features/horror_survival/presentation/game/player/first_person_controller.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/room_factory.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/world_builder.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/door_system.dart';
import 'package:game_test/features/horror_survival/presentation/widgets/interact_button.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/jump_scare_system.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/lighting_system.dart';
import 'package:game_test/features/horror_survival/presentation/providers/game_provider.dart';
import 'package:game_test/features/horror_survival/presentation/widgets/game_end_overlay.dart';
import 'package:game_test/features/horror_survival/presentation/widgets/game_hud.dart';
import 'package:game_test/features/horror_survival/presentation/widgets/jump_scare_overlay.dart';
import 'package:game_test/features/horror_survival/presentation/widgets/virtual_joystick.dart';
import 'package:game_test/l10n/app_localizations.dart';
import 'package:flutter_scene/scene.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart';

/// Main horror survival game screen with 3D scene and UI overlays.
class HorrorGamePage extends StatefulWidget {
  const HorrorGamePage({super.key});

  @override
  State<HorrorGamePage> createState() => _HorrorGamePageState();
}

class _HorrorGamePageState extends State<HorrorGamePage> {
  final InputState _inputState = InputState();
  final AudioManager _audioManager = AudioManager();

  Scene? _scene;
  FirstPersonController? _playerController;
  HorrorGameLoop? _gameLoop;
  bool _ready = false;
  double _totalTime = 0;
  NearbyInteractable _nearbyInteract = NearbyInteractable.none;
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  Future<void> _initGame() async {
    await Scene.initializeStaticResources();
    await _audioManager.init();

    final scene = Scene()
      ..exposure = 1.0
      ..ambientOcclusion.enabled = false
      ..postProcess.vignette.enabled = false
      ..postProcess.filmGrain.enabled = false
      ..postProcess.bloom.enabled = false
      ..directionalLight = DirectionalLight(
        direction: Vector3(-0.3, -1.0, -0.2),
        color: Vector3(1.0, 1.0, 1.0),
        intensity: 1.2,
      );

    final physicsWorld = BasicPhysicsWorld();
    scene.root.addComponent(physicsWorld);

    final lightingSystem = LightingSystem();
    final doorSystem = DoorSystem();
    final roomFactory = RoomFactory(
      lightingSystem: lightingSystem,
      doorSystem: doorSystem,
    );
    final worldBuilder = WorldBuilder(
      roomFactory: roomFactory,
      lightingSystem: lightingSystem,
    );

    final worldNode = worldBuilder.build();
    scene.add(worldNode);

    final playerController = FirstPersonController(
      physicsWorld: physicsWorld,
      inputState: _inputState,
      startPosition: BuildingLayout.playerSpawn,
    );
    scene.add(playerController.playerNode);

    final monsters = <MonsterEntity>[
      MonsterSpawner.spawn(worldNode, Vector3(12, 0, 2)),
      MonsterSpawner.spawn(worldNode, Vector3(0, 0, -10)),
    ];

    if (!mounted) return;
    final gameProvider = context.read<GameProvider>();
    final jumpScareSystem = JumpScareSystem(
      gameProvider: gameProvider,
      audioManager: _audioManager,
      playerController: playerController,
    )..registerFromRooms();

    final chaseAi = ChaseAI(
      physicsWorld: physicsWorld,
      audioManager: _audioManager,
      monsters: monsters,
    );

    final gameLoop = HorrorGameLoop(
      scene: scene,
      physicsWorld: physicsWorld,
      playerController: playerController,
      doorSystem: doorSystem,
      lightingSystem: lightingSystem,
      jumpScareSystem: jumpScareSystem,
      chaseAi: chaseAi,
      gameProvider: gameProvider,
      audioManager: _audioManager,
      monsters: monsters,
    );

    if (mounted) {
      setState(() {
        _scene = scene;
        _playerController = playerController;
        _gameLoop = gameLoop;
        _ready = true;
      });
      await _audioManager.playAmbientLoop(
        AudioPaths.ambientCorridor,
        volume: 0.35,
      );
    }
  }

  void _restartGame() {
    context.read<GameProvider>().reset();
    setState(() {
      _ready = false;
      _scene = null;
      _totalTime = 0;
      _nearbyInteract = NearbyInteractable.none;
    });
    _initGame();
  }

  void _updateKeyboardMovement() {
    var x = 0.0;
    var z = 0.0;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA)) x -= 1;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD)) x += 1;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW)) z += 1;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS)) z -= 1;
    _inputState.setKeyboardMovement(x: x, z: z);
  }

  void _onInteract() {
    _gameLoop?.handleInteract();
    showInteractFeedback(context, _gameLoop?.lastInteractResult);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
      if (event.logicalKey == LogicalKeyboardKey.keyE) {
        _onInteract();
      }
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }
    _updateKeyboardMovement();
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    _audioManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!_ready || _scene == null || _playerController == null || _gameLoop == null) {
      return GScaffold(
        body: Center(
          child: GText(l10n.loadingScene, style: GTextStyle.subtitle),
        ),
      );
    }

    return GScaffold(
      extendBodyBehindAppBar: true,
      body: Focus(
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SceneView(
              _scene!,
              cameraBuilder: (_) => _playerController!.buildCamera(),
              onTick: (elapsed, dt) {
                _totalTime = elapsed.inMicroseconds / 1e6;
                _updateKeyboardMovement();
                _gameLoop!.tick(dt, _totalTime);
                final nearby = _gameLoop!.nearbyInteract;
                if (nearby != _nearbyInteract) {
                  setState(() => _nearbyInteract = nearby);
                }
              },
            ),
            Positioned(
              left: MediaQuery.sizeOf(context).width * 0.35,
              top: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  _inputState.addLookDelta(
                    dx: details.delta.dx,
                    dy: details.delta.dy,
                  );
                },
              ),
            ),
            GameHud(nearbyInteract: _nearbyInteract),
            VirtualJoystick(inputState: _inputState),
            Positioned(
              right: 24,
              bottom: 40,
              child: InteractButton(
                nearbyInteract: _nearbyInteract,
                onPressed: _onInteract,
              ),
            ),
            const JumpScareOverlay(),
            GameEndOverlay(onRetry: _restartGame),
          ],
        ),
      ),
    );
  }
}
