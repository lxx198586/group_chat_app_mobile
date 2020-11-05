import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final String roomCollection;
  final String roomDoc;

  ChatScreen({this.roomCollection, this.roomDoc});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textEditingController = new TextEditingController();
  File imageFile;
  String imageUrl;
  final ScrollController listScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomDoc),
      ),
      body: Scaffold(
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(widget.roomCollection)
              .doc(widget.roomDoc)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              reverse: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot item = snapshot.data.documents[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: item['isAnonymous'] == 'notAnonymous' &&
                            item['photoURL'] != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(item['photoURL']))
                        : item['isAnonymous'] == 'notAnonymous' &&
                                item['photoURL'] == null
                            ? CircleAvatar(
                                backgroundImage: AssetImage(
                                    'assets/images/female-avatar.png'))
                            : CircleAvatar(
                                child: Icon(
                                  Icons.emoji_people,
                                  color: Colors.white,
                                ),
                                backgroundColor: Colors.grey,
                              ),
                    title: Container(
                      decoration: BoxDecoration(
                        color: (item['isAnonymous'] == 'isAnonymous')
                            ? Colors.green[200]
                            : Colors.purple[200],
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                        child: item['type'] == 0
                            ? Text(
                                item['message'],
                              )
                            : Image.network(
                                item['message'],
                                fit: BoxFit.contain,
                                height: 200,
                              ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BottomAppBar(
            color: Colors.grey[300],
            shape: const CircularNotchedRectangle(),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onSubmitted: (value) {
                        onSendMessage(textEditingController.text, 0);
                      },
                    ),
                  ),
                ),
                CupertinoButton(
                  onPressed: () {
                    getImage();
                  },
                  child: Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: getImage,
                color: Colors.pink,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    imageFile = File(pickedFile.path);

    if (imageFile != null) {
      // setState(() {
      //   isLoading = true;
      // });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        // isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      // setState(() {
      //   isLoading = false;
      // });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  void onSendMessage(String content, int type) {
    String isAnonymous;

    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection(widget.roomCollection)
          .doc(widget.roomDoc)
          .collection('messages')
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseAuth.instance.currentUser.isAnonymous == true
          ? isAnonymous = 'isAnonymous'
          : isAnonymous = 'notAnonymous';

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'timestamp': DateTime.now(),
            'message': content,
            'isAnonymous': isAnonymous,
            'type': type, // 1 is image, 0 is text
            'photoURL': FirebaseAuth.instance.currentUser.photoURL,
          },
        );
      });
    }
  }
}
