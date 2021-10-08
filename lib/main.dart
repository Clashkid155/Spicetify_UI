import 'dart:io';

import 'package:flutter/material.dart';

import 'functions/functions.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spicetify UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(seconds: 2),
        //curve: Curves.fastOutSlowIn,
        child: FutureBuilder<Map<dynamic, dynamic>>(
            future: listd(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                var sp = snapshot.data;
                return ListView.separated(
                  padding: EdgeInsets.all(10),
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemCount: sp!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      contentPadding: EdgeInsets.all(20),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${sp.keys.elementAt(index)}',
                            style: TextStyle(fontSize: 20),
                          ),
                          TextButton(
                            clipBehavior: Clip.hardEdge,
                            onPressed: () {
                              //Check for colour scheme

                              if (sp[sp.keys.elementAt(index)]['scheme']
                                  .isNotEmpty) {
                                print(
                                    sp[sp.keys.elementAt(index)]['scheme'][0]);
                                print(sp[sp.keys.elementAt(index)]);
                                exe(
                                    themename: sp.keys.elementAt(index),
                                    themesub: sp[sp.keys.elementAt(index)]
                                            ['scheme']
                                        .first,
                                    ext: sp[sp.keys.elementAt(index)]['js']
                                            .isEmpty
                                        ? ''
                                        : sp[sp.keys.elementAt(index)]['js']
                                            .first);
                              } else {
                                //exe(x: sp.keys.elementAt(index));
                                exe(
                                    themename: sp.keys.elementAt(index),
                                    ext: sp[sp.keys.elementAt(index)]['js']
                                            .isEmpty
                                        ? ''
                                        : sp[sp.keys.elementAt(index)]['js']
                                            .first);
                                print(sp[sp.keys.elementAt(index)]['js']);
                                print('Not here');
                              }
                            },
                            child: Text('Apply'),
                          ),
                        ],
                      ),
                      subtitle: sp[sp.keys.elementAt(index)]['images']
                              .isNotEmpty
                          ? Container(
                              width: 500,
                              height: 300,
                              child: ListView.separated(
                                  padding: EdgeInsets.all(10),
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const SizedBox(
                                            width: 15,
                                            height: 10,
                                          ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: sp[sp.keys.elementAt(index)]
                                          ['images']
                                      .length,
                                  //
                                  itemBuilder: (context, dex) {
                                    //print(sp['Ziro']['images'].isEmpty);
                                    // print(
                                    //     '${sp.keys.elementAt(index)}: ${sp[sp.keys.elementAt(index)]['images'][dex]}');
                                    if (sp[sp.keys.elementAt(index)]['images']
                                        .isNotEmpty) {
                                      return Image.file(File(
                                          sp[sp.keys.elementAt(index)]['images']
                                              [dex]));
                                    } else {
                                      print('Test');
                                      return Container(
                                        color: Colors.red,
                                        height: 2,
                                        child: Center(
                                            child: Text('Working on it')),
                                      );
                                    }
                                  }),
                            )
                          : Container(
                              height: 2,
                            ),
                    );
                  },
                );
              } else
                return CircularProgressIndicator();
            }),
      ),
    );
  }
}
