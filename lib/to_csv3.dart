library to_csv3;

import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:universal_html/html.dart' as html;

Future myCSV({
  required List<String> headerRow,
  required List<List<String>> listOfListOfStrings,
  required String? fileName,
  bool sharing = false,
  String? fileTimeStamp,
}) async {
  debugPrint("***** Gonna Create cv");
  String givenFileName = "${fileName ?? 'item_export'}_";

  DateTime now = DateTime.now();

  String formattedDate =
      fileTimeStamp ?? DateFormat('MM-dd-yyyy-HH-mm-ss').format(now);

  List<List<String>> headerAndDataList = [];
  headerAndDataList.add(headerRow);
  for (var dataRow in listOfListOfStrings) {
    headerAndDataList.add(dataRow);
  }

  String csvData = const ListToCsvConverter().convert(headerAndDataList);

  if (kIsWeb) {
    final bytes = utf8.encode(csvData);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..download = '$givenFileName$formattedDate.csv';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.Url.revokeObjectUrl(url);
  } else if (Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isWindows ||
      Platform.isMacOS) {
    final bytes = utf8.encode(csvData);
    Uint8List bytes2 = Uint8List.fromList(bytes);
    MimeType type = MimeType.csv;
    if (sharing == true) {
      XFile xFile = XFile.fromData(bytes2);
      await Share.shareXFiles([xFile], text: 'Csv File');
    } else {
      String formattedData = DateTime.now().millisecondsSinceEpoch.toString();
      String? unknownValue = await FileSaver.instance.saveAs(
          name: '$givenFileName$formattedDate.csv',
          bytes: bytes2,
          ext: 'csv',
          mimeType: type);
      debugPrint("Unknown value $unknownValue");
    }
  }
}
