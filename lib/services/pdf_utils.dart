import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfUtils {
  static Future<String> savePdf(Uint8List pdfBytes, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  static Future<void> openPdf(String filePath) async {
    await OpenFile.open(filePath);
  }
}
