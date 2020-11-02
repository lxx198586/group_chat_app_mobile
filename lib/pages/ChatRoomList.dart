import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_color/random_color.dart';

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
  ChatRoomList({this.name});

  @override
  _ChatRoomListState createState() => _ChatRoomListState();
}

class _ChatRoomListState extends State<ChatRoomList> {
  final DBRef = FirebaseFirestore.instance;
  List<String> roomNameList = [];
  List<DocumentSnapshot> documents = [];
  List<Color> generatedColors = <Color>[];

  // var totalRoomsNum = 0;
  TextEditingController roomController = new TextEditingController();

  void getData() async {
    roomNameList = [];
    await DBRef.collection(widget.name).get().then((snapshot) {
      snapshot.docs.forEach((doc) {
        roomNameList.add(doc.id);
        // print('0000000000000$roomNameList');
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
              showDialog(
                context: context,
                builder: (_) => new Dialog(
                  child: SizedBox(
                    height: 150,
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
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please create room name';
                              }
                              return null;
                            },
                          ),
                        ),
                        RaisedButton(
                          onPressed: createRoom,
                          child: Text('Create Room'),
                        ),
                      ],
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
        child: Expanded(
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
                  // onTap: () {},
                  leading: Icon(
                    Icons.chat_bubble,
                    size: 30,
                    color: _color,
                  ),
                  trailing: Icon(Icons.ac_unit),
                  title: Text(
                    roomNameList[index],
                  ),
                  subtitle: Text('aaa'),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void createRoom() async {
    var uuid = Uuid();
    var timestamp = DateTime.now();
    DBRef
            // choose the top room from the home page, 1 out of 15
            .collection(widget.name)
        // create the chat room
        .doc(roomController.text)
        // create the message ID
        .collection(uuid.v1())
        // add a default first message
        .doc()
        .set({
      'message': uuid.v1(),
      'timestamp': timestamp,
      // 'identifier': identifier,
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
    print(timestamp);
  }
}
