import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app_mobile/pages/ChatScreen.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_color/random_color.dart';
import 'dart:math' as math;

class DbListItem {
  String message;
  String timestamp;
  DbListItem({this.message, this.timestamp});
}

class DbList {
  List<DbListItem> dbList;
  DbList({this.dbList});
}

class ChatRoomList extends StatefulWidget {
  final String name;
  final String _timestamp = '';

  ChatRoomList({this.name});

  @override
  _ChatRoomListState createState() => _ChatRoomListState();
}

class _ChatRoomListState extends State<ChatRoomList> {
  final DBRef = FirebaseFirestore.instance;
  List<String> roomNameList = [];
  List<String> subtitleList = [];
  List<Color> generatedColors = <Color>[];
  String _timestamp = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // var totalRoomsNum = 0;
  TextEditingController roomController = new TextEditingController();

  Future<void> getData() async {
    roomNameList = [];
    final startAtTimestamp = Timestamp.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch - 86400000);
    print(startAtTimestamp.toDate());
    await DBRef.collection(widget.name)
        .orderBy("timestamp", descending: true).endBefore([startAtTimestamp])
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        roomNameList.add(doc.id);

        Timestamp t = doc.data()['timestamp'];
        // print(t);
        DateTime d = t.toDate();
        // print(d);
        _timestamp = d.toString();
        _timestamp = _timestamp.substring(0, 19);

        subtitleList.add(_timestamp);
        // print('0000000000000$subtitleList');
      });
    });
    setState(() {
      roomNameList = roomNameList;
    });
    // print('111111111111111$roomNameList');
  }

  @override
  void initState() {
    super.initState();
    getData();
    // print('222222222222222$roomNameList');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          FlatButton(
            onPressed: () {
              // print(roomNameList);
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: SizedBox(
                    height: 150,
                    child: new Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Room Name',
                                border: OutlineInputBorder(),
                              ),
                              controller: roomController,
                              // The validator receives the text that the user has entered.
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Please create room name';
                                } else if (roomNameList.contains(value)) {
                                  return 'Room Existed';
                                }
                                return null;
                              },
                            ),
                          ),
                          RaisedButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                return {
                                  createRoom(),
                                  getData(),
                                };
                              }
                            },
                            child: Text('Create Room'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Text('Create Room'),
          ),
        ],
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: getData,
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: roomNameList.length,
            itemBuilder: (context, index) {
              // Generate random color for the leading icon
              Color _color;
              if (generatedColors.length > index) {
                _color = generatedColors[index];
              } else {
                _color = RandomColor().randomColor();
                generatedColors.add(_color);
              }

              return ListTile(
                leading: Icon(
                  Icons.chat_bubble,
                  size: 30,
                  color: _color,
                ),
                trailing: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: Icon(
                    Icons.chat_bubble,
                    size: 30,
                    color: _color,
                  ),
                ),
                title: Text(
                  roomNameList[index],
                ),
                subtitle: Text(
                  '${subtitleList[index]} UTC',
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        roomCollection: widget.name,
                        roomDoc: roomNameList[index],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void createRoom() async {
    var uuid = Uuid();
    var timestamp = DateTime.now();
    String isAnonymous;

    FirebaseAuth.instance.currentUser.isAnonymous == true
        ? isAnonymous = 'isAnonymous'
        : isAnonymous = 'notAnonymous';

    DBRef
            // choose the top room from the home page, 1 out of 15
            .collection(widget.name)
        // create the chat room
        .doc(roomController.text)
        // create the message ID
        .collection('messages')
        // add a default first message
        .doc('first message')
        .set({
      'message': 'Chat room will last 24 hours.',
      'timestamp': timestamp,
      'isAnonymous': isAnonymous,
      'type': 0,
      'photoURL': FirebaseAuth.instance.currentUser.photoURL,
    });
    DBRef
            // choose the top room from the home page, 1 out of 15
            .collection(widget.name)
        // create the chat room
        .doc(roomController.text)
        .set({
      'timestamp': timestamp,
      // 'identifier': identifier,
    });
    Navigator.of(context).pop();
    // print(timestamp);
  }
}
