import 'package:equatable/equatable.dart';

class ContentReferenceModel extends Equatable {
  const ContentReferenceModel({
    required this.id,
    required this.title,
    required this.url,
    required this.publisher,
    required this.checkedAt,
  });

  final String id;
  final String title;
  final String url;
  final String publisher;
  final DateTime checkedAt;

  @override
  List<Object?> get props => [id, title, url, publisher, checkedAt];
}
