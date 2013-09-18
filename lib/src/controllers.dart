library nv.controllers;

import 'dart:async';
import 'dart:collection';
import 'package:bot/bot.dart';
import 'package:logging/logging.dart';
import 'package:observe/observe.dart';

import 'config.dart';
import 'models.dart';
import 'shared.dart';
import 'storage.dart';
import 'sync.dart';

part 'controllers/app_controller.dart';
part 'controllers/note_view_model.dart';

final _libLogger = new Logger('nv.controllers');

void _log(String message) => _libLogger.info(message);
