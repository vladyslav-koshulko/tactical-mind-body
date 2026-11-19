/// Чистый Dart-домен: модели, генераторы задач, индекс. Без Flutter.
library;

export 'src/cognitive/answer_matching.dart';
export 'src/cognitive/pack_task_provider.dart';
export 'src/cognitive/self_rating.dart';
export 'src/cognitive/task_provider.dart';
export 'src/common/enums.dart';
export 'src/common/json_reader.dart'
    show
        JsonConv,
        JsonObj,
        convBool,
        convInt,
        convNum,
        convObject,
        convString,
        convText,
        enumOf,
        expectKind,
        listOf,
        readRoot;
export 'src/common/text.dart' show nfc, normalizeNewlines, normalizeText;
export 'src/common/wire_enum.dart';
export 'src/content/accept.dart';
export 'src/content/cognitive_task.dart';
export 'src/content/cue.dart';
export 'src/content/spatial_types.dart';
export 'src/content/task_archetype.dart';
export 'src/content/task_category.dart';
export 'src/content/task_pack.dart';
export 'src/determinism/canonical_json.dart';
export 'src/determinism/cue_moments.dart';
export 'src/determinism/mulberry32.dart';
export 'src/determinism/payload_hash.dart';
export 'src/events/attempt_status.dart';
export 'src/events/events_export.dart';
export 'src/events/exercise_set.dart';
export 'src/events/round_log.dart';
export 'src/events/session.dart';
export 'src/events/task_attempt.dart';
export 'src/exercises/exercise.dart';
export 'src/exercises/exercise_pack.dart';
export 'src/profile/category_filter.dart';
export 'src/profile/profile_settings.dart';
export 'src/profile/targets.dart';
export 'src/session/session_block.dart';
export 'src/session/session_template.dart';
export 'src/validation/validation_api.dart';
