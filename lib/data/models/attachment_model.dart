import 'dart:convert';
import 'dart:typed_data';

enum AttachmentType { image, pdf, doc, text }

class AttachmentModel {
  final String id;
  final String name;
  final String? path;
  final Uint8List? bytes;
  final String mimeType;
  final AttachmentType fileType;
  final int size;
  final String? extractedText;

  AttachmentModel({
    required this.id,
    required this.name,
    this.path,
    this.bytes,
    required this.mimeType,
    required this.fileType,
    required this.size,
    this.extractedText,
  });

  bool get isImage => fileType == AttachmentType.image;
  bool get isDocument => fileType == AttachmentType.pdf || fileType == AttachmentType.doc || fileType == AttachmentType.text;

  String? get base64String {
    if (bytes != null && bytes!.isNotEmpty) {
      return base64Encode(bytes!);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'bytes': bytes != null ? base64Encode(bytes!) : null,
      'mimeType': mimeType,
      'fileType': fileType.name,
      'size': size,
      'extractedText': extractedText,
    };
  }

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String?,
      bytes: json['bytes'] != null ? base64Decode(json['bytes'] as String) : null,
      mimeType: json['mimeType'] as String,
      fileType: AttachmentType.values.firstWhere(
        (e) => e.name == json['fileType'],
        orElse: () => AttachmentType.text,
      ),
      size: json['size'] as int? ?? 0,
      extractedText: json['extractedText'] as String?,
    );
  }
}
