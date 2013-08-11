part of nv.debug;

class DebugVM {
  final AppController appModel;

  DebugVM(this.appModel);

  Future clear() {
    throw new UnimplementedError('DebugVM.clear is not impld');
  }

  Future populate() {

    return Future.forEach(PNP.keys, (String chapter) {
      return new Future(() {
        var note = appModel.openOrCreateNote(chapter);

        TextContent tc = note.content;

        var chapterContent = PNP[chapter];

        if(tc.value != chapterContent) {
          tc = new TextContent(chapterContent);
          appModel.updateNote(chapter, tc);
        }
      });
    });
  }
}
