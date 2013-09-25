library nv.tools.pages;

import 'dart:async';
import 'dart:io';
import 'package:bot_io/bot_git.dart';
import 'package:bot_io/bot_io.dart';
import 'package:hop/hop.dart';
import 'package:hop/src/hop_tasks/copy_js.dart' as copy_js;
import 'package:path/path.dart' as pathos;

const _TARGET_BRANCH = 'gh-pages';
const _SOURCE_DIR = 'build/web';

const _SCRIPT_FILES = const [];

Task makePageCrazy() => new Task.async(_makePageCrazy);

Future<bool> _makePageCrazy(TaskContext ctx) {

  return GitDir.fromExisting(pathos.current)
      .then((GitDir gd) {

        return gd.populateBranch(_TARGET_BRANCH, _populateWeb, 'Update from $_SOURCE_DIR');
      })
      .then((Commit commit){
        if(commit == null) {
          ctx.info('Nothing changed in the target directory');
        } else {
          ctx.info('Updated!');
        }
        return true;
      });
}

Future _populateWeb(TempDir dir) {
  var sourceDir = new Directory(pathos.join(pathos.current, _SOURCE_DIR));

  return _copyFiles(sourceDir, dir.path);
}

Future _copyFiles(Directory dir, String targetDirectoryPath) {
  assert(dir.existsSync());

  var fileStream = dir.list(recursive: false, followLinks: false)
      .where((FileSystemEntity fse) => fse is File);

  return AsyncStream.forEach(fileStream,
      (File file) => _copyFile(file, targetDirectoryPath))
      .then((_) {
        return copy_js.copyJs(targetDirectoryPath,
            includePackagePath: true,
            browserInterop: true, shadowDomDebug: true, browserDart: true);
      });
}

Future _copyFile(File sourceFile, String targetDirectoryPath) {

  var newFilePath = pathos.join(targetDirectoryPath, pathos.basename(sourceFile.path));

  var newFile = new File(newFilePath);
  assert(!newFile.existsSync());

  var sink = newFile.openWrite(mode: FileMode.WRITE);
  return sink.addStream(sourceFile.openRead());
}

class AsyncStream {

  static Future forEach(Stream source, Future action(Object element)) {
    var sub = new _AsyncForEachSub(source, action);
    return sub.future;
  }


}

typedef Future _DataAction<T>(T data);

class _AsyncForEachSub<T> extends _CustomSub<T> {
  final Completer _completer;
  final _DataAction<T> _dataAction;
  bool _completedWithError;

  _AsyncForEachSub(Stream<T> stream, this._dataAction) :
    _completer = new Completer(),
    super(stream);

  Future get future => _completer.future;

  void handleData(T data) {
    assert(!_completer.isCompleted);
    assert(!isPaused);
    pause(_handleData(data));
  }

  void handleDone() {
    assert(!isPaused);
    if(_completedWithError == true) {
      assert(_completer.isCompleted);
    } else {
      _completer.complete();
    }
  }

  void handleError(dynamic error) {
    assert(!isPaused);
    _completeWithError(error);
  }

  void _completeWithError(Object error) {
    assert(!_completer.isCompleted);
    _completedWithError = true;
    cancel();
    _completer.completeError(error);
  }

  Future _handleData(T data) {
    return new Future.sync(() => _dataAction(data))
      .catchError((Object error) {
        assert(isPaused);
        _completeWithError(error);
      });
  }
}

abstract class _CustomSub<T> {
  final StreamSubscription<T> _sub;

  _CustomSub(Stream<T> stream) : this._sub = stream.listen(_failOnData) {
    _sub.onData(handleData);
    _sub.onError(handleError);
    _sub.onDone(handleDone);
  }

  bool get isPaused => _sub.isPaused;

  void handleData(T data);

  void handleDone();

  void handleError(dynamic error);

  void cancel() => _sub.cancel();

  void pause([Future resumeSignal]) => _sub.pause(resumeSignal);

  static void _failOnData(data) {
    throw new UnsupportedError('should never get here');
  }
}
