import 'package:flutter/gestures.dart'
    show PointerScrollEvent, kSecondaryMouseButton;
import 'package:flutter/material.dart' hide Matrix4;
import 'package:flutter/services.dart' show HardwareKeyboard, LogicalKeyboardKey;
import 'package:game_test/core/constants/image_path.dart';
import 'package:game_test/core/widgets/g_scaffold.dart';
import 'package:game_test/core/widgets/g_text.dart';
import 'package:game_test/features/elements/presentation/game/coffin_builder.dart';
import 'package:game_test/features/elements/presentation/game/halloween_coffin_glued_builder.dart';
import 'package:game_test/features/elements/presentation/game/halloween_coffin_pieces_builder.dart';
import 'package:game_test/features/elements/presentation/game/orbit_camera_controller.dart';
import 'package:game_test/features/horror_survival/presentation/game/materials/horror_materials.dart';
import 'package:game_test/l10n/app_localizations.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Workshop screen for building and previewing reusable game elements.
///
/// Drag or two-finger scroll to pan (left/right/up/down), two-finger drag or
/// right-drag to orbit, pinch or Ctrl/Cmd+scroll to zoom, and tap a coffin to
/// toggle its lid. Opened from [HomeShellPage] when the Elements tab is selected.
class ElementsPage extends StatefulWidget {
  const ElementsPage({super.key});

  @override
  State<ElementsPage> createState() => _ElementsPageState();
}

class _ElementsPageState extends State<ElementsPage> {
  Scene? _scene;
  CoffinProp? _coffin;
  HalloweenCoffinGlued? _gluedCoffin;
  bool _ready = false;

  final OrbitCameraController _camera = OrbitCameraController();

  Offset? _gestureStart;
  Offset? _lastFocalPoint;
  double _pinchStartDistance = 0;
  // Camera target captured when a pinch begins so anchored zoom stays stable.
  Vector3 _pinchStartTarget = Vector3.zero();
  // Latest rendered view size, needed to convert screen points to camera rays.
  Size _viewSize = Size.zero;
  // True while the secondary (right) mouse button is held — drag then orbits.
  bool _rightMouseOrbiting = false;
  Offset? _rightMouseLastPosition;
  static const double _tapSlop = 12;
  // Treat scale as "not pinching" below this so two-finger drags can pan/orbit.
  static const double _pinchScaleEpsilon = 0.01;

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

    final cutSheet = HalloweenCoffinPiecesBuilder.buildFlatCutSheet(
      material: woodMaterial,
      baseMaterial: HorrorMaterials.coffinBaseBlack(),
    );
    world.add(cutSheet.root);

    // Glue the exact same template pieces together into an assembled coffin and
    // park it next to the flat cut sheet for a side-by-side comparison.
    final gluedCoffin = HalloweenCoffinGluedBuilder.build(
      material: woodMaterial,
      baseMaterial: HorrorMaterials.coffinBaseBlack(),
    );
    world.add(gluedCoffin.root);

    scene.add(world);

    if (!mounted) return;
    setState(() {
      _scene = scene;
      _coffin = coffin;
      _gluedCoffin = gluedCoffin;
      _ready = true;
    });
  }

  void _handleTap(Offset localPosition, Size viewSize) {
    final scene = _scene;
    final coffin = _coffin;
    final gluedCoffin = _gluedCoffin;
    if (scene == null || coffin == null) return;

    final camera = _camera.buildCamera();
    final ray = camera.screenPointToRay(localPosition, viewSize);
    final hit = scene.raycast(ray);
    if (hit == null) return;

    if (coffin.containsNode(hit.node)) {
      coffin.toggle();
      setState(() {});
      return;
    }

    if (gluedCoffin != null && gluedCoffin.containsNode(hit.node)) {
      gluedCoffin.toggle();
      setState(() {});
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _gestureStart = details.localFocalPoint;
    _lastFocalPoint = details.localFocalPoint;
    _pinchStartDistance = _camera.distance;
    // Snapshot the orbit target so pinch zoom can keep the focal point anchored.
    _pinchStartTarget = _camera.target.clone();
  }

  /// Applies pan / orbit / pinch from a [GestureDetector] scale update.
  ///
  /// One finger pans so the user can freely move left/right/up/down through the
  /// workshop. Two fingers orbit (when not pinching). A real pinch (scale away
  /// from 1) zooms toward the focal point. Call this from [onScaleUpdate].
  void _onScaleUpdate(ScaleUpdateDetails details) {
    _lastFocalPoint = details.localFocalPoint;

    // Right-mouse orbit is owned by the [Listener] handlers — ignore scale
    // updates for that gesture so we do not pan and orbit at the same time.
    if (_rightMouseOrbiting) return;

    final isPinching =
        (details.scale - 1.0).abs() > _pinchScaleEpsilon;

    // A meaningful scale change means the user is pinching — zoom and skip
    // pan/orbit so the focal point stays anchored without fighting translation.
    if (isPinching) {
      _camera.zoomFromPinchAt(
        startDistance: _pinchStartDistance,
        scale: details.scale,
        startTarget: _pinchStartTarget,
        focalPoint: details.localFocalPoint,
        viewSize: _viewSize,
      );
      setState(() {});
      return;
    }

    if (details.focalPointDelta == Offset.zero) return;

    // Two-finger drag rotates around the look-at point; one-finger drag slides
    // the look-at point so the camera can travel anywhere in the scene.
    if (details.pointerCount >= 2) {
      _camera.orbit(details.focalPointDelta.dx, details.focalPointDelta.dy);
    } else {
      _camera.pan(details.focalPointDelta.dx, details.focalPointDelta.dy);
    }
    setState(() {});
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
    final gluedCoffin = _gluedCoffin!;
    final scene = _scene!;

    return GScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewSize = Size(constraints.maxWidth, constraints.maxHeight);
          // Keep the latest view size so gesture handlers can build camera rays.
          _viewSize = viewSize;

          return Listener(
            onPointerDown: (event) {
              // Right-mouse drag orbits so desktop users can still rotate while
              // left-drag pans freely around the workshop.
              if (event.buttons & kSecondaryMouseButton != 0) {
                _rightMouseOrbiting = true;
                _rightMouseLastPosition = event.localPosition;
              }
            },
            onPointerMove: (event) {
              if (!_rightMouseOrbiting || _rightMouseLastPosition == null) {
                return;
              }
              final last = _rightMouseLastPosition!;
              final delta = event.localPosition - last;
              _rightMouseLastPosition = event.localPosition;
              if (delta != Offset.zero) {
                _camera.orbit(delta.dx, delta.dy);
                setState(() {});
              }
            },
            onPointerUp: (_) {
              _rightMouseOrbiting = false;
              _rightMouseLastPosition = null;
            },
            onPointerCancel: (_) {
              _rightMouseOrbiting = false;
              _rightMouseLastPosition = null;
            },
            onPointerSignal: (event) {
              if (event is! PointerScrollEvent) return;

              // Ctrl/Cmd + scroll keeps classic mouse-wheel zoom toward the
              // pointer. Plain two-finger trackpad swipes (and mouse wheel)
              // pan so the user can freely travel left/right/up/down.
              final wantsZoom = HardwareKeyboard.instance.isLogicalKeyPressed(
                    LogicalKeyboardKey.controlLeft,
                  ) ||
                  HardwareKeyboard.instance.isLogicalKeyPressed(
                    LogicalKeyboardKey.controlRight,
                  ) ||
                  HardwareKeyboard.instance.isLogicalKeyPressed(
                    LogicalKeyboardKey.metaLeft,
                  ) ||
                  HardwareKeyboard.instance.isLogicalKeyPressed(
                    LogicalKeyboardKey.metaRight,
                  );

              if (wantsZoom) {
                _camera.zoomFromScrollAt(
                  event.scrollDelta.dy,
                  event.localPosition,
                  viewSize,
                );
              } else {
                // Invert so swiping right moves the view content right.
                _camera.pan(-event.scrollDelta.dx, -event.scrollDelta.dy);
              }
              setState(() {});
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
                  gluedCoffin.tick(dt);
                  if ((coffin.isAnimating || gluedCoffin.isAnimating) &&
                      mounted) {
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
