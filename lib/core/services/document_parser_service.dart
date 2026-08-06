import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../data/models/attachment_model.dart';

class DocumentParserService extends GetxService {
  /// Extract text from PDF, DOCX, or TXT attachments
  Future<String> extractText(AttachmentModel attachment) async {
    try {
      if (attachment.fileType == AttachmentType.pdf) {
        return await _extractPdfText(attachment);
      } else if (attachment.fileType == AttachmentType.text || attachment.fileType == AttachmentType.doc) {
        return await _extractPlainText(attachment);
      }
    } catch (e) {
      if (kDebugMode) print('Error parsing document: $e');
    }
    return '';
  }

  Future<String> _extractPdfText(AttachmentModel attachment) async {
    List<int>? bytes = attachment.bytes;
    if (bytes == null && attachment.path != null) {
      final file = File(attachment.path!);
      if (await file.exists()) {
        bytes = await file.readAsBytes();
      }
    }

    if (bytes == null || bytes.isEmpty) return '';

    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final PdfTextExtractor extractor = PdfTextExtractor(document);
    final String text = extractor.extractText();
    document.dispose();
    return text.trim();
  }

  Future<String> _extractPlainText(AttachmentModel attachment) async {
    if (attachment.bytes != null && attachment.bytes!.isNotEmpty) {
      return utf8.decode(attachment.bytes!, allowMalformed: true);
    } else if (attachment.path != null) {
      final file = File(attachment.path!);
      if (await file.exists()) {
        return await file.readAsString();
      }
    }
    return '';
  }
}
