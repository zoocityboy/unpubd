import 'dart:math';

import 'package:dcli/dcli.dart';
import 'package:meta/meta.dart';
import 'package:settings_yaml/settings_yaml.dart';
import 'package:yaml/yaml.dart';

import 'unpubd_paths.dart';
import 'util/log.dart';

class UnpubdSettings {
  factory UnpubdSettings() => _self!;

  ///
  factory UnpubdSettings.load({bool showWarnings = false}) {
    if (_self != null) {
      return _self!;
    }

    try {
      final settings = SettingsYaml.load(pathToSettings: pathToSettings);
      _self =
          UnpubdSettings.loadFromSettings(settings, showWarnings: showWarnings);
      return _self!;
    } on YamlException catch (e) {
      logerr(red('Failed to load rules from $pathToSettings'));
      logerr(red(e.toString()));
      rethrow;
    } on RulesException catch (e) {
      logerr(red('Failed to load rules from $pathToSettings'));
      logerr(red(e.message));
      rethrow;
    }
  }

  @visibleForTesting
  UnpubdSettings.loadFromSettings(this.settings, {required this.showWarnings});

  static UnpubdSettings? _self;

  bool showWarnings;

  late final SettingsYaml settings;


  /// Path to the batman rules.yaml file.
  static late final String pathToSettings =
      env['UPUBD_PATH'] ?? join(UnpubdPaths().pathToSettingsDir, 'unpubd.yaml');

  ///
  late final String mongoDatabase =
      settings.asString('mongo_database', defaultValue: 'unpubd');

  ///
  String get mongoUsername =>
      settings.asString('mongo_username', defaultValue: 'unpubd');

  ///
  set mongoUsername(String mongousername) =>
      settings['mongo_username'] = mongousername;

  ///
  String get mongoPassword => settings.asString('mongo_password',
      defaultValue: generateRandomString(15));
  set mongoPassword(String mongoPassword) =>
      settings['mongo_password'] = mongoPassword;

  late final String mongoRootPassword = settings.asString('mongo_root_password',
      defaultValue: generateRandomString(15));

  ///
  late final String unpubHost =
      settings.asString('unpub_host', defaultValue: '0.0.0.0');

  ///
  String get unpubPort => settings.asString('unpub_port', defaultValue: '4000');
  set unpubPort(String port) => settings['unpub_port'] = port;

  void save() => settings.save();
}

///
class RulesException implements Exception {
  ///
  RulesException(this.message);
  String message;

  @override
  String toString() => message;
}

String generateRandomString(int len) {
  final r = Random();
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}
