import 'dart:io';

import 'package:doe/models/Donate.dart';
import 'package:doe/services/firebase_database_service.dart';
import 'package:doe/services/firebase_storage_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class PublishFormScreen extends StatefulWidget {
  final File image;
  final Donate donation;

  const PublishFormScreen({this.donation, this.image});

  @override
  _PublishFormScreenState createState() => _PublishFormScreenState();
}

class _PublishFormScreenState extends State<PublishFormScreen> {
  StorageUploadTask _uploadTask;

  @override
  initState(){
    super.initState();
    _publish();
  }

  _publish() async{
    
    String filePath = widget.donation.images;
    print('uploading donation image $filePath into firebase storage.');

    setState(() {
      _uploadTask =  FirebaseStorageService.getInstance().ref().child(filePath).putFile(widget.image);  
    });
    

  } 

  _submit() {
    try {
      print('saving donation in database');
       FireBaseDatabaseServiceImpl()
            .save('donations', widget.donation)
            .then((_){
             // _showAlert();
            })
            .catchError((error) => print(error));
    } catch (error) {
      print('error saving donation in database. $error.code: $error.message');
    }
  }

  _showAlert(){
    Alert(
      context: context,
      type: AlertType.error,
      title: "RFLUTTER ALERT",
      desc: "Flutter is more awesome with RFlutter Alert.",
      buttons: [
        DialogButton(
          child: Text(
            "COOL",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }
  
  @override
  Widget build(BuildContext context) {
    if(_uploadTask != null){
      return StreamBuilder<StorageTaskEvent>(
        stream: _uploadTask.events,
        builder: (context, snapshot){
          var event = snapshot?.data?.snapshot;
          double progressPercent = event != null
              ? event.bytesTransferred / event.totalByteCount : 0;
          print('Porcentage: $progressPercent');
          if(progressPercent == 1.0){
            _submit();
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).accentColor,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                value: progressPercent,
              ),
            ),
          );
        }
      );
    }else{
      return FlatButton.icon(
        onPressed: _publish, 
        icon: Icon(Icons.cloud_upload),
        label: Text('Tente novamente.'),
      );
    }
  }
}