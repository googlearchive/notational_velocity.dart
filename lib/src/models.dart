library nv.models;

import 'package:bot/bot.dart';
import 'package:meta/meta.dart';

class Note {
  final String title;
  final String content;
  final DateTime lastModified;
  final DateTime created;

  Note(this.title, this.created, this.lastModified, this.content) {
    assert(created.isBefore(lastModified) || created.isAtSameMomentAs(lastModified));
    assert(title != null);
    assert(content != null);
    assert(lastModified != null);
  }

  factory Note.now(String title, String content) {
    var now = new DateTime.now();
    return new Note(title, now, now, content);
  }

  String get key => title.toLowerCase();

  @override
  bool operator ==(other) =>
      other is Note &&
      other.title == title &&
      other.content == content &&
      other.lastModified == lastModified &&
      other.created == created;

  int get hashCode => Util.getHashCode([title, content, lastModified, created]);

  @override
  String toString() => 'Note: $title';
}
