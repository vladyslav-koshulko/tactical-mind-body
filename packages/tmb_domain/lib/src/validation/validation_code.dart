import 'severity.dart';

/// Стабильные коды правил валидации — SCHEMAS §6, по одному значению на правило.
///
/// Код (`PACK_…`, `EX_…`, `EVT_…`, `PROF_…`) не переименовывается: на него
/// ссылаются тесты, UI предпросмотра импорта и сервер. Порядок и номера
/// совпадают с таблицами §6; тест сверяет перечисление с документом.
enum ValidationCode {
  // --- 6.1 Общие ---
  packNotJson(1, 'PACK_NOT_JSON', Severity.error),
  packTooLarge(2, 'PACK_TOO_LARGE', Severity.error),
  packTooDeep(3, 'PACK_TOO_DEEP', Severity.error),
  packSchemaVersion(4, 'PACK_SCHEMA_VERSION', Severity.error),
  packSchemaUnsupported(5, 'PACK_SCHEMA_UNSUPPORTED', Severity.error),
  packBadKind(6, 'PACK_BAD_KIND', Severity.error),
  packMissingField(7, 'PACK_MISSING_FIELD', Severity.error),
  packBadType(8, 'PACK_BAD_TYPE', Severity.error),
  packUnknownField(9, 'PACK_UNKNOWN_FIELD', Severity.warning),
  packFieldNotAllowed(10, 'PACK_FIELD_NOT_ALLOWED', Severity.warning),
  packReservedField(11, 'PACK_RESERVED_FIELD', Severity.warning),
  packBadId(12, 'PACK_BAD_ID', Severity.error),
  packDupId(13, 'PACK_DUP_ID', Severity.error),
  packBadFormat(14, 'PACK_BAD_FORMAT', Severity.error),
  packBadEnum(15, 'PACK_BAD_ENUM', Severity.error),
  packLocaleMismatch(16, 'PACK_LOCALE_MISMATCH', Severity.error),
  packSourceOverridden(17, 'PACK_SOURCE_OVERRIDDEN', Severity.warning),
  packStringEmpty(18, 'PACK_STRING_EMPTY', Severity.error),
  packStringTooLong(19, 'PACK_STRING_TOO_LONG', Severity.error),
  packBadChars(20, 'PACK_BAD_CHARS', Severity.error),
  packMarkup(21, 'PACK_MARKUP', Severity.error),
  packUrlInText(22, 'PACK_URL_IN_TEXT', Severity.warning),
  packNumberRange(23, 'PACK_NUMBER_RANGE', Severity.error),
  packLimitItems(24, 'PACK_LIMIT_ITEMS', Severity.error),
  packLimitArray(25, 'PACK_LIMIT_ARRAY', Severity.error),

  // --- 6.2 Пак задач ---
  packBadDomain(26, 'PACK_BAD_DOMAIN', Severity.error),
  packDupCategory(27, 'PACK_DUP_CATEGORY', Severity.error),
  packUndeclaredDomain(28, 'PACK_UNDECLARED_DOMAIN', Severity.error),
  packEmptyCategory(29, 'PACK_EMPTY_CATEGORY', Severity.warning),
  packBadArchetype(30, 'PACK_BAD_ARCHETYPE', Severity.error),
  packVerbalVerifiable(31, 'PACK_VERBAL_VERIFIABLE', Severity.error),
  packNonverbalUnverifiable(32, 'PACK_NONVERBAL_UNVERIFIABLE', Severity.error),
  packNoSelfcheck(33, 'PACK_NO_SELFCHECK', Severity.error),
  packSelfcheckCount(34, 'PACK_SELFCHECK_COUNT', Severity.error),
  packBadDifficulty(35, 'PACK_BAD_DIFFICULTY', Severity.error),
  packBadTime(36, 'PACK_BAD_TIME', Severity.error),
  packTimeLong(37, 'PACK_TIME_LONG', Severity.warning),
  packDupPrompt(38, 'PACK_DUP_PROMPT', Severity.error),
  packChoiceOptions(39, 'PACK_CHOICE_OPTIONS', Severity.error),
  packChoiceAnswerRange(40, 'PACK_CHOICE_ANSWER_RANGE', Severity.error),
  packAcceptInvalid(41, 'PACK_ACCEPT_INVALID', Severity.error),
  packAnswerNotAccepted(42, 'PACK_ANSWER_NOT_ACCEPTED', Severity.error),
  packOrderingSize(43, 'PACK_ORDERING_SIZE', Severity.error),
  packOrderingDup(44, 'PACK_ORDERING_DUP', Severity.error),
  packCueRange(45, 'PACK_CUE_RANGE', Severity.error),
  packCueOrder(46, 'PACK_CUE_ORDER', Severity.error),
  packCueLate(47, 'PACK_CUE_LATE', Severity.warning),
  packSpatialBounds(48, 'PACK_SPATIAL_BOUNDS', Severity.error),
  packSpatialOverlap(49, 'PACK_SPATIAL_OVERLAP', Severity.error),
  packStreamTargets(50, 'PACK_STREAM_TARGETS', Severity.error),
  packParamRange(51, 'PACK_PARAM_RANGE', Severity.error),

  // --- 6.3 Пак упражнений ---
  exBadName(52, 'EX_BAD_NAME', Severity.error),
  exDupName(53, 'EX_DUP_NAME', Severity.warning),
  exNoMuscles(54, 'EX_NO_MUSCLES', Severity.error),
  exBadTag(55, 'EX_BAD_TAG', Severity.error),
  exUnknownTag(56, 'EX_UNKNOWN_TAG', Severity.warning),
  exBadLocation(57, 'EX_BAD_LOCATION', Severity.error),
  exBadLegacyId(58, 'EX_BAD_LEGACY_ID', Severity.error),
  exDupLegacyId(59, 'EX_DUP_LEGACY_ID', Severity.error),

  // --- 6.4 События и профиль ---
  evtBadUuid(60, 'EVT_BAD_UUID', Severity.error),
  evtDupId(61, 'EVT_DUP_ID', Severity.error),
  evtOrphan(62, 'EVT_ORPHAN', Severity.error),
  evtBadTime(63, 'EVT_BAD_TIME', Severity.error),
  evtTimeOrder(64, 'EVT_TIME_ORDER', Severity.error),
  evtBadEnum(65, 'EVT_BAD_ENUM', Severity.error),
  evtRange(66, 'EVT_RANGE', Severity.error),
  evtVerifiableMismatch(67, 'EVT_VERIFIABLE_MISMATCH', Severity.error),
  evtStatusMismatch(68, 'EVT_STATUS_MISMATCH', Severity.error),
  evtBadHash(69, 'EVT_BAD_HASH', Severity.error),
  evtLatencyMismatch(70, 'EVT_LATENCY_MISMATCH', Severity.warning),
  evtEncodedRound(71, 'EVT_ENCODED_ROUND', Severity.error),
  profBadCategory(72, 'PROF_BAD_CATEGORY', Severity.error),
  profTargetRange(73, 'PROF_TARGET_RANGE', Severity.error),
  profUnknownExercise(74, 'PROF_UNKNOWN_EXERCISE', Severity.warning),
  profEmptyPool(75, 'PROF_EMPTY_POOL', Severity.error);

  const ValidationCode(this.rule, this.code, this.severity);

  /// Номер правила в таблицах SCHEMAS §6.
  final int rule;

  /// Стабильный строковый код.
  final String code;

  /// Уровень по умолчанию (он же единственный: код определяет уровень).
  final Severity severity;
}
