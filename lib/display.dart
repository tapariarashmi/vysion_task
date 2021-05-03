import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:csv/csv.dart';



class DisplayFile extends StatelessWidget {
  
  final String path;
  DisplayFile(this.path);
  

  Future<List<List<dynamic>>> loadingCsvData(String filePath) async{
     final csvFile = new File(filePath).openRead();
                    print(filePath);
                     var result = await csvFile
                        .transform(utf8.decoder)
                        .transform(
                          CsvToListConverter(),
                        ).toList();
                        
                        print(result);
      return result;
  }
  dynamic snapData(var snapData){
    if(snapData!=null)
    return snapData;
    else
    return '';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CSV Data'),
      ),
        body: FutureBuilder(
        future: loadingCsvData(path),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          print(snapshot.data.toString());
          return snapshot.hasData
              ? Center(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(snapshot.data.toString())
                  ),
              )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
      
    );
  }
}