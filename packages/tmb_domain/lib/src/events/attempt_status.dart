import '../common/wire_enum.dart';

/// Чем закончилась когнитивная попытка (SCHEMAS §3.4).
enum AttemptStatus implements WireEnum {
  answered('answered'),
  timeout('timeout'),
  skipped('skipped');

  const AttemptStatus(this.wire);
  @override
  final String wire;
}
