import 'dart:io';

import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:process_run/which.dart';

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
      body: FutureBuilder<Map<dynamic, dynamic>>(
          future: listd(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text('Please wait its loading...'));
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
                  // print(sp[0].keys);

                  /*print(snapshot
                      .data![0][sp![0].keys.elementAt(index)].values
                      .map((e) => e));*/

                  return ListTile(
                    contentPadding: EdgeInsets.all(20),
                    title: Row(
                      //crossAxisAlignment: CrossAxisAlignment.end,
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
                            //sp.containsKey(sp.keys.elementAt(index))
                            if (sp[sp.keys.elementAt(index)]['scheme']
                                .isNotEmpty) {
                              print(sp[sp.keys.elementAt(index)]['scheme'][0]);
                              print(sp[sp.keys.elementAt(index)]);
                              exe(
                                  themename: sp.keys.elementAt(index),
                                  themesub: sp[sp.keys.elementAt(index)]
                                          ['scheme']
                                      .first,
                                  ext:
                                      sp[sp.keys.elementAt(index)]['js'].isEmpty
                                          ? ''
                                          : sp[sp.keys.elementAt(index)]['js']
                                              .first);
                            } else {
                              //exe(x: sp.keys.elementAt(index));
                              exe(
                                  themename: sp.keys.elementAt(index),
                                  ext:
                                      sp[sp.keys.elementAt(index)]['js'].isEmpty
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
                          itemCount:
                              sp[sp.keys.elementAt(index)]['images'].length,
                          itemBuilder: (context, index1) {
                            return Image.file(File(sp[sp.keys.elementAt(index)]
                                ['images'][index1]));
                          }),
                    ),
                  );
                },
              );
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

Future<Map<dynamic, dynamic>> listd() async {
  var te = {
    '': {
      'images': <String>[''],
      'js': [], // extensions
      'scheme': [] // Sub themes
    }
  };
  // print(te);
  var themesub;
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

      var pics = {
        folderName: {
          'images': <String>[e.path],
          'js': [], // extensions
          'scheme': [] // Sub themes
        }
      };
      //print(pics);
      //print(te['Turntable']);
      if (te.containsKey(folderName)) {
        // print(te[folderName]['images']);
        te.putIfAbsent(
            'Ziro',
            () => {
                  'images': <String>[e.path],
                  'js': [], // extensions
                  'scheme': [] // Sub themes
                });
        te[folderName]!['images']!.add(e.path);
      } else
        te.addAll(pics);
    }
    // Wait for completion first. 2s makes a difference
    Future.delayed(Duration(seconds: 2), () async {
      // Parse the config.ini to get sub theme
      if (e.path.contains(RegExp(r'(.ini)'))) {
        themesub = await File(e.path).readAsString().then((value) {
          // get text between braces [HI]=> HI
          var reg = RegExp(r'(?<=\[).+?(?=\])');
          var x = reg.allMatches(value).map((e) => e[0]);
          return x.toList();
        });
        //print(te['Fluent']);
        //print(themesub);
        te[folderName]?['scheme'] = themesub;
        /*var extensions = e.path.endsWith('.js')
          ? e.path.split(Platform.pathSeparator).reversed.elementAt(0)
          : '';
      //print(extensions);
      theme.addAll({
        folderName: Map.of({themesub: extensions})
      });*/

      }
      //print('Ran');
      //print(e.path);
      if (e.path.contains('.js')) {
        var extensions =
            e.path.split(Platform.pathSeparator).reversed.elementAt(0);
        //theme.update(folderName, (value) => 'hi');
        //theme[folderName]?[themesub] = extensions;

        //print('$folderName:$extensions');
        if (te.containsKey(folderName)) {
          te.update(folderName, (value) {
            //print(value['js']);
            value['js']?.add(extensions);
            return value;
          });
          //print(folderName);
          te[folderName]?['js'] = [extensions];
          //print(te['Turntable']?['js']);
          //print('$folderName : $extensions');
          //print(te[folderName]?['js']);

          //print(theme[folderName]);
        }
      }
    });
  }
  //print(te['Turntable']);
  return te
    ..remove('SpotifyNoControl')
    ..remove('');
}

/*return Scaffold(
      body: FutureBuilder<List<Map<dynamic, dynamic>>>(
          future: listd(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text('Please wait its loading...'));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              var sp = snapshot.data;
              return ListView.separated(
                padding: EdgeInsets.all(10),
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemCount: sp![0].length,
                itemBuilder: (BuildContext context, int index) {
                  // print(sp[0].keys);

                  /*print(snapshot
                      .data![0][sp![0].keys.elementAt(index)].values
                      .map((e) => e));*/

                  return ListTile(
                    contentPadding: EdgeInsets.all(20),
                    title: Row(
                      //crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${sp[0].keys.elementAt(index)}',
                          style: TextStyle(fontSize: 20),
                        ),
                        TextButton(
                          clipBehavior: Clip.hardEdge,
                          onPressed: () {
                            //Check for colour scheme
                            if (sp[1]
                                .containsKey(sp[0].keys.elementAt(index))) {
                              //
                              print(sp[1][sp[0].keys.elementAt(index)]
                                  .keys
                                  .first);
                              /*exe(
                                  themename: sp[0].keys.elementAt(index),
                                  themesub: sp[1][sp[0].keys.elementAt(index)]
                                      [0]);*/

                              // exe(sp[1][sp[0].keys.elementAt(index)]);
                            } else {
                              exe(x: sp[0].keys.elementAt(index));
                              print(sp[0].keys.elementAt(index));
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
                              .data![0][sp[0].keys.elementAt(index)].length,
                          itemBuilder: (context, index1) {
                            return Image.file(File(snapshot
                                .data![0][sp[0].keys.elementAt(index)].values
                                .map((e) => e)
                                .elementAt(index1)));
                          }),
                    ),
                  );
                },
              );
            } else
              return CircularProgressIndicator();
          }),
    );
  }
}*/

/*var pics = {
        folderName: {
          'images': <String>[e.path],
          'js': [], // extensions
          'scheme': [] // Sub themes
        }
      };
      print(pics);
      if (te.containsKey(folderName)) {
        // print(te[folderName]['images']);
        te[folderName]['images'].add(e.path);*/
void exe({String themename = '', String themesub = '', String ext = ''}) async {
  /* try {
    ProcessResult results = await Process.run(
        'spicetify', ['config', 'extensions'],
        runInShell: true);
    print(results.exitCode);
    print(results.stdout);
    await results.stdout;
  } on Exception catch (e) {
    print(e);
    //return 'Error';
  }*/
  print(themesub);
  print(themename);
  print(ext);

  if (whichSync('spicetify') != null) {
    var shell = Shell();
    var currenttheme = (await Process.run('spicetify', ['config', 'extensions'],
            runInShell: true))
        .stdout;
    // print(currenttheme);
    var deltheme = ext.isNotEmpty
        ? ext
        : currenttheme.isNotEmpty
            ? '${currenttheme.trim()}-'
            : '';
    // print(deltheme);
    // TODO: Fix apply extension unto another
    if (themesub.isEmpty) {
      var b = await shell.run(''' spicetify config current_theme $themename
     echo $deltheme
      
      ${currenttheme.isEmpty ? 'spicetify config extensions $deltheme' : 'spicetify config extensions ${currenttheme.trim()}-'}
    spicetify apply''');
    } else {
      await shell.run(''' spicetify config current_theme $themename
      spicetify config color_scheme $themesub
    ${currenttheme.isEmpty ? 'spicetify config extensions $deltheme' : 'spicetify config extensions ${currenttheme.trim()}-'}
    spicetify apply''');
    }
  }
}

/*

Future<List<Map<dynamic, dynamic>>> listd() async {
  Map te = {};
  Map theme = {};
  var themesub;
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
        folderName: Map.of({imgName: e.path})
      };
      //Map themes = {folderName: []};

      if (te.containsKey(folderName)) {
        te.update(folderName, (list) {
          list?.addAll({imgName: e.path});
          te.putIfAbsent('Ziro', () => {'': ''});
          //print(list.runtimeType);
          return list;
        });
      } else
        te.addAll(pics);
    } else if (e.path.contains(RegExp(r'(.ini)'))) {
      themesub = await File(e.path).readAsString().then((value) {
        // get text between braces [HI]=> HI
        var reg = RegExp(r'(?<=\[).+?(?=\])');
        var x = reg.allMatches(value).map((e) => e[0]);
        return x.toList();
      });
      var extensions = e.path.endsWith('.js')
          ? e.path.split(Platform.pathSeparator).reversed.elementAt(0)
          : '';
      //print(extensions);
      theme.addAll({
        folderName: Map.of({themesub: extensions})
      });
      //theme.update(key, (value) => null)
      //print(theme);

    } else if (e.path.contains('.js')) {
      var extensions =
          e.path.split(Platform.pathSeparator).reversed.elementAt(0);
      //theme.update(folderName, (value) => 'hi');
      theme[folderName]?[themesub] = extensions;
      print(theme[folderName]);
    }
  }
  print(theme);
  return [te..remove('SpotifyNoControl'), theme];
}

 */
