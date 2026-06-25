import 'package:flutter/gestures.dart' show PointerScrollEvent;
import 'package:flutter/material.dart' hide Matrix4;
import 'package:game_test/core/constants/image_path.dart';
import 'package:game_test/core/widgets/g_scaffold.dart';
import 'package:game_test/core/widgets/g_text.dart';
import 'package:game_test/features/elements/presentation/game/coffin_builder.dart';
import 'package:game_test/features/elements/presentation/game/orbit_camera_controller.dart';
import 'package:game_test/features/horror_survival/presentation/game/materials/horror_materials.dart';
import 'package:game_test/l10n/app_localizations.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Workshop screen for building and previewing reusable game elements.
///
/// Drag to orbit the camera, scroll or pinch to zoom, tap the coffin to
/// toggle its lid. Opened from [HomeShellPage] when the Elements tab is selected.
class ElementsPage extends StatefulWidget {
  const ElementsPage({super.key});

  @override
  State<ElementsPage> createState() => _ElementsPageState();
}

class _ElementsPageState extends State<ElementsPage> {
  Scene? _scene;
  CoffinProp? _coffin;
  bool _ready = false;

  final OrbitCameraController _camera = OrbitCameraController();

  Offset? _gestureStart;
  Offset? _lastFocalPoint;
  double _pinchStartDistance = 0;
  static const double _tapSlop = 12;

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

    final woodTexture = await gpuTextureFromAsset(ImagePath.halloweenCoffinWood);
    final woodMaterial = HorrorMaterials.coffinTextured(woodTexture);

    final coffin = CoffinBuilder.build(
      woodMaterial: woodMaterial,
      texturedWood: true,
    );
    world.add(coffin.root);

    scene.add(world);

    if (!mounted) return;
    setState(() {
      _scene = scene;
      _coffin = coffin;
      _ready = true;
    });
  }

  void _handleTap(Offset localPosition, Size viewSize) {
    final scene = _scene;
    final coffin = _coffin;
    if (scene == null || coffin == null) return;

    final camera = _camera.buildCamera();
    final ray = camera.screenPointToRay(localPosition, viewSize);
    final hit = scene.raycast(ray);
    if (hit != null && coffin.containsNode(hit.node)) {
      coffin.toggle();
      setState(() {});
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _gestureStart = details.localFocalPoint;
    _lastFocalPoint = details.localFocalPoint;
    _pinchStartDistance = _camera.distance;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    _lastFocalPoint = details.localFocalPoint;
    if (details.scale != 1.0) {
      _camera.zoomFromPinch(_pinchStartDistance, details.scale);
    }
    if (details.focalPointDelta != Offset.zero) {
      _camera.orbit(details.focalPointDelta.dx, details.focalPointDelta.dy);
    }
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
    final scene = _scene!;

    return GScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewSize = Size(constraints.maxWidth, constraints.maxHeight);

          return Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                _camera.zoomFromScroll(event.scrollDelta.dy);
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onScaleEnd: (_) {
                final start = _gestureStart;
                final end = _lastFocalPoint;
                _gestureStart = null;
                _lastFocalPoint = null;
                if (start != null &&
                    end != null &&
                    (end - start).distance <= _tapSlop) {
                  _handleTap(end, viewSize);
                }
              },
              child: SceneView(
                scene,
                cameraBuilder: (_) => _camera.buildCamera(),
                onTick: (_, dt) {
                  coffin.tick(dt);
                  if (coffin.isAnimating && mounted) {
                    setState(() {});
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
