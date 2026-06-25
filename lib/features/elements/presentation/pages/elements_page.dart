import 'package:flutter/material.dart' hide Matrix4;
import 'package:game_test/core/widgets/g_scaffold.dart';
import 'package:game_test/core/widgets/g_text.dart';
import 'package:game_test/features/elements/presentation/game/coffin_builder.dart';
import 'package:game_test/features/elements/presentation/widgets/coffin_control_bar.dart';
import 'package:game_test/features/horror_survival/presentation/game/materials/horror_materials.dart';
import 'package:game_test/l10n/app_localizations.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Workshop screen for building and previewing reusable game elements.
///
/// Currently previews the Halloween coffin prop with open/close controls.
/// Opened from [HomeShellPage] when the Elements tab is selected.
///
/// Example: `const ElementsPage()` inside [IndexedStack] on the home shell.
class ElementsPage extends StatefulWidget {
  const ElementsPage({super.key});

  @override
  State<ElementsPage> createState() => _ElementsPageState();
}

class _ElementsPageState extends State<ElementsPage> {
  Scene? _scene;
  CoffinProp? _coffin;
  bool _ready = false;

  static final Vector3 _cameraPosition = Vector3(2.8, 1.6, 2.8);
  static final Vector3 _cameraTarget = Vector3(0, 0.25, 0);

  @override
  void initState() {
    super.initState();
    _initPreview();
  }

  Future<void> _initPreview() async {
    await Scene.initializeStaticResources();

    final scene = Scene()
      ..exposure = 1.0
      ..toneMapping = ToneMappingMode.linear
      ..environmentIntensity = 0.0
      ..ambientOcclusion.enabled = false
      ..postProcess.vignette.enabled = false
      ..postProcess.filmGrain.enabled = false
      ..postProcess.bloom.enabled = false;

    final skySource = GradientSkySource(
      zenithColor: Vector3(0.12, 0.1, 0.14),
      horizonColor: Vector3(0.18, 0.14, 0.16),
      groundColor: Vector3(0.08, 0.06, 0.08),
      sunColor: Vector3.zero(),
    );
    scene.skybox = Skybox(skySource, intensity: 1.0);

    final world = Node(name: 'elements_world');
    world.add(
      Node(
        name: 'preview_ground',
        localTransform: Matrix4.translation(Vector3(0, -0.01, 0)),
        mesh: Mesh(
          PlaneGeometry(width: 8, depth: 8),
          HorrorMaterials.grass(),
        ),
      ),
    );

    final coffin = CoffinBuilder.build();
    coffin.root.localTransform = Matrix4.translation(Vector3(0, 0, 0));
    world.add(coffin.root);

    scene.add(world);

    if (!mounted) return;
    setState(() {
      _scene = scene;
      _coffin = coffin;
      _ready = true;
    });
  }

  PerspectiveCamera _buildCamera() {
    return PerspectiveCamera(
      position: _cameraPosition,
      target: _cameraTarget,
      up: Vector3(0, 1, 0),
      fovRadiansY: 55 * degrees2Radians,
      fovNear: 0.1,
      fovFar: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!_ready || _scene == null || _coffin == null) {
      return GScaffold(
        body: Center(
          child: GText(l10n.elementsLoadingPreview, style: GTextStyle.subtitle),
        ),
      );
    }

    final coffin = _coffin!;

    return GScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SceneView(
            _scene!,
            cameraBuilder: (_) => _buildCamera(),
            onTick: (_, dt) {
              coffin.tick(dt);
              if (mounted) {
                setState(() {});
              }
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: CoffinControlBar(
                    coffin: coffin,
                    onStateChanged: () => setState(() {}),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
