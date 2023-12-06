import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:object_detection/controller/scan_controller.dart';
class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanController>(
        init: ScanController(),
        builder: (controller) {
          return controller.isCameraInitialized.value
              ? Stack(
            children: [
              CameraPreview(controller.cameraController),
              if (controller.isObjectDetected.value)
                Center(
                  child: Container(
                    width: controller.w.value,
                    height: controller.h.value,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 3),
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        controller.label.value,
                        style: TextStyle(
                          backgroundColor: Colors.white,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          )
              : Center(child: Text("Loading Preview"));
        },
      ),
    );
  }
}
