import 'dart:io';

import 'package:flutter/material.dart';

void main() async {
  await listd();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      body: FutureBuilder<List<Map<dynamic, dynamic>>>(
          future: listd(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text('Please wait its loading...'));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return ListView.separated(
                padding: EdgeInsets.all(10),
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemCount: snapshot.data![0].length,
                itemBuilder: (BuildContext context, int index) {
                  print(snapshot.data![0].keys);

                  /*print(snapshot
                      .data![0][snapshot.data![0].keys.elementAt(index)].values
                      .map((e) => e));*/

                  return ListTile(
                    contentPadding: EdgeInsets.all(20),
                    title: Row(
                      //crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${snapshot.data![0].keys.elementAt(index)}',
                          style: TextStyle(fontSize: 20),
                        ),
                        TextButton(
                          clipBehavior: Clip.hardEdge,
                          onPressed: () {
                            if (snapshot.data![0].keys.elementAt(index) ==
                                snapshot.data![1].keys.elementAt(index)) {
                              print(snapshot.data![1].keys.elementAt(index));
                            } else {
                              print('Not here');
                            }
                          },
                          child: Text('Apply'),
                        ),
                      ],
                    ),

                    //isThreeLine: true,
                    subtitle: Container(
                      width: 500,
                      height: 300,
                      child: ListView.separated(
                          padding: EdgeInsets.all(10),
                          //shrinkWrap: true,
                          separatorBuilder: (BuildContext context, int index) =>
                              const SizedBox(
                                width: 15,
                                height: 10,
                              ),
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot
                              .data![0][snapshot.data![0].keys.elementAt(index)]
                              .length,
                          itemBuilder: (context, index1) {
                            return Image.file(File(snapshot
                                .data![0]
                                    [snapshot.data![0].keys.elementAt(index)]
                                .values
                                .map((e) => e)
                                .elementAt(index1)));
                          }),
                    ),
                  );
                },
              );
              /*snapshot.data![snapshot.data!.keys.elementAt(index)].values.map((e) => e)
               {
               Onepunch: {{Light_album: /home/francis/GitHub_Stuff/spicetify-themes/Onepunch/screenshots/light_album.png},
               {Light_profile: /home/francis/GitHub_Stuff/spicetify-themes/Onepunch/screenshots/light_profile.png}
               }
               */
            } else
              return CircularProgressIndicator();
          }),
    );
  }
}

Future pro() async {
  // List all files in the current directory,
  // in UNIX-like operating systems.
  //ProcessResult results = await Process.run('ls', ['-l']);
  Future.delayed(Duration(seconds: 2));
  try {
    ProcessResult results =
        await Process.run('spicetify', [], runInShell: true);
    print(results.exitCode);
    print(results.stdout);
    return await results.stdout;
  } on Exception catch (e) {
    print(e);
    return 'Error';
  }
}

Future<List<Map<dynamic, dynamic>>> listd() async {
  Map te = {};
  Map theme = {};
  var dir = Directory('/home/francis/GitHub_Stuff/spicetify-themes/');
  await for (var e in dir.list(recursive: true)) {
    var folderName =
        e.parent.toString().split('/').last.replaceFirst('\'', '') !=
                'screenshots'
            ? e.parent
                .toString()
                .split(Platform.pathSeparator)
                .last
                .replaceFirst('\'', '')
            : e.parent
                .toString()
                .split(Platform.pathSeparator)
                .reversed
                .elementAt(1);

    if (e.path.contains(RegExp(r'(gif|png)'))) {
      //.replaceFirst('\'', '');
      var imgName = e.path
          .split(Platform.pathSeparator)
          .reversed
          .elementAt(0)
          .splitMapJoin(RegExp(r'^[a-z]'),
              onMatch: (m) => '${m[0]?.toUpperCase()}')
          .split('.')[0];

      Map<String, Map<String, String>> pics = {
        // folderName: Map.of({imgName: e.path})
        folderName: Map.of({imgName: e.path})
      };
      Map themes = {folderName: []};
      //print(pics.runtimeType);
      if (te.containsKey(folderName)) {
        te.update(folderName, (list) {
          //print(list.runtimeType);
          list?.addAll({imgName: e.path});
          te.putIfAbsent('Ziro', () => {'': ''});
          //print(list.runtimeType);
          return list;
        });
      } else
        te.addAll(pics);
    } else if (e.path.contains('.ini')) {
      theme.addAll({folderName: e.path});
    }
  }
  //print(te);
  print(theme.keys);
  return [te..remove('SpotifyNoControl'), theme];
}
