import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as FlutterMaterial;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as VectorMath64;
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';


class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  CameraScreen({required this.cameras});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    await _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Camera')),
      body: CameraPreview(_controller),
    );
  }
}









class ARScreen extends StatefulWidget {
  @override
  _ARScreenState createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  late ArCoreController arController;
  late Database database;
  bool shouldAddMustache = true;
  List<ArCoreNode> mustacheNodes = [];

  @override
  void initState() {
    super.initState();
    _initializeARController();
    _initializeDatabase();
  }


  Future<void> _initializeARController() async {
    try {
      arController = await ArCoreController(
        id: UniqueKey().hashCode,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing ArCoreController: $e");
      }
    }
  }

  Future<void> _initializeDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'session_database.db');
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              'CREATE TABLE sessions (id INTEGER PRIMARY KEY, videoPath TEXT, durationInSeconds INTEGER)');
        });
  }

  @override
  void dispose() {
    for (var node in mustacheNodes) {
      arController.removeNode(nodeName: node.name!);
    }
    arController.dispose();
    database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AR')),
      body: _buildARView(),
    );
  }


  Widget _buildARView() {
    return Column(
      children: [
        Container(
          height: 400,  // Specify the height you want for the AR view
          child: ArCoreView(
            onArCoreViewCreated: (controller) {
              arController = controller;
              if (shouldAddMustache) {
                _addMustache();
              } else {
                _startVideoRecording();
              }
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _toggleAction();
          },
          child: Text(shouldAddMustache ? 'Start Video Recording' : 'Add Mustache'),
        ),
      ],
    );
  }


  void _toggleAction() {
    setState(() {
      shouldAddMustache = !shouldAddMustache;
      if (!shouldAddMustache) {
        _removeAllMustaches();
        _startVideoRecording();
      } else {
        _addMustache();
      }
    });
  }

  void _addMustache() {
    final mustacheNode = ArCoreNode(
      shape: ArCoreCylinder(
        materials: [ArCoreMaterial(color: FlutterMaterial.Colors.brown)],
        radius: 0.05,
        height: 0.1,
      ),
      position: VectorMath64.Vector3(0, 0, -1),
    );

    arController.addArCoreNodeWithAnchor(mustacheNode);
    mustacheNodes.add(mustacheNode);
  }

  void _removeAllMustaches() {
    for (var node in mustacheNodes) {
      arController.removeNode(nodeName: node.name!);
    }
    mustacheNodes.clear();
  }

  void _startVideoRecording() {
    // Implement logic to start video recording
    // Call _saveSessionData when recording is done.
    // For simplicity, let's assume the video path and duration.
    String videoPath = '/path/to/your/video.mp4';
    int durationInSeconds = 10; // Duration in seconds
    _saveSessionData(videoPath, durationInSeconds);
  }

  Future<void> _saveSessionData(String videoPath, int durationInSeconds) async {
    await database.insert('sessions', {
      'videoPath': videoPath,
      'durationInSeconds': durationInSeconds,
    });
  }
}
