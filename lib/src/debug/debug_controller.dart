part of nv.debug;

class DebugController {
  final AppController controller;

  DebugController(this.controller);

  Future populate() {

    return Future.forEach(PNP.keys, (String chapter) {
      return new Future(() {
        var note = controller.openOrCreateNote(chapter);

        TextContent tc = note.content;

        var chapterContent = PNP[chapter];

        if(tc.value != chapterContent) {
          tc = new TextContent(chapterContent);
          controller.updateNote(chapter, tc);
        }
      });
    });
  }
}
