// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmb_database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _utcOffsetMinMeta = const VerificationMeta(
    'utcOffsetMin',
  );
  @override
  late final GeneratedColumn<int> utcOffsetMin = GeneratedColumn<int>(
    'utc_offset_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateMeta = const VerificationMeta(
    'template',
  );
  @override
  late final GeneratedColumn<String> template = GeneratedColumn<String>(
    'template',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    utcOffsetMin,
    location,
    difficulty,
    template,
    appVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('utc_offset_min')) {
      context.handle(
        _utcOffsetMinMeta,
        utcOffsetMin.isAcceptableOrUnknown(
          data['utc_offset_min']!,
          _utcOffsetMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utcOffsetMinMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('template')) {
      context.handle(
        _templateMeta,
        template.isAcceptableOrUnknown(data['template']!, _templateMeta),
      );
    } else if (isInserting) {
      context.missing(_templateMeta);
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_appVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      utcOffsetMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}utc_offset_min'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      )!,
      template: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final int startedAt;

  /// `NULL` — сессия прервана (приложение убито).
  final int? endedAt;
  final int utcOffsetMin;
  final String location;
  final String difficulty;
  final String template;
  final String appVersion;
  const SessionRow({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.utcOffsetMin,
    required this.location,
    required this.difficulty,
    required this.template,
    required this.appVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    map['utc_offset_min'] = Variable<int>(utcOffsetMin);
    map['location'] = Variable<String>(location);
    map['difficulty'] = Variable<String>(difficulty);
    map['template'] = Variable<String>(template);
    map['app_version'] = Variable<String>(appVersion);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      utcOffsetMin: Value(utcOffsetMin),
      location: Value(location),
      difficulty: Value(difficulty),
      template: Value(template),
      appVersion: Value(appVersion),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      utcOffsetMin: serializer.fromJson<int>(json['utcOffsetMin']),
      location: serializer.fromJson<String>(json['location']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      template: serializer.fromJson<String>(json['template']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
      'utcOffsetMin': serializer.toJson<int>(utcOffsetMin),
      'location': serializer.toJson<String>(location),
      'difficulty': serializer.toJson<String>(difficulty),
      'template': serializer.toJson<String>(template),
      'appVersion': serializer.toJson<String>(appVersion),
    };
  }

  SessionRow copyWith({
    String? id,
    int? startedAt,
    Value<int?> endedAt = const Value.absent(),
    int? utcOffsetMin,
    String? location,
    String? difficulty,
    String? template,
    String? appVersion,
  }) => SessionRow(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    utcOffsetMin: utcOffsetMin ?? this.utcOffsetMin,
    location: location ?? this.location,
    difficulty: difficulty ?? this.difficulty,
    template: template ?? this.template,
    appVersion: appVersion ?? this.appVersion,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      utcOffsetMin: data.utcOffsetMin.present
          ? data.utcOffsetMin.value
          : this.utcOffsetMin,
      location: data.location.present ? data.location.value : this.location,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      template: data.template.present ? data.template.value : this.template,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('utcOffsetMin: $utcOffsetMin, ')
          ..write('location: $location, ')
          ..write('difficulty: $difficulty, ')
          ..write('template: $template, ')
          ..write('appVersion: $appVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    endedAt,
    utcOffsetMin,
    location,
    difficulty,
    template,
    appVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.utcOffsetMin == this.utcOffsetMin &&
          other.location == this.location &&
          other.difficulty == this.difficulty &&
          other.template == this.template &&
          other.appVersion == this.appVersion);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<int> utcOffsetMin;
  final Value<String> location;
  final Value<String> difficulty;
  final Value<String> template;
  final Value<String> appVersion;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.utcOffsetMin = const Value.absent(),
    this.location = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.template = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required int startedAt,
    this.endedAt = const Value.absent(),
    required int utcOffsetMin,
    required String location,
    required String difficulty,
    required String template,
    required String appVersion,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       utcOffsetMin = Value(utcOffsetMin),
       location = Value(location),
       difficulty = Value(difficulty),
       template = Value(template),
       appVersion = Value(appVersion);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? utcOffsetMin,
    Expression<String>? location,
    Expression<String>? difficulty,
    Expression<String>? template,
    Expression<String>? appVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (utcOffsetMin != null) 'utc_offset_min': utcOffsetMin,
      if (location != null) 'location': location,
      if (difficulty != null) 'difficulty': difficulty,
      if (template != null) 'template': template,
      if (appVersion != null) 'app_version': appVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<int>? startedAt,
    Value<int?>? endedAt,
    Value<int>? utcOffsetMin,
    Value<String>? location,
    Value<String>? difficulty,
    Value<String>? template,
    Value<String>? appVersion,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      utcOffsetMin: utcOffsetMin ?? this.utcOffsetMin,
      location: location ?? this.location,
      difficulty: difficulty ?? this.difficulty,
      template: template ?? this.template,
      appVersion: appVersion ?? this.appVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (utcOffsetMin.present) {
      map['utc_offset_min'] = Variable<int>(utcOffsetMin.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (template.present) {
      map['template'] = Variable<String>(template.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('utcOffsetMin: $utcOffsetMin, ')
          ..write('location: $location, ')
          ..write('difficulty: $difficulty, ')
          ..write('template: $template, ')
          ..write('appVersion: $appVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoundLogsTable extends RoundLogs
    with TableInfo<$RoundLogsTable, RoundLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoundLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _blockIndexMeta = const VerificationMeta(
    'blockIndex',
  );
  @override
  late final GeneratedColumn<int> blockIndex = GeneratedColumn<int>(
    'block_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundIndexMeta = const VerificationMeta(
    'roundIndex',
  );
  @override
  late final GeneratedColumn<int> roundIndex = GeneratedColumn<int>(
    'round_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    blockIndex,
    roundIndex,
    durationMs,
    rpe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'round_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoundLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('block_index')) {
      context.handle(
        _blockIndexMeta,
        blockIndex.isAcceptableOrUnknown(data['block_index']!, _blockIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_blockIndexMeta);
    }
    if (data.containsKey('round_index')) {
      context.handle(
        _roundIndexMeta,
        roundIndex.isAcceptableOrUnknown(data['round_index']!, _roundIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_roundIndexMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoundLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoundLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      blockIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}block_index'],
      )!,
      roundIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round_index'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rpe'],
      ),
    );
  }

  @override
  $RoundLogsTable createAlias(String alias) {
    return $RoundLogsTable(attachedDatabase, alias);
  }
}

class RoundLogRow extends DataClass implements Insertable<RoundLogRow> {
  final String id;
  final String sessionId;
  final int blockIndex;
  final int roundIndex;
  final int durationMs;

  /// 1 легко, 2 нормально, 3 тяжело; `NULL` — не оценил.
  final int? rpe;
  const RoundLogRow({
    required this.id,
    required this.sessionId,
    required this.blockIndex,
    required this.roundIndex,
    required this.durationMs,
    this.rpe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['block_index'] = Variable<int>(blockIndex);
    map['round_index'] = Variable<int>(roundIndex);
    map['duration_ms'] = Variable<int>(durationMs);
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<int>(rpe);
    }
    return map;
  }

  RoundLogsCompanion toCompanion(bool nullToAbsent) {
    return RoundLogsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      blockIndex: Value(blockIndex),
      roundIndex: Value(roundIndex),
      durationMs: Value(durationMs),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
    );
  }

  factory RoundLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoundLogRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      blockIndex: serializer.fromJson<int>(json['blockIndex']),
      roundIndex: serializer.fromJson<int>(json['roundIndex']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      rpe: serializer.fromJson<int?>(json['rpe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'blockIndex': serializer.toJson<int>(blockIndex),
      'roundIndex': serializer.toJson<int>(roundIndex),
      'durationMs': serializer.toJson<int>(durationMs),
      'rpe': serializer.toJson<int?>(rpe),
    };
  }

  RoundLogRow copyWith({
    String? id,
    String? sessionId,
    int? blockIndex,
    int? roundIndex,
    int? durationMs,
    Value<int?> rpe = const Value.absent(),
  }) => RoundLogRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    blockIndex: blockIndex ?? this.blockIndex,
    roundIndex: roundIndex ?? this.roundIndex,
    durationMs: durationMs ?? this.durationMs,
    rpe: rpe.present ? rpe.value : this.rpe,
  );
  RoundLogRow copyWithCompanion(RoundLogsCompanion data) {
    return RoundLogRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      blockIndex: data.blockIndex.present
          ? data.blockIndex.value
          : this.blockIndex,
      roundIndex: data.roundIndex.present
          ? data.roundIndex.value
          : this.roundIndex,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoundLogRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('blockIndex: $blockIndex, ')
          ..write('roundIndex: $roundIndex, ')
          ..write('durationMs: $durationMs, ')
          ..write('rpe: $rpe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, blockIndex, roundIndex, durationMs, rpe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoundLogRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.blockIndex == this.blockIndex &&
          other.roundIndex == this.roundIndex &&
          other.durationMs == this.durationMs &&
          other.rpe == this.rpe);
}

class RoundLogsCompanion extends UpdateCompanion<RoundLogRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> blockIndex;
  final Value<int> roundIndex;
  final Value<int> durationMs;
  final Value<int?> rpe;
  final Value<int> rowid;
  const RoundLogsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.blockIndex = const Value.absent(),
    this.roundIndex = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.rpe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoundLogsCompanion.insert({
    required String id,
    required String sessionId,
    required int blockIndex,
    required int roundIndex,
    required int durationMs,
    this.rpe = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       blockIndex = Value(blockIndex),
       roundIndex = Value(roundIndex),
       durationMs = Value(durationMs);
  static Insertable<RoundLogRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? blockIndex,
    Expression<int>? roundIndex,
    Expression<int>? durationMs,
    Expression<int>? rpe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (blockIndex != null) 'block_index': blockIndex,
      if (roundIndex != null) 'round_index': roundIndex,
      if (durationMs != null) 'duration_ms': durationMs,
      if (rpe != null) 'rpe': rpe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoundLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? blockIndex,
    Value<int>? roundIndex,
    Value<int>? durationMs,
    Value<int?>? rpe,
    Value<int>? rowid,
  }) {
    return RoundLogsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      blockIndex: blockIndex ?? this.blockIndex,
      roundIndex: roundIndex ?? this.roundIndex,
      durationMs: durationMs ?? this.durationMs,
      rpe: rpe ?? this.rpe,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (blockIndex.present) {
      map['block_index'] = Variable<int>(blockIndex.value);
    }
    if (roundIndex.present) {
      map['round_index'] = Variable<int>(roundIndex.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<int>(rpe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoundLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('blockIndex: $blockIndex, ')
          ..write('roundIndex: $roundIndex, ')
          ..write('durationMs: $durationMs, ')
          ..write('rpe: $rpe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseSetsTable extends ExerciseSets
    with TableInfo<$ExerciseSetsTable, ExerciseSetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roundIdMeta = const VerificationMeta(
    'roundId',
  );
  @override
  late final GeneratedColumn<String> roundId = GeneratedColumn<String>(
    'round_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES round_logs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _setIndexMeta = const VerificationMeta(
    'setIndex',
  );
  @override
  late final GeneratedColumn<int> setIndex = GeneratedColumn<int>(
    'set_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prescribedMeta = const VerificationMeta(
    'prescribed',
  );
  @override
  late final GeneratedColumn<int> prescribed = GeneratedColumn<int>(
    'prescribed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<int> done = GeneratedColumn<int>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    roundId,
    setIndex,
    exerciseId,
    unit,
    prescribed,
    done,
    startedAt,
    endedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseSetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('round_id')) {
      context.handle(
        _roundIdMeta,
        roundId.isAcceptableOrUnknown(data['round_id']!, _roundIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roundIdMeta);
    }
    if (data.containsKey('set_index')) {
      context.handle(
        _setIndexMeta,
        setIndex.isAcceptableOrUnknown(data['set_index']!, _setIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_setIndexMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('prescribed')) {
      context.handle(
        _prescribedMeta,
        prescribed.isAcceptableOrUnknown(data['prescribed']!, _prescribedMeta),
      );
    } else if (isInserting) {
      context.missing(_prescribedMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    } else if (isInserting) {
      context.missing(_doneMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseSetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseSetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      roundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}round_id'],
      )!,
      setIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_index'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      prescribed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prescribed'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}done'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      )!,
    );
  }

  @override
  $ExerciseSetsTable createAlias(String alias) {
    return $ExerciseSetsTable(attachedDatabase, alias);
  }
}

class ExerciseSetRow extends DataClass implements Insertable<ExerciseSetRow> {
  final String id;
  final String sessionId;
  final String roundId;
  final int setIndex;
  final String exerciseId;
  final String unit;

  /// План, зафиксированный при старте сессии (D6).
  final int prescribed;
  final int done;
  final int startedAt;
  final int endedAt;
  const ExerciseSetRow({
    required this.id,
    required this.sessionId,
    required this.roundId,
    required this.setIndex,
    required this.exerciseId,
    required this.unit,
    required this.prescribed,
    required this.done,
    required this.startedAt,
    required this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['round_id'] = Variable<String>(roundId);
    map['set_index'] = Variable<int>(setIndex);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['unit'] = Variable<String>(unit);
    map['prescribed'] = Variable<int>(prescribed);
    map['done'] = Variable<int>(done);
    map['started_at'] = Variable<int>(startedAt);
    map['ended_at'] = Variable<int>(endedAt);
    return map;
  }

  ExerciseSetsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseSetsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      roundId: Value(roundId),
      setIndex: Value(setIndex),
      exerciseId: Value(exerciseId),
      unit: Value(unit),
      prescribed: Value(prescribed),
      done: Value(done),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
    );
  }

  factory ExerciseSetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseSetRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      roundId: serializer.fromJson<String>(json['roundId']),
      setIndex: serializer.fromJson<int>(json['setIndex']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      unit: serializer.fromJson<String>(json['unit']),
      prescribed: serializer.fromJson<int>(json['prescribed']),
      done: serializer.fromJson<int>(json['done']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'roundId': serializer.toJson<String>(roundId),
      'setIndex': serializer.toJson<int>(setIndex),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'unit': serializer.toJson<String>(unit),
      'prescribed': serializer.toJson<int>(prescribed),
      'done': serializer.toJson<int>(done),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int>(endedAt),
    };
  }

  ExerciseSetRow copyWith({
    String? id,
    String? sessionId,
    String? roundId,
    int? setIndex,
    String? exerciseId,
    String? unit,
    int? prescribed,
    int? done,
    int? startedAt,
    int? endedAt,
  }) => ExerciseSetRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    roundId: roundId ?? this.roundId,
    setIndex: setIndex ?? this.setIndex,
    exerciseId: exerciseId ?? this.exerciseId,
    unit: unit ?? this.unit,
    prescribed: prescribed ?? this.prescribed,
    done: done ?? this.done,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
  );
  ExerciseSetRow copyWithCompanion(ExerciseSetsCompanion data) {
    return ExerciseSetRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      setIndex: data.setIndex.present ? data.setIndex.value : this.setIndex,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      unit: data.unit.present ? data.unit.value : this.unit,
      prescribed: data.prescribed.present
          ? data.prescribed.value
          : this.prescribed,
      done: data.done.present ? data.done.value : this.done,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseSetRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('roundId: $roundId, ')
          ..write('setIndex: $setIndex, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('unit: $unit, ')
          ..write('prescribed: $prescribed, ')
          ..write('done: $done, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    roundId,
    setIndex,
    exerciseId,
    unit,
    prescribed,
    done,
    startedAt,
    endedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseSetRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.roundId == this.roundId &&
          other.setIndex == this.setIndex &&
          other.exerciseId == this.exerciseId &&
          other.unit == this.unit &&
          other.prescribed == this.prescribed &&
          other.done == this.done &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt);
}

class ExerciseSetsCompanion extends UpdateCompanion<ExerciseSetRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> roundId;
  final Value<int> setIndex;
  final Value<String> exerciseId;
  final Value<String> unit;
  final Value<int> prescribed;
  final Value<int> done;
  final Value<int> startedAt;
  final Value<int> endedAt;
  final Value<int> rowid;
  const ExerciseSetsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.roundId = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.unit = const Value.absent(),
    this.prescribed = const Value.absent(),
    this.done = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseSetsCompanion.insert({
    required String id,
    required String sessionId,
    required String roundId,
    required int setIndex,
    required String exerciseId,
    required String unit,
    required int prescribed,
    required int done,
    required int startedAt,
    required int endedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       roundId = Value(roundId),
       setIndex = Value(setIndex),
       exerciseId = Value(exerciseId),
       unit = Value(unit),
       prescribed = Value(prescribed),
       done = Value(done),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt);
  static Insertable<ExerciseSetRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? roundId,
    Expression<int>? setIndex,
    Expression<String>? exerciseId,
    Expression<String>? unit,
    Expression<int>? prescribed,
    Expression<int>? done,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (roundId != null) 'round_id': roundId,
      if (setIndex != null) 'set_index': setIndex,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (unit != null) 'unit': unit,
      if (prescribed != null) 'prescribed': prescribed,
      if (done != null) 'done': done,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseSetsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? roundId,
    Value<int>? setIndex,
    Value<String>? exerciseId,
    Value<String>? unit,
    Value<int>? prescribed,
    Value<int>? done,
    Value<int>? startedAt,
    Value<int>? endedAt,
    Value<int>? rowid,
  }) {
    return ExerciseSetsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      roundId: roundId ?? this.roundId,
      setIndex: setIndex ?? this.setIndex,
      exerciseId: exerciseId ?? this.exerciseId,
      unit: unit ?? this.unit,
      prescribed: prescribed ?? this.prescribed,
      done: done ?? this.done,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (roundId.present) {
      map['round_id'] = Variable<String>(roundId.value);
    }
    if (setIndex.present) {
      map['set_index'] = Variable<int>(setIndex.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (prescribed.present) {
      map['prescribed'] = Variable<int>(prescribed.value);
    }
    if (done.present) {
      map['done'] = Variable<int>(done.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseSetsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('roundId: $roundId, ')
          ..write('setIndex: $setIndex, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('unit: $unit, ')
          ..write('prescribed: $prescribed, ')
          ..write('done: $done, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskAttemptsTable extends TaskAttempts
    with TableInfo<$TaskAttemptsTable, TaskAttemptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _blockIndexMeta = const VerificationMeta(
    'blockIndex',
  );
  @override
  late final GeneratedColumn<int> blockIndex = GeneratedColumn<int>(
    'block_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundIndexMeta = const VerificationMeta(
    'roundIndex',
  );
  @override
  late final GeneratedColumn<int> roundIndex = GeneratedColumn<int>(
    'round_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packSourceMeta = const VerificationMeta(
    'packSource',
  );
  @override
  late final GeneratedColumn<String> packSource = GeneratedColumn<String>(
    'pack_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archetypeMeta = const VerificationMeta(
    'archetype',
  );
  @override
  late final GeneratedColumn<String> archetype = GeneratedColumn<String>(
    'archetype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<int> seed = GeneratedColumn<int>(
    'seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presentedAtMeta = const VerificationMeta(
    'presentedAt',
  );
  @override
  late final GeneratedColumn<int> presentedAt = GeneratedColumn<int>(
    'presented_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<int> answeredAt = GeneratedColumn<int>(
    'answered_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latencyMsMeta = const VerificationMeta(
    'latencyMs',
  );
  @override
  late final GeneratedColumn<int> latencyMs = GeneratedColumn<int>(
    'latency_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _selfRatingMeta = const VerificationMeta(
    'selfRating',
  );
  @override
  late final GeneratedColumn<int> selfRating = GeneratedColumn<int>(
    'self_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _responseMeta = const VerificationMeta(
    'response',
  );
  @override
  late final GeneratedColumn<String> response = GeneratedColumn<String>(
    'response',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _encodedRoundIndexMeta = const VerificationMeta(
    'encodedRoundIndex',
  );
  @override
  late final GeneratedColumn<int> encodedRoundIndex = GeneratedColumn<int>(
    'encoded_round_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadHashMeta = const VerificationMeta(
    'payloadHash',
  );
  @override
  late final GeneratedColumn<String> payloadHash = GeneratedColumn<String>(
    'payload_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    blockIndex,
    roundIndex,
    taskId,
    packId,
    packSource,
    archetype,
    domain,
    difficulty,
    seed,
    status,
    presentedAt,
    answeredAt,
    latencyMs,
    isCorrect,
    selfRating,
    response,
    encodedRoundIndex,
    payloadHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskAttemptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('block_index')) {
      context.handle(
        _blockIndexMeta,
        blockIndex.isAcceptableOrUnknown(data['block_index']!, _blockIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_blockIndexMeta);
    }
    if (data.containsKey('round_index')) {
      context.handle(
        _roundIndexMeta,
        roundIndex.isAcceptableOrUnknown(data['round_index']!, _roundIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_roundIndexMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('pack_source')) {
      context.handle(
        _packSourceMeta,
        packSource.isAcceptableOrUnknown(data['pack_source']!, _packSourceMeta),
      );
    } else if (isInserting) {
      context.missing(_packSourceMeta);
    }
    if (data.containsKey('archetype')) {
      context.handle(
        _archetypeMeta,
        archetype.isAcceptableOrUnknown(data['archetype']!, _archetypeMeta),
      );
    } else if (isInserting) {
      context.missing(_archetypeMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('seed')) {
      context.handle(
        _seedMeta,
        seed.isAcceptableOrUnknown(data['seed']!, _seedMeta),
      );
    } else if (isInserting) {
      context.missing(_seedMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('presented_at')) {
      context.handle(
        _presentedAtMeta,
        presentedAt.isAcceptableOrUnknown(
          data['presented_at']!,
          _presentedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_presentedAtMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    }
    if (data.containsKey('latency_ms')) {
      context.handle(
        _latencyMsMeta,
        latencyMs.isAcceptableOrUnknown(data['latency_ms']!, _latencyMsMeta),
      );
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    }
    if (data.containsKey('self_rating')) {
      context.handle(
        _selfRatingMeta,
        selfRating.isAcceptableOrUnknown(data['self_rating']!, _selfRatingMeta),
      );
    }
    if (data.containsKey('response')) {
      context.handle(
        _responseMeta,
        response.isAcceptableOrUnknown(data['response']!, _responseMeta),
      );
    }
    if (data.containsKey('encoded_round_index')) {
      context.handle(
        _encodedRoundIndexMeta,
        encodedRoundIndex.isAcceptableOrUnknown(
          data['encoded_round_index']!,
          _encodedRoundIndexMeta,
        ),
      );
    }
    if (data.containsKey('payload_hash')) {
      context.handle(
        _payloadHashMeta,
        payloadHash.isAcceptableOrUnknown(
          data['payload_hash']!,
          _payloadHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadHashMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskAttemptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskAttemptRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      blockIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}block_index'],
      )!,
      roundIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round_index'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
      packSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_source'],
      )!,
      archetype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archetype'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      seed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      presentedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}presented_at'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_at'],
      ),
      latencyMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}latency_ms'],
      ),
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      ),
      selfRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}self_rating'],
      ),
      response: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response'],
      ),
      encodedRoundIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}encoded_round_index'],
      ),
      payloadHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_hash'],
      )!,
    );
  }

  @override
  $TaskAttemptsTable createAlias(String alias) {
    return $TaskAttemptsTable(attachedDatabase, alias);
  }
}

class TaskAttemptRow extends DataClass implements Insertable<TaskAttemptRow> {
  final String id;
  final String sessionId;
  final int blockIndex;
  final int roundIndex;
  final String taskId;
  final String packId;
  final String packSource;
  final String archetype;
  final String domain;
  final double difficulty;

  /// `0 … 2^53−1` — помещается в INTEGER SQLite (64 бита) без потерь.
  final int seed;
  final String status;
  final int presentedAt;
  final int? answeredAt;
  final int? latencyMs;

  /// `NULL` — непроверяемая задача (`verbal`).
  final bool? isCorrect;
  final int? selfRating;
  final String? response;
  final int? encodedRoundIndex;
  final String payloadHash;
  const TaskAttemptRow({
    required this.id,
    required this.sessionId,
    required this.blockIndex,
    required this.roundIndex,
    required this.taskId,
    required this.packId,
    required this.packSource,
    required this.archetype,
    required this.domain,
    required this.difficulty,
    required this.seed,
    required this.status,
    required this.presentedAt,
    this.answeredAt,
    this.latencyMs,
    this.isCorrect,
    this.selfRating,
    this.response,
    this.encodedRoundIndex,
    required this.payloadHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['block_index'] = Variable<int>(blockIndex);
    map['round_index'] = Variable<int>(roundIndex);
    map['task_id'] = Variable<String>(taskId);
    map['pack_id'] = Variable<String>(packId);
    map['pack_source'] = Variable<String>(packSource);
    map['archetype'] = Variable<String>(archetype);
    map['domain'] = Variable<String>(domain);
    map['difficulty'] = Variable<double>(difficulty);
    map['seed'] = Variable<int>(seed);
    map['status'] = Variable<String>(status);
    map['presented_at'] = Variable<int>(presentedAt);
    if (!nullToAbsent || answeredAt != null) {
      map['answered_at'] = Variable<int>(answeredAt);
    }
    if (!nullToAbsent || latencyMs != null) {
      map['latency_ms'] = Variable<int>(latencyMs);
    }
    if (!nullToAbsent || isCorrect != null) {
      map['is_correct'] = Variable<bool>(isCorrect);
    }
    if (!nullToAbsent || selfRating != null) {
      map['self_rating'] = Variable<int>(selfRating);
    }
    if (!nullToAbsent || response != null) {
      map['response'] = Variable<String>(response);
    }
    if (!nullToAbsent || encodedRoundIndex != null) {
      map['encoded_round_index'] = Variable<int>(encodedRoundIndex);
    }
    map['payload_hash'] = Variable<String>(payloadHash);
    return map;
  }

  TaskAttemptsCompanion toCompanion(bool nullToAbsent) {
    return TaskAttemptsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      blockIndex: Value(blockIndex),
      roundIndex: Value(roundIndex),
      taskId: Value(taskId),
      packId: Value(packId),
      packSource: Value(packSource),
      archetype: Value(archetype),
      domain: Value(domain),
      difficulty: Value(difficulty),
      seed: Value(seed),
      status: Value(status),
      presentedAt: Value(presentedAt),
      answeredAt: answeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredAt),
      latencyMs: latencyMs == null && nullToAbsent
          ? const Value.absent()
          : Value(latencyMs),
      isCorrect: isCorrect == null && nullToAbsent
          ? const Value.absent()
          : Value(isCorrect),
      selfRating: selfRating == null && nullToAbsent
          ? const Value.absent()
          : Value(selfRating),
      response: response == null && nullToAbsent
          ? const Value.absent()
          : Value(response),
      encodedRoundIndex: encodedRoundIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(encodedRoundIndex),
      payloadHash: Value(payloadHash),
    );
  }

  factory TaskAttemptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskAttemptRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      blockIndex: serializer.fromJson<int>(json['blockIndex']),
      roundIndex: serializer.fromJson<int>(json['roundIndex']),
      taskId: serializer.fromJson<String>(json['taskId']),
      packId: serializer.fromJson<String>(json['packId']),
      packSource: serializer.fromJson<String>(json['packSource']),
      archetype: serializer.fromJson<String>(json['archetype']),
      domain: serializer.fromJson<String>(json['domain']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      seed: serializer.fromJson<int>(json['seed']),
      status: serializer.fromJson<String>(json['status']),
      presentedAt: serializer.fromJson<int>(json['presentedAt']),
      answeredAt: serializer.fromJson<int?>(json['answeredAt']),
      latencyMs: serializer.fromJson<int?>(json['latencyMs']),
      isCorrect: serializer.fromJson<bool?>(json['isCorrect']),
      selfRating: serializer.fromJson<int?>(json['selfRating']),
      response: serializer.fromJson<String?>(json['response']),
      encodedRoundIndex: serializer.fromJson<int?>(json['encodedRoundIndex']),
      payloadHash: serializer.fromJson<String>(json['payloadHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'blockIndex': serializer.toJson<int>(blockIndex),
      'roundIndex': serializer.toJson<int>(roundIndex),
      'taskId': serializer.toJson<String>(taskId),
      'packId': serializer.toJson<String>(packId),
      'packSource': serializer.toJson<String>(packSource),
      'archetype': serializer.toJson<String>(archetype),
      'domain': serializer.toJson<String>(domain),
      'difficulty': serializer.toJson<double>(difficulty),
      'seed': serializer.toJson<int>(seed),
      'status': serializer.toJson<String>(status),
      'presentedAt': serializer.toJson<int>(presentedAt),
      'answeredAt': serializer.toJson<int?>(answeredAt),
      'latencyMs': serializer.toJson<int?>(latencyMs),
      'isCorrect': serializer.toJson<bool?>(isCorrect),
      'selfRating': serializer.toJson<int?>(selfRating),
      'response': serializer.toJson<String?>(response),
      'encodedRoundIndex': serializer.toJson<int?>(encodedRoundIndex),
      'payloadHash': serializer.toJson<String>(payloadHash),
    };
  }

  TaskAttemptRow copyWith({
    String? id,
    String? sessionId,
    int? blockIndex,
    int? roundIndex,
    String? taskId,
    String? packId,
    String? packSource,
    String? archetype,
    String? domain,
    double? difficulty,
    int? seed,
    String? status,
    int? presentedAt,
    Value<int?> answeredAt = const Value.absent(),
    Value<int?> latencyMs = const Value.absent(),
    Value<bool?> isCorrect = const Value.absent(),
    Value<int?> selfRating = const Value.absent(),
    Value<String?> response = const Value.absent(),
    Value<int?> encodedRoundIndex = const Value.absent(),
    String? payloadHash,
  }) => TaskAttemptRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    blockIndex: blockIndex ?? this.blockIndex,
    roundIndex: roundIndex ?? this.roundIndex,
    taskId: taskId ?? this.taskId,
    packId: packId ?? this.packId,
    packSource: packSource ?? this.packSource,
    archetype: archetype ?? this.archetype,
    domain: domain ?? this.domain,
    difficulty: difficulty ?? this.difficulty,
    seed: seed ?? this.seed,
    status: status ?? this.status,
    presentedAt: presentedAt ?? this.presentedAt,
    answeredAt: answeredAt.present ? answeredAt.value : this.answeredAt,
    latencyMs: latencyMs.present ? latencyMs.value : this.latencyMs,
    isCorrect: isCorrect.present ? isCorrect.value : this.isCorrect,
    selfRating: selfRating.present ? selfRating.value : this.selfRating,
    response: response.present ? response.value : this.response,
    encodedRoundIndex: encodedRoundIndex.present
        ? encodedRoundIndex.value
        : this.encodedRoundIndex,
    payloadHash: payloadHash ?? this.payloadHash,
  );
  TaskAttemptRow copyWithCompanion(TaskAttemptsCompanion data) {
    return TaskAttemptRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      blockIndex: data.blockIndex.present
          ? data.blockIndex.value
          : this.blockIndex,
      roundIndex: data.roundIndex.present
          ? data.roundIndex.value
          : this.roundIndex,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      packId: data.packId.present ? data.packId.value : this.packId,
      packSource: data.packSource.present
          ? data.packSource.value
          : this.packSource,
      archetype: data.archetype.present ? data.archetype.value : this.archetype,
      domain: data.domain.present ? data.domain.value : this.domain,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      seed: data.seed.present ? data.seed.value : this.seed,
      status: data.status.present ? data.status.value : this.status,
      presentedAt: data.presentedAt.present
          ? data.presentedAt.value
          : this.presentedAt,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
      latencyMs: data.latencyMs.present ? data.latencyMs.value : this.latencyMs,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      selfRating: data.selfRating.present
          ? data.selfRating.value
          : this.selfRating,
      response: data.response.present ? data.response.value : this.response,
      encodedRoundIndex: data.encodedRoundIndex.present
          ? data.encodedRoundIndex.value
          : this.encodedRoundIndex,
      payloadHash: data.payloadHash.present
          ? data.payloadHash.value
          : this.payloadHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskAttemptRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('blockIndex: $blockIndex, ')
          ..write('roundIndex: $roundIndex, ')
          ..write('taskId: $taskId, ')
          ..write('packId: $packId, ')
          ..write('packSource: $packSource, ')
          ..write('archetype: $archetype, ')
          ..write('domain: $domain, ')
          ..write('difficulty: $difficulty, ')
          ..write('seed: $seed, ')
          ..write('status: $status, ')
          ..write('presentedAt: $presentedAt, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('selfRating: $selfRating, ')
          ..write('response: $response, ')
          ..write('encodedRoundIndex: $encodedRoundIndex, ')
          ..write('payloadHash: $payloadHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    blockIndex,
    roundIndex,
    taskId,
    packId,
    packSource,
    archetype,
    domain,
    difficulty,
    seed,
    status,
    presentedAt,
    answeredAt,
    latencyMs,
    isCorrect,
    selfRating,
    response,
    encodedRoundIndex,
    payloadHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskAttemptRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.blockIndex == this.blockIndex &&
          other.roundIndex == this.roundIndex &&
          other.taskId == this.taskId &&
          other.packId == this.packId &&
          other.packSource == this.packSource &&
          other.archetype == this.archetype &&
          other.domain == this.domain &&
          other.difficulty == this.difficulty &&
          other.seed == this.seed &&
          other.status == this.status &&
          other.presentedAt == this.presentedAt &&
          other.answeredAt == this.answeredAt &&
          other.latencyMs == this.latencyMs &&
          other.isCorrect == this.isCorrect &&
          other.selfRating == this.selfRating &&
          other.response == this.response &&
          other.encodedRoundIndex == this.encodedRoundIndex &&
          other.payloadHash == this.payloadHash);
}

class TaskAttemptsCompanion extends UpdateCompanion<TaskAttemptRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> blockIndex;
  final Value<int> roundIndex;
  final Value<String> taskId;
  final Value<String> packId;
  final Value<String> packSource;
  final Value<String> archetype;
  final Value<String> domain;
  final Value<double> difficulty;
  final Value<int> seed;
  final Value<String> status;
  final Value<int> presentedAt;
  final Value<int?> answeredAt;
  final Value<int?> latencyMs;
  final Value<bool?> isCorrect;
  final Value<int?> selfRating;
  final Value<String?> response;
  final Value<int?> encodedRoundIndex;
  final Value<String> payloadHash;
  final Value<int> rowid;
  const TaskAttemptsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.blockIndex = const Value.absent(),
    this.roundIndex = const Value.absent(),
    this.taskId = const Value.absent(),
    this.packId = const Value.absent(),
    this.packSource = const Value.absent(),
    this.archetype = const Value.absent(),
    this.domain = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.seed = const Value.absent(),
    this.status = const Value.absent(),
    this.presentedAt = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.selfRating = const Value.absent(),
    this.response = const Value.absent(),
    this.encodedRoundIndex = const Value.absent(),
    this.payloadHash = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskAttemptsCompanion.insert({
    required String id,
    required String sessionId,
    required int blockIndex,
    required int roundIndex,
    required String taskId,
    required String packId,
    required String packSource,
    required String archetype,
    required String domain,
    required double difficulty,
    required int seed,
    required String status,
    required int presentedAt,
    this.answeredAt = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.selfRating = const Value.absent(),
    this.response = const Value.absent(),
    this.encodedRoundIndex = const Value.absent(),
    required String payloadHash,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       blockIndex = Value(blockIndex),
       roundIndex = Value(roundIndex),
       taskId = Value(taskId),
       packId = Value(packId),
       packSource = Value(packSource),
       archetype = Value(archetype),
       domain = Value(domain),
       difficulty = Value(difficulty),
       seed = Value(seed),
       status = Value(status),
       presentedAt = Value(presentedAt),
       payloadHash = Value(payloadHash);
  static Insertable<TaskAttemptRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? blockIndex,
    Expression<int>? roundIndex,
    Expression<String>? taskId,
    Expression<String>? packId,
    Expression<String>? packSource,
    Expression<String>? archetype,
    Expression<String>? domain,
    Expression<double>? difficulty,
    Expression<int>? seed,
    Expression<String>? status,
    Expression<int>? presentedAt,
    Expression<int>? answeredAt,
    Expression<int>? latencyMs,
    Expression<bool>? isCorrect,
    Expression<int>? selfRating,
    Expression<String>? response,
    Expression<int>? encodedRoundIndex,
    Expression<String>? payloadHash,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (blockIndex != null) 'block_index': blockIndex,
      if (roundIndex != null) 'round_index': roundIndex,
      if (taskId != null) 'task_id': taskId,
      if (packId != null) 'pack_id': packId,
      if (packSource != null) 'pack_source': packSource,
      if (archetype != null) 'archetype': archetype,
      if (domain != null) 'domain': domain,
      if (difficulty != null) 'difficulty': difficulty,
      if (seed != null) 'seed': seed,
      if (status != null) 'status': status,
      if (presentedAt != null) 'presented_at': presentedAt,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (latencyMs != null) 'latency_ms': latencyMs,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (selfRating != null) 'self_rating': selfRating,
      if (response != null) 'response': response,
      if (encodedRoundIndex != null) 'encoded_round_index': encodedRoundIndex,
      if (payloadHash != null) 'payload_hash': payloadHash,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskAttemptsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? blockIndex,
    Value<int>? roundIndex,
    Value<String>? taskId,
    Value<String>? packId,
    Value<String>? packSource,
    Value<String>? archetype,
    Value<String>? domain,
    Value<double>? difficulty,
    Value<int>? seed,
    Value<String>? status,
    Value<int>? presentedAt,
    Value<int?>? answeredAt,
    Value<int?>? latencyMs,
    Value<bool?>? isCorrect,
    Value<int?>? selfRating,
    Value<String?>? response,
    Value<int?>? encodedRoundIndex,
    Value<String>? payloadHash,
    Value<int>? rowid,
  }) {
    return TaskAttemptsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      blockIndex: blockIndex ?? this.blockIndex,
      roundIndex: roundIndex ?? this.roundIndex,
      taskId: taskId ?? this.taskId,
      packId: packId ?? this.packId,
      packSource: packSource ?? this.packSource,
      archetype: archetype ?? this.archetype,
      domain: domain ?? this.domain,
      difficulty: difficulty ?? this.difficulty,
      seed: seed ?? this.seed,
      status: status ?? this.status,
      presentedAt: presentedAt ?? this.presentedAt,
      answeredAt: answeredAt ?? this.answeredAt,
      latencyMs: latencyMs ?? this.latencyMs,
      isCorrect: isCorrect ?? this.isCorrect,
      selfRating: selfRating ?? this.selfRating,
      response: response ?? this.response,
      encodedRoundIndex: encodedRoundIndex ?? this.encodedRoundIndex,
      payloadHash: payloadHash ?? this.payloadHash,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (blockIndex.present) {
      map['block_index'] = Variable<int>(blockIndex.value);
    }
    if (roundIndex.present) {
      map['round_index'] = Variable<int>(roundIndex.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (packSource.present) {
      map['pack_source'] = Variable<String>(packSource.value);
    }
    if (archetype.present) {
      map['archetype'] = Variable<String>(archetype.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (seed.present) {
      map['seed'] = Variable<int>(seed.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (presentedAt.present) {
      map['presented_at'] = Variable<int>(presentedAt.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<int>(answeredAt.value);
    }
    if (latencyMs.present) {
      map['latency_ms'] = Variable<int>(latencyMs.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (selfRating.present) {
      map['self_rating'] = Variable<int>(selfRating.value);
    }
    if (response.present) {
      map['response'] = Variable<String>(response.value);
    }
    if (encodedRoundIndex.present) {
      map['encoded_round_index'] = Variable<int>(encodedRoundIndex.value);
    }
    if (payloadHash.present) {
      map['payload_hash'] = Variable<String>(payloadHash.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('blockIndex: $blockIndex, ')
          ..write('roundIndex: $roundIndex, ')
          ..write('taskId: $taskId, ')
          ..write('packId: $packId, ')
          ..write('packSource: $packSource, ')
          ..write('archetype: $archetype, ')
          ..write('domain: $domain, ')
          ..write('difficulty: $difficulty, ')
          ..write('seed: $seed, ')
          ..write('status: $status, ')
          ..write('presentedAt: $presentedAt, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('selfRating: $selfRating, ')
          ..write('response: $response, ')
          ..write('encodedRoundIndex: $encodedRoundIndex, ')
          ..write('payloadHash: $payloadHash, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileSettingsTableTable extends ProfileSettingsTable
    with TableInfo<$ProfileSettingsTableTable, ProfileSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _defaultRepsMinMeta = const VerificationMeta(
    'defaultRepsMin',
  );
  @override
  late final GeneratedColumn<int> defaultRepsMin = GeneratedColumn<int>(
    'default_reps_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(15),
  );
  static const VerificationMeta _defaultRepsMaxMeta = const VerificationMeta(
    'defaultRepsMax',
  );
  @override
  late final GeneratedColumn<int> defaultRepsMax = GeneratedColumn<int>(
    'default_reps_max',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(15),
  );
  static const VerificationMeta _defaultSecondsMinMeta = const VerificationMeta(
    'defaultSecondsMin',
  );
  @override
  late final GeneratedColumn<int> defaultSecondsMin = GeneratedColumn<int>(
    'default_seconds_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _defaultSecondsMaxMeta = const VerificationMeta(
    'defaultSecondsMax',
  );
  @override
  late final GeneratedColumn<int> defaultSecondsMax = GeneratedColumn<int>(
    'default_seconds_max',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _progressionEnabledMeta =
      const VerificationMeta('progressionEnabled');
  @override
  late final GeneratedColumn<bool> progressionEnabled = GeneratedColumn<bool>(
    'progression_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("progression_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schemaVersion,
    defaultRepsMin,
    defaultRepsMax,
    defaultSecondsMin,
    defaultSecondsMax,
    progressionEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('default_reps_min')) {
      context.handle(
        _defaultRepsMinMeta,
        defaultRepsMin.isAcceptableOrUnknown(
          data['default_reps_min']!,
          _defaultRepsMinMeta,
        ),
      );
    }
    if (data.containsKey('default_reps_max')) {
      context.handle(
        _defaultRepsMaxMeta,
        defaultRepsMax.isAcceptableOrUnknown(
          data['default_reps_max']!,
          _defaultRepsMaxMeta,
        ),
      );
    }
    if (data.containsKey('default_seconds_min')) {
      context.handle(
        _defaultSecondsMinMeta,
        defaultSecondsMin.isAcceptableOrUnknown(
          data['default_seconds_min']!,
          _defaultSecondsMinMeta,
        ),
      );
    }
    if (data.containsKey('default_seconds_max')) {
      context.handle(
        _defaultSecondsMaxMeta,
        defaultSecondsMax.isAcceptableOrUnknown(
          data['default_seconds_max']!,
          _defaultSecondsMaxMeta,
        ),
      );
    }
    if (data.containsKey('progression_enabled')) {
      context.handle(
        _progressionEnabledMeta,
        progressionEnabled.isAcceptableOrUnknown(
          data['progression_enabled']!,
          _progressionEnabledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      defaultRepsMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_reps_min'],
      )!,
      defaultRepsMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_reps_max'],
      )!,
      defaultSecondsMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_seconds_min'],
      )!,
      defaultSecondsMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_seconds_max'],
      )!,
      progressionEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}progression_enabled'],
      )!,
    );
  }

  @override
  $ProfileSettingsTableTable createAlias(String alias) {
    return $ProfileSettingsTableTable(attachedDatabase, alias);
  }
}

class ProfileSettingsRow extends DataClass
    implements Insertable<ProfileSettingsRow> {
  final int id;
  final int schemaVersion;
  final int defaultRepsMin;
  final int defaultRepsMax;
  final int defaultSecondsMin;
  final int defaultSecondsMax;
  final bool progressionEnabled;
  const ProfileSettingsRow({
    required this.id,
    required this.schemaVersion,
    required this.defaultRepsMin,
    required this.defaultRepsMax,
    required this.defaultSecondsMin,
    required this.defaultSecondsMax,
    required this.progressionEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['default_reps_min'] = Variable<int>(defaultRepsMin);
    map['default_reps_max'] = Variable<int>(defaultRepsMax);
    map['default_seconds_min'] = Variable<int>(defaultSecondsMin);
    map['default_seconds_max'] = Variable<int>(defaultSecondsMax);
    map['progression_enabled'] = Variable<bool>(progressionEnabled);
    return map;
  }

  ProfileSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return ProfileSettingsTableCompanion(
      id: Value(id),
      schemaVersion: Value(schemaVersion),
      defaultRepsMin: Value(defaultRepsMin),
      defaultRepsMax: Value(defaultRepsMax),
      defaultSecondsMin: Value(defaultSecondsMin),
      defaultSecondsMax: Value(defaultSecondsMax),
      progressionEnabled: Value(progressionEnabled),
    );
  }

  factory ProfileSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      defaultRepsMin: serializer.fromJson<int>(json['defaultRepsMin']),
      defaultRepsMax: serializer.fromJson<int>(json['defaultRepsMax']),
      defaultSecondsMin: serializer.fromJson<int>(json['defaultSecondsMin']),
      defaultSecondsMax: serializer.fromJson<int>(json['defaultSecondsMax']),
      progressionEnabled: serializer.fromJson<bool>(json['progressionEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'defaultRepsMin': serializer.toJson<int>(defaultRepsMin),
      'defaultRepsMax': serializer.toJson<int>(defaultRepsMax),
      'defaultSecondsMin': serializer.toJson<int>(defaultSecondsMin),
      'defaultSecondsMax': serializer.toJson<int>(defaultSecondsMax),
      'progressionEnabled': serializer.toJson<bool>(progressionEnabled),
    };
  }

  ProfileSettingsRow copyWith({
    int? id,
    int? schemaVersion,
    int? defaultRepsMin,
    int? defaultRepsMax,
    int? defaultSecondsMin,
    int? defaultSecondsMax,
    bool? progressionEnabled,
  }) => ProfileSettingsRow(
    id: id ?? this.id,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    defaultRepsMin: defaultRepsMin ?? this.defaultRepsMin,
    defaultRepsMax: defaultRepsMax ?? this.defaultRepsMax,
    defaultSecondsMin: defaultSecondsMin ?? this.defaultSecondsMin,
    defaultSecondsMax: defaultSecondsMax ?? this.defaultSecondsMax,
    progressionEnabled: progressionEnabled ?? this.progressionEnabled,
  );
  ProfileSettingsRow copyWithCompanion(ProfileSettingsTableCompanion data) {
    return ProfileSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      defaultRepsMin: data.defaultRepsMin.present
          ? data.defaultRepsMin.value
          : this.defaultRepsMin,
      defaultRepsMax: data.defaultRepsMax.present
          ? data.defaultRepsMax.value
          : this.defaultRepsMax,
      defaultSecondsMin: data.defaultSecondsMin.present
          ? data.defaultSecondsMin.value
          : this.defaultSecondsMin,
      defaultSecondsMax: data.defaultSecondsMax.present
          ? data.defaultSecondsMax.value
          : this.defaultSecondsMax,
      progressionEnabled: data.progressionEnabled.present
          ? data.progressionEnabled.value
          : this.progressionEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileSettingsRow(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('defaultRepsMin: $defaultRepsMin, ')
          ..write('defaultRepsMax: $defaultRepsMax, ')
          ..write('defaultSecondsMin: $defaultSecondsMin, ')
          ..write('defaultSecondsMax: $defaultSecondsMax, ')
          ..write('progressionEnabled: $progressionEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schemaVersion,
    defaultRepsMin,
    defaultRepsMax,
    defaultSecondsMin,
    defaultSecondsMax,
    progressionEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileSettingsRow &&
          other.id == this.id &&
          other.schemaVersion == this.schemaVersion &&
          other.defaultRepsMin == this.defaultRepsMin &&
          other.defaultRepsMax == this.defaultRepsMax &&
          other.defaultSecondsMin == this.defaultSecondsMin &&
          other.defaultSecondsMax == this.defaultSecondsMax &&
          other.progressionEnabled == this.progressionEnabled);
}

class ProfileSettingsTableCompanion
    extends UpdateCompanion<ProfileSettingsRow> {
  final Value<int> id;
  final Value<int> schemaVersion;
  final Value<int> defaultRepsMin;
  final Value<int> defaultRepsMax;
  final Value<int> defaultSecondsMin;
  final Value<int> defaultSecondsMax;
  final Value<bool> progressionEnabled;
  const ProfileSettingsTableCompanion({
    this.id = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.defaultRepsMin = const Value.absent(),
    this.defaultRepsMax = const Value.absent(),
    this.defaultSecondsMin = const Value.absent(),
    this.defaultSecondsMax = const Value.absent(),
    this.progressionEnabled = const Value.absent(),
  });
  ProfileSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.defaultRepsMin = const Value.absent(),
    this.defaultRepsMax = const Value.absent(),
    this.defaultSecondsMin = const Value.absent(),
    this.defaultSecondsMax = const Value.absent(),
    this.progressionEnabled = const Value.absent(),
  });
  static Insertable<ProfileSettingsRow> custom({
    Expression<int>? id,
    Expression<int>? schemaVersion,
    Expression<int>? defaultRepsMin,
    Expression<int>? defaultRepsMax,
    Expression<int>? defaultSecondsMin,
    Expression<int>? defaultSecondsMax,
    Expression<bool>? progressionEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (defaultRepsMin != null) 'default_reps_min': defaultRepsMin,
      if (defaultRepsMax != null) 'default_reps_max': defaultRepsMax,
      if (defaultSecondsMin != null) 'default_seconds_min': defaultSecondsMin,
      if (defaultSecondsMax != null) 'default_seconds_max': defaultSecondsMax,
      if (progressionEnabled != null) 'progression_enabled': progressionEnabled,
    });
  }

  ProfileSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? schemaVersion,
    Value<int>? defaultRepsMin,
    Value<int>? defaultRepsMax,
    Value<int>? defaultSecondsMin,
    Value<int>? defaultSecondsMax,
    Value<bool>? progressionEnabled,
  }) {
    return ProfileSettingsTableCompanion(
      id: id ?? this.id,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      defaultRepsMin: defaultRepsMin ?? this.defaultRepsMin,
      defaultRepsMax: defaultRepsMax ?? this.defaultRepsMax,
      defaultSecondsMin: defaultSecondsMin ?? this.defaultSecondsMin,
      defaultSecondsMax: defaultSecondsMax ?? this.defaultSecondsMax,
      progressionEnabled: progressionEnabled ?? this.progressionEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (defaultRepsMin.present) {
      map['default_reps_min'] = Variable<int>(defaultRepsMin.value);
    }
    if (defaultRepsMax.present) {
      map['default_reps_max'] = Variable<int>(defaultRepsMax.value);
    }
    if (defaultSecondsMin.present) {
      map['default_seconds_min'] = Variable<int>(defaultSecondsMin.value);
    }
    if (defaultSecondsMax.present) {
      map['default_seconds_max'] = Variable<int>(defaultSecondsMax.value);
    }
    if (progressionEnabled.present) {
      map['progression_enabled'] = Variable<bool>(progressionEnabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('defaultRepsMin: $defaultRepsMin, ')
          ..write('defaultRepsMax: $defaultRepsMax, ')
          ..write('defaultSecondsMin: $defaultSecondsMin, ')
          ..write('defaultSecondsMax: $defaultSecondsMax, ')
          ..write('progressionEnabled: $progressionEnabled')
          ..write(')'))
        .toString();
  }
}

class $DisabledCategoriesTable extends DisabledCategories
    with TableInfo<$DisabledCategoriesTable, DisabledCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DisabledCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [path];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'disabled_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<DisabledCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {path};
  @override
  DisabledCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DisabledCategoryRow(
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
    );
  }

  @override
  $DisabledCategoriesTable createAlias(String alias) {
    return $DisabledCategoriesTable(attachedDatabase, alias);
  }
}

class DisabledCategoryRow extends DataClass
    implements Insertable<DisabledCategoryRow> {
  final String path;
  const DisabledCategoryRow({required this.path});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['path'] = Variable<String>(path);
    return map;
  }

  DisabledCategoriesCompanion toCompanion(bool nullToAbsent) {
    return DisabledCategoriesCompanion(path: Value(path));
  }

  factory DisabledCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DisabledCategoryRow(path: serializer.fromJson<String>(json['path']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'path': serializer.toJson<String>(path)};
  }

  DisabledCategoryRow copyWith({String? path}) =>
      DisabledCategoryRow(path: path ?? this.path);
  DisabledCategoryRow copyWithCompanion(DisabledCategoriesCompanion data) {
    return DisabledCategoryRow(
      path: data.path.present ? data.path.value : this.path,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DisabledCategoryRow(')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => path.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DisabledCategoryRow && other.path == this.path);
}

class DisabledCategoriesCompanion extends UpdateCompanion<DisabledCategoryRow> {
  final Value<String> path;
  final Value<int> rowid;
  const DisabledCategoriesCompanion({
    this.path = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DisabledCategoriesCompanion.insert({
    required String path,
    this.rowid = const Value.absent(),
  }) : path = Value(path);
  static Insertable<DisabledCategoryRow> custom({
    Expression<String>? path,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (path != null) 'path': path,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DisabledCategoriesCompanion copyWith({
    Value<String>? path,
    Value<int>? rowid,
  }) {
    return DisabledCategoriesCompanion(
      path: path ?? this.path,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DisabledCategoriesCompanion(')
          ..write('path: $path, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseTargetsTable extends ExerciseTargets
    with TableInfo<$ExerciseTargetsTable, ExerciseTargetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseTargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMinMeta = const VerificationMeta(
    'targetMin',
  );
  @override
  late final GeneratedColumn<int> targetMin = GeneratedColumn<int>(
    'target_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMaxMeta = const VerificationMeta(
    'targetMax',
  );
  @override
  late final GeneratedColumn<int> targetMax = GeneratedColumn<int>(
    'target_max',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockedByUserMeta = const VerificationMeta(
    'lockedByUser',
  );
  @override
  late final GeneratedColumn<bool> lockedByUser = GeneratedColumn<bool>(
    'locked_by_user',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked_by_user" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    exerciseId,
    targetMin,
    targetMax,
    lockedByUser,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseTargetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('target_min')) {
      context.handle(
        _targetMinMeta,
        targetMin.isAcceptableOrUnknown(data['target_min']!, _targetMinMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMinMeta);
    }
    if (data.containsKey('target_max')) {
      context.handle(
        _targetMaxMeta,
        targetMax.isAcceptableOrUnknown(data['target_max']!, _targetMaxMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMaxMeta);
    }
    if (data.containsKey('locked_by_user')) {
      context.handle(
        _lockedByUserMeta,
        lockedByUser.isAcceptableOrUnknown(
          data['locked_by_user']!,
          _lockedByUserMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId};
  @override
  ExerciseTargetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseTargetRow(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      targetMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_min'],
      )!,
      targetMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_max'],
      )!,
      lockedByUser: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked_by_user'],
      )!,
    );
  }

  @override
  $ExerciseTargetsTable createAlias(String alias) {
    return $ExerciseTargetsTable(attachedDatabase, alias);
  }
}

class ExerciseTargetRow extends DataClass
    implements Insertable<ExerciseTargetRow> {
  final String exerciseId;
  final int targetMin;
  final int targetMax;
  final bool lockedByUser;
  const ExerciseTargetRow({
    required this.exerciseId,
    required this.targetMin,
    required this.targetMax,
    required this.lockedByUser,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['target_min'] = Variable<int>(targetMin);
    map['target_max'] = Variable<int>(targetMax);
    map['locked_by_user'] = Variable<bool>(lockedByUser);
    return map;
  }

  ExerciseTargetsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseTargetsCompanion(
      exerciseId: Value(exerciseId),
      targetMin: Value(targetMin),
      targetMax: Value(targetMax),
      lockedByUser: Value(lockedByUser),
    );
  }

  factory ExerciseTargetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseTargetRow(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      targetMin: serializer.fromJson<int>(json['targetMin']),
      targetMax: serializer.fromJson<int>(json['targetMax']),
      lockedByUser: serializer.fromJson<bool>(json['lockedByUser']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'targetMin': serializer.toJson<int>(targetMin),
      'targetMax': serializer.toJson<int>(targetMax),
      'lockedByUser': serializer.toJson<bool>(lockedByUser),
    };
  }

  ExerciseTargetRow copyWith({
    String? exerciseId,
    int? targetMin,
    int? targetMax,
    bool? lockedByUser,
  }) => ExerciseTargetRow(
    exerciseId: exerciseId ?? this.exerciseId,
    targetMin: targetMin ?? this.targetMin,
    targetMax: targetMax ?? this.targetMax,
    lockedByUser: lockedByUser ?? this.lockedByUser,
  );
  ExerciseTargetRow copyWithCompanion(ExerciseTargetsCompanion data) {
    return ExerciseTargetRow(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      targetMin: data.targetMin.present ? data.targetMin.value : this.targetMin,
      targetMax: data.targetMax.present ? data.targetMax.value : this.targetMax,
      lockedByUser: data.lockedByUser.present
          ? data.lockedByUser.value
          : this.lockedByUser,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseTargetRow(')
          ..write('exerciseId: $exerciseId, ')
          ..write('targetMin: $targetMin, ')
          ..write('targetMax: $targetMax, ')
          ..write('lockedByUser: $lockedByUser')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(exerciseId, targetMin, targetMax, lockedByUser);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseTargetRow &&
          other.exerciseId == this.exerciseId &&
          other.targetMin == this.targetMin &&
          other.targetMax == this.targetMax &&
          other.lockedByUser == this.lockedByUser);
}

class ExerciseTargetsCompanion extends UpdateCompanion<ExerciseTargetRow> {
  final Value<String> exerciseId;
  final Value<int> targetMin;
  final Value<int> targetMax;
  final Value<bool> lockedByUser;
  final Value<int> rowid;
  const ExerciseTargetsCompanion({
    this.exerciseId = const Value.absent(),
    this.targetMin = const Value.absent(),
    this.targetMax = const Value.absent(),
    this.lockedByUser = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseTargetsCompanion.insert({
    required String exerciseId,
    required int targetMin,
    required int targetMax,
    this.lockedByUser = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       targetMin = Value(targetMin),
       targetMax = Value(targetMax);
  static Insertable<ExerciseTargetRow> custom({
    Expression<String>? exerciseId,
    Expression<int>? targetMin,
    Expression<int>? targetMax,
    Expression<bool>? lockedByUser,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (targetMin != null) 'target_min': targetMin,
      if (targetMax != null) 'target_max': targetMax,
      if (lockedByUser != null) 'locked_by_user': lockedByUser,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseTargetsCompanion copyWith({
    Value<String>? exerciseId,
    Value<int>? targetMin,
    Value<int>? targetMax,
    Value<bool>? lockedByUser,
    Value<int>? rowid,
  }) {
    return ExerciseTargetsCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      targetMin: targetMin ?? this.targetMin,
      targetMax: targetMax ?? this.targetMax,
      lockedByUser: lockedByUser ?? this.lockedByUser,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (targetMin.present) {
      map['target_min'] = Variable<int>(targetMin.value);
    }
    if (targetMax.present) {
      map['target_max'] = Variable<int>(targetMax.value);
    }
    if (lockedByUser.present) {
      map['locked_by_user'] = Variable<bool>(lockedByUser.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseTargetsCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('targetMin: $targetMin, ')
          ..write('targetMax: $targetMax, ')
          ..write('lockedByUser: $lockedByUser, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionPreferencesTableTable extends SessionPreferencesTable
    with TableInfo<$SessionPreferencesTableTable, SessionPreferencesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionPreferencesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _templateMeta = const VerificationMeta(
    'template',
  );
  @override
  late final GeneratedColumn<String> template = GeneratedColumn<String>(
    'template',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('dual_task'),
  );
  static const VerificationMeta _roundsMeta = const VerificationMeta('rounds');
  @override
  late final GeneratedColumn<int> rounds = GeneratedColumn<int>(
    'rounds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _cognitiveSecMeta = const VerificationMeta(
    'cognitiveSec',
  );
  @override
  late final GeneratedColumn<int> cognitiveSec = GeneratedColumn<int>(
    'cognitive_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(180),
  );
  static const VerificationMeta _restSecMeta = const VerificationMeta(
    'restSec',
  );
  @override
  late final GeneratedColumn<int> restSec = GeneratedColumn<int>(
    'rest_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('HOME'),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('recruit'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    template,
    rounds,
    cognitiveSec,
    restSec,
    location,
    difficulty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionPreferencesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('template')) {
      context.handle(
        _templateMeta,
        template.isAcceptableOrUnknown(data['template']!, _templateMeta),
      );
    }
    if (data.containsKey('rounds')) {
      context.handle(
        _roundsMeta,
        rounds.isAcceptableOrUnknown(data['rounds']!, _roundsMeta),
      );
    }
    if (data.containsKey('cognitive_sec')) {
      context.handle(
        _cognitiveSecMeta,
        cognitiveSec.isAcceptableOrUnknown(
          data['cognitive_sec']!,
          _cognitiveSecMeta,
        ),
      );
    }
    if (data.containsKey('rest_sec')) {
      context.handle(
        _restSecMeta,
        restSec.isAcceptableOrUnknown(data['rest_sec']!, _restSecMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionPreferencesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionPreferencesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      template: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template'],
      )!,
      rounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounds'],
      )!,
      cognitiveSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cognitive_sec'],
      )!,
      restSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_sec'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      )!,
    );
  }

  @override
  $SessionPreferencesTableTable createAlias(String alias) {
    return $SessionPreferencesTableTable(attachedDatabase, alias);
  }
}

class SessionPreferencesRow extends DataClass
    implements Insertable<SessionPreferencesRow> {
  final int id;
  final String template;
  final int rounds;
  final int cognitiveSec;
  final int restSec;
  final String location;
  final String difficulty;
  const SessionPreferencesRow({
    required this.id,
    required this.template,
    required this.rounds,
    required this.cognitiveSec,
    required this.restSec,
    required this.location,
    required this.difficulty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['template'] = Variable<String>(template);
    map['rounds'] = Variable<int>(rounds);
    map['cognitive_sec'] = Variable<int>(cognitiveSec);
    map['rest_sec'] = Variable<int>(restSec);
    map['location'] = Variable<String>(location);
    map['difficulty'] = Variable<String>(difficulty);
    return map;
  }

  SessionPreferencesTableCompanion toCompanion(bool nullToAbsent) {
    return SessionPreferencesTableCompanion(
      id: Value(id),
      template: Value(template),
      rounds: Value(rounds),
      cognitiveSec: Value(cognitiveSec),
      restSec: Value(restSec),
      location: Value(location),
      difficulty: Value(difficulty),
    );
  }

  factory SessionPreferencesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionPreferencesRow(
      id: serializer.fromJson<int>(json['id']),
      template: serializer.fromJson<String>(json['template']),
      rounds: serializer.fromJson<int>(json['rounds']),
      cognitiveSec: serializer.fromJson<int>(json['cognitiveSec']),
      restSec: serializer.fromJson<int>(json['restSec']),
      location: serializer.fromJson<String>(json['location']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'template': serializer.toJson<String>(template),
      'rounds': serializer.toJson<int>(rounds),
      'cognitiveSec': serializer.toJson<int>(cognitiveSec),
      'restSec': serializer.toJson<int>(restSec),
      'location': serializer.toJson<String>(location),
      'difficulty': serializer.toJson<String>(difficulty),
    };
  }

  SessionPreferencesRow copyWith({
    int? id,
    String? template,
    int? rounds,
    int? cognitiveSec,
    int? restSec,
    String? location,
    String? difficulty,
  }) => SessionPreferencesRow(
    id: id ?? this.id,
    template: template ?? this.template,
    rounds: rounds ?? this.rounds,
    cognitiveSec: cognitiveSec ?? this.cognitiveSec,
    restSec: restSec ?? this.restSec,
    location: location ?? this.location,
    difficulty: difficulty ?? this.difficulty,
  );
  SessionPreferencesRow copyWithCompanion(
    SessionPreferencesTableCompanion data,
  ) {
    return SessionPreferencesRow(
      id: data.id.present ? data.id.value : this.id,
      template: data.template.present ? data.template.value : this.template,
      rounds: data.rounds.present ? data.rounds.value : this.rounds,
      cognitiveSec: data.cognitiveSec.present
          ? data.cognitiveSec.value
          : this.cognitiveSec,
      restSec: data.restSec.present ? data.restSec.value : this.restSec,
      location: data.location.present ? data.location.value : this.location,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionPreferencesRow(')
          ..write('id: $id, ')
          ..write('template: $template, ')
          ..write('rounds: $rounds, ')
          ..write('cognitiveSec: $cognitiveSec, ')
          ..write('restSec: $restSec, ')
          ..write('location: $location, ')
          ..write('difficulty: $difficulty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    template,
    rounds,
    cognitiveSec,
    restSec,
    location,
    difficulty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionPreferencesRow &&
          other.id == this.id &&
          other.template == this.template &&
          other.rounds == this.rounds &&
          other.cognitiveSec == this.cognitiveSec &&
          other.restSec == this.restSec &&
          other.location == this.location &&
          other.difficulty == this.difficulty);
}

class SessionPreferencesTableCompanion
    extends UpdateCompanion<SessionPreferencesRow> {
  final Value<int> id;
  final Value<String> template;
  final Value<int> rounds;
  final Value<int> cognitiveSec;
  final Value<int> restSec;
  final Value<String> location;
  final Value<String> difficulty;
  const SessionPreferencesTableCompanion({
    this.id = const Value.absent(),
    this.template = const Value.absent(),
    this.rounds = const Value.absent(),
    this.cognitiveSec = const Value.absent(),
    this.restSec = const Value.absent(),
    this.location = const Value.absent(),
    this.difficulty = const Value.absent(),
  });
  SessionPreferencesTableCompanion.insert({
    this.id = const Value.absent(),
    this.template = const Value.absent(),
    this.rounds = const Value.absent(),
    this.cognitiveSec = const Value.absent(),
    this.restSec = const Value.absent(),
    this.location = const Value.absent(),
    this.difficulty = const Value.absent(),
  });
  static Insertable<SessionPreferencesRow> custom({
    Expression<int>? id,
    Expression<String>? template,
    Expression<int>? rounds,
    Expression<int>? cognitiveSec,
    Expression<int>? restSec,
    Expression<String>? location,
    Expression<String>? difficulty,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (template != null) 'template': template,
      if (rounds != null) 'rounds': rounds,
      if (cognitiveSec != null) 'cognitive_sec': cognitiveSec,
      if (restSec != null) 'rest_sec': restSec,
      if (location != null) 'location': location,
      if (difficulty != null) 'difficulty': difficulty,
    });
  }

  SessionPreferencesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? template,
    Value<int>? rounds,
    Value<int>? cognitiveSec,
    Value<int>? restSec,
    Value<String>? location,
    Value<String>? difficulty,
  }) {
    return SessionPreferencesTableCompanion(
      id: id ?? this.id,
      template: template ?? this.template,
      rounds: rounds ?? this.rounds,
      cognitiveSec: cognitiveSec ?? this.cognitiveSec,
      restSec: restSec ?? this.restSec,
      location: location ?? this.location,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (template.present) {
      map['template'] = Variable<String>(template.value);
    }
    if (rounds.present) {
      map['rounds'] = Variable<int>(rounds.value);
    }
    if (cognitiveSec.present) {
      map['cognitive_sec'] = Variable<int>(cognitiveSec.value);
    }
    if (restSec.present) {
      map['rest_sec'] = Variable<int>(restSec.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionPreferencesTableCompanion(')
          ..write('id: $id, ')
          ..write('template: $template, ')
          ..write('rounds: $rounds, ')
          ..write('cognitiveSec: $cognitiveSec, ')
          ..write('restSec: $restSec, ')
          ..write('location: $location, ')
          ..write('difficulty: $difficulty')
          ..write(')'))
        .toString();
  }
}

class $UserPacksTable extends UserPacks
    with TableInfo<$UserPacksTable, UserPackRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packSourceMeta = const VerificationMeta(
    'packSource',
  );
  @override
  late final GeneratedColumn<String> packSource = GeneratedColumn<String>(
    'pack_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemCountMeta = const VerificationMeta(
    'itemCount',
  );
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
    'item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<int> installedAt = GeneratedColumn<int>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    kind,
    packId,
    packSource,
    title,
    locale,
    itemCount,
    installedAt,
    content,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPackRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('pack_source')) {
      context.handle(
        _packSourceMeta,
        packSource.isAcceptableOrUnknown(data['pack_source']!, _packSourceMeta),
      );
    } else if (isInserting) {
      context.missing(_packSourceMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    if (data.containsKey('item_count')) {
      context.handle(
        _itemCountMeta,
        itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta),
      );
    } else if (isInserting) {
      context.missing(_itemCountMeta);
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installedAtMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {kind, packId};
  @override
  UserPackRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPackRow(
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
      packSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_source'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      itemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_count'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installed_at'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $UserPacksTable createAlias(String alias) {
    return $UserPacksTable(attachedDatabase, alias);
  }
}

class UserPackRow extends DataClass implements Insertable<UserPackRow> {
  /// `task_pack` | `exercise_pack`.
  final String kind;

  /// Поле `pack` документа.
  final String packId;

  /// `imported` | `user`; присваивает тот, кто пак установил (решение 10).
  final String packSource;
  final String title;

  /// `locale` пака задач или `defaultLocale` пака упражнений.
  final String locale;
  final int itemCount;
  final int installedAt;

  /// Канонический JSON документа (`toJson`), `kind` и `schemaVersion` внутри.
  final String content;
  const UserPackRow({
    required this.kind,
    required this.packId,
    required this.packSource,
    required this.title,
    required this.locale,
    required this.itemCount,
    required this.installedAt,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['kind'] = Variable<String>(kind);
    map['pack_id'] = Variable<String>(packId);
    map['pack_source'] = Variable<String>(packSource);
    map['title'] = Variable<String>(title);
    map['locale'] = Variable<String>(locale);
    map['item_count'] = Variable<int>(itemCount);
    map['installed_at'] = Variable<int>(installedAt);
    map['content'] = Variable<String>(content);
    return map;
  }

  UserPacksCompanion toCompanion(bool nullToAbsent) {
    return UserPacksCompanion(
      kind: Value(kind),
      packId: Value(packId),
      packSource: Value(packSource),
      title: Value(title),
      locale: Value(locale),
      itemCount: Value(itemCount),
      installedAt: Value(installedAt),
      content: Value(content),
    );
  }

  factory UserPackRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPackRow(
      kind: serializer.fromJson<String>(json['kind']),
      packId: serializer.fromJson<String>(json['packId']),
      packSource: serializer.fromJson<String>(json['packSource']),
      title: serializer.fromJson<String>(json['title']),
      locale: serializer.fromJson<String>(json['locale']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
      installedAt: serializer.fromJson<int>(json['installedAt']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'kind': serializer.toJson<String>(kind),
      'packId': serializer.toJson<String>(packId),
      'packSource': serializer.toJson<String>(packSource),
      'title': serializer.toJson<String>(title),
      'locale': serializer.toJson<String>(locale),
      'itemCount': serializer.toJson<int>(itemCount),
      'installedAt': serializer.toJson<int>(installedAt),
      'content': serializer.toJson<String>(content),
    };
  }

  UserPackRow copyWith({
    String? kind,
    String? packId,
    String? packSource,
    String? title,
    String? locale,
    int? itemCount,
    int? installedAt,
    String? content,
  }) => UserPackRow(
    kind: kind ?? this.kind,
    packId: packId ?? this.packId,
    packSource: packSource ?? this.packSource,
    title: title ?? this.title,
    locale: locale ?? this.locale,
    itemCount: itemCount ?? this.itemCount,
    installedAt: installedAt ?? this.installedAt,
    content: content ?? this.content,
  );
  UserPackRow copyWithCompanion(UserPacksCompanion data) {
    return UserPackRow(
      kind: data.kind.present ? data.kind.value : this.kind,
      packId: data.packId.present ? data.packId.value : this.packId,
      packSource: data.packSource.present
          ? data.packSource.value
          : this.packSource,
      title: data.title.present ? data.title.value : this.title,
      locale: data.locale.present ? data.locale.value : this.locale,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPackRow(')
          ..write('kind: $kind, ')
          ..write('packId: $packId, ')
          ..write('packSource: $packSource, ')
          ..write('title: $title, ')
          ..write('locale: $locale, ')
          ..write('itemCount: $itemCount, ')
          ..write('installedAt: $installedAt, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    kind,
    packId,
    packSource,
    title,
    locale,
    itemCount,
    installedAt,
    content,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPackRow &&
          other.kind == this.kind &&
          other.packId == this.packId &&
          other.packSource == this.packSource &&
          other.title == this.title &&
          other.locale == this.locale &&
          other.itemCount == this.itemCount &&
          other.installedAt == this.installedAt &&
          other.content == this.content);
}

class UserPacksCompanion extends UpdateCompanion<UserPackRow> {
  final Value<String> kind;
  final Value<String> packId;
  final Value<String> packSource;
  final Value<String> title;
  final Value<String> locale;
  final Value<int> itemCount;
  final Value<int> installedAt;
  final Value<String> content;
  final Value<int> rowid;
  const UserPacksCompanion({
    this.kind = const Value.absent(),
    this.packId = const Value.absent(),
    this.packSource = const Value.absent(),
    this.title = const Value.absent(),
    this.locale = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPacksCompanion.insert({
    required String kind,
    required String packId,
    required String packSource,
    required String title,
    required String locale,
    required int itemCount,
    required int installedAt,
    required String content,
    this.rowid = const Value.absent(),
  }) : kind = Value(kind),
       packId = Value(packId),
       packSource = Value(packSource),
       title = Value(title),
       locale = Value(locale),
       itemCount = Value(itemCount),
       installedAt = Value(installedAt),
       content = Value(content);
  static Insertable<UserPackRow> custom({
    Expression<String>? kind,
    Expression<String>? packId,
    Expression<String>? packSource,
    Expression<String>? title,
    Expression<String>? locale,
    Expression<int>? itemCount,
    Expression<int>? installedAt,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (kind != null) 'kind': kind,
      if (packId != null) 'pack_id': packId,
      if (packSource != null) 'pack_source': packSource,
      if (title != null) 'title': title,
      if (locale != null) 'locale': locale,
      if (itemCount != null) 'item_count': itemCount,
      if (installedAt != null) 'installed_at': installedAt,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPacksCompanion copyWith({
    Value<String>? kind,
    Value<String>? packId,
    Value<String>? packSource,
    Value<String>? title,
    Value<String>? locale,
    Value<int>? itemCount,
    Value<int>? installedAt,
    Value<String>? content,
    Value<int>? rowid,
  }) {
    return UserPacksCompanion(
      kind: kind ?? this.kind,
      packId: packId ?? this.packId,
      packSource: packSource ?? this.packSource,
      title: title ?? this.title,
      locale: locale ?? this.locale,
      itemCount: itemCount ?? this.itemCount,
      installedAt: installedAt ?? this.installedAt,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (packSource.present) {
      map['pack_source'] = Variable<String>(packSource.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<int>(installedAt.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPacksCompanion(')
          ..write('kind: $kind, ')
          ..write('packId: $packId, ')
          ..write('packSource: $packSource, ')
          ..write('title: $title, ')
          ..write('locale: $locale, ')
          ..write('itemCount: $itemCount, ')
          ..write('installedAt: $installedAt, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$TmbDatabase extends GeneratedDatabase {
  _$TmbDatabase(QueryExecutor e) : super(e);
  $TmbDatabaseManager get managers => $TmbDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $RoundLogsTable roundLogs = $RoundLogsTable(this);
  late final $ExerciseSetsTable exerciseSets = $ExerciseSetsTable(this);
  late final $TaskAttemptsTable taskAttempts = $TaskAttemptsTable(this);
  late final $ProfileSettingsTableTable profileSettingsTable =
      $ProfileSettingsTableTable(this);
  late final $DisabledCategoriesTable disabledCategories =
      $DisabledCategoriesTable(this);
  late final $ExerciseTargetsTable exerciseTargets = $ExerciseTargetsTable(
    this,
  );
  late final $SessionPreferencesTableTable sessionPreferencesTable =
      $SessionPreferencesTableTable(this);
  late final $UserPacksTable userPacks = $UserPacksTable(this);
  late final Index idxRoundLogsSession = Index(
    'idx_round_logs_session',
    'CREATE INDEX idx_round_logs_session ON round_logs (session_id)',
  );
  late final Index idxExerciseSetsSession = Index(
    'idx_exercise_sets_session',
    'CREATE INDEX idx_exercise_sets_session ON exercise_sets (session_id)',
  );
  late final Index idxExerciseSetsRound = Index(
    'idx_exercise_sets_round',
    'CREATE INDEX idx_exercise_sets_round ON exercise_sets (round_id)',
  );
  late final Index idxExerciseSetsExerciseTime = Index(
    'idx_exercise_sets_exercise_time',
    'CREATE INDEX idx_exercise_sets_exercise_time ON exercise_sets (exercise_id, started_at)',
  );
  late final Index idxTaskAttemptsSession = Index(
    'idx_task_attempts_session',
    'CREATE INDEX idx_task_attempts_session ON task_attempts (session_id)',
  );
  late final Index idxTaskAttemptsPack = Index(
    'idx_task_attempts_pack',
    'CREATE INDEX idx_task_attempts_pack ON task_attempts (pack_id, task_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessions,
    roundLogs,
    exerciseSets,
    taskAttempts,
    profileSettingsTable,
    disabledCategories,
    exerciseTargets,
    sessionPreferencesTable,
    userPacks,
    idxRoundLogsSession,
    idxExerciseSetsSession,
    idxExerciseSetsRound,
    idxExerciseSetsExerciseTime,
    idxTaskAttemptsSession,
    idxTaskAttemptsPack,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('round_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'round_logs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('task_attempts', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required int startedAt,
  Value<int?> endedAt,
  required int utcOffsetMin,
  required String location,
  required String difficulty,
  required String template,
  required String appVersion,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<int> startedAt,
  Value<int?> endedAt,
  Value<int> utcOffsetMin,
  Value<String> location,
  Value<String> difficulty,
  Value<String> template,
  Value<String> appVersion,
  Value<int> rowid,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$TmbDatabase, $SessionsTable, SessionRow> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoundLogsTable, List<RoundLogRow>>
  _roundLogsRefsTable(_$TmbDatabase db) => MultiTypedResultKey.fromTable(
    db.roundLogs,
    aliasName: 'sessions__id__round_logs__session_id',
  );

  $$RoundLogsTableProcessedTableManager get roundLogsRefs {
    final manager = $$RoundLogsTableTableManager(
      $_db,
      $_db.roundLogs,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_roundLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseSetsTable, List<ExerciseSetRow>>
  _exerciseSetsRefsTable(_$TmbDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseSets,
    aliasName: 'sessions__id__exercise_sets__session_id',
  );

  $$ExerciseSetsTableProcessedTableManager get exerciseSetsRefs {
    final manager = $$ExerciseSetsTableTableManager(
      $_db,
      $_db.exerciseSets,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TaskAttemptsTable, List<TaskAttemptRow>>
  _taskAttemptsRefsTable(_$TmbDatabase db) => MultiTypedResultKey.fromTable(
    db.taskAttempts,
    aliasName: 'sessions__id__task_attempts__session_id',
  );

  $$TaskAttemptsTableProcessedTableManager get taskAttemptsRefs {
    final manager = $$TaskAttemptsTableTableManager(
      $_db,
      $_db.taskAttempts,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskAttemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$TmbDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get utcOffsetMin => $composableBuilder(
    column: $table.utcOffsetMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get template => $composableBuilder(
    column: $table.template,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> roundLogsRefs(
    Expression<bool> Function($$RoundLogsTableFilterComposer f) f,
  ) {
    final $$RoundLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.roundLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundLogsTableFilterComposer(
            $db: $db,
            $table: $db.roundLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseSetsRefs(
    Expression<bool> Function($$ExerciseSetsTableFilterComposer f) f,
  ) {
    final $$ExerciseSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskAttemptsRefs(
    Expression<bool> Function($$TaskAttemptsTableFilterComposer f) f,
  ) {
    final $$TaskAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskAttempts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.taskAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$TmbDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get utcOffsetMin => $composableBuilder(
    column: $table.utcOffsetMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get template => $composableBuilder(
    column: $table.template,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$TmbDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get utcOffsetMin => $composableBuilder(
    column: $table.utcOffsetMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get template =>
      $composableBuilder(column: $table.template, builder: (column) => column);

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  Expression<T> roundLogsRefs<T extends Object>(
    Expression<T> Function($$RoundLogsTableAnnotationComposer a) f,
  ) {
    final $$RoundLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.roundLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.roundLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseSetsRefs<T extends Object>(
    Expression<T> Function($$ExerciseSetsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskAttemptsRefs<T extends Object>(
    Expression<T> Function($$TaskAttemptsTableAnnotationComposer a) f,
  ) {
    final $$TaskAttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskAttempts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskAttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.taskAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$TmbDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (SessionRow, $$SessionsTableReferences),
          SessionRow,
          PrefetchHooks Function({
            bool roundLogsRefs,
            bool exerciseSetsRefs,
            bool taskAttemptsRefs,
          })
        > {
  $$SessionsTableTableManager(_$TmbDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<int> utcOffsetMin = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<String> template = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                utcOffsetMin: utcOffsetMin,
                location: location,
                difficulty: difficulty,
                template: template,
                appVersion: appVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int startedAt,
                Value<int?> endedAt = const Value.absent(),
                required int utcOffsetMin,
                required String location,
                required String difficulty,
                required String template,
                required String appVersion,
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                utcOffsetMin: utcOffsetMin,
                location: location,
                difficulty: difficulty,
                template: template,
                appVersion: appVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, SessionRow>(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                roundLogsRefs = false,
                exerciseSetsRefs = false,
                taskAttemptsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (roundLogsRefs) db.roundLogs,
                    if (exerciseSetsRefs) db.exerciseSets,
                    if (taskAttemptsRefs) db.taskAttempts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (roundLogsRefs)
                        await $_getPrefetchedDataByColumns<
                          SessionRow,
                          $SessionsTable,
                          RoundLogRow,
                          $RoundLogsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._roundLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).roundLogsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (exerciseSetsRefs)
                        await $_getPrefetchedDataByColumns<
                          SessionRow,
                          $SessionsTable,
                          ExerciseSetRow,
                          $ExerciseSetsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._exerciseSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseSetsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (taskAttemptsRefs)
                        await $_getPrefetchedDataByColumns<
                          SessionRow,
                          $SessionsTable,
                          TaskAttemptRow,
                          $TaskAttemptsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._taskAttemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).taskAttemptsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$TmbDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, $$SessionsTableReferences),
      SessionRow,
      PrefetchHooks Function({
        bool roundLogsRefs,
        bool exerciseSetsRefs,
        bool taskAttemptsRefs,
      })
    >;
typedef $$RoundLogsTableCreateCompanionBuilder = RoundLogsCompanion Function({
  required String id,
  required String sessionId,
  required int blockIndex,
  required int roundIndex,
  required int durationMs,
  Value<int?> rpe,
  Value<int> rowid,
});
typedef $$RoundLogsTableUpdateCompanionBuilder = RoundLogsCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<int> blockIndex,
  Value<int> roundIndex,
  Value<int> durationMs,
  Value<int?> rpe,
  Value<int> rowid,
});

final class $$RoundLogsTableReferences
    extends BaseReferences<_$TmbDatabase, $RoundLogsTable, RoundLogRow> {
  $$RoundLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$TmbDatabase db) =>
      db.sessions.createAlias('round_logs__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExerciseSetsTable, List<ExerciseSetRow>>
  _exerciseSetsRefsTable(_$TmbDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseSets,
    aliasName: 'round_logs__id__exercise_sets__round_id',
  );

  $$ExerciseSetsTableProcessedTableManager get exerciseSetsRefs {
    final manager = $$ExerciseSetsTableTableManager(
      $_db,
      $_db.exerciseSets,
    ).filter((f) => f.roundId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoundLogsTableFilterComposer
    extends Composer<_$TmbDatabase, $RoundLogsTable> {
  $$RoundLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get blockIndex => $composableBuilder(
    column: $table.blockIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exerciseSetsRefs(
    Expression<bool> Function($$ExerciseSetsTableFilterComposer f) f,
  ) {
    final $$ExerciseSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoundLogsTableOrderingComposer
    extends Composer<_$TmbDatabase, $RoundLogsTable> {
  $$RoundLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get blockIndex => $composableBuilder(
    column: $table.blockIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoundLogsTableAnnotationComposer
    extends Composer<_$TmbDatabase, $RoundLogsTable> {
  $$RoundLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get blockIndex => $composableBuilder(
    column: $table.blockIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exerciseSetsRefs<T extends Object>(
    Expression<T> Function($$ExerciseSetsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoundLogsTableTableManager
    extends
        RootTableManager<
          _$TmbDatabase,
          $RoundLogsTable,
          RoundLogRow,
          $$RoundLogsTableFilterComposer,
          $$RoundLogsTableOrderingComposer,
          $$RoundLogsTableAnnotationComposer,
          $$RoundLogsTableCreateCompanionBuilder,
          $$RoundLogsTableUpdateCompanionBuilder,
          (RoundLogRow, $$RoundLogsTableReferences),
          RoundLogRow,
          PrefetchHooks Function({bool sessionId, bool exerciseSetsRefs})
        > {
  $$RoundLogsTableTableManager(_$TmbDatabase db, $RoundLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoundLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoundLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoundLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> blockIndex = const Value.absent(),
                Value<int> roundIndex = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoundLogsCompanion(
                id: id,
                sessionId: sessionId,
                blockIndex: blockIndex,
                roundIndex: roundIndex,
                durationMs: durationMs,
                rpe: rpe,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int blockIndex,
                required int roundIndex,
                required int durationMs,
                Value<int?> rpe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoundLogsCompanion.insert(
                id: id,
                sessionId: sessionId,
                blockIndex: blockIndex,
                roundIndex: roundIndex,
                durationMs: durationMs,
                rpe: rpe,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoundLogsTable, RoundLogRow>(table),
                  $$RoundLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, exerciseSetsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseSetsRefs) db.exerciseSets,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$RoundLogsTableReferences
                                ._sessionIdTable(db),
                            referencedColumn: $$RoundLogsTableReferences
                                ._sessionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseSetsRefs)
                        await $_getPrefetchedDataByColumns<
                          RoundLogRow,
                          $RoundLogsTable,
                          ExerciseSetRow,
                          $ExerciseSetsTable
                        >(
                          currentTable: table,
                          referencedTable: $$RoundLogsTableReferences
                              ._exerciseSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoundLogsTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseSetsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'round_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoundLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$TmbDatabase,
      $RoundLogsTable,
      RoundLogRow,
      $$RoundLogsTableFilterComposer,
      $$RoundLogsTableOrderingComposer,
      $$RoundLogsTableAnnotationComposer,
      $$RoundLogsTableCreateCompanionBuilder,
      $$RoundLogsTableUpdateCompanionBuilder,
      (RoundLogRow, $$RoundLogsTableReferences),
      RoundLogRow,
      PrefetchHooks Function({bool sessionId, bool exerciseSetsRefs})
    >;
typedef $$ExerciseSetsTableCreateCompanionBuilder =
    ExerciseSetsCompanion Function({
      required String id,
      required String sessionId,
      required String roundId,
      required int setIndex,
      required String exerciseId,
      required String unit,
      required int prescribed,
      required int done,
      required int startedAt,
      required int endedAt,
      Value<int> rowid,
    });
typedef $$ExerciseSetsTableUpdateCompanionBuilder =
    ExerciseSetsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> roundId,
      Value<int> setIndex,
      Value<String> exerciseId,
      Value<String> unit,
      Value<int> prescribed,
      Value<int> done,
      Value<int> startedAt,
      Value<int> endedAt,
      Value<int> rowid,
    });

final class $$ExerciseSetsTableReferences
    extends BaseReferences<_$TmbDatabase, $ExerciseSetsTable, ExerciseSetRow> {
  $$ExerciseSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$TmbDatabase db) =>
      db.sessions.createAlias('exercise_sets__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoundLogsTable _roundIdTable(_$TmbDatabase db) =>
      db.roundLogs.createAlias('exercise_sets__round_id__round_logs__id');

  $$RoundLogsTableProcessedTableManager get roundId {
    final $_column = $_itemColumn<String>('round_id')!;

    final manager = $$RoundLogsTableTableManager(
      $_db,
      $_db.roundLogs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roundIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseSetsTableFilterComposer
    extends Composer<_$TmbDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prescribed => $composableBuilder(
    column: $table.prescribed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundLogsTableFilterComposer get roundId {
    final $$RoundLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.roundLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundLogsTableFilterComposer(
            $db: $db,
            $table: $db.roundLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableOrderingComposer
    extends Composer<_$TmbDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prescribed => $composableBuilder(
    column: $table.prescribed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundLogsTableOrderingComposer get roundId {
    final $$RoundLogsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.roundLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundLogsTableOrderingComposer(
            $db: $db,
            $table: $db.roundLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableAnnotationComposer
    extends Composer<_$TmbDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get prescribed => $composableBuilder(
    column: $table.prescribed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundLogsTableAnnotationComposer get roundId {
    final $$RoundLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.roundLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.roundLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableTableManager
    extends
        RootTableManager<
          _$TmbDatabase,
          $ExerciseSetsTable,
          ExerciseSetRow,
          $$ExerciseSetsTableFilterComposer,
          $$ExerciseSetsTableOrderingComposer,
          $$ExerciseSetsTableAnnotationComposer,
          $$ExerciseSetsTableCreateCompanionBuilder,
          $$ExerciseSetsTableUpdateCompanionBuilder,
          (ExerciseSetRow, $$ExerciseSetsTableReferences),
          ExerciseSetRow,
          PrefetchHooks Function({bool sessionId, bool roundId})
        > {
  $$ExerciseSetsTableTableManager(_$TmbDatabase db, $ExerciseSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> roundId = const Value.absent(),
                Value<int> setIndex = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int> prescribed = const Value.absent(),
                Value<int> done = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseSetsCompanion(
                id: id,
                sessionId: sessionId,
                roundId: roundId,
                setIndex: setIndex,
                exerciseId: exerciseId,
                unit: unit,
                prescribed: prescribed,
                done: done,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String roundId,
                required int setIndex,
                required String exerciseId,
                required String unit,
                required int prescribed,
                required int done,
                required int startedAt,
                required int endedAt,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseSetsCompanion.insert(
                id: id,
                sessionId: sessionId,
                roundId: roundId,
                setIndex: setIndex,
                exerciseId: exerciseId,
                unit: unit,
                prescribed: prescribed,
                done: done,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseSetsTable, ExerciseSetRow>(table),
                  $$ExerciseSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, roundId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$ExerciseSetsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$ExerciseSetsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (roundId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.roundId,
                        referencedTable: $$ExerciseSetsTableReferences
                            ._roundIdTable(db),
                        referencedColumn: $$ExerciseSetsTableReferences
                            ._roundIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$TmbDatabase,
      $ExerciseSetsTable,
      ExerciseSetRow,
      $$ExerciseSetsTableFilterComposer,
      $$ExerciseSetsTableOrderingComposer,
      $$ExerciseSetsTableAnnotationComposer,
      $$ExerciseSetsTableCreateCompanionBuilder,
      $$ExerciseSetsTableUpdateCompanionBuilder,
      (ExerciseSetRow, $$ExerciseSetsTableReferences),
      ExerciseSetRow,
      PrefetchHooks Function({bool sessionId, bool roundId})
    >;
typedef $$TaskAttemptsTableCreateCompanionBuilder =
    TaskAttemptsCompanion Function({
      required String id,
      required String sessionId,
      required int blockIndex,
      required int roundIndex,
      required String taskId,
      required String packId,
      required String packSource,
      required String archetype,
      required String domain,
      required double difficulty,
      required int seed,
      required String status,
      required int presentedAt,
      Value<int?> answeredAt,
      Value<int?> latencyMs,
      Value<bool?> isCorrect,
      Value<int?> selfRating,
      Value<String?> response,
      Value<int?> encodedRoundIndex,
      required String payloadHash,
      Value<int> rowid,
    });
typedef $$TaskAttemptsTableUpdateCompanionBuilder =
    TaskAttemptsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<int> blockIndex,
      Value<int> roundIndex,
      Value<String> taskId,
      Value<String> packId,
      Value<String> packSource,
      Value<String> archetype,
      Value<String> domain,
      Value<double> difficulty,
      Value<int> seed,
      Value<String> status,
      Value<int> presentedAt,
      Value<int?> answeredAt,
      Value<int?> latencyMs,
      Value<bool?> isCorrect,
      Value<int?> selfRating,
      Value<String?> response,
      Value<int?> encodedRoundIndex,
      Value<String> payloadHash,
      Value<int> rowid,
    });

final class $$TaskAttemptsTableReferences
    extends BaseReferences<_$TmbDatabase, $TaskAttemptsTable, TaskAttemptRow> {
  $$TaskAttemptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$TmbDatabase db) =>
      db.sessions.createAlias('task_attempts__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskAttemptsTableFilterComposer
    extends Composer<_$TmbDatabase, $TaskAttemptsTable> {
  $$TaskAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get blockIndex => $composableBuilder(
    column: $table.blockIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packId => $composableBuilder(
    column: $table.packId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packSource => $composableBuilder(
    column: $table.packSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archetype => $composableBuilder(
    column: $table.archetype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get presentedAt => $composableBuilder(
    column: $table.presentedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selfRating => $composableBuilder(
    column: $table.selfRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get response => $composableBuilder(
    column: $table.response,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get encodedRoundIndex => $composableBuilder(
    column: $table.encodedRoundIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskAttemptsTableOrderingComposer
    extends Composer<_$TmbDatabase, $TaskAttemptsTable> {
  $$TaskAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get blockIndex => $composableBuilder(
    column: $table.blockIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packId => $composableBuilder(
    column: $table.packId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packSource => $composableBuilder(
    column: $table.packSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archetype => $composableBuilder(
    column: $table.archetype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get presentedAt => $composableBuilder(
    column: $table.presentedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selfRating => $composableBuilder(
    column: $table.selfRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get response => $composableBuilder(
    column: $table.response,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get encodedRoundIndex => $composableBuilder(
    column: $table.encodedRoundIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskAttemptsTableAnnotationComposer
    extends Composer<_$TmbDatabase, $TaskAttemptsTable> {
  $$TaskAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get blockIndex => $composableBuilder(
    column: $table.blockIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get packId =>
      $composableBuilder(column: $table.packId, builder: (column) => column);

  GeneratedColumn<String> get packSource => $composableBuilder(
    column: $table.packSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get archetype =>
      $composableBuilder(column: $table.archetype, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get presentedAt => $composableBuilder(
    column: $table.presentedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get latencyMs =>
      $composableBuilder(column: $table.latencyMs, builder: (column) => column);

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get selfRating => $composableBuilder(
    column: $table.selfRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get response =>
      $composableBuilder(column: $table.response, builder: (column) => column);

  GeneratedColumn<int> get encodedRoundIndex => $composableBuilder(
    column: $table.encodedRoundIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskAttemptsTableTableManager
    extends
        RootTableManager<
          _$TmbDatabase,
          $TaskAttemptsTable,
          TaskAttemptRow,
          $$TaskAttemptsTableFilterComposer,
          $$TaskAttemptsTableOrderingComposer,
          $$TaskAttemptsTableAnnotationComposer,
          $$TaskAttemptsTableCreateCompanionBuilder,
          $$TaskAttemptsTableUpdateCompanionBuilder,
          (TaskAttemptRow, $$TaskAttemptsTableReferences),
          TaskAttemptRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$TaskAttemptsTableTableManager(_$TmbDatabase db, $TaskAttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> blockIndex = const Value.absent(),
                Value<int> roundIndex = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<String> packSource = const Value.absent(),
                Value<String> archetype = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> seed = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> presentedAt = const Value.absent(),
                Value<int?> answeredAt = const Value.absent(),
                Value<int?> latencyMs = const Value.absent(),
                Value<bool?> isCorrect = const Value.absent(),
                Value<int?> selfRating = const Value.absent(),
                Value<String?> response = const Value.absent(),
                Value<int?> encodedRoundIndex = const Value.absent(),
                Value<String> payloadHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskAttemptsCompanion(
                id: id,
                sessionId: sessionId,
                blockIndex: blockIndex,
                roundIndex: roundIndex,
                taskId: taskId,
                packId: packId,
                packSource: packSource,
                archetype: archetype,
                domain: domain,
                difficulty: difficulty,
                seed: seed,
                status: status,
                presentedAt: presentedAt,
                answeredAt: answeredAt,
                latencyMs: latencyMs,
                isCorrect: isCorrect,
                selfRating: selfRating,
                response: response,
                encodedRoundIndex: encodedRoundIndex,
                payloadHash: payloadHash,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int blockIndex,
                required int roundIndex,
                required String taskId,
                required String packId,
                required String packSource,
                required String archetype,
                required String domain,
                required double difficulty,
                required int seed,
                required String status,
                required int presentedAt,
                Value<int?> answeredAt = const Value.absent(),
                Value<int?> latencyMs = const Value.absent(),
                Value<bool?> isCorrect = const Value.absent(),
                Value<int?> selfRating = const Value.absent(),
                Value<String?> response = const Value.absent(),
                Value<int?> encodedRoundIndex = const Value.absent(),
                required String payloadHash,
                Value<int> rowid = const Value.absent(),
              }) => TaskAttemptsCompanion.insert(
                id: id,
                sessionId: sessionId,
                blockIndex: blockIndex,
                roundIndex: roundIndex,
                taskId: taskId,
                packId: packId,
                packSource: packSource,
                archetype: archetype,
                domain: domain,
                difficulty: difficulty,
                seed: seed,
                status: status,
                presentedAt: presentedAt,
                answeredAt: answeredAt,
                latencyMs: latencyMs,
                isCorrect: isCorrect,
                selfRating: selfRating,
                response: response,
                encodedRoundIndex: encodedRoundIndex,
                payloadHash: payloadHash,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskAttemptsTable, TaskAttemptRow>(table),
                  $$TaskAttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$TaskAttemptsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$TaskAttemptsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TaskAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$TmbDatabase,
      $TaskAttemptsTable,
      TaskAttemptRow,
      $$TaskAttemptsTableFilterComposer,
      $$TaskAttemptsTableOrderingComposer,
      $$TaskAttemptsTableAnnotationComposer,
      $$TaskAttemptsTableCreateCompanionBuilder,
      $$TaskAttemptsTableUpdateCompanionBuilder,
      (TaskAttemptRow, $$TaskAttemptsTableReferences),
      TaskAttemptRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$ProfileSettingsTableTableCreateCompanionBuilder =
    ProfileSettingsTableCompanion Function({
      Value<int> id,
      Value<int> schemaVersion,
      Value<int> defaultRepsMin,
      Value<int> defaultRepsMax,
      Value<int> defaultSecondsMin,
      Value<int> defaultSecondsMax,
      Value<bool> progressionEnabled,
    });
typedef $$ProfileSettingsTableTableUpdateCompanionBuilder =
    ProfileSettingsTableCompanion Function({
      Value<int> id,
      Value<int> schemaVersion,
      Value<int> defaultRepsMin,
      Value<int> defaultRepsMax,
      Value<int> defaultSecondsMin,
      Value<int> defaultSecondsMax,
      Value<bool> progressionEnabled,
    });

class $$ProfileSettingsTableTableFilterComposer
    extends Composer<_$TmbDatabase, $ProfileSettingsTableTable> {
  $$ProfileSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultRepsMin => $composableBuilder(
    column: $table.defaultRepsMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultRepsMax => $composableBuilder(
    column: $table.defaultRepsMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultSecondsMin => $composableBuilder(
    column: $table.defaultSecondsMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultSecondsMax => $composableBuilder(
    column: $table.defaultSecondsMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get progressionEnabled => $composableBuilder(
    column: $table.progressionEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfileSettingsTableTableOrderingComposer
    extends Composer<_$TmbDatabase, $ProfileSettingsTableTable> {
  $$ProfileSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultRepsMin => $composableBuilder(
    column: $table.defaultRepsMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultRepsMax => $composableBuilder(
    column: $table.defaultRepsMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultSecondsMin => $composableBuilder(
    column: $table.defaultSecondsMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultSecondsMax => $composableBuilder(
    column: $table.defaultSecondsMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get progressionEnabled => $composableBuilder(
    column: $table.progressionEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfileSettingsTableTableAnnotationComposer
    extends Composer<_$TmbDatabase, $ProfileSettingsTableTable> {
  $$ProfileSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultRepsMin => $composableBuilder(
    column: $table.defaultRepsMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultRepsMax => $composableBuilder(
    column: $table.defaultRepsMax,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultSecondsMin => $composableBuilder(
    column: $table.defaultSecondsMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultSecondsMax => $composableBuilder(
    column: $table.defaultSecondsMax,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get progressionEnabled => $composableBuilder(
    column: $table.progressionEnabled,
    builder: (column) => column,
  );
}

class $$ProfileSettingsTableTableTableManager
    extends
        RootTableManager<
          _$TmbDatabase,
          $ProfileSettingsTableTable,
          ProfileSettingsRow,
          $$ProfileSettingsTableTableFilterComposer,
          $$ProfileSettingsTableTableOrderingComposer,
          $$ProfileSettingsTableTableAnnotationComposer,
          $$ProfileSettingsTableTableCreateCompanionBuilder,
          $$ProfileSettingsTableTableUpdateCompanionBuilder,
          (
            ProfileSettingsRow,
            BaseReferences<
              _$TmbDatabase,
              $ProfileSettingsTableTable,
              ProfileSettingsRow
            >,
          ),
          ProfileSettingsRow,
          PrefetchHooks Function()
        > {
  $$ProfileSettingsTableTableTableManager(
    _$TmbDatabase db,
    $ProfileSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileSettingsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProfileSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<int> defaultRepsMin = const Value.absent(),
                Value<int> defaultRepsMax = const Value.absent(),
                Value<int> defaultSecondsMin = const Value.absent(),
                Value<int> defaultSecondsMax = const Value.absent(),
                Value<bool> progressionEnabled = const Value.absent(),
              }) => ProfileSettingsTableCompanion(
                id: id,
                schemaVersion: schemaVersion,
                defaultRepsMin: defaultRepsMin,
                defaultRepsMax: defaultRepsMax,
                defaultSecondsMin: defaultSecondsMin,
                defaultSecondsMax: defaultSecondsMax,
                progressionEnabled: progressionEnabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<int> defaultRepsMin = const Value.absent(),
                Value<int> defaultRepsMax = const Value.absent(),
                Value<int> defaultSecondsMin = const Value.absent(),
                Value<int> defaultSecondsMax = const Value.absent(),
                Value<bool> progressionEnabled = const Value.absent(),
              }) => ProfileSettingsTableCompanion.insert(
                id: id,
                schemaVersion: schemaVersion,
                defaultRepsMin: defaultRepsMin,
                defaultRepsMax: defaultRepsMax,
                defaultSecondsMin: defaultSecondsMin,
                defaultSecondsMax: defaultSecondsMax,
                progressionEnabled: progressionEnabled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfileSettingsTableTable, ProfileSettingsRow>(
                    table,
                  ),
                  BaseReferences<
                    _$TmbDatabase,
                    $ProfileSettingsTableTable,
                    ProfileSettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$TmbDatabase,
      $ProfileSettingsTableTable,
      ProfileSettingsRow,
      $$ProfileSettingsTableTableFilterComposer,
      $$ProfileSettingsTableTableOrderingComposer,
      $$ProfileSettingsTableTableAnnotationComposer,
      $$ProfileSettingsTableTableCreateCompanionBuilder,
      $$ProfileSettingsTableTableUpdateCompanionBuilder,
      (
        ProfileSettingsRow,
        BaseReferences<
          _$TmbDatabase,
          $ProfileSettingsTableTable,
          ProfileSettingsRow
        >,
      ),
      ProfileSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$DisabledCategoriesTableCreateCompanionBuilder =
    DisabledCategoriesCompanion Function({
      required String path,
      Value<int> rowid,
    });
typedef $$DisabledCategoriesTableUpdateCompanionBuilder =
    DisabledCategoriesCompanion Function({
      Value<String> path,
      Value<int> rowid,
    });

class $$DisabledCategoriesTableFilterComposer
    extends Composer<_$TmbDatabase, $DisabledCategoriesTable> {
  $$DisabledCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DisabledCategoriesTableOrderingComposer
    extends Composer<_$TmbDatabase, $DisabledCategoriesTable> {
  $$DisabledCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DisabledCategoriesTableAnnotationComposer
    extends Composer<_$TmbDatabase, $DisabledCategoriesTable> {
  $$DisabledCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);
}

class $$DisabledCategoriesTableTableManager
    extends
        RootTableManager<
          _$TmbDatabase,
          $DisabledCategoriesTable,
          DisabledCategoryRow,
          $$DisabledCategoriesTableFilterComposer,
          $$DisabledCategoriesTableOrderingComposer,
          $$DisabledCategoriesTableAnnotationComposer,
          $$DisabledCategoriesTableCreateCompanionBuilder,
          $$DisabledCategoriesTableUpdateCompanionBuilder,
          (
            DisabledCategoryRow,
            BaseReferences<
              _$TmbDatabase,
              $DisabledCategoriesTable,
              DisabledCategoryRow
            >,
          ),
          DisabledCategoryRow,
          PrefetchHooks Function()
        > {
  $$DisabledCategoriesTableTableManager(
    _$TmbDatabase db,
    $DisabledCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DisabledCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DisabledCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DisabledCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback: ({
            Value<String> path = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => DisabledCategoriesCompanion(path: path, rowid: rowid),
          createCompanionCallback: ({
            required String path,
            Value<int> rowid = const Value.absent(),
          }) => DisabledCategoriesCompanion.insert(path: path, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DisabledCategoriesTable, DisabledCategoryRow>(
                    table,
                  ),
                  BaseReferences<
                    _$TmbDatabase,
                    $DisabledCategoriesTable,
                    DisabledCategoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DisabledCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$TmbDatabase,
      $DisabledCategoriesTable,
      DisabledCategoryRow,
      $$DisabledCategoriesTableFilterComposer,
      $$DisabledCategoriesTableOrderingComposer,
      $$DisabledCategoriesTableAnnotationComposer,
      $$DisabledCategoriesTableCreateCompanionBuilder,
      $$DisabledCategoriesTableUpdateCompanionBuilder,
      (
        DisabledCategoryRow,
        BaseReferences<
          _$TmbDatabase,
          $DisabledCategoriesTable,
          DisabledCategoryRow
        >,
      ),
      DisabledCategoryRow,
      PrefetchHooks Function()
    >;
typedef $$ExerciseTargetsTableCreateCompanionBuilder =
    ExerciseTargetsCompanion Function({
      required String exerciseId,
      required int targetMin,
      required int targetMax,
      Value<bool> lockedByUser,
      Value<int> rowid,
    });
typedef $$ExerciseTargetsTableUpdateCompanionBuilder =
    ExerciseTargetsCompanion Function({
      Value<String> exerciseId,
      Value<int> targetMin,
      Value<int> targetMax,
      Value<bool> lockedByUser,
      Value<int> rowid,
    });

class $$ExerciseTargetsTableFilterComposer
    extends Composer<_$TmbDatabase, $ExerciseTargetsTable> {
  $$ExerciseTargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMin => $composableBuilder(
    column: $table.targetMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMax => $composableBuilder(
    column: $table.targetMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lockedByUser => $composableBuilder(
    column: $table.lockedByUser,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseTargetsTableOrderingComposer
    extends Composer<_$TmbDatabase, $ExerciseTargetsTable> {
  $$ExerciseTargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMin => $composableBuilder(
    column: $table.targetMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMax => $composableBuilder(
    column: $table.targetMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lockedByUser => $composableBuilder(
    column: $table.lockedByUser,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseTargetsTableAnnotationComposer
    extends Composer<_$TmbDatabase, $ExerciseTargetsTable> {
  $$ExerciseTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetMin =>
      $composableBuilder(column: $table.targetMin, builder: (column) => column);

  GeneratedColumn<int> get targetMax =>
      $composableBuilder(column: $table.targetMax, builder: (column) => column);

  GeneratedColumn<bool> get lockedByUser => $composableBuilder(
    column: $table.lockedByUser,
    builder: (column) => column,
  );
}

class $$ExerciseTargetsTableTableManager
    extends
        RootTableManager<
          _$TmbDatabase,
          $ExerciseTargetsTable,
          ExerciseTargetRow,
          $$ExerciseTargetsTableFilterComposer,
          $$ExerciseTargetsTableOrderingComposer,
          $$ExerciseTargetsTableAnnotationComposer,
          $$ExerciseTargetsTableCreateCompanionBuilder,
          $$ExerciseTargetsTableUpdateCompanionBuilder,
          (
            ExerciseTargetRow,
            BaseReferences<
              _$TmbDatabase,
              $ExerciseTargetsTable,
              ExerciseTargetRow
            >,
          ),
          ExerciseTargetRow,
          PrefetchHooks Function()
        > {
  $$ExerciseTargetsTableTableManager(
    _$TmbDatabase db,
    $ExerciseTargetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseTargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseTargetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<int> targetMin = const Value.absent(),
                Value<int> targetMax = const Value.absent(),
                Value<bool> lockedByUser = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseTargetsCompanion(
                exerciseId: exerciseId,
                targetMin: targetMin,
                targetMax: targetMax,
                lockedByUser: lockedByUser,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required int targetMin,
                required int targetMax,
                Value<bool> lockedByUser = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseTargetsCompanion.insert(
                exerciseId: exerciseId,
                targetMin: targetMin,
                targetMax: targetMax,
                lockedByUser: lockedByUser,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseTargetsTable, ExerciseTargetRow>(table),
                  BaseReferences<
                    _$TmbDatabase,
                    $ExerciseTargetsTable,
                    ExerciseTargetRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$TmbDatabase,
      $ExerciseTargetsTable,
      ExerciseTargetRow,
      $$ExerciseTargetsTableFilterComposer,
      $$ExerciseTargetsTableOrderingComposer,
      $$ExerciseTargetsTableAnnotationComposer,
      $$ExerciseTargetsTableCreateCompanionBuilder,
      $$ExerciseTargetsTableUpdateCompanionBuilder,
      (
        ExerciseTargetRow,
        BaseReferences<_$TmbDatabase, $ExerciseTargetsTable, ExerciseTargetRow>,
      ),
      ExerciseTargetRow,
      PrefetchHooks Function()
    >;
typedef $$SessionPreferencesTableTableCreateCompanionBuilder =
    SessionPreferencesTableCompanion Function({
      Value<int> id,
      Value<String> template,
      Value<int> rounds,
      Value<int> cognitiveSec,
      Value<int> restSec,
      Value<String> location,
      Value<String> difficulty,
    });
typedef $$SessionPreferencesTableTableUpdateCompanionBuilder =
    SessionPreferencesTableCompanion Function({
      Value<int> id,
      Value<String> template,
      Value<int> rounds,
      Value<int> cognitiveSec,
      Value<int> restSec,
      Value<String> location,
      Value<String> difficulty,
    });

class $$SessionPreferencesTableTableFilterComposer
    extends Composer<_$TmbDatabase, $SessionPreferencesTableTable> {
  $$SessionPreferencesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get template => $composableBuilder(
    column: $table.template,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cognitiveSec => $composableBuilder(
    column: $table.cognitiveSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSec => $composableBuilder(
    column: $table.restSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionPreferencesTableTableOrderingComposer
    extends Composer<_$TmbDatabase, $SessionPreferencesTableTable> {
  $$SessionPreferencesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get template => $composableBuilder(
    column: $table.template,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cognitiveSec => $composableBuilder(
    column: $table.cognitiveSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSec => $composableBuilder(
    column: $table.restSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionPreferencesTableTableAnnotationComposer
    extends Composer<_$TmbDatabase, $SessionPreferencesTableTable> {
  $$SessionPreferencesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get template =>
      $composableBuilder(column: $table.template, builder: (column) => column);

  GeneratedColumn<int> get rounds =>
      $composableBuilder(column: $table.rounds, builder: (column) => column);

  GeneratedColumn<int> get cognitiveSec => $composableBuilder(
    column: $table.cognitiveSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restSec =>
      $composableBuilder(column: $table.restSec, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );
}

class $$SessionPreferencesTableTableTableManager
    extends
        RootTableManager<
          _$TmbDatabase,
          $SessionPreferencesTableTable,
          SessionPreferencesRow,
          $$SessionPreferencesTableTableFilterComposer,
          $$SessionPreferencesTableTableOrderingComposer,
          $$SessionPreferencesTableTableAnnotationComposer,
          $$SessionPreferencesTableTableCreateCompanionBuilder,
          $$SessionPreferencesTableTableUpdateCompanionBuilder,
          (
            SessionPreferencesRow,
            BaseReferences<
              _$TmbDatabase,
              $SessionPreferencesTableTable,
              SessionPreferencesRow
            >,
          ),
          SessionPreferencesRow,
          PrefetchHooks Function()
        > {
  $$SessionPreferencesTableTableTableManager(
    _$TmbDatabase db,
    $SessionPreferencesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionPreferencesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SessionPreferencesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SessionPreferencesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> template = const Value.absent(),
                Value<int> rounds = const Value.absent(),
                Value<int> cognitiveSec = const Value.absent(),
                Value<int> restSec = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
              }) => SessionPreferencesTableCompanion(
                id: id,
                template: template,
                rounds: rounds,
                cognitiveSec: cognitiveSec,
                restSec: restSec,
                location: location,
                difficulty: difficulty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> template = const Value.absent(),
                Value<int> rounds = const Value.absent(),
                Value<int> cognitiveSec = const Value.absent(),
                Value<int> restSec = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
              }) => SessionPreferencesTableCompanion.insert(
                id: id,
                template: template,
                rounds: rounds,
                cognitiveSec: cognitiveSec,
                restSec: restSec,
                location: location,
                difficulty: difficulty,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $SessionPreferencesTableTable,
                    SessionPreferencesRow
                  >(table),
                  BaseReferences<
                    _$TmbDatabase,
                    $SessionPreferencesTableTable,
                    SessionPreferencesRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionPreferencesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$TmbDatabase,
      $SessionPreferencesTableTable,
      SessionPreferencesRow,
      $$SessionPreferencesTableTableFilterComposer,
      $$SessionPreferencesTableTableOrderingComposer,
      $$SessionPreferencesTableTableAnnotationComposer,
      $$SessionPreferencesTableTableCreateCompanionBuilder,
      $$SessionPreferencesTableTableUpdateCompanionBuilder,
      (
        SessionPreferencesRow,
        BaseReferences<
          _$TmbDatabase,
          $SessionPreferencesTableTable,
          SessionPreferencesRow
        >,
      ),
      SessionPreferencesRow,
      PrefetchHooks Function()
    >;
typedef $$UserPacksTableCreateCompanionBuilder = UserPacksCompanion Function({
  required String kind,
  required String packId,
  required String packSource,
  required String title,
  required String locale,
  required int itemCount,
  required int installedAt,
  required String content,
  Value<int> rowid,
});
typedef $$UserPacksTableUpdateCompanionBuilder = UserPacksCompanion Function({
  Value<String> kind,
  Value<String> packId,
  Value<String> packSource,
  Value<String> title,
  Value<String> locale,
  Value<int> itemCount,
  Value<int> installedAt,
  Value<String> content,
  Value<int> rowid,
});

class $$UserPacksTableFilterComposer
    extends Composer<_$TmbDatabase, $UserPacksTable> {
  $$UserPacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packId => $composableBuilder(
    column: $table.packId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packSource => $composableBuilder(
    column: $table.packSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPacksTableOrderingComposer
    extends Composer<_$TmbDatabase, $UserPacksTable> {
  $$UserPacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packId => $composableBuilder(
    column: $table.packId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packSource => $composableBuilder(
    column: $table.packSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPacksTableAnnotationComposer
    extends Composer<_$TmbDatabase, $UserPacksTable> {
  $$UserPacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get packId =>
      $composableBuilder(column: $table.packId, builder: (column) => column);

  GeneratedColumn<String> get packSource => $composableBuilder(
    column: $table.packSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);

  GeneratedColumn<int> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$UserPacksTableTableManager
    extends
        RootTableManager<
          _$TmbDatabase,
          $UserPacksTable,
          UserPackRow,
          $$UserPacksTableFilterComposer,
          $$UserPacksTableOrderingComposer,
          $$UserPacksTableAnnotationComposer,
          $$UserPacksTableCreateCompanionBuilder,
          $$UserPacksTableUpdateCompanionBuilder,
          (
            UserPackRow,
            BaseReferences<_$TmbDatabase, $UserPacksTable, UserPackRow>,
          ),
          UserPackRow,
          PrefetchHooks Function()
        > {
  $$UserPacksTableTableManager(_$TmbDatabase db, $UserPacksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> kind = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<String> packSource = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
                Value<int> installedAt = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPacksCompanion(
                kind: kind,
                packId: packId,
                packSource: packSource,
                title: title,
                locale: locale,
                itemCount: itemCount,
                installedAt: installedAt,
                content: content,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String kind,
                required String packId,
                required String packSource,
                required String title,
                required String locale,
                required int itemCount,
                required int installedAt,
                required String content,
                Value<int> rowid = const Value.absent(),
              }) => UserPacksCompanion.insert(
                kind: kind,
                packId: packId,
                packSource: packSource,
                title: title,
                locale: locale,
                itemCount: itemCount,
                installedAt: installedAt,
                content: content,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserPacksTable, UserPackRow>(table),
                  BaseReferences<_$TmbDatabase, $UserPacksTable, UserPackRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPacksTableProcessedTableManager =
    ProcessedTableManager<
      _$TmbDatabase,
      $UserPacksTable,
      UserPackRow,
      $$UserPacksTableFilterComposer,
      $$UserPacksTableOrderingComposer,
      $$UserPacksTableAnnotationComposer,
      $$UserPacksTableCreateCompanionBuilder,
      $$UserPacksTableUpdateCompanionBuilder,
      (
        UserPackRow,
        BaseReferences<_$TmbDatabase, $UserPacksTable, UserPackRow>,
      ),
      UserPackRow,
      PrefetchHooks Function()
    >;

class $TmbDatabaseManager {
  final _$TmbDatabase _db;
  $TmbDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$RoundLogsTableTableManager get roundLogs =>
      $$RoundLogsTableTableManager(_db, _db.roundLogs);
  $$ExerciseSetsTableTableManager get exerciseSets =>
      $$ExerciseSetsTableTableManager(_db, _db.exerciseSets);
  $$TaskAttemptsTableTableManager get taskAttempts =>
      $$TaskAttemptsTableTableManager(_db, _db.taskAttempts);
  $$ProfileSettingsTableTableTableManager get profileSettingsTable =>
      $$ProfileSettingsTableTableTableManager(_db, _db.profileSettingsTable);
  $$DisabledCategoriesTableTableManager get disabledCategories =>
      $$DisabledCategoriesTableTableManager(_db, _db.disabledCategories);
  $$ExerciseTargetsTableTableManager get exerciseTargets =>
      $$ExerciseTargetsTableTableManager(_db, _db.exerciseTargets);
  $$SessionPreferencesTableTableTableManager get sessionPreferencesTable =>
      $$SessionPreferencesTableTableTableManager(
        _db,
        _db.sessionPreferencesTable,
      );
  $$UserPacksTableTableManager get userPacks =>
      $$UserPacksTableTableManager(_db, _db.userPacks);
}
