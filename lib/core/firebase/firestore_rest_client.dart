import 'package:dio/dio.dart';

class FirestoreRestClient {
  FirestoreRestClient({
    required Dio client,
    required this.projectId,
    required this.tokenProvider,
  }) : _client = client;

  final Dio _client;
  final String projectId;
  final Future<String> Function() tokenProvider;

  String get _base =>
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  Future<void> setDocument(
    String path,
    Map<String, Object?> data, {
    List<String> serverTimestampFields = const [],
  }) async {
    final fields = Map<String, Object?>.from(data)
      ..removeWhere((key, _) => serverTimestampFields.contains(key));
    await _client.post<void>(
      '${_base.substring(0, _base.length - '/documents'.length)}/documents:commit',
      data: {
        'writes': [
          {
            'update': {
              'name': '$_base/$path',
              'fields': fields.map(
                (key, value) => MapEntry(key, _encode(value)),
              ),
            },
            if (serverTimestampFields.isNotEmpty)
              'updateTransforms': serverTimestampFields
                  .map(
                    (field) => {
                      'fieldPath': field,
                      'setToServerValue': 'REQUEST_TIME',
                    },
                  )
                  .toList(),
          },
        ],
      },
      options: await _options(),
    );
  }

  Future<Map<String, dynamic>?> getDocument(String path) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '$_base/$path',
        options: await _options(),
      );
      return _decodeFields(response.data?['fields']);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> listDocuments(String path) async {
    final response = await _client.get<Map<String, dynamic>>(
      '$_base/$path',
      queryParameters: const {'pageSize': 1000},
      options: await _options(),
    );
    final documents = response.data?['documents'] as List? ?? const [];
    return documents.map((value) {
      final document = Map<String, dynamic>.from(value as Map);
      final name = document['name'] as String;
      return {
        ..._decodeFields(document['fields']),
        '_documentId': name.split('/').last,
      };
    }).toList();
  }

  Future<void> deleteDocument(String path) async {
    try {
      await _client.delete<void>('$_base/$path', options: await _options());
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) rethrow;
    }
  }

  Future<Options> _options() async => Options(
    headers: {'Authorization': 'Bearer ${await tokenProvider()}'},
    contentType: Headers.jsonContentType,
  );

  Map<String, dynamic> _encode(Object? value) {
    if (value == null) return const {'nullValue': null};
    if (value is bool) return {'booleanValue': value};
    if (value is int) return {'integerValue': value.toString()};
    if (value is double) return {'doubleValue': value};
    if (value is String) {
      final isIsoDate = RegExp(
        r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}',
      ).hasMatch(value);
      return isIsoDate ? {'timestampValue': value} : {'stringValue': value};
    }
    if (value is List) {
      return {
        'arrayValue': {'values': value.map(_encode).toList()},
      };
    }
    if (value is Map) {
      return {
        'mapValue': {
          'fields': value.map(
            (key, item) => MapEntry(key.toString(), _encode(item)),
          ),
        },
      };
    }
    return {'stringValue': value.toString()};
  }

  Map<String, dynamic> _decodeFields(Object? source) {
    if (source is! Map) return <String, dynamic>{};
    return source.map(
      (key, value) => MapEntry(key.toString(), _decode(value as Map)),
    );
  }

  Object? _decode(Map source) {
    if (source.containsKey('nullValue')) return null;
    if (source.containsKey('stringValue')) return source['stringValue'];
    if (source.containsKey('booleanValue')) return source['booleanValue'];
    if (source.containsKey('integerValue')) {
      return int.parse(source['integerValue'].toString());
    }
    if (source.containsKey('doubleValue')) return source['doubleValue'];
    if (source.containsKey('timestampValue')) return source['timestampValue'];
    if (source['arrayValue'] case final Map array) {
      return (array['values'] as List? ?? const [])
          .map((value) => _decode(value as Map))
          .toList();
    }
    if (source['mapValue'] case final Map map) {
      return _decodeFields(map['fields']);
    }
    return null;
  }
}
