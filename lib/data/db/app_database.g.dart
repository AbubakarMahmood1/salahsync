// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppSettingsEntriesTable extends AppSettingsEntries
    with TableInfo<$AppSettingsEntriesTable, AppSettingsEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsEntriesTable createAlias(String alias) {
    return $AppSettingsEntriesTable(attachedDatabase, alias);
  }
}

class AppSettingsEntry extends DataClass
    implements Insertable<AppSettingsEntry> {
  final String key;
  final String value;
  const AppSettingsEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingsEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingsEntry copyWith({String? key, String? value}) =>
      AppSettingsEntry(key: key ?? this.key, value: value ?? this.value);
  AppSettingsEntry copyWithCompanion(AppSettingsEntriesCompanion data) {
    return AppSettingsEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsEntriesCompanion extends UpdateCompanion<AppSettingsEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingsEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IbadahTaskEntriesTable extends IbadahTaskEntries
    with TableInfo<$IbadahTaskEntriesTable, IbadahTaskEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IbadahTaskEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prayerLinkMeta = const VerificationMeta(
    'prayerLink',
  );
  @override
  late final GeneratedColumn<String> prayerLink = GeneratedColumn<String>(
    'prayer_link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timingMeta = const VerificationMeta('timing');
  @override
  late final GeneratedColumn<String> timing = GeneratedColumn<String>(
    'timing',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('after'),
  );
  static const VerificationMeta _repeatTypeMeta = const VerificationMeta(
    'repeatType',
  );
  @override
  late final GeneratedColumn<String> repeatType = GeneratedColumn<String>(
    'repeat_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatDaysMeta = const VerificationMeta(
    'repeatDays',
  );
  @override
  late final GeneratedColumn<String> repeatDays = GeneratedColumn<String>(
    'repeat_days',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countTargetMeta = const VerificationMeta(
    'countTarget',
  );
  @override
  late final GeneratedColumn<int> countTarget = GeneratedColumn<int>(
    'count_target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    prayerLink,
    timing,
    repeatType,
    repeatDays,
    countTarget,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ibadah_task_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<IbadahTaskEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('prayer_link')) {
      context.handle(
        _prayerLinkMeta,
        prayerLink.isAcceptableOrUnknown(data['prayer_link']!, _prayerLinkMeta),
      );
    }
    if (data.containsKey('timing')) {
      context.handle(
        _timingMeta,
        timing.isAcceptableOrUnknown(data['timing']!, _timingMeta),
      );
    }
    if (data.containsKey('repeat_type')) {
      context.handle(
        _repeatTypeMeta,
        repeatType.isAcceptableOrUnknown(data['repeat_type']!, _repeatTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_repeatTypeMeta);
    }
    if (data.containsKey('repeat_days')) {
      context.handle(
        _repeatDaysMeta,
        repeatDays.isAcceptableOrUnknown(data['repeat_days']!, _repeatDaysMeta),
      );
    }
    if (data.containsKey('count_target')) {
      context.handle(
        _countTargetMeta,
        countTarget.isAcceptableOrUnknown(
          data['count_target']!,
          _countTargetMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IbadahTaskEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IbadahTaskEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      prayerLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prayer_link'],
      ),
      timing: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timing'],
      )!,
      repeatType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_type'],
      )!,
      repeatDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_days'],
      ),
      countTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count_target'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $IbadahTaskEntriesTable createAlias(String alias) {
    return $IbadahTaskEntriesTable(attachedDatabase, alias);
  }
}

class IbadahTaskEntry extends DataClass implements Insertable<IbadahTaskEntry> {
  final int id;
  final String title;
  final String? description;
  final String? prayerLink;
  final String timing;
  final String repeatType;
  final String? repeatDays;
  final int? countTarget;
  final bool isActive;
  final int sortOrder;
  const IbadahTaskEntry({
    required this.id,
    required this.title,
    this.description,
    this.prayerLink,
    required this.timing,
    required this.repeatType,
    this.repeatDays,
    this.countTarget,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || prayerLink != null) {
      map['prayer_link'] = Variable<String>(prayerLink);
    }
    map['timing'] = Variable<String>(timing);
    map['repeat_type'] = Variable<String>(repeatType);
    if (!nullToAbsent || repeatDays != null) {
      map['repeat_days'] = Variable<String>(repeatDays);
    }
    if (!nullToAbsent || countTarget != null) {
      map['count_target'] = Variable<int>(countTarget);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  IbadahTaskEntriesCompanion toCompanion(bool nullToAbsent) {
    return IbadahTaskEntriesCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      prayerLink: prayerLink == null && nullToAbsent
          ? const Value.absent()
          : Value(prayerLink),
      timing: Value(timing),
      repeatType: Value(repeatType),
      repeatDays: repeatDays == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatDays),
      countTarget: countTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(countTarget),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory IbadahTaskEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IbadahTaskEntry(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      prayerLink: serializer.fromJson<String?>(json['prayerLink']),
      timing: serializer.fromJson<String>(json['timing']),
      repeatType: serializer.fromJson<String>(json['repeatType']),
      repeatDays: serializer.fromJson<String?>(json['repeatDays']),
      countTarget: serializer.fromJson<int?>(json['countTarget']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'prayerLink': serializer.toJson<String?>(prayerLink),
      'timing': serializer.toJson<String>(timing),
      'repeatType': serializer.toJson<String>(repeatType),
      'repeatDays': serializer.toJson<String?>(repeatDays),
      'countTarget': serializer.toJson<int?>(countTarget),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  IbadahTaskEntry copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> prayerLink = const Value.absent(),
    String? timing,
    String? repeatType,
    Value<String?> repeatDays = const Value.absent(),
    Value<int?> countTarget = const Value.absent(),
    bool? isActive,
    int? sortOrder,
  }) => IbadahTaskEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    prayerLink: prayerLink.present ? prayerLink.value : this.prayerLink,
    timing: timing ?? this.timing,
    repeatType: repeatType ?? this.repeatType,
    repeatDays: repeatDays.present ? repeatDays.value : this.repeatDays,
    countTarget: countTarget.present ? countTarget.value : this.countTarget,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  IbadahTaskEntry copyWithCompanion(IbadahTaskEntriesCompanion data) {
    return IbadahTaskEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      prayerLink: data.prayerLink.present
          ? data.prayerLink.value
          : this.prayerLink,
      timing: data.timing.present ? data.timing.value : this.timing,
      repeatType: data.repeatType.present
          ? data.repeatType.value
          : this.repeatType,
      repeatDays: data.repeatDays.present
          ? data.repeatDays.value
          : this.repeatDays,
      countTarget: data.countTarget.present
          ? data.countTarget.value
          : this.countTarget,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IbadahTaskEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('prayerLink: $prayerLink, ')
          ..write('timing: $timing, ')
          ..write('repeatType: $repeatType, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('countTarget: $countTarget, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    prayerLink,
    timing,
    repeatType,
    repeatDays,
    countTarget,
    isActive,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IbadahTaskEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.prayerLink == this.prayerLink &&
          other.timing == this.timing &&
          other.repeatType == this.repeatType &&
          other.repeatDays == this.repeatDays &&
          other.countTarget == this.countTarget &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class IbadahTaskEntriesCompanion extends UpdateCompanion<IbadahTaskEntry> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> prayerLink;
  final Value<String> timing;
  final Value<String> repeatType;
  final Value<String?> repeatDays;
  final Value<int?> countTarget;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  const IbadahTaskEntriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.prayerLink = const Value.absent(),
    this.timing = const Value.absent(),
    this.repeatType = const Value.absent(),
    this.repeatDays = const Value.absent(),
    this.countTarget = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  IbadahTaskEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.prayerLink = const Value.absent(),
    this.timing = const Value.absent(),
    required String repeatType,
    this.repeatDays = const Value.absent(),
    this.countTarget = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : title = Value(title),
       repeatType = Value(repeatType);
  static Insertable<IbadahTaskEntry> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? prayerLink,
    Expression<String>? timing,
    Expression<String>? repeatType,
    Expression<String>? repeatDays,
    Expression<int>? countTarget,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (prayerLink != null) 'prayer_link': prayerLink,
      if (timing != null) 'timing': timing,
      if (repeatType != null) 'repeat_type': repeatType,
      if (repeatDays != null) 'repeat_days': repeatDays,
      if (countTarget != null) 'count_target': countTarget,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  IbadahTaskEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? prayerLink,
    Value<String>? timing,
    Value<String>? repeatType,
    Value<String?>? repeatDays,
    Value<int?>? countTarget,
    Value<bool>? isActive,
    Value<int>? sortOrder,
  }) {
    return IbadahTaskEntriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      prayerLink: prayerLink ?? this.prayerLink,
      timing: timing ?? this.timing,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      countTarget: countTarget ?? this.countTarget,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (prayerLink.present) {
      map['prayer_link'] = Variable<String>(prayerLink.value);
    }
    if (timing.present) {
      map['timing'] = Variable<String>(timing.value);
    }
    if (repeatType.present) {
      map['repeat_type'] = Variable<String>(repeatType.value);
    }
    if (repeatDays.present) {
      map['repeat_days'] = Variable<String>(repeatDays.value);
    }
    if (countTarget.present) {
      map['count_target'] = Variable<int>(countTarget.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IbadahTaskEntriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('prayerLink: $prayerLink, ')
          ..write('timing: $timing, ')
          ..write('repeatType: $repeatType, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('countTarget: $countTarget, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $IbadahCompletionEntriesTable extends IbadahCompletionEntries
    with TableInfo<$IbadahCompletionEntriesTable, IbadahCompletionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IbadahCompletionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ibadah_task_entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prayerInstanceMeta = const VerificationMeta(
    'prayerInstance',
  );
  @override
  late final GeneratedColumn<String> prayerInstance = GeneratedColumn<String>(
    'prayer_instance',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countDoneMeta = const VerificationMeta(
    'countDone',
  );
  @override
  late final GeneratedColumn<int> countDone = GeneratedColumn<int>(
    'count_done',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    date,
    prayerInstance,
    countDone,
    completed,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ibadah_completion_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<IbadahCompletionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('prayer_instance')) {
      context.handle(
        _prayerInstanceMeta,
        prayerInstance.isAcceptableOrUnknown(
          data['prayer_instance']!,
          _prayerInstanceMeta,
        ),
      );
    }
    if (data.containsKey('count_done')) {
      context.handle(
        _countDoneMeta,
        countDone.isAcceptableOrUnknown(data['count_done']!, _countDoneMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {taskId, date, prayerInstance},
  ];
  @override
  IbadahCompletionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IbadahCompletionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      prayerInstance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prayer_instance'],
      ),
      countDone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count_done'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $IbadahCompletionEntriesTable createAlias(String alias) {
    return $IbadahCompletionEntriesTable(attachedDatabase, alias);
  }
}

class IbadahCompletionEntry extends DataClass
    implements Insertable<IbadahCompletionEntry> {
  final int id;
  final int taskId;
  final String date;
  final String? prayerInstance;
  final int countDone;
  final bool completed;
  final String? notes;
  const IbadahCompletionEntry({
    required this.id,
    required this.taskId,
    required this.date,
    this.prayerInstance,
    required this.countDone,
    required this.completed,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || prayerInstance != null) {
      map['prayer_instance'] = Variable<String>(prayerInstance);
    }
    map['count_done'] = Variable<int>(countDone);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  IbadahCompletionEntriesCompanion toCompanion(bool nullToAbsent) {
    return IbadahCompletionEntriesCompanion(
      id: Value(id),
      taskId: Value(taskId),
      date: Value(date),
      prayerInstance: prayerInstance == null && nullToAbsent
          ? const Value.absent()
          : Value(prayerInstance),
      countDone: Value(countDone),
      completed: Value(completed),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory IbadahCompletionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IbadahCompletionEntry(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      date: serializer.fromJson<String>(json['date']),
      prayerInstance: serializer.fromJson<String?>(json['prayerInstance']),
      countDone: serializer.fromJson<int>(json['countDone']),
      completed: serializer.fromJson<bool>(json['completed']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'date': serializer.toJson<String>(date),
      'prayerInstance': serializer.toJson<String?>(prayerInstance),
      'countDone': serializer.toJson<int>(countDone),
      'completed': serializer.toJson<bool>(completed),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  IbadahCompletionEntry copyWith({
    int? id,
    int? taskId,
    String? date,
    Value<String?> prayerInstance = const Value.absent(),
    int? countDone,
    bool? completed,
    Value<String?> notes = const Value.absent(),
  }) => IbadahCompletionEntry(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    date: date ?? this.date,
    prayerInstance: prayerInstance.present
        ? prayerInstance.value
        : this.prayerInstance,
    countDone: countDone ?? this.countDone,
    completed: completed ?? this.completed,
    notes: notes.present ? notes.value : this.notes,
  );
  IbadahCompletionEntry copyWithCompanion(
    IbadahCompletionEntriesCompanion data,
  ) {
    return IbadahCompletionEntry(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      date: data.date.present ? data.date.value : this.date,
      prayerInstance: data.prayerInstance.present
          ? data.prayerInstance.value
          : this.prayerInstance,
      countDone: data.countDone.present ? data.countDone.value : this.countDone,
      completed: data.completed.present ? data.completed.value : this.completed,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IbadahCompletionEntry(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('date: $date, ')
          ..write('prayerInstance: $prayerInstance, ')
          ..write('countDone: $countDone, ')
          ..write('completed: $completed, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    date,
    prayerInstance,
    countDone,
    completed,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IbadahCompletionEntry &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.date == this.date &&
          other.prayerInstance == this.prayerInstance &&
          other.countDone == this.countDone &&
          other.completed == this.completed &&
          other.notes == this.notes);
}

class IbadahCompletionEntriesCompanion
    extends UpdateCompanion<IbadahCompletionEntry> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<String> date;
  final Value<String?> prayerInstance;
  final Value<int> countDone;
  final Value<bool> completed;
  final Value<String?> notes;
  const IbadahCompletionEntriesCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.date = const Value.absent(),
    this.prayerInstance = const Value.absent(),
    this.countDone = const Value.absent(),
    this.completed = const Value.absent(),
    this.notes = const Value.absent(),
  });
  IbadahCompletionEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int taskId,
    required String date,
    this.prayerInstance = const Value.absent(),
    this.countDone = const Value.absent(),
    this.completed = const Value.absent(),
    this.notes = const Value.absent(),
  }) : taskId = Value(taskId),
       date = Value(date);
  static Insertable<IbadahCompletionEntry> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<String>? date,
    Expression<String>? prayerInstance,
    Expression<int>? countDone,
    Expression<bool>? completed,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (date != null) 'date': date,
      if (prayerInstance != null) 'prayer_instance': prayerInstance,
      if (countDone != null) 'count_done': countDone,
      if (completed != null) 'completed': completed,
      if (notes != null) 'notes': notes,
    });
  }

  IbadahCompletionEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? taskId,
    Value<String>? date,
    Value<String?>? prayerInstance,
    Value<int>? countDone,
    Value<bool>? completed,
    Value<String?>? notes,
  }) {
    return IbadahCompletionEntriesCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      date: date ?? this.date,
      prayerInstance: prayerInstance ?? this.prayerInstance,
      countDone: countDone ?? this.countDone,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (prayerInstance.present) {
      map['prayer_instance'] = Variable<String>(prayerInstance.value);
    }
    if (countDone.present) {
      map['count_done'] = Variable<int>(countDone.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IbadahCompletionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('date: $date, ')
          ..write('prayerInstance: $prayerInstance, ')
          ..write('countDone: $countDone, ')
          ..write('completed: $completed, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $MosquesTable extends Mosques with TableInfo<$MosquesTable, Mosque> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MosquesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<String> area = GeneratedColumn<String>(
    'area',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    area,
    latitude,
    longitude,
    isPrimary,
    isActive,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mosques';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mosque> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('area')) {
      context.handle(
        _areaMeta,
        area.isAcceptableOrUnknown(data['area']!, _areaMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mosque map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mosque(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      area: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MosquesTable createAlias(String alias) {
    return $MosquesTable(attachedDatabase, alias);
  }
}

class Mosque extends DataClass implements Insertable<Mosque> {
  final int id;
  final String name;
  final String? area;
  final double? latitude;
  final double? longitude;
  final bool isPrimary;
  final bool isActive;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  const Mosque({
    required this.id,
    required this.name,
    this.area,
    this.latitude,
    this.longitude,
    required this.isPrimary,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || area != null) {
      map['area'] = Variable<String>(area);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['is_primary'] = Variable<bool>(isPrimary);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  MosquesCompanion toCompanion(bool nullToAbsent) {
    return MosquesCompanion(
      id: Value(id),
      name: Value(name),
      area: area == null && nullToAbsent ? const Value.absent() : Value(area),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      isPrimary: Value(isPrimary),
      isActive: Value(isActive),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Mosque.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mosque(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      area: serializer.fromJson<String?>(json['area']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'area': serializer.toJson<String?>(area),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'isActive': serializer.toJson<bool>(isActive),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Mosque copyWith({
    int? id,
    String? name,
    Value<String?> area = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    bool? isPrimary,
    bool? isActive,
    Value<String?> notes = const Value.absent(),
    String? createdAt,
    String? updatedAt,
  }) => Mosque(
    id: id ?? this.id,
    name: name ?? this.name,
    area: area.present ? area.value : this.area,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    isPrimary: isPrimary ?? this.isPrimary,
    isActive: isActive ?? this.isActive,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Mosque copyWithCompanion(MosquesCompanion data) {
    return Mosque(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      area: data.area.present ? data.area.value : this.area,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mosque(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('area: $area, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    area,
    latitude,
    longitude,
    isPrimary,
    isActive,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mosque &&
          other.id == this.id &&
          other.name == this.name &&
          other.area == this.area &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.isPrimary == this.isPrimary &&
          other.isActive == this.isActive &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MosquesCompanion extends UpdateCompanion<Mosque> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> area;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<bool> isPrimary;
  final Value<bool> isActive;
  final Value<String?> notes;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const MosquesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.area = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MosquesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.area = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Mosque> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? area,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<bool>? isPrimary,
    Expression<bool>? isActive,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (area != null) 'area': area,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (isActive != null) 'is_active': isActive,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MosquesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? area,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<bool>? isPrimary,
    Value<bool>? isActive,
    Value<String?>? notes,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return MosquesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (area.present) {
      map['area'] = Variable<String>(area.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MosquesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('area: $area, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PrayerLogEntriesTable extends PrayerLogEntries
    with TableInfo<$PrayerLogEntriesTable, PrayerLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prayerMeta = const VerificationMeta('prayer');
  @override
  late final GeneratedColumn<String> prayer = GeneratedColumn<String>(
    'prayer',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _mosqueIdMeta = const VerificationMeta(
    'mosqueId',
  );
  @override
  late final GeneratedColumn<int> mosqueId = GeneratedColumn<int>(
    'mosque_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mosques (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<String> loggedAt = GeneratedColumn<String>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    prayer,
    status,
    mosqueId,
    notes,
    loggedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('prayer')) {
      context.handle(
        _prayerMeta,
        prayer.isAcceptableOrUnknown(data['prayer']!, _prayerMeta),
      );
    } else if (isInserting) {
      context.missing(_prayerMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('mosque_id')) {
      context.handle(
        _mosqueIdMeta,
        mosqueId.isAcceptableOrUnknown(data['mosque_id']!, _mosqueIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {date, prayer},
  ];
  @override
  PrayerLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerLogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      prayer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prayer'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      mosqueId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mosque_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logged_at'],
      )!,
    );
  }

  @override
  $PrayerLogEntriesTable createAlias(String alias) {
    return $PrayerLogEntriesTable(attachedDatabase, alias);
  }
}

class PrayerLogEntry extends DataClass implements Insertable<PrayerLogEntry> {
  final int id;
  final String date;
  final String prayer;
  final String status;
  final int? mosqueId;
  final String? notes;
  final String loggedAt;
  const PrayerLogEntry({
    required this.id,
    required this.date,
    required this.prayer,
    required this.status,
    this.mosqueId,
    this.notes,
    required this.loggedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['prayer'] = Variable<String>(prayer);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || mosqueId != null) {
      map['mosque_id'] = Variable<int>(mosqueId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['logged_at'] = Variable<String>(loggedAt);
    return map;
  }

  PrayerLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return PrayerLogEntriesCompanion(
      id: Value(id),
      date: Value(date),
      prayer: Value(prayer),
      status: Value(status),
      mosqueId: mosqueId == null && nullToAbsent
          ? const Value.absent()
          : Value(mosqueId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      loggedAt: Value(loggedAt),
    );
  }

  factory PrayerLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerLogEntry(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      prayer: serializer.fromJson<String>(json['prayer']),
      status: serializer.fromJson<String>(json['status']),
      mosqueId: serializer.fromJson<int?>(json['mosqueId']),
      notes: serializer.fromJson<String?>(json['notes']),
      loggedAt: serializer.fromJson<String>(json['loggedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'prayer': serializer.toJson<String>(prayer),
      'status': serializer.toJson<String>(status),
      'mosqueId': serializer.toJson<int?>(mosqueId),
      'notes': serializer.toJson<String?>(notes),
      'loggedAt': serializer.toJson<String>(loggedAt),
    };
  }

  PrayerLogEntry copyWith({
    int? id,
    String? date,
    String? prayer,
    String? status,
    Value<int?> mosqueId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? loggedAt,
  }) => PrayerLogEntry(
    id: id ?? this.id,
    date: date ?? this.date,
    prayer: prayer ?? this.prayer,
    status: status ?? this.status,
    mosqueId: mosqueId.present ? mosqueId.value : this.mosqueId,
    notes: notes.present ? notes.value : this.notes,
    loggedAt: loggedAt ?? this.loggedAt,
  );
  PrayerLogEntry copyWithCompanion(PrayerLogEntriesCompanion data) {
    return PrayerLogEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      prayer: data.prayer.present ? data.prayer.value : this.prayer,
      status: data.status.present ? data.status.value : this.status,
      mosqueId: data.mosqueId.present ? data.mosqueId.value : this.mosqueId,
      notes: data.notes.present ? data.notes.value : this.notes,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerLogEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('prayer: $prayer, ')
          ..write('status: $status, ')
          ..write('mosqueId: $mosqueId, ')
          ..write('notes: $notes, ')
          ..write('loggedAt: $loggedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, prayer, status, mosqueId, notes, loggedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerLogEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.prayer == this.prayer &&
          other.status == this.status &&
          other.mosqueId == this.mosqueId &&
          other.notes == this.notes &&
          other.loggedAt == this.loggedAt);
}

class PrayerLogEntriesCompanion extends UpdateCompanion<PrayerLogEntry> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> prayer;
  final Value<String> status;
  final Value<int?> mosqueId;
  final Value<String?> notes;
  final Value<String> loggedAt;
  const PrayerLogEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.prayer = const Value.absent(),
    this.status = const Value.absent(),
    this.mosqueId = const Value.absent(),
    this.notes = const Value.absent(),
    this.loggedAt = const Value.absent(),
  });
  PrayerLogEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String prayer,
    required String status,
    this.mosqueId = const Value.absent(),
    this.notes = const Value.absent(),
    required String loggedAt,
  }) : date = Value(date),
       prayer = Value(prayer),
       status = Value(status),
       loggedAt = Value(loggedAt);
  static Insertable<PrayerLogEntry> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? prayer,
    Expression<String>? status,
    Expression<int>? mosqueId,
    Expression<String>? notes,
    Expression<String>? loggedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (prayer != null) 'prayer': prayer,
      if (status != null) 'status': status,
      if (mosqueId != null) 'mosque_id': mosqueId,
      if (notes != null) 'notes': notes,
      if (loggedAt != null) 'logged_at': loggedAt,
    });
  }

  PrayerLogEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? prayer,
    Value<String>? status,
    Value<int?>? mosqueId,
    Value<String?>? notes,
    Value<String>? loggedAt,
  }) {
    return PrayerLogEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      prayer: prayer ?? this.prayer,
      status: status ?? this.status,
      mosqueId: mosqueId ?? this.mosqueId,
      notes: notes ?? this.notes,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (prayer.present) {
      map['prayer'] = Variable<String>(prayer.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (mosqueId.present) {
      map['mosque_id'] = Variable<int>(mosqueId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<String>(loggedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerLogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('prayer: $prayer, ')
          ..write('status: $status, ')
          ..write('mosqueId: $mosqueId, ')
          ..write('notes: $notes, ')
          ..write('loggedAt: $loggedAt')
          ..write(')'))
        .toString();
  }
}

class $TimingRuleEntriesTable extends TimingRuleEntries
    with TableInfo<$TimingRuleEntriesTable, TimingRuleEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimingRuleEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mosqueIdMeta = const VerificationMeta(
    'mosqueId',
  );
  @override
  late final GeneratedColumn<int> mosqueId = GeneratedColumn<int>(
    'mosque_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mosques (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SalahPrayer, String> prayer =
      GeneratedColumn<String>(
        'prayer',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SalahPrayer>($TimingRuleEntriesTable.$converterprayer);
  @override
  late final GeneratedColumnWithTypeConverter<TimingRuleMode, String> mode =
      GeneratedColumn<String>(
        'mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TimingRuleMode>($TimingRuleEntriesTable.$convertermode);
  static const VerificationMeta _offsetMinutesMeta = const VerificationMeta(
    'offsetMinutes',
  );
  @override
  late final GeneratedColumn<int> offsetMinutes = GeneratedColumn<int>(
    'offset_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TimeOfDayValue?, String>
  fixedTime =
      GeneratedColumn<String>(
        'fixed_time',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<TimeOfDayValue?>(
        $TimingRuleEntriesTable.$converterfixedTimen,
      );
  @override
  late final GeneratedColumnWithTypeConverter<MonthDay?, String> rangeStart =
      GeneratedColumn<String>(
        'range_start',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<MonthDay?>($TimingRuleEntriesTable.$converterrangeStartn);
  @override
  late final GeneratedColumnWithTypeConverter<MonthDay?, String> rangeEnd =
      GeneratedColumn<String>(
        'range_end',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<MonthDay?>($TimingRuleEntriesTable.$converterrangeEndn);
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mosqueId,
    prayer,
    mode,
    offsetMinutes,
    fixedTime,
    rangeStart,
    rangeEnd,
    priority,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timing_rule_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimingRuleEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mosque_id')) {
      context.handle(
        _mosqueIdMeta,
        mosqueId.isAcceptableOrUnknown(data['mosque_id']!, _mosqueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mosqueIdMeta);
    }
    if (data.containsKey('offset_minutes')) {
      context.handle(
        _offsetMinutesMeta,
        offsetMinutes.isAcceptableOrUnknown(
          data['offset_minutes']!,
          _offsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimingRuleEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimingRuleEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mosqueId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mosque_id'],
      )!,
      prayer: $TimingRuleEntriesTable.$converterprayer.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}prayer'],
        )!,
      ),
      mode: $TimingRuleEntriesTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mode'],
        )!,
      ),
      offsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offset_minutes'],
      ),
      fixedTime: $TimingRuleEntriesTable.$converterfixedTimen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fixed_time'],
        ),
      ),
      rangeStart: $TimingRuleEntriesTable.$converterrangeStartn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}range_start'],
        ),
      ),
      rangeEnd: $TimingRuleEntriesTable.$converterrangeEndn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}range_end'],
        ),
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TimingRuleEntriesTable createAlias(String alias) {
    return $TimingRuleEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SalahPrayer, String, String> $converterprayer =
      const EnumNameConverter<SalahPrayer>(SalahPrayer.values);
  static JsonTypeConverter2<TimingRuleMode, String, String> $convertermode =
      const EnumNameConverter<TimingRuleMode>(TimingRuleMode.values);
  static TypeConverter<TimeOfDayValue, String> $converterfixedTime =
      const TimeOfDayValueConverter();
  static TypeConverter<TimeOfDayValue?, String?> $converterfixedTimen =
      NullAwareTypeConverter.wrap($converterfixedTime);
  static TypeConverter<MonthDay, String> $converterrangeStart =
      const MonthDayConverter();
  static TypeConverter<MonthDay?, String?> $converterrangeStartn =
      NullAwareTypeConverter.wrap($converterrangeStart);
  static TypeConverter<MonthDay, String> $converterrangeEnd =
      const MonthDayConverter();
  static TypeConverter<MonthDay?, String?> $converterrangeEndn =
      NullAwareTypeConverter.wrap($converterrangeEnd);
}

class TimingRuleEntry extends DataClass implements Insertable<TimingRuleEntry> {
  final int id;
  final int mosqueId;
  final SalahPrayer prayer;
  final TimingRuleMode mode;
  final int? offsetMinutes;
  final TimeOfDayValue? fixedTime;
  final MonthDay? rangeStart;
  final MonthDay? rangeEnd;
  final int priority;
  final String createdAt;
  const TimingRuleEntry({
    required this.id,
    required this.mosqueId,
    required this.prayer,
    required this.mode,
    this.offsetMinutes,
    this.fixedTime,
    this.rangeStart,
    this.rangeEnd,
    required this.priority,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mosque_id'] = Variable<int>(mosqueId);
    {
      map['prayer'] = Variable<String>(
        $TimingRuleEntriesTable.$converterprayer.toSql(prayer),
      );
    }
    {
      map['mode'] = Variable<String>(
        $TimingRuleEntriesTable.$convertermode.toSql(mode),
      );
    }
    if (!nullToAbsent || offsetMinutes != null) {
      map['offset_minutes'] = Variable<int>(offsetMinutes);
    }
    if (!nullToAbsent || fixedTime != null) {
      map['fixed_time'] = Variable<String>(
        $TimingRuleEntriesTable.$converterfixedTimen.toSql(fixedTime),
      );
    }
    if (!nullToAbsent || rangeStart != null) {
      map['range_start'] = Variable<String>(
        $TimingRuleEntriesTable.$converterrangeStartn.toSql(rangeStart),
      );
    }
    if (!nullToAbsent || rangeEnd != null) {
      map['range_end'] = Variable<String>(
        $TimingRuleEntriesTable.$converterrangeEndn.toSql(rangeEnd),
      );
    }
    map['priority'] = Variable<int>(priority);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  TimingRuleEntriesCompanion toCompanion(bool nullToAbsent) {
    return TimingRuleEntriesCompanion(
      id: Value(id),
      mosqueId: Value(mosqueId),
      prayer: Value(prayer),
      mode: Value(mode),
      offsetMinutes: offsetMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(offsetMinutes),
      fixedTime: fixedTime == null && nullToAbsent
          ? const Value.absent()
          : Value(fixedTime),
      rangeStart: rangeStart == null && nullToAbsent
          ? const Value.absent()
          : Value(rangeStart),
      rangeEnd: rangeEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(rangeEnd),
      priority: Value(priority),
      createdAt: Value(createdAt),
    );
  }

  factory TimingRuleEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimingRuleEntry(
      id: serializer.fromJson<int>(json['id']),
      mosqueId: serializer.fromJson<int>(json['mosqueId']),
      prayer: $TimingRuleEntriesTable.$converterprayer.fromJson(
        serializer.fromJson<String>(json['prayer']),
      ),
      mode: $TimingRuleEntriesTable.$convertermode.fromJson(
        serializer.fromJson<String>(json['mode']),
      ),
      offsetMinutes: serializer.fromJson<int?>(json['offsetMinutes']),
      fixedTime: serializer.fromJson<TimeOfDayValue?>(json['fixedTime']),
      rangeStart: serializer.fromJson<MonthDay?>(json['rangeStart']),
      rangeEnd: serializer.fromJson<MonthDay?>(json['rangeEnd']),
      priority: serializer.fromJson<int>(json['priority']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mosqueId': serializer.toJson<int>(mosqueId),
      'prayer': serializer.toJson<String>(
        $TimingRuleEntriesTable.$converterprayer.toJson(prayer),
      ),
      'mode': serializer.toJson<String>(
        $TimingRuleEntriesTable.$convertermode.toJson(mode),
      ),
      'offsetMinutes': serializer.toJson<int?>(offsetMinutes),
      'fixedTime': serializer.toJson<TimeOfDayValue?>(fixedTime),
      'rangeStart': serializer.toJson<MonthDay?>(rangeStart),
      'rangeEnd': serializer.toJson<MonthDay?>(rangeEnd),
      'priority': serializer.toJson<int>(priority),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  TimingRuleEntry copyWith({
    int? id,
    int? mosqueId,
    SalahPrayer? prayer,
    TimingRuleMode? mode,
    Value<int?> offsetMinutes = const Value.absent(),
    Value<TimeOfDayValue?> fixedTime = const Value.absent(),
    Value<MonthDay?> rangeStart = const Value.absent(),
    Value<MonthDay?> rangeEnd = const Value.absent(),
    int? priority,
    String? createdAt,
  }) => TimingRuleEntry(
    id: id ?? this.id,
    mosqueId: mosqueId ?? this.mosqueId,
    prayer: prayer ?? this.prayer,
    mode: mode ?? this.mode,
    offsetMinutes: offsetMinutes.present
        ? offsetMinutes.value
        : this.offsetMinutes,
    fixedTime: fixedTime.present ? fixedTime.value : this.fixedTime,
    rangeStart: rangeStart.present ? rangeStart.value : this.rangeStart,
    rangeEnd: rangeEnd.present ? rangeEnd.value : this.rangeEnd,
    priority: priority ?? this.priority,
    createdAt: createdAt ?? this.createdAt,
  );
  TimingRuleEntry copyWithCompanion(TimingRuleEntriesCompanion data) {
    return TimingRuleEntry(
      id: data.id.present ? data.id.value : this.id,
      mosqueId: data.mosqueId.present ? data.mosqueId.value : this.mosqueId,
      prayer: data.prayer.present ? data.prayer.value : this.prayer,
      mode: data.mode.present ? data.mode.value : this.mode,
      offsetMinutes: data.offsetMinutes.present
          ? data.offsetMinutes.value
          : this.offsetMinutes,
      fixedTime: data.fixedTime.present ? data.fixedTime.value : this.fixedTime,
      rangeStart: data.rangeStart.present
          ? data.rangeStart.value
          : this.rangeStart,
      rangeEnd: data.rangeEnd.present ? data.rangeEnd.value : this.rangeEnd,
      priority: data.priority.present ? data.priority.value : this.priority,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimingRuleEntry(')
          ..write('id: $id, ')
          ..write('mosqueId: $mosqueId, ')
          ..write('prayer: $prayer, ')
          ..write('mode: $mode, ')
          ..write('offsetMinutes: $offsetMinutes, ')
          ..write('fixedTime: $fixedTime, ')
          ..write('rangeStart: $rangeStart, ')
          ..write('rangeEnd: $rangeEnd, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mosqueId,
    prayer,
    mode,
    offsetMinutes,
    fixedTime,
    rangeStart,
    rangeEnd,
    priority,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimingRuleEntry &&
          other.id == this.id &&
          other.mosqueId == this.mosqueId &&
          other.prayer == this.prayer &&
          other.mode == this.mode &&
          other.offsetMinutes == this.offsetMinutes &&
          other.fixedTime == this.fixedTime &&
          other.rangeStart == this.rangeStart &&
          other.rangeEnd == this.rangeEnd &&
          other.priority == this.priority &&
          other.createdAt == this.createdAt);
}

class TimingRuleEntriesCompanion extends UpdateCompanion<TimingRuleEntry> {
  final Value<int> id;
  final Value<int> mosqueId;
  final Value<SalahPrayer> prayer;
  final Value<TimingRuleMode> mode;
  final Value<int?> offsetMinutes;
  final Value<TimeOfDayValue?> fixedTime;
  final Value<MonthDay?> rangeStart;
  final Value<MonthDay?> rangeEnd;
  final Value<int> priority;
  final Value<String> createdAt;
  const TimingRuleEntriesCompanion({
    this.id = const Value.absent(),
    this.mosqueId = const Value.absent(),
    this.prayer = const Value.absent(),
    this.mode = const Value.absent(),
    this.offsetMinutes = const Value.absent(),
    this.fixedTime = const Value.absent(),
    this.rangeStart = const Value.absent(),
    this.rangeEnd = const Value.absent(),
    this.priority = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TimingRuleEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int mosqueId,
    required SalahPrayer prayer,
    required TimingRuleMode mode,
    this.offsetMinutes = const Value.absent(),
    this.fixedTime = const Value.absent(),
    this.rangeStart = const Value.absent(),
    this.rangeEnd = const Value.absent(),
    this.priority = const Value.absent(),
    required String createdAt,
  }) : mosqueId = Value(mosqueId),
       prayer = Value(prayer),
       mode = Value(mode),
       createdAt = Value(createdAt);
  static Insertable<TimingRuleEntry> custom({
    Expression<int>? id,
    Expression<int>? mosqueId,
    Expression<String>? prayer,
    Expression<String>? mode,
    Expression<int>? offsetMinutes,
    Expression<String>? fixedTime,
    Expression<String>? rangeStart,
    Expression<String>? rangeEnd,
    Expression<int>? priority,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mosqueId != null) 'mosque_id': mosqueId,
      if (prayer != null) 'prayer': prayer,
      if (mode != null) 'mode': mode,
      if (offsetMinutes != null) 'offset_minutes': offsetMinutes,
      if (fixedTime != null) 'fixed_time': fixedTime,
      if (rangeStart != null) 'range_start': rangeStart,
      if (rangeEnd != null) 'range_end': rangeEnd,
      if (priority != null) 'priority': priority,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TimingRuleEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? mosqueId,
    Value<SalahPrayer>? prayer,
    Value<TimingRuleMode>? mode,
    Value<int?>? offsetMinutes,
    Value<TimeOfDayValue?>? fixedTime,
    Value<MonthDay?>? rangeStart,
    Value<MonthDay?>? rangeEnd,
    Value<int>? priority,
    Value<String>? createdAt,
  }) {
    return TimingRuleEntriesCompanion(
      id: id ?? this.id,
      mosqueId: mosqueId ?? this.mosqueId,
      prayer: prayer ?? this.prayer,
      mode: mode ?? this.mode,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      fixedTime: fixedTime ?? this.fixedTime,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mosqueId.present) {
      map['mosque_id'] = Variable<int>(mosqueId.value);
    }
    if (prayer.present) {
      map['prayer'] = Variable<String>(
        $TimingRuleEntriesTable.$converterprayer.toSql(prayer.value),
      );
    }
    if (mode.present) {
      map['mode'] = Variable<String>(
        $TimingRuleEntriesTable.$convertermode.toSql(mode.value),
      );
    }
    if (offsetMinutes.present) {
      map['offset_minutes'] = Variable<int>(offsetMinutes.value);
    }
    if (fixedTime.present) {
      map['fixed_time'] = Variable<String>(
        $TimingRuleEntriesTable.$converterfixedTimen.toSql(fixedTime.value),
      );
    }
    if (rangeStart.present) {
      map['range_start'] = Variable<String>(
        $TimingRuleEntriesTable.$converterrangeStartn.toSql(rangeStart.value),
      );
    }
    if (rangeEnd.present) {
      map['range_end'] = Variable<String>(
        $TimingRuleEntriesTable.$converterrangeEndn.toSql(rangeEnd.value),
      );
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimingRuleEntriesCompanion(')
          ..write('id: $id, ')
          ..write('mosqueId: $mosqueId, ')
          ..write('prayer: $prayer, ')
          ..write('mode: $mode, ')
          ..write('offsetMinutes: $offsetMinutes, ')
          ..write('fixedTime: $fixedTime, ')
          ..write('rangeStart: $rangeStart, ')
          ..write('rangeEnd: $rangeEnd, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsEntriesTable appSettingsEntries =
      $AppSettingsEntriesTable(this);
  late final $IbadahTaskEntriesTable ibadahTaskEntries =
      $IbadahTaskEntriesTable(this);
  late final $IbadahCompletionEntriesTable ibadahCompletionEntries =
      $IbadahCompletionEntriesTable(this);
  late final $MosquesTable mosques = $MosquesTable(this);
  late final $PrayerLogEntriesTable prayerLogEntries = $PrayerLogEntriesTable(
    this,
  );
  late final $TimingRuleEntriesTable timingRuleEntries =
      $TimingRuleEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettingsEntries,
    ibadahTaskEntries,
    ibadahCompletionEntries,
    mosques,
    prayerLogEntries,
    timingRuleEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ibadah_task_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('ibadah_completion_entries', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'mosques',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('prayer_log_entries', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'mosques',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('timing_rule_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AppSettingsEntriesTableCreateCompanionBuilder =
    AppSettingsEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsEntriesTableUpdateCompanionBuilder =
    AppSettingsEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsEntriesTable,
          AppSettingsEntry,
          $$AppSettingsEntriesTableFilterComposer,
          $$AppSettingsEntriesTableOrderingComposer,
          $$AppSettingsEntriesTableAnnotationComposer,
          $$AppSettingsEntriesTableCreateCompanionBuilder,
          $$AppSettingsEntriesTableUpdateCompanionBuilder,
          (
            AppSettingsEntry,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsEntriesTable,
              AppSettingsEntry
            >,
          ),
          AppSettingsEntry,
          PrefetchHooks Function()
        > {
  $$AppSettingsEntriesTableTableManager(
    _$AppDatabase db,
    $AppSettingsEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsEntriesCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsEntriesTable,
      AppSettingsEntry,
      $$AppSettingsEntriesTableFilterComposer,
      $$AppSettingsEntriesTableOrderingComposer,
      $$AppSettingsEntriesTableAnnotationComposer,
      $$AppSettingsEntriesTableCreateCompanionBuilder,
      $$AppSettingsEntriesTableUpdateCompanionBuilder,
      (
        AppSettingsEntry,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsEntriesTable,
          AppSettingsEntry
        >,
      ),
      AppSettingsEntry,
      PrefetchHooks Function()
    >;
typedef $$IbadahTaskEntriesTableCreateCompanionBuilder =
    IbadahTaskEntriesCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> description,
      Value<String?> prayerLink,
      Value<String> timing,
      required String repeatType,
      Value<String?> repeatDays,
      Value<int?> countTarget,
      Value<bool> isActive,
      Value<int> sortOrder,
    });
typedef $$IbadahTaskEntriesTableUpdateCompanionBuilder =
    IbadahTaskEntriesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> description,
      Value<String?> prayerLink,
      Value<String> timing,
      Value<String> repeatType,
      Value<String?> repeatDays,
      Value<int?> countTarget,
      Value<bool> isActive,
      Value<int> sortOrder,
    });

final class $$IbadahTaskEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $IbadahTaskEntriesTable,
          IbadahTaskEntry
        > {
  $$IbadahTaskEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $IbadahCompletionEntriesTable,
    List<IbadahCompletionEntry>
  >
  _ibadahCompletionEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ibadahCompletionEntries,
        aliasName: $_aliasNameGenerator(
          db.ibadahTaskEntries.id,
          db.ibadahCompletionEntries.taskId,
        ),
      );

  $$IbadahCompletionEntriesTableProcessedTableManager
  get ibadahCompletionEntriesRefs {
    final manager = $$IbadahCompletionEntriesTableTableManager(
      $_db,
      $_db.ibadahCompletionEntries,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ibadahCompletionEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IbadahTaskEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $IbadahTaskEntriesTable> {
  $$IbadahTaskEntriesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prayerLink => $composableBuilder(
    column: $table.prayerLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timing => $composableBuilder(
    column: $table.timing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatType => $composableBuilder(
    column: $table.repeatType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countTarget => $composableBuilder(
    column: $table.countTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ibadahCompletionEntriesRefs(
    Expression<bool> Function($$IbadahCompletionEntriesTableFilterComposer f) f,
  ) {
    final $$IbadahCompletionEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ibadahCompletionEntries,
          getReferencedColumn: (t) => t.taskId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IbadahCompletionEntriesTableFilterComposer(
                $db: $db,
                $table: $db.ibadahCompletionEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$IbadahTaskEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $IbadahTaskEntriesTable> {
  $$IbadahTaskEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prayerLink => $composableBuilder(
    column: $table.prayerLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timing => $composableBuilder(
    column: $table.timing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatType => $composableBuilder(
    column: $table.repeatType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countTarget => $composableBuilder(
    column: $table.countTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IbadahTaskEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IbadahTaskEntriesTable> {
  $$IbadahTaskEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prayerLink => $composableBuilder(
    column: $table.prayerLink,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timing =>
      $composableBuilder(column: $table.timing, builder: (column) => column);

  GeneratedColumn<String> get repeatType => $composableBuilder(
    column: $table.repeatType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get countTarget => $composableBuilder(
    column: $table.countTarget,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> ibadahCompletionEntriesRefs<T extends Object>(
    Expression<T> Function($$IbadahCompletionEntriesTableAnnotationComposer a)
    f,
  ) {
    final $$IbadahCompletionEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ibadahCompletionEntries,
          getReferencedColumn: (t) => t.taskId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IbadahCompletionEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.ibadahCompletionEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$IbadahTaskEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IbadahTaskEntriesTable,
          IbadahTaskEntry,
          $$IbadahTaskEntriesTableFilterComposer,
          $$IbadahTaskEntriesTableOrderingComposer,
          $$IbadahTaskEntriesTableAnnotationComposer,
          $$IbadahTaskEntriesTableCreateCompanionBuilder,
          $$IbadahTaskEntriesTableUpdateCompanionBuilder,
          (IbadahTaskEntry, $$IbadahTaskEntriesTableReferences),
          IbadahTaskEntry,
          PrefetchHooks Function({bool ibadahCompletionEntriesRefs})
        > {
  $$IbadahTaskEntriesTableTableManager(
    _$AppDatabase db,
    $IbadahTaskEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IbadahTaskEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IbadahTaskEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IbadahTaskEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> prayerLink = const Value.absent(),
                Value<String> timing = const Value.absent(),
                Value<String> repeatType = const Value.absent(),
                Value<String?> repeatDays = const Value.absent(),
                Value<int?> countTarget = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => IbadahTaskEntriesCompanion(
                id: id,
                title: title,
                description: description,
                prayerLink: prayerLink,
                timing: timing,
                repeatType: repeatType,
                repeatDays: repeatDays,
                countTarget: countTarget,
                isActive: isActive,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> prayerLink = const Value.absent(),
                Value<String> timing = const Value.absent(),
                required String repeatType,
                Value<String?> repeatDays = const Value.absent(),
                Value<int?> countTarget = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => IbadahTaskEntriesCompanion.insert(
                id: id,
                title: title,
                description: description,
                prayerLink: prayerLink,
                timing: timing,
                repeatType: repeatType,
                repeatDays: repeatDays,
                countTarget: countTarget,
                isActive: isActive,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IbadahTaskEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ibadahCompletionEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ibadahCompletionEntriesRefs) db.ibadahCompletionEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ibadahCompletionEntriesRefs)
                    await $_getPrefetchedData<
                      IbadahTaskEntry,
                      $IbadahTaskEntriesTable,
                      IbadahCompletionEntry
                    >(
                      currentTable: table,
                      referencedTable: $$IbadahTaskEntriesTableReferences
                          ._ibadahCompletionEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$IbadahTaskEntriesTableReferences(
                            db,
                            table,
                            p0,
                          ).ibadahCompletionEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.taskId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$IbadahTaskEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IbadahTaskEntriesTable,
      IbadahTaskEntry,
      $$IbadahTaskEntriesTableFilterComposer,
      $$IbadahTaskEntriesTableOrderingComposer,
      $$IbadahTaskEntriesTableAnnotationComposer,
      $$IbadahTaskEntriesTableCreateCompanionBuilder,
      $$IbadahTaskEntriesTableUpdateCompanionBuilder,
      (IbadahTaskEntry, $$IbadahTaskEntriesTableReferences),
      IbadahTaskEntry,
      PrefetchHooks Function({bool ibadahCompletionEntriesRefs})
    >;
typedef $$IbadahCompletionEntriesTableCreateCompanionBuilder =
    IbadahCompletionEntriesCompanion Function({
      Value<int> id,
      required int taskId,
      required String date,
      Value<String?> prayerInstance,
      Value<int> countDone,
      Value<bool> completed,
      Value<String?> notes,
    });
typedef $$IbadahCompletionEntriesTableUpdateCompanionBuilder =
    IbadahCompletionEntriesCompanion Function({
      Value<int> id,
      Value<int> taskId,
      Value<String> date,
      Value<String?> prayerInstance,
      Value<int> countDone,
      Value<bool> completed,
      Value<String?> notes,
    });

final class $$IbadahCompletionEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $IbadahCompletionEntriesTable,
          IbadahCompletionEntry
        > {
  $$IbadahCompletionEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IbadahTaskEntriesTable _taskIdTable(_$AppDatabase db) =>
      db.ibadahTaskEntries.createAlias(
        $_aliasNameGenerator(
          db.ibadahCompletionEntries.taskId,
          db.ibadahTaskEntries.id,
        ),
      );

  $$IbadahTaskEntriesTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<int>('task_id')!;

    final manager = $$IbadahTaskEntriesTableTableManager(
      $_db,
      $_db.ibadahTaskEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IbadahCompletionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $IbadahCompletionEntriesTable> {
  $$IbadahCompletionEntriesTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prayerInstance => $composableBuilder(
    column: $table.prayerInstance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countDone => $composableBuilder(
    column: $table.countDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$IbadahTaskEntriesTableFilterComposer get taskId {
    final $$IbadahTaskEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.ibadahTaskEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IbadahTaskEntriesTableFilterComposer(
            $db: $db,
            $table: $db.ibadahTaskEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IbadahCompletionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $IbadahCompletionEntriesTable> {
  $$IbadahCompletionEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prayerInstance => $composableBuilder(
    column: $table.prayerInstance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countDone => $composableBuilder(
    column: $table.countDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$IbadahTaskEntriesTableOrderingComposer get taskId {
    final $$IbadahTaskEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.ibadahTaskEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IbadahTaskEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.ibadahTaskEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IbadahCompletionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IbadahCompletionEntriesTable> {
  $$IbadahCompletionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get prayerInstance => $composableBuilder(
    column: $table.prayerInstance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get countDone =>
      $composableBuilder(column: $table.countDone, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$IbadahTaskEntriesTableAnnotationComposer get taskId {
    final $$IbadahTaskEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.taskId,
          referencedTable: $db.ibadahTaskEntries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IbadahTaskEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.ibadahTaskEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$IbadahCompletionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IbadahCompletionEntriesTable,
          IbadahCompletionEntry,
          $$IbadahCompletionEntriesTableFilterComposer,
          $$IbadahCompletionEntriesTableOrderingComposer,
          $$IbadahCompletionEntriesTableAnnotationComposer,
          $$IbadahCompletionEntriesTableCreateCompanionBuilder,
          $$IbadahCompletionEntriesTableUpdateCompanionBuilder,
          (IbadahCompletionEntry, $$IbadahCompletionEntriesTableReferences),
          IbadahCompletionEntry,
          PrefetchHooks Function({bool taskId})
        > {
  $$IbadahCompletionEntriesTableTableManager(
    _$AppDatabase db,
    $IbadahCompletionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IbadahCompletionEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$IbadahCompletionEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$IbadahCompletionEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> taskId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> prayerInstance = const Value.absent(),
                Value<int> countDone = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => IbadahCompletionEntriesCompanion(
                id: id,
                taskId: taskId,
                date: date,
                prayerInstance: prayerInstance,
                countDone: countDone,
                completed: completed,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int taskId,
                required String date,
                Value<String?> prayerInstance = const Value.absent(),
                Value<int> countDone = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => IbadahCompletionEntriesCompanion.insert(
                id: id,
                taskId: taskId,
                date: date,
                prayerInstance: prayerInstance,
                countDone: countDone,
                completed: completed,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IbadahCompletionEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
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
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable:
                                    $$IbadahCompletionEntriesTableReferences
                                        ._taskIdTable(db),
                                referencedColumn:
                                    $$IbadahCompletionEntriesTableReferences
                                        ._taskIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$IbadahCompletionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IbadahCompletionEntriesTable,
      IbadahCompletionEntry,
      $$IbadahCompletionEntriesTableFilterComposer,
      $$IbadahCompletionEntriesTableOrderingComposer,
      $$IbadahCompletionEntriesTableAnnotationComposer,
      $$IbadahCompletionEntriesTableCreateCompanionBuilder,
      $$IbadahCompletionEntriesTableUpdateCompanionBuilder,
      (IbadahCompletionEntry, $$IbadahCompletionEntriesTableReferences),
      IbadahCompletionEntry,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$MosquesTableCreateCompanionBuilder =
    MosquesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> area,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<bool> isPrimary,
      Value<bool> isActive,
      Value<String?> notes,
      required String createdAt,
      required String updatedAt,
    });
typedef $$MosquesTableUpdateCompanionBuilder =
    MosquesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> area,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<bool> isPrimary,
      Value<bool> isActive,
      Value<String?> notes,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

final class $$MosquesTableReferences
    extends BaseReferences<_$AppDatabase, $MosquesTable, Mosque> {
  $$MosquesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PrayerLogEntriesTable, List<PrayerLogEntry>>
  _prayerLogEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.prayerLogEntries,
    aliasName: $_aliasNameGenerator(
      db.mosques.id,
      db.prayerLogEntries.mosqueId,
    ),
  );

  $$PrayerLogEntriesTableProcessedTableManager get prayerLogEntriesRefs {
    final manager = $$PrayerLogEntriesTableTableManager(
      $_db,
      $_db.prayerLogEntries,
    ).filter((f) => f.mosqueId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _prayerLogEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TimingRuleEntriesTable, List<TimingRuleEntry>>
  _timingRuleEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.timingRuleEntries,
        aliasName: $_aliasNameGenerator(
          db.mosques.id,
          db.timingRuleEntries.mosqueId,
        ),
      );

  $$TimingRuleEntriesTableProcessedTableManager get timingRuleEntriesRefs {
    final manager = $$TimingRuleEntriesTableTableManager(
      $_db,
      $_db.timingRuleEntries,
    ).filter((f) => f.mosqueId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _timingRuleEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MosquesTableFilterComposer
    extends Composer<_$AppDatabase, $MosquesTable> {
  $$MosquesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> prayerLogEntriesRefs(
    Expression<bool> Function($$PrayerLogEntriesTableFilterComposer f) f,
  ) {
    final $$PrayerLogEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prayerLogEntries,
      getReferencedColumn: (t) => t.mosqueId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerLogEntriesTableFilterComposer(
            $db: $db,
            $table: $db.prayerLogEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> timingRuleEntriesRefs(
    Expression<bool> Function($$TimingRuleEntriesTableFilterComposer f) f,
  ) {
    final $$TimingRuleEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timingRuleEntries,
      getReferencedColumn: (t) => t.mosqueId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimingRuleEntriesTableFilterComposer(
            $db: $db,
            $table: $db.timingRuleEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MosquesTableOrderingComposer
    extends Composer<_$AppDatabase, $MosquesTable> {
  $$MosquesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MosquesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MosquesTable> {
  $$MosquesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> prayerLogEntriesRefs<T extends Object>(
    Expression<T> Function($$PrayerLogEntriesTableAnnotationComposer a) f,
  ) {
    final $$PrayerLogEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prayerLogEntries,
      getReferencedColumn: (t) => t.mosqueId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerLogEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.prayerLogEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> timingRuleEntriesRefs<T extends Object>(
    Expression<T> Function($$TimingRuleEntriesTableAnnotationComposer a) f,
  ) {
    final $$TimingRuleEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.timingRuleEntries,
          getReferencedColumn: (t) => t.mosqueId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TimingRuleEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.timingRuleEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MosquesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MosquesTable,
          Mosque,
          $$MosquesTableFilterComposer,
          $$MosquesTableOrderingComposer,
          $$MosquesTableAnnotationComposer,
          $$MosquesTableCreateCompanionBuilder,
          $$MosquesTableUpdateCompanionBuilder,
          (Mosque, $$MosquesTableReferences),
          Mosque,
          PrefetchHooks Function({
            bool prayerLogEntriesRefs,
            bool timingRuleEntriesRefs,
          })
        > {
  $$MosquesTableTableManager(_$AppDatabase db, $MosquesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MosquesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MosquesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MosquesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> area = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => MosquesCompanion(
                id: id,
                name: name,
                area: area,
                latitude: latitude,
                longitude: longitude,
                isPrimary: isPrimary,
                isActive: isActive,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> area = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => MosquesCompanion.insert(
                id: id,
                name: name,
                area: area,
                latitude: latitude,
                longitude: longitude,
                isPrimary: isPrimary,
                isActive: isActive,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MosquesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({prayerLogEntriesRefs = false, timingRuleEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (prayerLogEntriesRefs) db.prayerLogEntries,
                    if (timingRuleEntriesRefs) db.timingRuleEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (prayerLogEntriesRefs)
                        await $_getPrefetchedData<
                          Mosque,
                          $MosquesTable,
                          PrayerLogEntry
                        >(
                          currentTable: table,
                          referencedTable: $$MosquesTableReferences
                              ._prayerLogEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MosquesTableReferences(
                                db,
                                table,
                                p0,
                              ).prayerLogEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mosqueId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (timingRuleEntriesRefs)
                        await $_getPrefetchedData<
                          Mosque,
                          $MosquesTable,
                          TimingRuleEntry
                        >(
                          currentTable: table,
                          referencedTable: $$MosquesTableReferences
                              ._timingRuleEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MosquesTableReferences(
                                db,
                                table,
                                p0,
                              ).timingRuleEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mosqueId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MosquesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MosquesTable,
      Mosque,
      $$MosquesTableFilterComposer,
      $$MosquesTableOrderingComposer,
      $$MosquesTableAnnotationComposer,
      $$MosquesTableCreateCompanionBuilder,
      $$MosquesTableUpdateCompanionBuilder,
      (Mosque, $$MosquesTableReferences),
      Mosque,
      PrefetchHooks Function({
        bool prayerLogEntriesRefs,
        bool timingRuleEntriesRefs,
      })
    >;
typedef $$PrayerLogEntriesTableCreateCompanionBuilder =
    PrayerLogEntriesCompanion Function({
      Value<int> id,
      required String date,
      required String prayer,
      required String status,
      Value<int?> mosqueId,
      Value<String?> notes,
      required String loggedAt,
    });
typedef $$PrayerLogEntriesTableUpdateCompanionBuilder =
    PrayerLogEntriesCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> prayer,
      Value<String> status,
      Value<int?> mosqueId,
      Value<String?> notes,
      Value<String> loggedAt,
    });

final class $$PrayerLogEntriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $PrayerLogEntriesTable, PrayerLogEntry> {
  $$PrayerLogEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MosquesTable _mosqueIdTable(_$AppDatabase db) =>
      db.mosques.createAlias(
        $_aliasNameGenerator(db.prayerLogEntries.mosqueId, db.mosques.id),
      );

  $$MosquesTableProcessedTableManager? get mosqueId {
    final $_column = $_itemColumn<int>('mosque_id');
    if ($_column == null) return null;
    final manager = $$MosquesTableTableManager(
      $_db,
      $_db.mosques,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mosqueIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PrayerLogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerLogEntriesTable> {
  $$PrayerLogEntriesTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MosquesTableFilterComposer get mosqueId {
    final $$MosquesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mosqueId,
      referencedTable: $db.mosques,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MosquesTableFilterComposer(
            $db: $db,
            $table: $db.mosques,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerLogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerLogEntriesTable> {
  $$PrayerLogEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MosquesTableOrderingComposer get mosqueId {
    final $$MosquesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mosqueId,
      referencedTable: $db.mosques,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MosquesTableOrderingComposer(
            $db: $db,
            $table: $db.mosques,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerLogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerLogEntriesTable> {
  $$PrayerLogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get prayer =>
      $composableBuilder(column: $table.prayer, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  $$MosquesTableAnnotationComposer get mosqueId {
    final $$MosquesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mosqueId,
      referencedTable: $db.mosques,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MosquesTableAnnotationComposer(
            $db: $db,
            $table: $db.mosques,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerLogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerLogEntriesTable,
          PrayerLogEntry,
          $$PrayerLogEntriesTableFilterComposer,
          $$PrayerLogEntriesTableOrderingComposer,
          $$PrayerLogEntriesTableAnnotationComposer,
          $$PrayerLogEntriesTableCreateCompanionBuilder,
          $$PrayerLogEntriesTableUpdateCompanionBuilder,
          (PrayerLogEntry, $$PrayerLogEntriesTableReferences),
          PrayerLogEntry,
          PrefetchHooks Function({bool mosqueId})
        > {
  $$PrayerLogEntriesTableTableManager(
    _$AppDatabase db,
    $PrayerLogEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerLogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerLogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerLogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> prayer = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> mosqueId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> loggedAt = const Value.absent(),
              }) => PrayerLogEntriesCompanion(
                id: id,
                date: date,
                prayer: prayer,
                status: status,
                mosqueId: mosqueId,
                notes: notes,
                loggedAt: loggedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required String prayer,
                required String status,
                Value<int?> mosqueId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String loggedAt,
              }) => PrayerLogEntriesCompanion.insert(
                id: id,
                date: date,
                prayer: prayer,
                status: status,
                mosqueId: mosqueId,
                notes: notes,
                loggedAt: loggedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrayerLogEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mosqueId = false}) {
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
                    if (mosqueId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mosqueId,
                                referencedTable:
                                    $$PrayerLogEntriesTableReferences
                                        ._mosqueIdTable(db),
                                referencedColumn:
                                    $$PrayerLogEntriesTableReferences
                                        ._mosqueIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$PrayerLogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerLogEntriesTable,
      PrayerLogEntry,
      $$PrayerLogEntriesTableFilterComposer,
      $$PrayerLogEntriesTableOrderingComposer,
      $$PrayerLogEntriesTableAnnotationComposer,
      $$PrayerLogEntriesTableCreateCompanionBuilder,
      $$PrayerLogEntriesTableUpdateCompanionBuilder,
      (PrayerLogEntry, $$PrayerLogEntriesTableReferences),
      PrayerLogEntry,
      PrefetchHooks Function({bool mosqueId})
    >;
typedef $$TimingRuleEntriesTableCreateCompanionBuilder =
    TimingRuleEntriesCompanion Function({
      Value<int> id,
      required int mosqueId,
      required SalahPrayer prayer,
      required TimingRuleMode mode,
      Value<int?> offsetMinutes,
      Value<TimeOfDayValue?> fixedTime,
      Value<MonthDay?> rangeStart,
      Value<MonthDay?> rangeEnd,
      Value<int> priority,
      required String createdAt,
    });
typedef $$TimingRuleEntriesTableUpdateCompanionBuilder =
    TimingRuleEntriesCompanion Function({
      Value<int> id,
      Value<int> mosqueId,
      Value<SalahPrayer> prayer,
      Value<TimingRuleMode> mode,
      Value<int?> offsetMinutes,
      Value<TimeOfDayValue?> fixedTime,
      Value<MonthDay?> rangeStart,
      Value<MonthDay?> rangeEnd,
      Value<int> priority,
      Value<String> createdAt,
    });

final class $$TimingRuleEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TimingRuleEntriesTable,
          TimingRuleEntry
        > {
  $$TimingRuleEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MosquesTable _mosqueIdTable(_$AppDatabase db) =>
      db.mosques.createAlias(
        $_aliasNameGenerator(db.timingRuleEntries.mosqueId, db.mosques.id),
      );

  $$MosquesTableProcessedTableManager get mosqueId {
    final $_column = $_itemColumn<int>('mosque_id')!;

    final manager = $$MosquesTableTableManager(
      $_db,
      $_db.mosques,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mosqueIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TimingRuleEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TimingRuleEntriesTable> {
  $$TimingRuleEntriesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<SalahPrayer, SalahPrayer, String> get prayer =>
      $composableBuilder(
        column: $table.prayer,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<TimingRuleMode, TimingRuleMode, String>
  get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TimeOfDayValue?, TimeOfDayValue, String>
  get fixedTime => $composableBuilder(
    column: $table.fixedTime,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MonthDay?, MonthDay, String> get rangeStart =>
      $composableBuilder(
        column: $table.rangeStart,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<MonthDay?, MonthDay, String> get rangeEnd =>
      $composableBuilder(
        column: $table.rangeEnd,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MosquesTableFilterComposer get mosqueId {
    final $$MosquesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mosqueId,
      referencedTable: $db.mosques,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MosquesTableFilterComposer(
            $db: $db,
            $table: $db.mosques,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimingRuleEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimingRuleEntriesTable> {
  $$TimingRuleEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fixedTime => $composableBuilder(
    column: $table.fixedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rangeStart => $composableBuilder(
    column: $table.rangeStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rangeEnd => $composableBuilder(
    column: $table.rangeEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MosquesTableOrderingComposer get mosqueId {
    final $$MosquesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mosqueId,
      referencedTable: $db.mosques,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MosquesTableOrderingComposer(
            $db: $db,
            $table: $db.mosques,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimingRuleEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimingRuleEntriesTable> {
  $$TimingRuleEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SalahPrayer, String> get prayer =>
      $composableBuilder(column: $table.prayer, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TimingRuleMode, String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TimeOfDayValue?, String> get fixedTime =>
      $composableBuilder(column: $table.fixedTime, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MonthDay?, String> get rangeStart =>
      $composableBuilder(
        column: $table.rangeStart,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<MonthDay?, String> get rangeEnd =>
      $composableBuilder(column: $table.rangeEnd, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MosquesTableAnnotationComposer get mosqueId {
    final $$MosquesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mosqueId,
      referencedTable: $db.mosques,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MosquesTableAnnotationComposer(
            $db: $db,
            $table: $db.mosques,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimingRuleEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimingRuleEntriesTable,
          TimingRuleEntry,
          $$TimingRuleEntriesTableFilterComposer,
          $$TimingRuleEntriesTableOrderingComposer,
          $$TimingRuleEntriesTableAnnotationComposer,
          $$TimingRuleEntriesTableCreateCompanionBuilder,
          $$TimingRuleEntriesTableUpdateCompanionBuilder,
          (TimingRuleEntry, $$TimingRuleEntriesTableReferences),
          TimingRuleEntry,
          PrefetchHooks Function({bool mosqueId})
        > {
  $$TimingRuleEntriesTableTableManager(
    _$AppDatabase db,
    $TimingRuleEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimingRuleEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimingRuleEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimingRuleEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> mosqueId = const Value.absent(),
                Value<SalahPrayer> prayer = const Value.absent(),
                Value<TimingRuleMode> mode = const Value.absent(),
                Value<int?> offsetMinutes = const Value.absent(),
                Value<TimeOfDayValue?> fixedTime = const Value.absent(),
                Value<MonthDay?> rangeStart = const Value.absent(),
                Value<MonthDay?> rangeEnd = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => TimingRuleEntriesCompanion(
                id: id,
                mosqueId: mosqueId,
                prayer: prayer,
                mode: mode,
                offsetMinutes: offsetMinutes,
                fixedTime: fixedTime,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                priority: priority,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int mosqueId,
                required SalahPrayer prayer,
                required TimingRuleMode mode,
                Value<int?> offsetMinutes = const Value.absent(),
                Value<TimeOfDayValue?> fixedTime = const Value.absent(),
                Value<MonthDay?> rangeStart = const Value.absent(),
                Value<MonthDay?> rangeEnd = const Value.absent(),
                Value<int> priority = const Value.absent(),
                required String createdAt,
              }) => TimingRuleEntriesCompanion.insert(
                id: id,
                mosqueId: mosqueId,
                prayer: prayer,
                mode: mode,
                offsetMinutes: offsetMinutes,
                fixedTime: fixedTime,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                priority: priority,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimingRuleEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mosqueId = false}) {
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
                    if (mosqueId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mosqueId,
                                referencedTable:
                                    $$TimingRuleEntriesTableReferences
                                        ._mosqueIdTable(db),
                                referencedColumn:
                                    $$TimingRuleEntriesTableReferences
                                        ._mosqueIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$TimingRuleEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimingRuleEntriesTable,
      TimingRuleEntry,
      $$TimingRuleEntriesTableFilterComposer,
      $$TimingRuleEntriesTableOrderingComposer,
      $$TimingRuleEntriesTableAnnotationComposer,
      $$TimingRuleEntriesTableCreateCompanionBuilder,
      $$TimingRuleEntriesTableUpdateCompanionBuilder,
      (TimingRuleEntry, $$TimingRuleEntriesTableReferences),
      TimingRuleEntry,
      PrefetchHooks Function({bool mosqueId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsEntriesTableTableManager get appSettingsEntries =>
      $$AppSettingsEntriesTableTableManager(_db, _db.appSettingsEntries);
  $$IbadahTaskEntriesTableTableManager get ibadahTaskEntries =>
      $$IbadahTaskEntriesTableTableManager(_db, _db.ibadahTaskEntries);
  $$IbadahCompletionEntriesTableTableManager get ibadahCompletionEntries =>
      $$IbadahCompletionEntriesTableTableManager(
        _db,
        _db.ibadahCompletionEntries,
      );
  $$MosquesTableTableManager get mosques =>
      $$MosquesTableTableManager(_db, _db.mosques);
  $$PrayerLogEntriesTableTableManager get prayerLogEntries =>
      $$PrayerLogEntriesTableTableManager(_db, _db.prayerLogEntries);
  $$TimingRuleEntriesTableTableManager get timingRuleEntries =>
      $$TimingRuleEntriesTableTableManager(_db, _db.timingRuleEntries);
}
