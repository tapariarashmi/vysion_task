import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'display.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Task(),
    );
  }
}

class Task extends StatefulWidget {
  @override
  _TaskState createState() => _TaskState();
}

class _TaskState extends State<Task> with TickerProviderStateMixin{
  var url = Uri.parse('https://enstallapi.enpaas.com/api/ConfigSetting/ConfigSettingListOne?strKey=GetStockDemoFilesPath');
  var httpClient = HttpClient();
  String filePath ='';
  late AnimationController controller;
  bool loaded = false;

  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
      // controller.repeat(reverse:true);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> downloadstatus(String text) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(text),
      );
    }
  );
}

  Future<String> downloadFile()async{
    controller.forward();
    print('download button clicked');
    try{

    http.Response response = await http.get(url);
    print(response.statusCode);

    if(response.statusCode==200)
      {
        String data = response.body;
        print(data);
                        
        Map<String,dynamic> content = jsonDecode(data);
        String contentURL = content['strValue'].toString();
        print(contentURL);
                        
        try {
              contentURL = contentURL + '/Upload/Demo/demo_stocks.csv';
              var request = await httpClient.getUrl(Uri.parse(contentURL));
              var fileresponse = await request.close();
              if(fileresponse.statusCode == 200) {
                  var bytes = await consolidateHttpClientResponseBytes(fileresponse);
                  filePath = (await getApplicationSupportDirectory()).path;
                  filePath = filePath+'/demo.csv';
                  File file = File(filePath);
                  await file.writeAsBytes(bytes);
                  print('downloaded');
                  controller.reset();
                  downloadstatus('Downloaded!');
                }
              else{
                  controller.reset();
                  downloadstatus('Unable to download!');
                  filePath = 'Error';
              }
            }
          catch(ex){
              print(ex);
              filePath = 'Error';
              controller.reset();
              downloadstatus('Unable to download!');
            }
          
          print(filePath);
      }
      else{
        controller.reset();
        downloadstatus('Unable to download!');
      }
    }
    catch(ex){
      print(ex);
      filePath = 'Error';
      controller.reset();
      downloadstatus('Unable to download!');
    }
      return filePath;
  }

  Future<String> readFile()async{
    controller.forward();
    print('get button');
          try{
                  filePath = (await getApplicationSupportDirectory()).path;
                  filePath = filePath+'/demo.csv';
                  final csvFile = new File(filePath).openRead();
                    print(filePath);
                     var result = await csvFile
                        .transform(utf8.decoder)
                        .transform(
                          CsvToListConverter(),
                        ).toList();
                        
                        print(result);
                   
                  controller.reset();
                  loaded = true;
                  // downloadstatus('loaded file!');
          }
          catch(ex){
            loaded=false;
            print(ex);
            filePath = 'Can not fetch file';
            controller.reset();
            downloadstatus('Unable to load file!');
          }
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
          children:[
            ElevatedButton(
                  child: Text('Download CSV'),
                  onPressed:()async{
                    await downloadFile();
                  }
              
            ),
            ElevatedButton(
                child: Text('get CSV'),
                onPressed:()async{
                  await readFile();
                  if(loaded){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>DisplayFile(filePath)));
                  }
                }
            ),
            CircularProgressIndicator(
              value: controller.value,
            ),
          ]
        ),
              ),
      ),
    );
  }
}