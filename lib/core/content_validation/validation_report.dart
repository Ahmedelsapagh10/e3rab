import 'package:equatable/equatable.dart';

enum ValidationSeverity { warning, error }

class ValidationIssue extends Equatable {
  const ValidationIssue({
    required this.code,
    required this.message,
    required this.path,
    this.severity = ValidationSeverity.error,
  });

  final String code;
  final String message;
  final String path;
  final ValidationSeverity severity;

  @override
  List<Object?> get props => [code, message, path, severity];
}

class ValidationReport extends Equatable {
  const ValidationReport(this.issues);

  final List<ValidationIssue> issues;

  bool get isValid =>
      issues.every((issue) => issue.severity != ValidationSeverity.error);

  List<ValidationIssue> get errors => issues
      .where((issue) => issue.severity == ValidationSeverity.error)
      .toList(growable: false);

  List<ValidationIssue> get warnings => issues
      .where((issue) => issue.severity == ValidationSeverity.warning)
      .toList(growable: false);

  @override
  List<Object?> get props => [issues];
}
