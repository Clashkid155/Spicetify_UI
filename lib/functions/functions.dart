import 'dart:io';

import 'package:ini/ini.dart';
import 'package:process_run/shell.dart';

Future<Map<dynamic, dynamic>> listd() async {
  var te = {
    '': {
      'images': <String>[''],
      'js': [], // extensions
      'scheme': [] // Sub themes
    }
  };
  // print(te);
  //var themesub;
  var path = await platform();
  path = '$path${Platform.pathSeparator}Themes';
  //print(path);
  var dir = Directory(path);
  //print(File(dir.toString()).parent);
  //print(dir.toString());
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
      /* Useful
      var imgName = e.path
          .split(Platform.pathSeparator)
          .reversed
          .elementAt(0)
          .splitMapJoin(RegExp(r'^[a-z]'),
              onMatch: (m) => '${m[0]?.toUpperCase()}')
          .split('.')[0];*/

      var pics = {
        folderName: {
          'images': <String>[e.path],
          'js': [], // extensions
          'scheme': [] // Sub themes
        }
      };
      if (te.containsKey(folderName)) {
        te.putIfAbsent(
            // Just for now
            'Ziro',
            () => {
                  'images': <String>[],
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
        var tr = await File(e.path).readAsString();
        var themesub = Config.fromString(tr).sections().toList();
        print(themesub);
        te[folderName]?['scheme'] = themesub;
      }

      if (e.path.contains('.js')) {
        var extensions =
            e.path.split(Platform.pathSeparator).reversed.elementAt(0);

        if (te.containsKey(folderName)) {
          te.update(folderName, (value) {
            value['js']?.add(extensions);
            return value;
          });

          te[folderName]?['js'] = [extensions];
        }
      }
    });
  }
  te['Dribbblish']?['images']?.removeAt(0);
  return te
    ..remove('SpotifyNoControl')
    ..remove('');
}

void exe({String themename = '', String themesub = '', String ext = ''}) async {
  var deltheme;
  if (whichSync('spicetify') != null) {
    var shell = Shell();
    var currenttheme = (await Process.run('spicetify', ['config', 'extensions'],
            runInShell: true))
        .stdout;
    if (currenttheme.toString().isNotEmpty && ext.isNotEmpty) {
      deltheme =
          'spicetify config extensions ${currenttheme.trim()}-\n spicetify config extensions $ext';
      print('Main if block $deltheme');
    } else {
      deltheme = ext.isNotEmpty
          ? ext
          : currenttheme.isNotEmpty
              ? '${currenttheme.trim()}-'
              : '';
      deltheme = 'spicetify config extensions $deltheme';
      print('Else block $deltheme');
    }

    // #${currenttheme.isEmpty ? 'spicetify config extensions $deltheme' : 'spicetify config extensions ${currenttheme.trim()}-'}
    // TODO: Fix apply extension unto another
    if (themesub.isEmpty) {
      // Not needed
      await shell.run(''' spicetify config current_theme $themename
     echo $deltheme
      
      $deltheme
    spicetify apply''');
    } else {
      await shell.run(''' spicetify config current_theme $themename
      spicetify config color_scheme $themesub
    $deltheme
    spicetify apply''');
    }
  }
}

Future platform() async {
  var path;
  //print(await which('spicetify'));
  if ((await which('spicetify')) != null) {
    var temp = (await Process.run('spicetify', ['-c'], runInShell: true))
        .stdout
        .toString()
        .trim();

    path = Directory(temp).parent.path;
  }
  return path;
}
