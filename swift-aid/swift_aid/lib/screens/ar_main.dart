import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARMainScreen extends StatefulWidget {
  const ARMainScreen({super.key});
  @override
  State<ARMainScreen> createState() => _ARMainScreenState();
}

class _ARMainScreenState extends State<ARMainScreen> {
  late ARSessionManager _arSessionManager;
  late ARObjectManager _arObjectManager;
  late ARAnchorManager _arAnchorManager;
  late ARLocationManager _arLocationManager;

  ARNode? _localObject;

  void onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;
    _arAnchorManager = arAnchorManager;
    _arLocationManager = arLocationManager;

    _arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: true,
      handleTaps: false,
    );
    _arObjectManager.onInitialize();
  }

  Future<void> _addObject() async {
    final node = ARNode(
      type: NodeType.localGLTF2,
      uri: 'assets/cube.glb',
      scale: vector.Vector3(0.5, 0.5, 0.5),
      position: vector.Vector3(0.0, 0.0, -1.0),
    );

    bool? didAdd = await _arObjectManager.addNode(node);
    if (didAdd == true) {
      _localObject = node;
    }
  }

  @override
  void dispose() {
    _arSessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Scene')),
      body: Stack(
        children: [
          ARView(onARViewCreated: onARViewCreated),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _addObject,
              child: const Text('Place 3D Object'),
            ),
          ),
        ],
      ),
    );
  }
}
