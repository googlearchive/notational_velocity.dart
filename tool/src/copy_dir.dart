library tool.copy_dir;

import "dart:io";
import 'package:path/path.dart' as pathos;

void copyDirectory(String src, String dest) {
  Directory srcDir = new Directory(src);
  for (FileSystemEntity entity in srcDir.listSync()) {
    String name = pathos.basename(entity.path);

    if (entity is File) {
      _copyFile(entity.path, dest);
    } else {
      assert(entity is Directory);
      copyDirectory( entity.path, pathos.join(dest, name));
    }
  }
}

void _copyFile(String src, String dest) {
  File srcFile = new File(src);
  File destFile = new File(pathos.join( dest, pathos.basename(src)));

  if (!destFile.existsSync() ||
      srcFile.lastModifiedSync() != destFile.lastModifiedSync()) {

    destFile.directory.createSync(recursive: true);

    destFile.writeAsBytesSync(srcFile.readAsBytesSync());
  }
}
