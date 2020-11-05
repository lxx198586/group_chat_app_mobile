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
      imageUrl: 'assets/images/games.png',
      name: 'Games',
    ),
    HomeList(
      imageUrl: 'assets/images/store.png',
      name: 'Store',
    ),
    HomeList(
      imageUrl: 'assets/images/news.png',
      name: 'News',
    ),
    HomeList(
      imageUrl: 'assets/images/stock.png',
      name: 'Stock',
    ),
    HomeList(
      imageUrl: 'assets/images/skype.png',
      name: 'Skype',
    ),
    HomeList(
      imageUrl: 'assets/images/games.png',
      name: 'Games',
    ),
    HomeList(
      imageUrl: 'assets/images/store.png',
      name: 'Store',
    ),
    HomeList(
      imageUrl: 'assets/images/news.png',
      name: 'News',
    ),
    HomeList(
      imageUrl: 'assets/images/stock.png',
      name: 'Stock',
    ),
    HomeList(
      imageUrl: 'assets/images/skype.png',
      name: 'Skype',
    ),
    HomeList(
      imageUrl: 'assets/images/games.png',
      name: 'Games',
    ),
    HomeList(
      imageUrl: 'assets/images/store.png',
      name: 'Store',
    ),
    HomeList(
      imageUrl: 'assets/images/news.png',
      name: 'News',
    ),
    HomeList(
      imageUrl: 'assets/images/stock.png',
      name: 'Stock',
    ),
    HomeList(
      imageUrl: 'assets/images/skype.png',
      name: 'Skype',
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
