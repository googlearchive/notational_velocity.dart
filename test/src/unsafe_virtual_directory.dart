library test.nv.unsafe_virtual_directory;

import 'dart:async';
import 'dart:io';

import 'package:mime/mime.dart';
import "package:path/path.dart";
import "package:http_server/http_server.dart";

class UnsafeVirtualDirectory implements VirtualDirectory {
  final String root;

  bool allowDirectoryListing = false;
  bool followLinks = true;

  final RegExp _invalidPathRegExp = new RegExp("[\\\/\x00]");

  Function _errorCallback;
  Function _dirCallback;

  UnsafeVirtualDirectory(this.root);

  void serve(Stream<HttpRequest> requests) {
    requests.listen(serveRequest);
  }

  void serveRequest(HttpRequest request) {
    _locateResource('.', request.uri.pathSegments.iterator..moveNext())
        .then((entity) {
          if (entity == null) {
            _serveErrorPage(HttpStatus.NOT_FOUND, request);
            return;
          }
          if (entity is File) {
            _serveFile(entity, request);
          } else if (entity is Directory) {
            _serveDirectory(entity, request);
          } else {
            _serveErrorPage(HttpStatus.NOT_FOUND, request);
          }
        });
  }

  void setDirectoryHandler(void callback(Directory dir, HttpRequest request)) {
    _dirCallback = callback;
  }

  void setErrorPageHandler(void callback(HttpRequest request)) {
    _errorCallback = callback;
  }

  Future<FileSystemEntity> _locateResource(String path,
                                           Iterator<String> segments) {
    path = normalize(path);
    var fullPath = join(root, path);
    return FileSystemEntity.type(fullPath, followLinks: false)
        .then((type) {
          switch (type) {
            case FileSystemEntityType.FILE:
              if (segments.current == null) {
                return new File(fullPath);
              }
              break;

            case FileSystemEntityType.DIRECTORY:
              if (segments.current == null) {
                if (allowDirectoryListing) {
                  return new Directory(fullPath);
                }
              } else {
                if (_invalidPathRegExp.hasMatch(segments.current)) break;
                return _locateResource(join(path, segments.current),
                                       segments..moveNext());
              }
              break;

            case FileSystemEntityType.LINK:
              if (followLinks) {
                return new Link(fullPath).target()
                    .then((target) {
                      String targetPath = normalize(target);
                      if (isAbsolute(targetPath)) {
                        targetPath = relative(targetPath, from: root);
                      } else {
                        targetPath = join(dirname(path), targetPath);
                      }
                      return _locateResource(targetPath, segments);
                    });
              }
              break;
          }
          // Return `null` on fall-through, to indicate NOT_FOUND.
          return null;
        });
  }

  void _serveFile(File file, HttpRequest request) {
    var response = request.response;
    // TODO(ajohnsen): Set up Zone support for these errors.
    file.lastModified().then((lastModified) {
      if (request.headers.ifModifiedSince != null &&
          !lastModified.isAfter(request.headers.ifModifiedSince)) {
        response.statusCode = HttpStatus.NOT_MODIFIED;
        response.close();
        return;
      }

      response.headers.set(HttpHeaders.LAST_MODIFIED, lastModified);
      response.headers.set(HttpHeaders.ACCEPT_RANGES, "bytes");

      if (request.method == 'HEAD') {
        response.close();
        return;
      }

      return file.length().then((length) {
        String range = request.headers.value("range");
        if (range != null) {
          // We only support one range, where the standard support several.
          Match matches = new RegExp(r"^bytes=(\d*)\-(\d*)$").firstMatch(range);
          // If the range header have the right format, handle it.
          if (matches != null) {
            // Serve sub-range.
            int start;
            int end;
            if (matches[1].isEmpty) {
              start = matches[2].isEmpty ?
                  length :
                  length - int.parse(matches[2]);
              end = length;
            } else {
              start = int.parse(matches[1]);
              end = matches[2].isEmpty ? length : int.parse(matches[2]) + 1;
            }

            // Override Content-Length with the actual bytes sent.
            response.headers.set(HttpHeaders.CONTENT_LENGTH, end - start);

            // Set 'Partial Content' status code.
            response.statusCode = HttpStatus.PARTIAL_CONTENT;
            response.headers.set(HttpHeaders.CONTENT_RANGE,
                                 "bytes $start-${end - 1}/$length");

            // Pipe the 'range' of the file.
            file.openRead(start, end)
                .pipe(new _VirtualDirectoryFileStream(response, file.path))
                .catchError((_) {});
            return;
          }
        }

        file.openRead()
            .pipe(new _VirtualDirectoryFileStream(response, file.path))
            .catchError((_) {});
      });
    }).catchError((_) {
      response.close();
    });
  }

  void _serveDirectory(Directory dir, HttpRequest request) {
    if (_dirCallback != null) {
      _dirCallback(dir, request);
      return;
    }
    var response = request.response;
    dir.stat().then((stats) {
      if (request.headers.ifModifiedSince != null &&
          !stats.modified.isAfter(request.headers.ifModifiedSince)) {
        response.statusCode = HttpStatus.NOT_MODIFIED;
        response.close();
        return;
      }

      response.headers.set(HttpHeaders.LAST_MODIFIED, stats.modified);
      var path = request.uri.path;
      var header =
'''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Index of $path</title>
</head>
<body>
<h1>Index of $path</h1>
<table>
  <tr>
    <td>Name</td>
    <td>Last modified</td>
    <td>Size</td>
  </tr>
''';
      var server = response.headers.value(HttpHeaders.SERVER);
      if (server == null) server = "";
      var footer =
'''</table>
$server
</body>
</html>
''';

      response.write(header);

      void add(String name, String modified, var size) {
        if (size == null) size = "-";
        if (modified == null) modified = "";
        var p = normalize(join(path, name));
        var entry =
'''  <tr>
    <td><a href="$p">$name</a></td>
    <td>$modified</td>
    <td style="text-align: right">$size</td>
  </tr>''';
        response.write(entry);
      }

      if (path != '/') {
        add('../', null, null);
      }

      dir.list(followLinks: true).listen((entity) {
        // TODO(ajohnsen): Consider async dir listing.
        if (entity is File) {
          var stat = entity.statSync();
          add(basename(entity.path),
              stat.modified.toString(),
              stat.size);
        } else if (entity is Directory) {
          add(basename(entity.path) + '/',
              entity.statSync().modified.toString(),
              null);
        }
      }, onError: (e) {
      }, onDone: () {
        response.write(footer);
        response.close();
      });
    }, onError: (e) => response.close());
  }

  void _serveErrorPage(int error, HttpRequest request) {
    var response = request.response;
    response.statusCode = error;
    if (_errorCallback != null) {
      _errorCallback(request);
      return;
    }
    // Default error page.
    var path = request.uri.path;
    var reason = response.reasonPhrase;

    var server = response.headers.value(HttpHeaders.SERVER);
    if (server == null) server = "";
    var page =
'''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>$reason: $path</title>
</head>
<body>
<h1>Error $error at \'$path\': $reason</h1>
$server
</body>
</html>''';
    response.write(page);
    response.close();
  }
}


class _VirtualDirectoryFileStream extends StreamConsumer<List<int>> {
  final HttpResponse response;
  final String path;
  var buffer = [];

  _VirtualDirectoryFileStream(HttpResponse this.response, String this.path);

  Future addStream(Stream<List<int>> stream) {
    stream.listen(
        (data) {
          if (buffer == null) {
            response.add(data);
            return;
          }
          if (buffer.length == 0) {
            if (data.length >= defaultMagicNumbersMaxLength) {
              setMimeType(data);
              response.add(data);
              buffer = null;
            } else {
              buffer.addAll(data);
            }
          } else {
            buffer.addAll(data);
            if (buffer.length >= defaultMagicNumbersMaxLength) {
              setMimeType(buffer);
              response.add(buffer);
              buffer = null;
            }
          }
        },
        onDone: () {
          if (buffer != null) {
            if (buffer.length == 0) {
              setMimeType(null);
            } else {
              setMimeType(buffer);
              response.add(buffer);
            }
          }
          response.close();
        },
        onError: response.addError);
    return response.done;
  }

  Future close() => new Future.value();

  void setMimeType(var bytes) {
    var mimeType = lookupMimeType(path, headerBytes: bytes);
    if (mimeType != null) {
      response.headers.contentType = ContentType.parse(mimeType);
    }
  }
}
