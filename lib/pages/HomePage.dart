import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ChatRoomList.dart';

class HomeList {
  String name;
  String imageUrl;

  HomeList({
    this.name,
    this.imageUrl,
  });
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String displayName = '';

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }

  final List<HomeList> homeList = [
    HomeList(
      imageUrl: 'assets/images/Anger.png',
      name: 'Anger',
    ),
    HomeList(
      imageUrl: 'assets/images/Contempt.png',
      name: 'Contempt',
    ),
    HomeList(
      imageUrl: 'assets/images/Disgust.png',
      name: 'Disgust',
    ),
    HomeList(
      imageUrl: 'assets/images/Fear.png',
      name: 'Fear',
    ),
    HomeList(
      imageUrl: 'assets/images/Guilt.png',
      name: 'Guilt',
    ),
    HomeList(
      imageUrl: 'assets/images/Interest.png',
      name: 'Interest',
    ),
    HomeList(
      imageUrl: 'assets/images/Jealousy.png',
      name: 'Jealousy',
    ),
    HomeList(
      imageUrl: 'assets/images/Joy.png',
      name: 'Joy',
    ),
    HomeList(
      imageUrl: 'assets/images/Loneliness.png',
      name: 'Loneliness',
    ),
    HomeList(
      imageUrl: 'assets/images/Sadness.png',
      name: 'Sadness',
    ),
    HomeList(
      imageUrl: 'assets/images/Self-Hostility.png',
      name: 'Self-Hostility',
    ),
    HomeList(
      imageUrl: 'assets/images/Shame.png',
      name: 'Shame',
    ),
    HomeList(
      imageUrl: 'assets/images/Shyness.png',
      name: 'Shyness',
    ),
    HomeList(
      imageUrl: 'assets/images/Surprise.png',
      name: 'Surprise',
    ),
    HomeList(
      imageUrl: 'assets/images/Trust.png',
      name: 'Trust',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        // print('User is currently signed out!');
        // setState(() {
        //   displayName = '';
        // });
      } else {
        // print('User is signed in!');
        (FirebaseAuth.instance.currentUser.isAnonymous == false)
            ? displayName = FirebaseAuth.instance.currentUser.displayName
            : displayName = 'Anonymous';
        setState(() {
          displayName = displayName;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _signOut();
            },
          ),
          FlatButton(
            onPressed: () {
              print('${FirebaseAuth.instance.currentUser}');
              print(displayName);
            },
            child: Icon(Icons.ac_unit),
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // childAspectRatio: 0.8,
              crossAxisCount: 3,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                HomeList homeListEach = homeList[index];
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // print(FirebaseAuth.instance.currentUser),
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoomList(
                              name: homeListEach.name,
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              child: Image(
                                height:
                                    MediaQuery.of(context).size.width * 0.3 - 3,
                                width: MediaQuery.of(context).size.width * 0.3,
                                image: AssetImage(homeListEach.imageUrl),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 15,
                            bottom: 10,
                            child: Text(
                              homeListEach.name,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              childCount: homeList.length,
            ),
          ),
        ],
      ),
    );
  }
}
