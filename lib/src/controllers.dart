library nv.controllers;

import 'dart:async';
import 'package:bot/bot.dart';
import 'package:logging/logging.dart';
import 'package:observe/observe.dart';

import 'config.dart';
import 'models.dart';
import 'shared.dart';
import 'sync.dart';

part 'controllers/app_controller.dart';

final _libLogger = new Logger('nv.controllers');

void _log(String message) => _libLogger.info(message);
