import 'dart:developer';

import 'package:books_reader/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDF1 extends StatefulWidget {
  const PDF1({super.key});

  @override
  State<PDF1> createState() => _PDF1State();
}

class _PDF1State extends State<PDF1> {
  late PdfViewerController _pdfViewerController;
  late PdfTextSearchResult searchResult;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool isShowBookMark = false;
  OverlayEntry? _overlayEntry;

  void _showContextMenu(
      BuildContext context, PdfTextSelectionChangedDetails details) {
    final OverlayState overlayState = Overlay.of(context)!;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: details.globalSelectedRegion!.center.dy - 55,
        left: details.globalSelectedRegion!.bottomLeft.dx,
        child: ElevatedButton(
          child: const Text('+ Note', style: TextStyle(fontSize: 17)),
          onPressed: () {
            b1BookMarks.add({
              'page': b1LastPage.toString(),
              'text': details.selectedText,
            });
            Clipboard.setData(ClipboardData(text: details.selectedText));
            _pdfViewerController.clearSelection();
          },
        ),
      ),
    );
    overlayState.insert(_overlayEntry!);
  }

  @override
  void initState() {
    _pdfViewerController = PdfViewerController()..jumpToPage(b1LastPage);
    searchResult = PdfTextSearchResult();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Syncfusion Flutter PdfViewer'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () async {
                searchResult = await _pdfViewerController.searchText(
                  'Chapter  1',
                  b1LastPage - 1,
                  searchOption: TextSearchOption.caseSensitive,
                );

                log('Total instance count: ${searchResult.totalInstanceCount}');
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.bookmark,
                color: Colors.white,
              ),
              onPressed: () {
                isShowBookMark = !isShowBookMark;
                setState(() {});
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            SfPdfViewer.asset(
              'assets/sample.pdf',
              controller: _pdfViewerController,
              key: _pdfViewerKey,
              pageLayoutMode: PdfPageLayoutMode.single,
              onTextSelectionChanged: (details) {
                if (details.selectedText == null && _overlayEntry != null) {
                  _overlayEntry!.remove();
                  _overlayEntry = null;
                } else if (details.selectedText != null &&
                    _overlayEntry == null) {
                  _showContextMenu(context, details);
                }
              },
              onPageChanged: (details) {
                log(details.newPageNumber.toString());
                b1LastPage = details.newPageNumber;
              },
            ),
            if (isShowBookMark)
              Container(
                color: Colors.white,
                child: ListView.builder(
                  itemBuilder: ((context, index) {
                    return GestureDetector(
                      onTap: () async {
                        String bookMarkText = b1BookMarks[index]['text'];
                        String searchText =
                            bookMarkText.replaceAll(RegExp(r"\s+"), " ");

                        searchResult = await _pdfViewerController.searchText(
                          bookMarkText,
                          (int.parse(b1BookMarks[index]['page']) - 1),
                          searchOption: TextSearchOption.caseSensitive,
                        );
                        _pdfViewerController
                            .jumpToPage(int.parse(b1BookMarks[index]['page']));
                        isShowBookMark = false;
                        log('Total instance count: ${searchResult.totalInstanceCount}');

                        setState(() {});
                      },
                      child: ListTile(
                        leading: Text('Page ${b1BookMarks[index]['page']}'),
                        title: Text(
                          b1BookMarks[index]['text'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                        trailing: IconButton(
                            onPressed: () {
                              b1BookMarks.removeAt(index);
                              setState(() {});
                            },
                            icon: const Icon(Icons.delete)),
                      ),
                    );
                  }),
                  itemCount: b1BookMarks.length,
                ),
              )
          ],
        ),
      ),
    );
  }
}
