import 'package:tmb_domain/tmb_domain.dart';

/// Сессия со всеми её сырыми событиями — единица записи и чтения истории.
final class SessionBundle {
  SessionBundle({
    required this.session,
    Iterable<RoundLog> rounds = const [],
    Iterable<ExerciseSet> sets = const [],
    Iterable<TaskAttempt> attempts = const [],
  }) : rounds = List.unmodifiable(rounds),
       sets = List.unmodifiable(sets),
       attempts = List.unmodifiable(attempts);

  final Session session;
  final List<RoundLog> rounds;
  final List<ExerciseSet> sets;
  final List<TaskAttempt> attempts;
}
