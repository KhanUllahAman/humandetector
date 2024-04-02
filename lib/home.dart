import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:newhumandetector/main.dart';
import 'package:tflite/tflite.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraImage? cameraImage;
  CameraController? cameraController;
  String output = '';
  
  @override
  void initState(){
    super.initState();
    loadCamera();
    loadmodal();
  }
  loadCamera(){
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraController!.initialize().then((value){
       if(!mounted){
        return;
       }else{
        setState(() {
          cameraController!.startImageStream((imageStream) { 
            cameraImage = imageStream;
            runModal();
          });
        });
       }
    });
  }
  runModal()async{
    if(cameraImage!=null){
      var predictions = await Tflite.runModelOnFrame(bytesList: cameraImage!.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: cameraImage!.height,
      imageWidth: cameraImage!.width,
      imageMean: 127.5,
      rotation: 90,
      numResults: 2,
      threshold: 0.1,
      asynch: true
      );
      predictions!.forEach((element) {
        setState(() {
          output = element['label'];
        });
      });
    }
  }
  loadmodal()async{
    await Tflite.loadModel(model: "assets/model.tflite", labels: "assets/labels.txt");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text("Live Face Detector App"),
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(20),
          child: Container(
            height: MediaQuery.of(context).size.height*0.7,
            width: MediaQuery.of(context).size.width,
            child: !cameraController!.value.isInitialized? 
            Container(): AspectRatio(aspectRatio: cameraController!.value.aspectRatio, 
            child: CameraPreview(cameraController!),
            ),
          ),
          ),
          Text(output, 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
          )
        ],
      ),
    );
  }
}