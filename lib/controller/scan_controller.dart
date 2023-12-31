import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ScanController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initCamera();
    initTFLite();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cameraController.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;

  var isCameraInitialized = false.obs;
  var cameraCount = 0.obs;

  var x = 0.0.obs;
  var y = 0.0.obs;
  var w = 0.0.obs;
  var h = 0.0.obs;
  var label = "".obs;
  var isObjectDetected = false.obs;

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.max);
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0.obs;
            objectDetection(image);
          }
          update();
        });
      });
      isCameraInitialized.value = true;
      update();
    } else {
      print('permission not granted');
    }
  }

  initTFLite() async {
    await Tflite.loadModel(
      model: "assets/models.tflite",
      labels: "assets/labels1.txt",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }

  objectDetection(CameraImage image) async {
    var detector = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((e) {
          return e.bytes;
        }).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true);

    if (detector != null && detector.isNotEmpty) {
      print("Result is $detector");
      var detectedObject = detector.first;
      label.value = detectedObject["label"];
      isObjectDetected.value = true;

      // Dummy coordinates and size
      x.value = 50.0; // Example position
      y.value = 50.0; // Example position
      w.value = 200.0; // Example width
      h.value = 200.0; // Example height
    } else {
      isObjectDetected.value = false;
    }
    update();
  }
}

