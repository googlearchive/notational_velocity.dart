library nv.models;

import 'package:bot/bot.dart';
import 'package:meta/meta.dart';

class Note {
  final String title;
  final String content;
  final DateTime lastModified;

  Note(this.title, this.lastModified, this.content) {
    assert(title != null);
    assert(content != null);
    assert(lastModified != null);
  }

  factory Note.now(String title, String content) =>
      new Note(title, new DateTime.now(), content);

  String get key => title.toLowerCase();

  @override
  bool operator ==(other) =>
      other is Note &&
      other.title == title &&
      other.content == content &&
      other.lastModified == lastModified;

  int get hashCode => Util.getHashCode([title, content, lastModified]);

  @override
  String toString() => 'Note: $title';
}
