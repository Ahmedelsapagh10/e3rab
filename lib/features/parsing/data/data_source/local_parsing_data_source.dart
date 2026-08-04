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
    this.assetPath = 'assets/content/e3rab_parsing_bank_v1.json',
  }) : _bundle = bundle,
       _validator = validator;

  final AssetBundle _bundle;
  final ParsingBankValidator _validator;
  final String assetPath;
  List<ParsingSampleModel>? _samples;

  @override
  Future<List<ParsingSampleModel>> loadSamples() async {
    if (_samples case final samples?) return samples;
    final decoded = jsonDecode(await _bundle.loadString(assetPath));
    final bank = Map<String, dynamic>.from(decoded as Map);
    if (!_validator.isValid(bank)) {
      throw const FormatException('Invalid E3rab parsing bank.');
    }
    final values = (bank['samples'] as List)
        .map(
          (value) => ParsingSampleMapper.fromJson(
            Map<String, dynamic>.from(value as Map),
          ),
        )
        .toList(growable: false);
    _samples = values;
    return values;
  }
}
