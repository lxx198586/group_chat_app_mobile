import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';



class DbListItem {
  String message;
  String timestamp;

  DbListItem({this.message,this.timestamp});
}



class DbList{
  List<DbListItem> dbList;

  DbList({this.dbList});
}



class ChatRoomList extends StatefulWidget {
  String name;

  ChatRoomList({this.name});

  @override
  _ChatRoomListState createState() => _ChatRoomListState();
}

class _ChatRoomListState extends State<ChatRoomList> {
  final DBRef = FirebaseDatabase.instance.reference();
  TextEditingController roomController = new TextEditingController();

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
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  child: Text("test test"),
                );
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }

  void createRoom() {
    var uuid = Uuid();
    var timestamp = DateTime.now().toString();
    DBRef
            // choose the top room from the home page, 1 out of 15
            .child(widget.name)
        // create the personal room
        .child(roomController.text)
        // create the message ID
        .child(uuid.v1())
        // add a default first message
        .set({
      'message': uuid.v1(),
      'timestamp': timestamp,
      // 'identifier': identifier,
    });
    Navigator.of(context).pop();
    print(timestamp);
  }
}
