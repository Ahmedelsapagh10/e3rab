import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/parsing_models.dart';
import '../parsing_bank_validator.dart';
import '../parsing_sample_mapper.dart';

abstract class LocalParsingDataSource {
  Future<List<ParsingSampleModel>> loadSamples();
}

class AssetParsingDataSource implements LocalParsingDataSource {
  AssetParsingDataSource({
    required AssetBundle bundle,
    ParsingBankValidator validator = const ParsingBankValidator(),
    this.assetPath,
    this.assetPaths,
    this.catalogAssetPath = 'assets/content/e3rab_parsing_catalog_v1.json',
  }) : _bundle = bundle,
       _validator = validator;

  final AssetBundle _bundle;
  final ParsingBankValidator _validator;
  final String? assetPath;
  final List<String>? assetPaths;
  final String catalogAssetPath;
  List<ParsingSampleModel>? _samples;

  @override
  Future<List<ParsingSampleModel>> loadSamples() async {
    if (_samples case final samples?) return samples;
    final entries = await _resolveEntries();
    final values = <ParsingSampleModel>[];
    final sampleIds = <String>{};
    final orders = <int>{};
    for (final entry in entries) {
      final decoded = jsonDecode(await _bundle.loadString(entry.assetPath));
      final bank = Map<String, dynamic>.from(decoded as Map);
      if (!_validator.isValid(bank) ||
          entry.contentVersion != bank['contentVersion']) {
        throw FormatException('Invalid E3rab parsing bank: ${entry.id}.');
      }
      final samples = (bank['samples'] as List).map(
        (value) => ParsingSampleMapper.fromJson(
          Map<String, dynamic>.from(value as Map),
        ),
      );
      for (final sample in samples) {
        if (!sampleIds.add(sample.id) ||
            !orders.add(sample.order) ||
            !entry.trackIds.contains(sample.trackId)) {
          throw FormatException('Invalid cross-bank sample: ${sample.id}.');
        }
        values.add(sample);
      }
    }
    values.sort((a, b) => a.order.compareTo(b.order));
    _samples = List.unmodifiable(values);
    return _samples!;
  }

  Future<List<_ParsingBankEntry>> _resolveEntries() async {
    final directPaths = assetPaths ?? (assetPath == null ? null : [assetPath!]);
    if (directPaths != null) {
      final entries = <_ParsingBankEntry>[];
      for (final path in directPaths) {
        final bank = Map<String, dynamic>.from(
          jsonDecode(await _bundle.loadString(path)) as Map,
        );
        final samples = (bank['samples'] as List).cast<Map<String, dynamic>>();
        entries.add(
          _ParsingBankEntry(
            id: path,
            assetPath: path,
            contentVersion: _versionFromBank(bank),
            trackIds: samples
                .map((sample) => sample['trackId'])
                .whereType<String>()
                .toSet(),
          ),
        );
      }
      return entries;
    }
    final catalog = Map<String, dynamic>.from(
      jsonDecode(await _bundle.loadString(catalogAssetPath)) as Map,
    );
    final banks = catalog['banks'];
    if (catalog['schemaVersion'] != 1 || banks is! List || banks.isEmpty) {
      throw const FormatException('Invalid E3rab parsing catalog.');
    }
    final entries = banks
        .map(
          (value) => _ParsingBankEntry.fromJson(
            Map<String, dynamic>.from(value as Map),
          ),
        )
        .toList(growable: false);
    if (entries.map((entry) => entry.id).toSet().length != entries.length) {
      throw const FormatException('Duplicate E3rab parsing bank ID.');
    }
    return entries;
  }

  String _versionFromBank(Map<String, dynamic> bank) =>
      bank['contentVersion'] as String;
}

class _ParsingBankEntry {
  const _ParsingBankEntry({
    required this.id,
    required this.assetPath,
    required this.contentVersion,
    required this.trackIds,
  });

  factory _ParsingBankEntry.fromJson(Map<String, dynamic> json) =>
      _ParsingBankEntry(
        id: json['id'] as String,
        assetPath: json['assetPath'] as String,
        contentVersion: json['contentVersion'] as String,
        trackIds: Set<String>.from(json['trackIds'] as List),
      );

  final String id;
  final String assetPath;
  final String contentVersion;
  final Set<String> trackIds;
}
