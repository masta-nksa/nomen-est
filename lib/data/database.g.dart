// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ClassesTable extends Classes with TableInfo<$ClassesTable, SchoolClass> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceFileMeta = const VerificationMeta(
    'sourceFile',
  );
  @override
  late final GeneratedColumn<String> sourceFile = GeneratedColumn<String>(
    'source_file',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, label, sourceFile, importedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'classes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchoolClass> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('source_file')) {
      context.handle(
        _sourceFileMeta,
        sourceFile.isAcceptableOrUnknown(data['source_file']!, _sourceFileMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceFileMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SchoolClass map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchoolClass(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      sourceFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_file'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $ClassesTable createAlias(String alias) {
    return $ClassesTable(attachedDatabase, alias);
  }
}

class SchoolClass extends DataClass implements Insertable<SchoolClass> {
  final int id;
  final String label;
  final String sourceFile;
  final DateTime importedAt;
  const SchoolClass({
    required this.id,
    required this.label,
    required this.sourceFile,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['source_file'] = Variable<String>(sourceFile);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  ClassesCompanion toCompanion(bool nullToAbsent) {
    return ClassesCompanion(
      id: Value(id),
      label: Value(label),
      sourceFile: Value(sourceFile),
      importedAt: Value(importedAt),
    );
  }

  factory SchoolClass.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchoolClass(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      sourceFile: serializer.fromJson<String>(json['sourceFile']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'sourceFile': serializer.toJson<String>(sourceFile),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  SchoolClass copyWith({
    int? id,
    String? label,
    String? sourceFile,
    DateTime? importedAt,
  }) => SchoolClass(
    id: id ?? this.id,
    label: label ?? this.label,
    sourceFile: sourceFile ?? this.sourceFile,
    importedAt: importedAt ?? this.importedAt,
  );
  SchoolClass copyWithCompanion(ClassesCompanion data) {
    return SchoolClass(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      sourceFile: data.sourceFile.present
          ? data.sourceFile.value
          : this.sourceFile,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchoolClass(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('sourceFile: $sourceFile, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, sourceFile, importedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchoolClass &&
          other.id == this.id &&
          other.label == this.label &&
          other.sourceFile == this.sourceFile &&
          other.importedAt == this.importedAt);
}

class ClassesCompanion extends UpdateCompanion<SchoolClass> {
  final Value<int> id;
  final Value<String> label;
  final Value<String> sourceFile;
  final Value<DateTime> importedAt;
  const ClassesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.sourceFile = const Value.absent(),
    this.importedAt = const Value.absent(),
  });
  ClassesCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required String sourceFile,
    required DateTime importedAt,
  }) : label = Value(label),
       sourceFile = Value(sourceFile),
       importedAt = Value(importedAt);
  static Insertable<SchoolClass> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? sourceFile,
    Expression<DateTime>? importedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (sourceFile != null) 'source_file': sourceFile,
      if (importedAt != null) 'imported_at': importedAt,
    });
  }

  ClassesCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<String>? sourceFile,
    Value<DateTime>? importedAt,
  }) {
    return ClassesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      sourceFile: sourceFile ?? this.sourceFile,
      importedAt: importedAt ?? this.importedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (sourceFile.present) {
      map['source_file'] = Variable<String>(sourceFile.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('sourceFile: $sourceFile, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }
}

class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES classes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jpegBytesMeta = const VerificationMeta(
    'jpegBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> jpegBytes = GeneratedColumn<Uint8List>(
    'jpeg_bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    classId,
    displayName,
    firstName,
    lastName,
    jpegBytes,
    orderIndex,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<Student> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('jpeg_bytes')) {
      context.handle(
        _jpegBytesMeta,
        jpegBytes.isAcceptableOrUnknown(data['jpeg_bytes']!, _jpegBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_jpegBytesMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      jpegBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}jpeg_bytes'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final int id;
  final int classId;
  final String displayName;
  final String firstName;
  final String lastName;
  final Uint8List jpegBytes;
  final int orderIndex;

  /// Someone who leaves the class mid-year is deactivated, not deleted.
  ///
  /// A delete would cascade through the draw log and the saved groups and
  /// quietly rewrite a history that did happen. Inactive students drop out of
  /// the pool and out of the quiz; their past stays readable.
  final bool active;
  const Student({
    required this.id,
    required this.classId,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.jpegBytes,
    required this.orderIndex,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_id'] = Variable<int>(classId);
    map['display_name'] = Variable<String>(displayName);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['jpeg_bytes'] = Variable<Uint8List>(jpegBytes);
    map['order_index'] = Variable<int>(orderIndex);
    map['active'] = Variable<bool>(active);
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      classId: Value(classId),
      displayName: Value(displayName),
      firstName: Value(firstName),
      lastName: Value(lastName),
      jpegBytes: Value(jpegBytes),
      orderIndex: Value(orderIndex),
      active: Value(active),
    );
  }

  factory Student.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<int>(json['id']),
      classId: serializer.fromJson<int>(json['classId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      jpegBytes: serializer.fromJson<Uint8List>(json['jpegBytes']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'classId': serializer.toJson<int>(classId),
      'displayName': serializer.toJson<String>(displayName),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'jpegBytes': serializer.toJson<Uint8List>(jpegBytes),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'active': serializer.toJson<bool>(active),
    };
  }

  Student copyWith({
    int? id,
    int? classId,
    String? displayName,
    String? firstName,
    String? lastName,
    Uint8List? jpegBytes,
    int? orderIndex,
    bool? active,
  }) => Student(
    id: id ?? this.id,
    classId: classId ?? this.classId,
    displayName: displayName ?? this.displayName,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    jpegBytes: jpegBytes ?? this.jpegBytes,
    orderIndex: orderIndex ?? this.orderIndex,
    active: active ?? this.active,
  );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      classId: data.classId.present ? data.classId.value : this.classId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      jpegBytes: data.jpegBytes.present ? data.jpegBytes.value : this.jpegBytes,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('displayName: $displayName, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('jpegBytes: $jpegBytes, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    classId,
    displayName,
    firstName,
    lastName,
    $driftBlobEquality.hash(jpegBytes),
    orderIndex,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.classId == this.classId &&
          other.displayName == this.displayName &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          $driftBlobEquality.equals(other.jpegBytes, this.jpegBytes) &&
          other.orderIndex == this.orderIndex &&
          other.active == this.active);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<int> id;
  final Value<int> classId;
  final Value<String> displayName;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<Uint8List> jpegBytes;
  final Value<int> orderIndex;
  final Value<bool> active;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.classId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.jpegBytes = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.active = const Value.absent(),
  });
  StudentsCompanion.insert({
    this.id = const Value.absent(),
    required int classId,
    required String displayName,
    required String firstName,
    required String lastName,
    required Uint8List jpegBytes,
    required int orderIndex,
    this.active = const Value.absent(),
  }) : classId = Value(classId),
       displayName = Value(displayName),
       firstName = Value(firstName),
       lastName = Value(lastName),
       jpegBytes = Value(jpegBytes),
       orderIndex = Value(orderIndex);
  static Insertable<Student> custom({
    Expression<int>? id,
    Expression<int>? classId,
    Expression<String>? displayName,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<Uint8List>? jpegBytes,
    Expression<int>? orderIndex,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classId != null) 'class_id': classId,
      if (displayName != null) 'display_name': displayName,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (jpegBytes != null) 'jpeg_bytes': jpegBytes,
      if (orderIndex != null) 'order_index': orderIndex,
      if (active != null) 'active': active,
    });
  }

  StudentsCompanion copyWith({
    Value<int>? id,
    Value<int>? classId,
    Value<String>? displayName,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<Uint8List>? jpegBytes,
    Value<int>? orderIndex,
    Value<bool>? active,
  }) {
    return StudentsCompanion(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      jpegBytes: jpegBytes ?? this.jpegBytes,
      orderIndex: orderIndex ?? this.orderIndex,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (jpegBytes.present) {
      map['jpeg_bytes'] = Variable<Uint8List>(jpegBytes.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('displayName: $displayName, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('jpegBytes: $jpegBytes, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $ProgressTable extends Progress
    with TableInfo<$ProgressTable, ProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _boxMeta = const VerificationMeta('box');
  @override
  late final GeneratedColumn<int> box = GeneratedColumn<int>(
    'box',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<int> correct = GeneratedColumn<int>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _wrongMeta = const VerificationMeta('wrong');
  @override
  late final GeneratedColumn<int> wrong = GeneratedColumn<int>(
    'wrong',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streakMeta = const VerificationMeta('streak');
  @override
  late final GeneratedColumn<int> streak = GeneratedColumn<int>(
    'streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgMsMeta = const VerificationMeta('avgMs');
  @override
  late final GeneratedColumn<int> avgMs = GeneratedColumn<int>(
    'avg_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    studentId,
    box,
    correct,
    wrong,
    streak,
    lastSeenAt,
    avgMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    }
    if (data.containsKey('box')) {
      context.handle(
        _boxMeta,
        box.isAcceptableOrUnknown(data['box']!, _boxMeta),
      );
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    }
    if (data.containsKey('wrong')) {
      context.handle(
        _wrongMeta,
        wrong.isAcceptableOrUnknown(data['wrong']!, _wrongMeta),
      );
    }
    if (data.containsKey('streak')) {
      context.handle(
        _streakMeta,
        streak.isAcceptableOrUnknown(data['streak']!, _streakMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('avg_ms')) {
      context.handle(
        _avgMsMeta,
        avgMs.isAcceptableOrUnknown(data['avg_ms']!, _avgMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {studentId};
  @override
  ProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressData(
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      box: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}box'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct'],
      )!,
      wrong: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong'],
      )!,
      streak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
      avgMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_ms'],
      )!,
    );
  }

  @override
  $ProgressTable createAlias(String alias) {
    return $ProgressTable(attachedDatabase, alias);
  }
}

class ProgressData extends DataClass implements Insertable<ProgressData> {
  final int studentId;
  final int box;
  final int correct;
  final int wrong;
  final int streak;
  final DateTime? lastSeenAt;
  final int avgMs;
  const ProgressData({
    required this.studentId,
    required this.box,
    required this.correct,
    required this.wrong,
    required this.streak,
    this.lastSeenAt,
    required this.avgMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['student_id'] = Variable<int>(studentId);
    map['box'] = Variable<int>(box);
    map['correct'] = Variable<int>(correct);
    map['wrong'] = Variable<int>(wrong);
    map['streak'] = Variable<int>(streak);
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    map['avg_ms'] = Variable<int>(avgMs);
    return map;
  }

  ProgressCompanion toCompanion(bool nullToAbsent) {
    return ProgressCompanion(
      studentId: Value(studentId),
      box: Value(box),
      correct: Value(correct),
      wrong: Value(wrong),
      streak: Value(streak),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      avgMs: Value(avgMs),
    );
  }

  factory ProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressData(
      studentId: serializer.fromJson<int>(json['studentId']),
      box: serializer.fromJson<int>(json['box']),
      correct: serializer.fromJson<int>(json['correct']),
      wrong: serializer.fromJson<int>(json['wrong']),
      streak: serializer.fromJson<int>(json['streak']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      avgMs: serializer.fromJson<int>(json['avgMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'studentId': serializer.toJson<int>(studentId),
      'box': serializer.toJson<int>(box),
      'correct': serializer.toJson<int>(correct),
      'wrong': serializer.toJson<int>(wrong),
      'streak': serializer.toJson<int>(streak),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'avgMs': serializer.toJson<int>(avgMs),
    };
  }

  ProgressData copyWith({
    int? studentId,
    int? box,
    int? correct,
    int? wrong,
    int? streak,
    Value<DateTime?> lastSeenAt = const Value.absent(),
    int? avgMs,
  }) => ProgressData(
    studentId: studentId ?? this.studentId,
    box: box ?? this.box,
    correct: correct ?? this.correct,
    wrong: wrong ?? this.wrong,
    streak: streak ?? this.streak,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    avgMs: avgMs ?? this.avgMs,
  );
  ProgressData copyWithCompanion(ProgressCompanion data) {
    return ProgressData(
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      box: data.box.present ? data.box.value : this.box,
      correct: data.correct.present ? data.correct.value : this.correct,
      wrong: data.wrong.present ? data.wrong.value : this.wrong,
      streak: data.streak.present ? data.streak.value : this.streak,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      avgMs: data.avgMs.present ? data.avgMs.value : this.avgMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressData(')
          ..write('studentId: $studentId, ')
          ..write('box: $box, ')
          ..write('correct: $correct, ')
          ..write('wrong: $wrong, ')
          ..write('streak: $streak, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('avgMs: $avgMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(studentId, box, correct, wrong, streak, lastSeenAt, avgMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressData &&
          other.studentId == this.studentId &&
          other.box == this.box &&
          other.correct == this.correct &&
          other.wrong == this.wrong &&
          other.streak == this.streak &&
          other.lastSeenAt == this.lastSeenAt &&
          other.avgMs == this.avgMs);
}

class ProgressCompanion extends UpdateCompanion<ProgressData> {
  final Value<int> studentId;
  final Value<int> box;
  final Value<int> correct;
  final Value<int> wrong;
  final Value<int> streak;
  final Value<DateTime?> lastSeenAt;
  final Value<int> avgMs;
  const ProgressCompanion({
    this.studentId = const Value.absent(),
    this.box = const Value.absent(),
    this.correct = const Value.absent(),
    this.wrong = const Value.absent(),
    this.streak = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.avgMs = const Value.absent(),
  });
  ProgressCompanion.insert({
    this.studentId = const Value.absent(),
    this.box = const Value.absent(),
    this.correct = const Value.absent(),
    this.wrong = const Value.absent(),
    this.streak = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.avgMs = const Value.absent(),
  });
  static Insertable<ProgressData> custom({
    Expression<int>? studentId,
    Expression<int>? box,
    Expression<int>? correct,
    Expression<int>? wrong,
    Expression<int>? streak,
    Expression<DateTime>? lastSeenAt,
    Expression<int>? avgMs,
  }) {
    return RawValuesInsertable({
      if (studentId != null) 'student_id': studentId,
      if (box != null) 'box': box,
      if (correct != null) 'correct': correct,
      if (wrong != null) 'wrong': wrong,
      if (streak != null) 'streak': streak,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (avgMs != null) 'avg_ms': avgMs,
    });
  }

  ProgressCompanion copyWith({
    Value<int>? studentId,
    Value<int>? box,
    Value<int>? correct,
    Value<int>? wrong,
    Value<int>? streak,
    Value<DateTime?>? lastSeenAt,
    Value<int>? avgMs,
  }) {
    return ProgressCompanion(
      studentId: studentId ?? this.studentId,
      box: box ?? this.box,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
      streak: streak ?? this.streak,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      avgMs: avgMs ?? this.avgMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (box.present) {
      map['box'] = Variable<int>(box.value);
    }
    if (correct.present) {
      map['correct'] = Variable<int>(correct.value);
    }
    if (wrong.present) {
      map['wrong'] = Variable<int>(wrong.value);
    }
    if (streak.present) {
      map['streak'] = Variable<int>(streak.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (avgMs.present) {
      map['avg_ms'] = Variable<int>(avgMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressCompanion(')
          ..write('studentId: $studentId, ')
          ..write('box: $box, ')
          ..write('correct: $correct, ')
          ..write('wrong: $wrong, ')
          ..write('streak: $streak, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('avgMs: $avgMs')
          ..write(')'))
        .toString();
  }
}

class $ConfusionsTable extends Confusions
    with TableInfo<$ConfusionsTable, Confusion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfusionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _confusedWithIdMeta = const VerificationMeta(
    'confusedWithId',
  );
  @override
  late final GeneratedColumn<int> confusedWithId = GeneratedColumn<int>(
    'confused_with_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [studentId, confusedWithId, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'confusions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Confusion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('confused_with_id')) {
      context.handle(
        _confusedWithIdMeta,
        confusedWithId.isAcceptableOrUnknown(
          data['confused_with_id']!,
          _confusedWithIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confusedWithIdMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {studentId, confusedWithId};
  @override
  Confusion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Confusion(
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      confusedWithId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confused_with_id'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $ConfusionsTable createAlias(String alias) {
    return $ConfusionsTable(attachedDatabase, alias);
  }
}

class Confusion extends DataClass implements Insertable<Confusion> {
  final int studentId;
  final int confusedWithId;
  final int count;
  const Confusion({
    required this.studentId,
    required this.confusedWithId,
    required this.count,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['student_id'] = Variable<int>(studentId);
    map['confused_with_id'] = Variable<int>(confusedWithId);
    map['count'] = Variable<int>(count);
    return map;
  }

  ConfusionsCompanion toCompanion(bool nullToAbsent) {
    return ConfusionsCompanion(
      studentId: Value(studentId),
      confusedWithId: Value(confusedWithId),
      count: Value(count),
    );
  }

  factory Confusion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Confusion(
      studentId: serializer.fromJson<int>(json['studentId']),
      confusedWithId: serializer.fromJson<int>(json['confusedWithId']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'studentId': serializer.toJson<int>(studentId),
      'confusedWithId': serializer.toJson<int>(confusedWithId),
      'count': serializer.toJson<int>(count),
    };
  }

  Confusion copyWith({int? studentId, int? confusedWithId, int? count}) =>
      Confusion(
        studentId: studentId ?? this.studentId,
        confusedWithId: confusedWithId ?? this.confusedWithId,
        count: count ?? this.count,
      );
  Confusion copyWithCompanion(ConfusionsCompanion data) {
    return Confusion(
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      confusedWithId: data.confusedWithId.present
          ? data.confusedWithId.value
          : this.confusedWithId,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Confusion(')
          ..write('studentId: $studentId, ')
          ..write('confusedWithId: $confusedWithId, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(studentId, confusedWithId, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Confusion &&
          other.studentId == this.studentId &&
          other.confusedWithId == this.confusedWithId &&
          other.count == this.count);
}

class ConfusionsCompanion extends UpdateCompanion<Confusion> {
  final Value<int> studentId;
  final Value<int> confusedWithId;
  final Value<int> count;
  final Value<int> rowid;
  const ConfusionsCompanion({
    this.studentId = const Value.absent(),
    this.confusedWithId = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfusionsCompanion.insert({
    required int studentId,
    required int confusedWithId,
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : studentId = Value(studentId),
       confusedWithId = Value(confusedWithId);
  static Insertable<Confusion> custom({
    Expression<int>? studentId,
    Expression<int>? confusedWithId,
    Expression<int>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (studentId != null) 'student_id': studentId,
      if (confusedWithId != null) 'confused_with_id': confusedWithId,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfusionsCompanion copyWith({
    Value<int>? studentId,
    Value<int>? confusedWithId,
    Value<int>? count,
    Value<int>? rowid,
  }) {
    return ConfusionsCompanion(
      studentId: studentId ?? this.studentId,
      confusedWithId: confusedWithId ?? this.confusedWithId,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (confusedWithId.present) {
      map['confused_with_id'] = Variable<int>(confusedWithId.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfusionsCompanion(')
          ..write('studentId: $studentId, ')
          ..write('confusedWithId: $confusedWithId, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DrawEventsTable extends DrawEvents
    with TableInfo<$DrawEventsTable, DrawEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DrawEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES classes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _poolKeyMeta = const VerificationMeta(
    'poolKey',
  );
  @override
  late final GeneratedColumn<String> poolKey = GeneratedColumn<String>(
    'pool_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultPoolKey),
  );
  static const VerificationMeta _drawnAtMeta = const VerificationMeta(
    'drawnAt',
  );
  @override
  late final GeneratedColumn<DateTime> drawnAt = GeneratedColumn<DateTime>(
    'drawn_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    classId,
    studentId,
    poolKey,
    drawnAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'draw_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<DrawEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('pool_key')) {
      context.handle(
        _poolKeyMeta,
        poolKey.isAcceptableOrUnknown(data['pool_key']!, _poolKeyMeta),
      );
    }
    if (data.containsKey('drawn_at')) {
      context.handle(
        _drawnAtMeta,
        drawnAt.isAcceptableOrUnknown(data['drawn_at']!, _drawnAtMeta),
      );
    } else if (isInserting) {
      context.missing(_drawnAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DrawEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DrawEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      poolKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pool_key'],
      )!,
      drawnAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}drawn_at'],
      )!,
    );
  }

  @override
  $DrawEventsTable createAlias(String alias) {
    return $DrawEventsTable(attachedDatabase, alias);
  }
}

class DrawEvent extends DataClass implements Insertable<DrawEvent> {
  final int id;
  final int classId;
  final int studentId;
  final String poolKey;
  final DateTime drawnAt;
  const DrawEvent({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.poolKey,
    required this.drawnAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_id'] = Variable<int>(classId);
    map['student_id'] = Variable<int>(studentId);
    map['pool_key'] = Variable<String>(poolKey);
    map['drawn_at'] = Variable<DateTime>(drawnAt);
    return map;
  }

  DrawEventsCompanion toCompanion(bool nullToAbsent) {
    return DrawEventsCompanion(
      id: Value(id),
      classId: Value(classId),
      studentId: Value(studentId),
      poolKey: Value(poolKey),
      drawnAt: Value(drawnAt),
    );
  }

  factory DrawEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DrawEvent(
      id: serializer.fromJson<int>(json['id']),
      classId: serializer.fromJson<int>(json['classId']),
      studentId: serializer.fromJson<int>(json['studentId']),
      poolKey: serializer.fromJson<String>(json['poolKey']),
      drawnAt: serializer.fromJson<DateTime>(json['drawnAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'classId': serializer.toJson<int>(classId),
      'studentId': serializer.toJson<int>(studentId),
      'poolKey': serializer.toJson<String>(poolKey),
      'drawnAt': serializer.toJson<DateTime>(drawnAt),
    };
  }

  DrawEvent copyWith({
    int? id,
    int? classId,
    int? studentId,
    String? poolKey,
    DateTime? drawnAt,
  }) => DrawEvent(
    id: id ?? this.id,
    classId: classId ?? this.classId,
    studentId: studentId ?? this.studentId,
    poolKey: poolKey ?? this.poolKey,
    drawnAt: drawnAt ?? this.drawnAt,
  );
  DrawEvent copyWithCompanion(DrawEventsCompanion data) {
    return DrawEvent(
      id: data.id.present ? data.id.value : this.id,
      classId: data.classId.present ? data.classId.value : this.classId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      poolKey: data.poolKey.present ? data.poolKey.value : this.poolKey,
      drawnAt: data.drawnAt.present ? data.drawnAt.value : this.drawnAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DrawEvent(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('studentId: $studentId, ')
          ..write('poolKey: $poolKey, ')
          ..write('drawnAt: $drawnAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, classId, studentId, poolKey, drawnAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DrawEvent &&
          other.id == this.id &&
          other.classId == this.classId &&
          other.studentId == this.studentId &&
          other.poolKey == this.poolKey &&
          other.drawnAt == this.drawnAt);
}

class DrawEventsCompanion extends UpdateCompanion<DrawEvent> {
  final Value<int> id;
  final Value<int> classId;
  final Value<int> studentId;
  final Value<String> poolKey;
  final Value<DateTime> drawnAt;
  const DrawEventsCompanion({
    this.id = const Value.absent(),
    this.classId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.poolKey = const Value.absent(),
    this.drawnAt = const Value.absent(),
  });
  DrawEventsCompanion.insert({
    this.id = const Value.absent(),
    required int classId,
    required int studentId,
    this.poolKey = const Value.absent(),
    required DateTime drawnAt,
  }) : classId = Value(classId),
       studentId = Value(studentId),
       drawnAt = Value(drawnAt);
  static Insertable<DrawEvent> custom({
    Expression<int>? id,
    Expression<int>? classId,
    Expression<int>? studentId,
    Expression<String>? poolKey,
    Expression<DateTime>? drawnAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classId != null) 'class_id': classId,
      if (studentId != null) 'student_id': studentId,
      if (poolKey != null) 'pool_key': poolKey,
      if (drawnAt != null) 'drawn_at': drawnAt,
    });
  }

  DrawEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? classId,
    Value<int>? studentId,
    Value<String>? poolKey,
    Value<DateTime>? drawnAt,
  }) {
    return DrawEventsCompanion(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      studentId: studentId ?? this.studentId,
      poolKey: poolKey ?? this.poolKey,
      drawnAt: drawnAt ?? this.drawnAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (poolKey.present) {
      map['pool_key'] = Variable<String>(poolKey.value);
    }
    if (drawnAt.present) {
      map['drawn_at'] = Variable<DateTime>(drawnAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DrawEventsCompanion(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('studentId: $studentId, ')
          ..write('poolKey: $poolKey, ')
          ..write('drawnAt: $drawnAt')
          ..write(')'))
        .toString();
  }
}

class $PoolResetsTable extends PoolResets
    with TableInfo<$PoolResetsTable, PoolReset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PoolResetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES classes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _poolKeyMeta = const VerificationMeta(
    'poolKey',
  );
  @override
  late final GeneratedColumn<String> poolKey = GeneratedColumn<String>(
    'pool_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultPoolKey),
  );
  static const VerificationMeta _resetAtMeta = const VerificationMeta(
    'resetAt',
  );
  @override
  late final GeneratedColumn<DateTime> resetAt = GeneratedColumn<DateTime>(
    'reset_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _autoMeta = const VerificationMeta('auto');
  @override
  late final GeneratedColumn<bool> auto = GeneratedColumn<bool>(
    'auto',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, classId, poolKey, resetAt, auto];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pool_resets';
  @override
  VerificationContext validateIntegrity(
    Insertable<PoolReset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('pool_key')) {
      context.handle(
        _poolKeyMeta,
        poolKey.isAcceptableOrUnknown(data['pool_key']!, _poolKeyMeta),
      );
    }
    if (data.containsKey('reset_at')) {
      context.handle(
        _resetAtMeta,
        resetAt.isAcceptableOrUnknown(data['reset_at']!, _resetAtMeta),
      );
    } else if (isInserting) {
      context.missing(_resetAtMeta);
    }
    if (data.containsKey('auto')) {
      context.handle(
        _autoMeta,
        auto.isAcceptableOrUnknown(data['auto']!, _autoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PoolReset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PoolReset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_id'],
      )!,
      poolKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pool_key'],
      )!,
      resetAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reset_at'],
      )!,
      auto: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto'],
      )!,
    );
  }

  @override
  $PoolResetsTable createAlias(String alias) {
    return $PoolResetsTable(attachedDatabase, alias);
  }
}

class PoolReset extends DataClass implements Insertable<PoolReset> {
  final int id;
  final int classId;
  final String poolKey;
  final DateTime resetAt;

  /// Whether the app started the round by itself instead of asking.
  final bool auto;
  const PoolReset({
    required this.id,
    required this.classId,
    required this.poolKey,
    required this.resetAt,
    required this.auto,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_id'] = Variable<int>(classId);
    map['pool_key'] = Variable<String>(poolKey);
    map['reset_at'] = Variable<DateTime>(resetAt);
    map['auto'] = Variable<bool>(auto);
    return map;
  }

  PoolResetsCompanion toCompanion(bool nullToAbsent) {
    return PoolResetsCompanion(
      id: Value(id),
      classId: Value(classId),
      poolKey: Value(poolKey),
      resetAt: Value(resetAt),
      auto: Value(auto),
    );
  }

  factory PoolReset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PoolReset(
      id: serializer.fromJson<int>(json['id']),
      classId: serializer.fromJson<int>(json['classId']),
      poolKey: serializer.fromJson<String>(json['poolKey']),
      resetAt: serializer.fromJson<DateTime>(json['resetAt']),
      auto: serializer.fromJson<bool>(json['auto']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'classId': serializer.toJson<int>(classId),
      'poolKey': serializer.toJson<String>(poolKey),
      'resetAt': serializer.toJson<DateTime>(resetAt),
      'auto': serializer.toJson<bool>(auto),
    };
  }

  PoolReset copyWith({
    int? id,
    int? classId,
    String? poolKey,
    DateTime? resetAt,
    bool? auto,
  }) => PoolReset(
    id: id ?? this.id,
    classId: classId ?? this.classId,
    poolKey: poolKey ?? this.poolKey,
    resetAt: resetAt ?? this.resetAt,
    auto: auto ?? this.auto,
  );
  PoolReset copyWithCompanion(PoolResetsCompanion data) {
    return PoolReset(
      id: data.id.present ? data.id.value : this.id,
      classId: data.classId.present ? data.classId.value : this.classId,
      poolKey: data.poolKey.present ? data.poolKey.value : this.poolKey,
      resetAt: data.resetAt.present ? data.resetAt.value : this.resetAt,
      auto: data.auto.present ? data.auto.value : this.auto,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PoolReset(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('poolKey: $poolKey, ')
          ..write('resetAt: $resetAt, ')
          ..write('auto: $auto')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, classId, poolKey, resetAt, auto);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PoolReset &&
          other.id == this.id &&
          other.classId == this.classId &&
          other.poolKey == this.poolKey &&
          other.resetAt == this.resetAt &&
          other.auto == this.auto);
}

class PoolResetsCompanion extends UpdateCompanion<PoolReset> {
  final Value<int> id;
  final Value<int> classId;
  final Value<String> poolKey;
  final Value<DateTime> resetAt;
  final Value<bool> auto;
  const PoolResetsCompanion({
    this.id = const Value.absent(),
    this.classId = const Value.absent(),
    this.poolKey = const Value.absent(),
    this.resetAt = const Value.absent(),
    this.auto = const Value.absent(),
  });
  PoolResetsCompanion.insert({
    this.id = const Value.absent(),
    required int classId,
    this.poolKey = const Value.absent(),
    required DateTime resetAt,
    this.auto = const Value.absent(),
  }) : classId = Value(classId),
       resetAt = Value(resetAt);
  static Insertable<PoolReset> custom({
    Expression<int>? id,
    Expression<int>? classId,
    Expression<String>? poolKey,
    Expression<DateTime>? resetAt,
    Expression<bool>? auto,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classId != null) 'class_id': classId,
      if (poolKey != null) 'pool_key': poolKey,
      if (resetAt != null) 'reset_at': resetAt,
      if (auto != null) 'auto': auto,
    });
  }

  PoolResetsCompanion copyWith({
    Value<int>? id,
    Value<int>? classId,
    Value<String>? poolKey,
    Value<DateTime>? resetAt,
    Value<bool>? auto,
  }) {
    return PoolResetsCompanion(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      poolKey: poolKey ?? this.poolKey,
      resetAt: resetAt ?? this.resetAt,
      auto: auto ?? this.auto,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (poolKey.present) {
      map['pool_key'] = Variable<String>(poolKey.value);
    }
    if (resetAt.present) {
      map['reset_at'] = Variable<DateTime>(resetAt.value);
    }
    if (auto.present) {
      map['auto'] = Variable<bool>(auto.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PoolResetsCompanion(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('poolKey: $poolKey, ')
          ..write('resetAt: $resetAt, ')
          ..write('auto: $auto')
          ..write(')'))
        .toString();
  }
}

class $AbsencesTable extends Absences with TableInfo<$AbsencesTable, Absence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AbsencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES classes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [classId, studentId, day];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'absences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Absence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {classId, studentId, day};
  @override
  Absence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Absence(
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day'],
      )!,
    );
  }

  @override
  $AbsencesTable createAlias(String alias) {
    return $AbsencesTable(attachedDatabase, alias);
  }
}

class Absence extends DataClass implements Insertable<Absence> {
  final int classId;
  final int studentId;

  /// Calendar day as `20260816`, see [dayNumber].
  final int day;
  const Absence({
    required this.classId,
    required this.studentId,
    required this.day,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['class_id'] = Variable<int>(classId);
    map['student_id'] = Variable<int>(studentId);
    map['day'] = Variable<int>(day);
    return map;
  }

  AbsencesCompanion toCompanion(bool nullToAbsent) {
    return AbsencesCompanion(
      classId: Value(classId),
      studentId: Value(studentId),
      day: Value(day),
    );
  }

  factory Absence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Absence(
      classId: serializer.fromJson<int>(json['classId']),
      studentId: serializer.fromJson<int>(json['studentId']),
      day: serializer.fromJson<int>(json['day']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'classId': serializer.toJson<int>(classId),
      'studentId': serializer.toJson<int>(studentId),
      'day': serializer.toJson<int>(day),
    };
  }

  Absence copyWith({int? classId, int? studentId, int? day}) => Absence(
    classId: classId ?? this.classId,
    studentId: studentId ?? this.studentId,
    day: day ?? this.day,
  );
  Absence copyWithCompanion(AbsencesCompanion data) {
    return Absence(
      classId: data.classId.present ? data.classId.value : this.classId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      day: data.day.present ? data.day.value : this.day,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Absence(')
          ..write('classId: $classId, ')
          ..write('studentId: $studentId, ')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(classId, studentId, day);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Absence &&
          other.classId == this.classId &&
          other.studentId == this.studentId &&
          other.day == this.day);
}

class AbsencesCompanion extends UpdateCompanion<Absence> {
  final Value<int> classId;
  final Value<int> studentId;
  final Value<int> day;
  final Value<int> rowid;
  const AbsencesCompanion({
    this.classId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.day = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AbsencesCompanion.insert({
    required int classId,
    required int studentId,
    required int day,
    this.rowid = const Value.absent(),
  }) : classId = Value(classId),
       studentId = Value(studentId),
       day = Value(day);
  static Insertable<Absence> custom({
    Expression<int>? classId,
    Expression<int>? studentId,
    Expression<int>? day,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (classId != null) 'class_id': classId,
      if (studentId != null) 'student_id': studentId,
      if (day != null) 'day': day,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AbsencesCompanion copyWith({
    Value<int>? classId,
    Value<int>? studentId,
    Value<int>? day,
    Value<int>? rowid,
  }) {
    return AbsencesCompanion(
      classId: classId ?? this.classId,
      studentId: studentId ?? this.studentId,
      day: day ?? this.day,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AbsencesCompanion(')
          ..write('classId: $classId, ')
          ..write('studentId: $studentId, ')
          ..write('day: $day, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupSetsTable extends GroupSets
    with TableInfo<$GroupSetsTable, GroupSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupSetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES classes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, classId, label, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
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
  GroupSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GroupSetsTable createAlias(String alias) {
    return $GroupSetsTable(attachedDatabase, alias);
  }
}

class GroupSet extends DataClass implements Insertable<GroupSet> {
  final int id;
  final int classId;
  final String label;
  final DateTime createdAt;
  const GroupSet({
    required this.id,
    required this.classId,
    required this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_id'] = Variable<int>(classId);
    map['label'] = Variable<String>(label);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GroupSetsCompanion toCompanion(bool nullToAbsent) {
    return GroupSetsCompanion(
      id: Value(id),
      classId: Value(classId),
      label: Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory GroupSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupSet(
      id: serializer.fromJson<int>(json['id']),
      classId: serializer.fromJson<int>(json['classId']),
      label: serializer.fromJson<String>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'classId': serializer.toJson<int>(classId),
      'label': serializer.toJson<String>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GroupSet copyWith({
    int? id,
    int? classId,
    String? label,
    DateTime? createdAt,
  }) => GroupSet(
    id: id ?? this.id,
    classId: classId ?? this.classId,
    label: label ?? this.label,
    createdAt: createdAt ?? this.createdAt,
  );
  GroupSet copyWithCompanion(GroupSetsCompanion data) {
    return GroupSet(
      id: data.id.present ? data.id.value : this.id,
      classId: data.classId.present ? data.classId.value : this.classId,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupSet(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, classId, label, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupSet &&
          other.id == this.id &&
          other.classId == this.classId &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class GroupSetsCompanion extends UpdateCompanion<GroupSet> {
  final Value<int> id;
  final Value<int> classId;
  final Value<String> label;
  final Value<DateTime> createdAt;
  const GroupSetsCompanion({
    this.id = const Value.absent(),
    this.classId = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GroupSetsCompanion.insert({
    this.id = const Value.absent(),
    required int classId,
    required String label,
    required DateTime createdAt,
  }) : classId = Value(classId),
       label = Value(label),
       createdAt = Value(createdAt);
  static Insertable<GroupSet> custom({
    Expression<int>? id,
    Expression<int>? classId,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classId != null) 'class_id': classId,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GroupSetsCompanion copyWith({
    Value<int>? id,
    Value<int>? classId,
    Value<String>? label,
    Value<DateTime>? createdAt,
  }) {
    return GroupSetsCompanion(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupSetsCompanion(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GroupMembersTable extends GroupMembers
    with TableInfo<$GroupMembersTable, GroupMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupSetIdMeta = const VerificationMeta(
    'groupSetId',
  );
  @override
  late final GeneratedColumn<int> groupSetId = GeneratedColumn<int>(
    'group_set_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES group_sets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _groupIndexMeta = const VerificationMeta(
    'groupIndex',
  );
  @override
  late final GeneratedColumn<int> groupIndex = GeneratedColumn<int>(
    'group_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    groupSetId,
    groupIndex,
    studentId,
    role,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_set_id')) {
      context.handle(
        _groupSetIdMeta,
        groupSetId.isAcceptableOrUnknown(
          data['group_set_id']!,
          _groupSetIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_groupSetIdMeta);
    }
    if (data.containsKey('group_index')) {
      context.handle(
        _groupIndexMeta,
        groupIndex.isAcceptableOrUnknown(data['group_index']!, _groupIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIndexMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupSetId, studentId};
  @override
  GroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMember(
      groupSetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_set_id'],
      )!,
      groupIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_index'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
    );
  }

  @override
  $GroupMembersTable createAlias(String alias) {
    return $GroupMembersTable(attachedDatabase, alias);
  }
}

class GroupMember extends DataClass implements Insertable<GroupMember> {
  final int groupSetId;

  /// 0-based index of the group within its set.
  final int groupIndex;
  final int studentId;

  /// "Protokoll", "Zeit", "Präsentation" — assigned per grouping.
  final String? role;
  const GroupMember({
    required this.groupSetId,
    required this.groupIndex,
    required this.studentId,
    this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_set_id'] = Variable<int>(groupSetId);
    map['group_index'] = Variable<int>(groupIndex);
    map['student_id'] = Variable<int>(studentId);
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    return map;
  }

  GroupMembersCompanion toCompanion(bool nullToAbsent) {
    return GroupMembersCompanion(
      groupSetId: Value(groupSetId),
      groupIndex: Value(groupIndex),
      studentId: Value(studentId),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
    );
  }

  factory GroupMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMember(
      groupSetId: serializer.fromJson<int>(json['groupSetId']),
      groupIndex: serializer.fromJson<int>(json['groupIndex']),
      studentId: serializer.fromJson<int>(json['studentId']),
      role: serializer.fromJson<String?>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupSetId': serializer.toJson<int>(groupSetId),
      'groupIndex': serializer.toJson<int>(groupIndex),
      'studentId': serializer.toJson<int>(studentId),
      'role': serializer.toJson<String?>(role),
    };
  }

  GroupMember copyWith({
    int? groupSetId,
    int? groupIndex,
    int? studentId,
    Value<String?> role = const Value.absent(),
  }) => GroupMember(
    groupSetId: groupSetId ?? this.groupSetId,
    groupIndex: groupIndex ?? this.groupIndex,
    studentId: studentId ?? this.studentId,
    role: role.present ? role.value : this.role,
  );
  GroupMember copyWithCompanion(GroupMembersCompanion data) {
    return GroupMember(
      groupSetId: data.groupSetId.present
          ? data.groupSetId.value
          : this.groupSetId,
      groupIndex: data.groupIndex.present
          ? data.groupIndex.value
          : this.groupIndex,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMember(')
          ..write('groupSetId: $groupSetId, ')
          ..write('groupIndex: $groupIndex, ')
          ..write('studentId: $studentId, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupSetId, groupIndex, studentId, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMember &&
          other.groupSetId == this.groupSetId &&
          other.groupIndex == this.groupIndex &&
          other.studentId == this.studentId &&
          other.role == this.role);
}

class GroupMembersCompanion extends UpdateCompanion<GroupMember> {
  final Value<int> groupSetId;
  final Value<int> groupIndex;
  final Value<int> studentId;
  final Value<String?> role;
  final Value<int> rowid;
  const GroupMembersCompanion({
    this.groupSetId = const Value.absent(),
    this.groupIndex = const Value.absent(),
    this.studentId = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupMembersCompanion.insert({
    required int groupSetId,
    required int groupIndex,
    required int studentId,
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : groupSetId = Value(groupSetId),
       groupIndex = Value(groupIndex),
       studentId = Value(studentId);
  static Insertable<GroupMember> custom({
    Expression<int>? groupSetId,
    Expression<int>? groupIndex,
    Expression<int>? studentId,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupSetId != null) 'group_set_id': groupSetId,
      if (groupIndex != null) 'group_index': groupIndex,
      if (studentId != null) 'student_id': studentId,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupMembersCompanion copyWith({
    Value<int>? groupSetId,
    Value<int>? groupIndex,
    Value<int>? studentId,
    Value<String?>? role,
    Value<int>? rowid,
  }) {
    return GroupMembersCompanion(
      groupSetId: groupSetId ?? this.groupSetId,
      groupIndex: groupIndex ?? this.groupIndex,
      studentId: studentId ?? this.studentId,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupSetId.present) {
      map['group_set_id'] = Variable<int>(groupSetId.value);
    }
    if (groupIndex.present) {
      map['group_index'] = Variable<int>(groupIndex.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembersCompanion(')
          ..write('groupSetId: $groupSetId, ')
          ..write('groupIndex: $groupIndex, ')
          ..write('studentId: $studentId, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PairCountsTable extends PairCounts
    with TableInfo<$PairCountsTable, PairCount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PairCountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES classes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _studentAMeta = const VerificationMeta(
    'studentA',
  );
  @override
  late final GeneratedColumn<int> studentA = GeneratedColumn<int>(
    'student_a',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _studentBMeta = const VerificationMeta(
    'studentB',
  );
  @override
  late final GeneratedColumn<int> studentB = GeneratedColumn<int>(
    'student_b',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAtMeta = const VerificationMeta('lastAt');
  @override
  late final GeneratedColumn<DateTime> lastAt = GeneratedColumn<DateTime>(
    'last_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    classId,
    studentA,
    studentB,
    count,
    lastAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pair_counts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PairCount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('student_a')) {
      context.handle(
        _studentAMeta,
        studentA.isAcceptableOrUnknown(data['student_a']!, _studentAMeta),
      );
    } else if (isInserting) {
      context.missing(_studentAMeta);
    }
    if (data.containsKey('student_b')) {
      context.handle(
        _studentBMeta,
        studentB.isAcceptableOrUnknown(data['student_b']!, _studentBMeta),
      );
    } else if (isInserting) {
      context.missing(_studentBMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('last_at')) {
      context.handle(
        _lastAtMeta,
        lastAt.isAcceptableOrUnknown(data['last_at']!, _lastAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {classId, studentA, studentB};
  @override
  PairCount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PairCount(
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_id'],
      )!,
      studentA: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_a'],
      )!,
      studentB: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_b'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      lastAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_at'],
      ),
    );
  }

  @override
  $PairCountsTable createAlias(String alias) {
    return $PairCountsTable(attachedDatabase, alias);
  }
}

class PairCount extends DataClass implements Insertable<PairCount> {
  final int classId;
  final int studentA;
  final int studentB;
  final int count;
  final DateTime? lastAt;
  const PairCount({
    required this.classId,
    required this.studentA,
    required this.studentB,
    required this.count,
    this.lastAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['class_id'] = Variable<int>(classId);
    map['student_a'] = Variable<int>(studentA);
    map['student_b'] = Variable<int>(studentB);
    map['count'] = Variable<int>(count);
    if (!nullToAbsent || lastAt != null) {
      map['last_at'] = Variable<DateTime>(lastAt);
    }
    return map;
  }

  PairCountsCompanion toCompanion(bool nullToAbsent) {
    return PairCountsCompanion(
      classId: Value(classId),
      studentA: Value(studentA),
      studentB: Value(studentB),
      count: Value(count),
      lastAt: lastAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAt),
    );
  }

  factory PairCount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PairCount(
      classId: serializer.fromJson<int>(json['classId']),
      studentA: serializer.fromJson<int>(json['studentA']),
      studentB: serializer.fromJson<int>(json['studentB']),
      count: serializer.fromJson<int>(json['count']),
      lastAt: serializer.fromJson<DateTime?>(json['lastAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'classId': serializer.toJson<int>(classId),
      'studentA': serializer.toJson<int>(studentA),
      'studentB': serializer.toJson<int>(studentB),
      'count': serializer.toJson<int>(count),
      'lastAt': serializer.toJson<DateTime?>(lastAt),
    };
  }

  PairCount copyWith({
    int? classId,
    int? studentA,
    int? studentB,
    int? count,
    Value<DateTime?> lastAt = const Value.absent(),
  }) => PairCount(
    classId: classId ?? this.classId,
    studentA: studentA ?? this.studentA,
    studentB: studentB ?? this.studentB,
    count: count ?? this.count,
    lastAt: lastAt.present ? lastAt.value : this.lastAt,
  );
  PairCount copyWithCompanion(PairCountsCompanion data) {
    return PairCount(
      classId: data.classId.present ? data.classId.value : this.classId,
      studentA: data.studentA.present ? data.studentA.value : this.studentA,
      studentB: data.studentB.present ? data.studentB.value : this.studentB,
      count: data.count.present ? data.count.value : this.count,
      lastAt: data.lastAt.present ? data.lastAt.value : this.lastAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PairCount(')
          ..write('classId: $classId, ')
          ..write('studentA: $studentA, ')
          ..write('studentB: $studentB, ')
          ..write('count: $count, ')
          ..write('lastAt: $lastAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(classId, studentA, studentB, count, lastAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PairCount &&
          other.classId == this.classId &&
          other.studentA == this.studentA &&
          other.studentB == this.studentB &&
          other.count == this.count &&
          other.lastAt == this.lastAt);
}

class PairCountsCompanion extends UpdateCompanion<PairCount> {
  final Value<int> classId;
  final Value<int> studentA;
  final Value<int> studentB;
  final Value<int> count;
  final Value<DateTime?> lastAt;
  final Value<int> rowid;
  const PairCountsCompanion({
    this.classId = const Value.absent(),
    this.studentA = const Value.absent(),
    this.studentB = const Value.absent(),
    this.count = const Value.absent(),
    this.lastAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PairCountsCompanion.insert({
    required int classId,
    required int studentA,
    required int studentB,
    this.count = const Value.absent(),
    this.lastAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : classId = Value(classId),
       studentA = Value(studentA),
       studentB = Value(studentB);
  static Insertable<PairCount> custom({
    Expression<int>? classId,
    Expression<int>? studentA,
    Expression<int>? studentB,
    Expression<int>? count,
    Expression<DateTime>? lastAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (classId != null) 'class_id': classId,
      if (studentA != null) 'student_a': studentA,
      if (studentB != null) 'student_b': studentB,
      if (count != null) 'count': count,
      if (lastAt != null) 'last_at': lastAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PairCountsCompanion copyWith({
    Value<int>? classId,
    Value<int>? studentA,
    Value<int>? studentB,
    Value<int>? count,
    Value<DateTime?>? lastAt,
    Value<int>? rowid,
  }) {
    return PairCountsCompanion(
      classId: classId ?? this.classId,
      studentA: studentA ?? this.studentA,
      studentB: studentB ?? this.studentB,
      count: count ?? this.count,
      lastAt: lastAt ?? this.lastAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (studentA.present) {
      map['student_a'] = Variable<int>(studentA.value);
    }
    if (studentB.present) {
      map['student_b'] = Variable<int>(studentB.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (lastAt.present) {
      map['last_at'] = Variable<DateTime>(lastAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PairCountsCompanion(')
          ..write('classId: $classId, ')
          ..write('studentA: $studentA, ')
          ..write('studentB: $studentB, ')
          ..write('count: $count, ')
          ..write('lastAt: $lastAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupConstraintsTable extends GroupConstraints
    with TableInfo<$GroupConstraintsTable, GroupConstraint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupConstraintsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES classes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _studentAMeta = const VerificationMeta(
    'studentA',
  );
  @override
  late final GeneratedColumn<int> studentA = GeneratedColumn<int>(
    'student_a',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _studentBMeta = const VerificationMeta(
    'studentB',
  );
  @override
  late final GeneratedColumn<int> studentB = GeneratedColumn<int>(
    'student_b',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ConstraintKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ConstraintKind>($GroupConstraintsTable.$converterkind);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    classId,
    studentA,
    studentB,
    kind,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_constraints';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupConstraint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('student_a')) {
      context.handle(
        _studentAMeta,
        studentA.isAcceptableOrUnknown(data['student_a']!, _studentAMeta),
      );
    } else if (isInserting) {
      context.missing(_studentAMeta);
    }
    if (data.containsKey('student_b')) {
      context.handle(
        _studentBMeta,
        studentB.isAcceptableOrUnknown(data['student_b']!, _studentBMeta),
      );
    } else if (isInserting) {
      context.missing(_studentBMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupConstraint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupConstraint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_id'],
      )!,
      studentA: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_a'],
      )!,
      studentB: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_b'],
      )!,
      kind: $GroupConstraintsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $GroupConstraintsTable createAlias(String alias) {
    return $GroupConstraintsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ConstraintKind, String, String> $converterkind =
      const EnumNameConverter<ConstraintKind>(ConstraintKind.values);
}

class GroupConstraint extends DataClass implements Insertable<GroupConstraint> {
  final int id;
  final int classId;
  final int studentA;
  final int studentB;
  final ConstraintKind kind;
  final String? note;
  const GroupConstraint({
    required this.id,
    required this.classId,
    required this.studentA,
    required this.studentB,
    required this.kind,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_id'] = Variable<int>(classId);
    map['student_a'] = Variable<int>(studentA);
    map['student_b'] = Variable<int>(studentB);
    {
      map['kind'] = Variable<String>(
        $GroupConstraintsTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  GroupConstraintsCompanion toCompanion(bool nullToAbsent) {
    return GroupConstraintsCompanion(
      id: Value(id),
      classId: Value(classId),
      studentA: Value(studentA),
      studentB: Value(studentB),
      kind: Value(kind),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory GroupConstraint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupConstraint(
      id: serializer.fromJson<int>(json['id']),
      classId: serializer.fromJson<int>(json['classId']),
      studentA: serializer.fromJson<int>(json['studentA']),
      studentB: serializer.fromJson<int>(json['studentB']),
      kind: $GroupConstraintsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'classId': serializer.toJson<int>(classId),
      'studentA': serializer.toJson<int>(studentA),
      'studentB': serializer.toJson<int>(studentB),
      'kind': serializer.toJson<String>(
        $GroupConstraintsTable.$converterkind.toJson(kind),
      ),
      'note': serializer.toJson<String?>(note),
    };
  }

  GroupConstraint copyWith({
    int? id,
    int? classId,
    int? studentA,
    int? studentB,
    ConstraintKind? kind,
    Value<String?> note = const Value.absent(),
  }) => GroupConstraint(
    id: id ?? this.id,
    classId: classId ?? this.classId,
    studentA: studentA ?? this.studentA,
    studentB: studentB ?? this.studentB,
    kind: kind ?? this.kind,
    note: note.present ? note.value : this.note,
  );
  GroupConstraint copyWithCompanion(GroupConstraintsCompanion data) {
    return GroupConstraint(
      id: data.id.present ? data.id.value : this.id,
      classId: data.classId.present ? data.classId.value : this.classId,
      studentA: data.studentA.present ? data.studentA.value : this.studentA,
      studentB: data.studentB.present ? data.studentB.value : this.studentB,
      kind: data.kind.present ? data.kind.value : this.kind,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupConstraint(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('studentA: $studentA, ')
          ..write('studentB: $studentB, ')
          ..write('kind: $kind, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, classId, studentA, studentB, kind, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupConstraint &&
          other.id == this.id &&
          other.classId == this.classId &&
          other.studentA == this.studentA &&
          other.studentB == this.studentB &&
          other.kind == this.kind &&
          other.note == this.note);
}

class GroupConstraintsCompanion extends UpdateCompanion<GroupConstraint> {
  final Value<int> id;
  final Value<int> classId;
  final Value<int> studentA;
  final Value<int> studentB;
  final Value<ConstraintKind> kind;
  final Value<String?> note;
  const GroupConstraintsCompanion({
    this.id = const Value.absent(),
    this.classId = const Value.absent(),
    this.studentA = const Value.absent(),
    this.studentB = const Value.absent(),
    this.kind = const Value.absent(),
    this.note = const Value.absent(),
  });
  GroupConstraintsCompanion.insert({
    this.id = const Value.absent(),
    required int classId,
    required int studentA,
    required int studentB,
    required ConstraintKind kind,
    this.note = const Value.absent(),
  }) : classId = Value(classId),
       studentA = Value(studentA),
       studentB = Value(studentB),
       kind = Value(kind);
  static Insertable<GroupConstraint> custom({
    Expression<int>? id,
    Expression<int>? classId,
    Expression<int>? studentA,
    Expression<int>? studentB,
    Expression<String>? kind,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classId != null) 'class_id': classId,
      if (studentA != null) 'student_a': studentA,
      if (studentB != null) 'student_b': studentB,
      if (kind != null) 'kind': kind,
      if (note != null) 'note': note,
    });
  }

  GroupConstraintsCompanion copyWith({
    Value<int>? id,
    Value<int>? classId,
    Value<int>? studentA,
    Value<int>? studentB,
    Value<ConstraintKind>? kind,
    Value<String?>? note,
  }) {
    return GroupConstraintsCompanion(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      studentA: studentA ?? this.studentA,
      studentB: studentB ?? this.studentB,
      kind: kind ?? this.kind,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (studentA.present) {
      map['student_a'] = Variable<int>(studentA.value);
    }
    if (studentB.present) {
      map['student_b'] = Variable<int>(studentB.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $GroupConstraintsTable.$converterkind.toSql(kind.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupConstraintsCompanion(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('studentA: $studentA, ')
          ..write('studentB: $studentB, ')
          ..write('kind: $kind, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
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
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
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
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
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

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
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
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
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

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
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
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClassesTable classes = $ClassesTable(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $ProgressTable progress = $ProgressTable(this);
  late final $ConfusionsTable confusions = $ConfusionsTable(this);
  late final $DrawEventsTable drawEvents = $DrawEventsTable(this);
  late final $PoolResetsTable poolResets = $PoolResetsTable(this);
  late final $AbsencesTable absences = $AbsencesTable(this);
  late final $GroupSetsTable groupSets = $GroupSetsTable(this);
  late final $GroupMembersTable groupMembers = $GroupMembersTable(this);
  late final $PairCountsTable pairCounts = $PairCountsTable(this);
  late final $GroupConstraintsTable groupConstraints = $GroupConstraintsTable(
    this,
  );
  late final $SettingsTable settings = $SettingsTable(this);
  late final Index idxDrawClassPoolTime = Index(
    'idx_draw_class_pool_time',
    'CREATE INDEX IF NOT EXISTS idx_draw_class_pool_time ON draw_events (class_id, pool_key, drawn_at DESC)',
  );
  late final Index idxDrawStudent = Index(
    'idx_draw_student',
    'CREATE INDEX IF NOT EXISTS idx_draw_student ON draw_events (class_id, student_id)',
  );
  late final Index idxAbsenceDay = Index(
    'idx_absence_day',
    'CREATE INDEX IF NOT EXISTS idx_absence_day ON absences (class_id, day)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    classes,
    students,
    progress,
    confusions,
    drawEvents,
    poolResets,
    absences,
    groupSets,
    groupMembers,
    pairCounts,
    groupConstraints,
    settings,
    idxDrawClassPoolTime,
    idxDrawStudent,
    idxAbsenceDay,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'classes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('students', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('confusions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('confusions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'classes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('draw_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('draw_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'classes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pool_resets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'classes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('absences', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('absences', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'classes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'group_sets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_members', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_members', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'classes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pair_counts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pair_counts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pair_counts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'classes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_constraints', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_constraints', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_constraints', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ClassesTableCreateCompanionBuilder =
    ClassesCompanion Function({
      Value<int> id,
      required String label,
      required String sourceFile,
      required DateTime importedAt,
    });
typedef $$ClassesTableUpdateCompanionBuilder =
    ClassesCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<String> sourceFile,
      Value<DateTime> importedAt,
    });

final class $$ClassesTableReferences
    extends BaseReferences<_$AppDatabase, $ClassesTable, SchoolClass> {
  $$ClassesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StudentsTable, List<Student>> _studentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.students,
    aliasName: 'classes__id__students__class_id',
  );

  $$StudentsTableProcessedTableManager get studentsRefs {
    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_studentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DrawEventsTable, List<DrawEvent>>
  _drawEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.drawEvents,
    aliasName: 'classes__id__draw_events__class_id',
  );

  $$DrawEventsTableProcessedTableManager get drawEventsRefs {
    final manager = $$DrawEventsTableTableManager(
      $_db,
      $_db.drawEvents,
    ).filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_drawEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PoolResetsTable, List<PoolReset>>
  _poolResetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.poolResets,
    aliasName: 'classes__id__pool_resets__class_id',
  );

  $$PoolResetsTableProcessedTableManager get poolResetsRefs {
    final manager = $$PoolResetsTableTableManager(
      $_db,
      $_db.poolResets,
    ).filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_poolResetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AbsencesTable, List<Absence>> _absencesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.absences,
    aliasName: 'classes__id__absences__class_id',
  );

  $$AbsencesTableProcessedTableManager get absencesRefs {
    final manager = $$AbsencesTableTableManager(
      $_db,
      $_db.absences,
    ).filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_absencesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroupSetsTable, List<GroupSet>>
  _groupSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupSets,
    aliasName: 'classes__id__group_sets__class_id',
  );

  $$GroupSetsTableProcessedTableManager get groupSetsRefs {
    final manager = $$GroupSetsTableTableManager(
      $_db,
      $_db.groupSets,
    ).filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PairCountsTable, List<PairCount>>
  _pairCountsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pairCounts,
    aliasName: 'classes__id__pair_counts__class_id',
  );

  $$PairCountsTableProcessedTableManager get pairCountsRefs {
    final manager = $$PairCountsTableTableManager(
      $_db,
      $_db.pairCounts,
    ).filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pairCountsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroupConstraintsTable, List<GroupConstraint>>
  _groupConstraintsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupConstraints,
    aliasName: 'classes__id__group_constraints__class_id',
  );

  $$GroupConstraintsTableProcessedTableManager get groupConstraintsRefs {
    final manager = $$GroupConstraintsTableTableManager(
      $_db,
      $_db.groupConstraints,
    ).filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupConstraintsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClassesTableFilterComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFile => $composableBuilder(
    column: $table.sourceFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> studentsRefs(
    Expression<bool> Function($$StudentsTableFilterComposer f) f,
  ) {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> drawEventsRefs(
    Expression<bool> Function($$DrawEventsTableFilterComposer f) f,
  ) {
    final $$DrawEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.drawEvents,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawEventsTableFilterComposer(
            $db: $db,
            $table: $db.drawEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> poolResetsRefs(
    Expression<bool> Function($$PoolResetsTableFilterComposer f) f,
  ) {
    final $$PoolResetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.poolResets,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoolResetsTableFilterComposer(
            $db: $db,
            $table: $db.poolResets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> absencesRefs(
    Expression<bool> Function($$AbsencesTableFilterComposer f) f,
  ) {
    final $$AbsencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.absences,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AbsencesTableFilterComposer(
            $db: $db,
            $table: $db.absences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> groupSetsRefs(
    Expression<bool> Function($$GroupSetsTableFilterComposer f) f,
  ) {
    final $$GroupSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupSets,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupSetsTableFilterComposer(
            $db: $db,
            $table: $db.groupSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pairCountsRefs(
    Expression<bool> Function($$PairCountsTableFilterComposer f) f,
  ) {
    final $$PairCountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pairCounts,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairCountsTableFilterComposer(
            $db: $db,
            $table: $db.pairCounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> groupConstraintsRefs(
    Expression<bool> Function($$GroupConstraintsTableFilterComposer f) f,
  ) {
    final $$GroupConstraintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupConstraints,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupConstraintsTableFilterComposer(
            $db: $db,
            $table: $db.groupConstraints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClassesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFile => $composableBuilder(
    column: $table.sourceFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClassesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get sourceFile => $composableBuilder(
    column: $table.sourceFile,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  Expression<T> studentsRefs<T extends Object>(
    Expression<T> Function($$StudentsTableAnnotationComposer a) f,
  ) {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> drawEventsRefs<T extends Object>(
    Expression<T> Function($$DrawEventsTableAnnotationComposer a) f,
  ) {
    final $$DrawEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.drawEvents,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.drawEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> poolResetsRefs<T extends Object>(
    Expression<T> Function($$PoolResetsTableAnnotationComposer a) f,
  ) {
    final $$PoolResetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.poolResets,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PoolResetsTableAnnotationComposer(
            $db: $db,
            $table: $db.poolResets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> absencesRefs<T extends Object>(
    Expression<T> Function($$AbsencesTableAnnotationComposer a) f,
  ) {
    final $$AbsencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.absences,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AbsencesTableAnnotationComposer(
            $db: $db,
            $table: $db.absences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> groupSetsRefs<T extends Object>(
    Expression<T> Function($$GroupSetsTableAnnotationComposer a) f,
  ) {
    final $$GroupSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupSets,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.groupSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pairCountsRefs<T extends Object>(
    Expression<T> Function($$PairCountsTableAnnotationComposer a) f,
  ) {
    final $$PairCountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pairCounts,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairCountsTableAnnotationComposer(
            $db: $db,
            $table: $db.pairCounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> groupConstraintsRefs<T extends Object>(
    Expression<T> Function($$GroupConstraintsTableAnnotationComposer a) f,
  ) {
    final $$GroupConstraintsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupConstraints,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupConstraintsTableAnnotationComposer(
            $db: $db,
            $table: $db.groupConstraints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClassesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClassesTable,
          SchoolClass,
          $$ClassesTableFilterComposer,
          $$ClassesTableOrderingComposer,
          $$ClassesTableAnnotationComposer,
          $$ClassesTableCreateCompanionBuilder,
          $$ClassesTableUpdateCompanionBuilder,
          (SchoolClass, $$ClassesTableReferences),
          SchoolClass,
          PrefetchHooks Function({
            bool studentsRefs,
            bool drawEventsRefs,
            bool poolResetsRefs,
            bool absencesRefs,
            bool groupSetsRefs,
            bool pairCountsRefs,
            bool groupConstraintsRefs,
          })
        > {
  $$ClassesTableTableManager(_$AppDatabase db, $ClassesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> sourceFile = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
              }) => ClassesCompanion(
                id: id,
                label: label,
                sourceFile: sourceFile,
                importedAt: importedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required String sourceFile,
                required DateTime importedAt,
              }) => ClassesCompanion.insert(
                id: id,
                label: label,
                sourceFile: sourceFile,
                importedAt: importedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClassesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                studentsRefs = false,
                drawEventsRefs = false,
                poolResetsRefs = false,
                absencesRefs = false,
                groupSetsRefs = false,
                pairCountsRefs = false,
                groupConstraintsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (studentsRefs) db.students,
                    if (drawEventsRefs) db.drawEvents,
                    if (poolResetsRefs) db.poolResets,
                    if (absencesRefs) db.absences,
                    if (groupSetsRefs) db.groupSets,
                    if (pairCountsRefs) db.pairCounts,
                    if (groupConstraintsRefs) db.groupConstraints,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (studentsRefs)
                        await $_getPrefetchedData<
                          SchoolClass,
                          $ClassesTable,
                          Student
                        >(
                          currentTable: table,
                          referencedTable: $$ClassesTableReferences
                              ._studentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).studentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.classId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (drawEventsRefs)
                        await $_getPrefetchedData<
                          SchoolClass,
                          $ClassesTable,
                          DrawEvent
                        >(
                          currentTable: table,
                          referencedTable: $$ClassesTableReferences
                              ._drawEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).drawEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.classId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (poolResetsRefs)
                        await $_getPrefetchedData<
                          SchoolClass,
                          $ClassesTable,
                          PoolReset
                        >(
                          currentTable: table,
                          referencedTable: $$ClassesTableReferences
                              ._poolResetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).poolResetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.classId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (absencesRefs)
                        await $_getPrefetchedData<
                          SchoolClass,
                          $ClassesTable,
                          Absence
                        >(
                          currentTable: table,
                          referencedTable: $$ClassesTableReferences
                              ._absencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).absencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.classId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (groupSetsRefs)
                        await $_getPrefetchedData<
                          SchoolClass,
                          $ClassesTable,
                          GroupSet
                        >(
                          currentTable: table,
                          referencedTable: $$ClassesTableReferences
                              ._groupSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).groupSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.classId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pairCountsRefs)
                        await $_getPrefetchedData<
                          SchoolClass,
                          $ClassesTable,
                          PairCount
                        >(
                          currentTable: table,
                          referencedTable: $$ClassesTableReferences
                              ._pairCountsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).pairCountsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.classId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (groupConstraintsRefs)
                        await $_getPrefetchedData<
                          SchoolClass,
                          $ClassesTable,
                          GroupConstraint
                        >(
                          currentTable: table,
                          referencedTable: $$ClassesTableReferences
                              ._groupConstraintsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).groupConstraintsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.classId == item.id,
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

typedef $$ClassesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClassesTable,
      SchoolClass,
      $$ClassesTableFilterComposer,
      $$ClassesTableOrderingComposer,
      $$ClassesTableAnnotationComposer,
      $$ClassesTableCreateCompanionBuilder,
      $$ClassesTableUpdateCompanionBuilder,
      (SchoolClass, $$ClassesTableReferences),
      SchoolClass,
      PrefetchHooks Function({
        bool studentsRefs,
        bool drawEventsRefs,
        bool poolResetsRefs,
        bool absencesRefs,
        bool groupSetsRefs,
        bool pairCountsRefs,
        bool groupConstraintsRefs,
      })
    >;
typedef $$StudentsTableCreateCompanionBuilder =
    StudentsCompanion Function({
      Value<int> id,
      required int classId,
      required String displayName,
      required String firstName,
      required String lastName,
      required Uint8List jpegBytes,
      required int orderIndex,
      Value<bool> active,
    });
typedef $$StudentsTableUpdateCompanionBuilder =
    StudentsCompanion Function({
      Value<int> id,
      Value<int> classId,
      Value<String> displayName,
      Value<String> firstName,
      Value<String> lastName,
      Value<Uint8List> jpegBytes,
      Value<int> orderIndex,
      Value<bool> active,
    });

final class $$StudentsTableReferences
    extends BaseReferences<_$AppDatabase, $StudentsTable, Student> {
  $$StudentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClassesTable _classIdTable(_$AppDatabase db) =>
      db.classes.createAlias('students__class_id__classes__id');

  $$ClassesTableProcessedTableManager get classId {
    final $_column = $_itemColumn<int>('class_id')!;

    final manager = $$ClassesTableTableManager(
      $_db,
      $_db.classes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ProgressTable, List<ProgressData>>
  _progressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.progress,
    aliasName: 'students__id__progress__student_id',
  );

  $$ProgressTableProcessedTableManager get progressRefs {
    final manager = $$ProgressTableTableManager(
      $_db,
      $_db.progress,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_progressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConfusionsTable, List<Confusion>>
  _confusionsShownTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.confusions,
    aliasName: 'students__id__confusions__student_id',
  );

  $$ConfusionsTableProcessedTableManager get confusionsShown {
    final manager = $$ConfusionsTableTableManager(
      $_db,
      $_db.confusions,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_confusionsShownTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConfusionsTable, List<Confusion>>
  _confusionsPickedTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.confusions,
    aliasName: 'students__id__confusions__confused_with_id',
  );

  $$ConfusionsTableProcessedTableManager get confusionsPicked {
    final manager = $$ConfusionsTableTableManager(
      $_db,
      $_db.confusions,
    ).filter((f) => f.confusedWithId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_confusionsPickedTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DrawEventsTable, List<DrawEvent>>
  _drawEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.drawEvents,
    aliasName: 'students__id__draw_events__student_id',
  );

  $$DrawEventsTableProcessedTableManager get drawEventsRefs {
    final manager = $$DrawEventsTableTableManager(
      $_db,
      $_db.drawEvents,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_drawEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AbsencesTable, List<Absence>> _absencesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.absences,
    aliasName: 'students__id__absences__student_id',
  );

  $$AbsencesTableProcessedTableManager get absencesRefs {
    final manager = $$AbsencesTableTableManager(
      $_db,
      $_db.absences,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_absencesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
  _groupMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupMembers,
    aliasName: 'students__id__group_members__student_id',
  );

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager(
      $_db,
      $_db.groupMembers,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PairCountsTable, List<PairCount>>
  _pairCountsAsATable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pairCounts,
    aliasName: 'students__id__pair_counts__student_a',
  );

  $$PairCountsTableProcessedTableManager get pairCountsAsA {
    final manager = $$PairCountsTableTableManager(
      $_db,
      $_db.pairCounts,
    ).filter((f) => f.studentA.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pairCountsAsATable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PairCountsTable, List<PairCount>>
  _pairCountsAsBTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pairCounts,
    aliasName: 'students__id__pair_counts__student_b',
  );

  $$PairCountsTableProcessedTableManager get pairCountsAsB {
    final manager = $$PairCountsTableTableManager(
      $_db,
      $_db.pairCounts,
    ).filter((f) => f.studentB.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pairCountsAsBTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroupConstraintsTable, List<GroupConstraint>>
  _constraintsAsATable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupConstraints,
    aliasName: 'students__id__group_constraints__student_a',
  );

  $$GroupConstraintsTableProcessedTableManager get constraintsAsA {
    final manager = $$GroupConstraintsTableTableManager(
      $_db,
      $_db.groupConstraints,
    ).filter((f) => f.studentA.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_constraintsAsATable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroupConstraintsTable, List<GroupConstraint>>
  _constraintsAsBTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupConstraints,
    aliasName: 'students__id__group_constraints__student_b',
  );

  $$GroupConstraintsTableProcessedTableManager get constraintsAsB {
    final manager = $$GroupConstraintsTableTableManager(
      $_db,
      $_db.groupConstraints,
    ).filter((f) => f.studentB.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_constraintsAsBTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get jpegBytes => $composableBuilder(
    column: $table.jpegBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  $$ClassesTableFilterComposer get classId {
    final $$ClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableFilterComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> progressRefs(
    Expression<bool> Function($$ProgressTableFilterComposer f) f,
  ) {
    final $$ProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.progress,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgressTableFilterComposer(
            $db: $db,
            $table: $db.progress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> confusionsShown(
    Expression<bool> Function($$ConfusionsTableFilterComposer f) f,
  ) {
    final $$ConfusionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.confusions,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfusionsTableFilterComposer(
            $db: $db,
            $table: $db.confusions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> confusionsPicked(
    Expression<bool> Function($$ConfusionsTableFilterComposer f) f,
  ) {
    final $$ConfusionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.confusions,
      getReferencedColumn: (t) => t.confusedWithId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfusionsTableFilterComposer(
            $db: $db,
            $table: $db.confusions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> drawEventsRefs(
    Expression<bool> Function($$DrawEventsTableFilterComposer f) f,
  ) {
    final $$DrawEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.drawEvents,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawEventsTableFilterComposer(
            $db: $db,
            $table: $db.drawEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> absencesRefs(
    Expression<bool> Function($$AbsencesTableFilterComposer f) f,
  ) {
    final $$AbsencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.absences,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AbsencesTableFilterComposer(
            $db: $db,
            $table: $db.absences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> groupMembersRefs(
    Expression<bool> Function($$GroupMembersTableFilterComposer f) f,
  ) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableFilterComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pairCountsAsA(
    Expression<bool> Function($$PairCountsTableFilterComposer f) f,
  ) {
    final $$PairCountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pairCounts,
      getReferencedColumn: (t) => t.studentA,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairCountsTableFilterComposer(
            $db: $db,
            $table: $db.pairCounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pairCountsAsB(
    Expression<bool> Function($$PairCountsTableFilterComposer f) f,
  ) {
    final $$PairCountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pairCounts,
      getReferencedColumn: (t) => t.studentB,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairCountsTableFilterComposer(
            $db: $db,
            $table: $db.pairCounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> constraintsAsA(
    Expression<bool> Function($$GroupConstraintsTableFilterComposer f) f,
  ) {
    final $$GroupConstraintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupConstraints,
      getReferencedColumn: (t) => t.studentA,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupConstraintsTableFilterComposer(
            $db: $db,
            $table: $db.groupConstraints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> constraintsAsB(
    Expression<bool> Function($$GroupConstraintsTableFilterComposer f) f,
  ) {
    final $$GroupConstraintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupConstraints,
      getReferencedColumn: (t) => t.studentB,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupConstraintsTableFilterComposer(
            $db: $db,
            $table: $db.groupConstraints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get jpegBytes => $composableBuilder(
    column: $table.jpegBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClassesTableOrderingComposer get classId {
    final $$ClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableOrderingComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<Uint8List> get jpegBytes =>
      $composableBuilder(column: $table.jpegBytes, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  $$ClassesTableAnnotationComposer get classId {
    final $$ClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> progressRefs<T extends Object>(
    Expression<T> Function($$ProgressTableAnnotationComposer a) f,
  ) {
    final $$ProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.progress,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.progress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> confusionsShown<T extends Object>(
    Expression<T> Function($$ConfusionsTableAnnotationComposer a) f,
  ) {
    final $$ConfusionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.confusions,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfusionsTableAnnotationComposer(
            $db: $db,
            $table: $db.confusions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> confusionsPicked<T extends Object>(
    Expression<T> Function($$ConfusionsTableAnnotationComposer a) f,
  ) {
    final $$ConfusionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.confusions,
      getReferencedColumn: (t) => t.confusedWithId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfusionsTableAnnotationComposer(
            $db: $db,
            $table: $db.confusions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> drawEventsRefs<T extends Object>(
    Expression<T> Function($$DrawEventsTableAnnotationComposer a) f,
  ) {
    final $$DrawEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.drawEvents,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.drawEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> absencesRefs<T extends Object>(
    Expression<T> Function($$AbsencesTableAnnotationComposer a) f,
  ) {
    final $$AbsencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.absences,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AbsencesTableAnnotationComposer(
            $db: $db,
            $table: $db.absences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> groupMembersRefs<T extends Object>(
    Expression<T> Function($$GroupMembersTableAnnotationComposer a) f,
  ) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pairCountsAsA<T extends Object>(
    Expression<T> Function($$PairCountsTableAnnotationComposer a) f,
  ) {
    final $$PairCountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pairCounts,
      getReferencedColumn: (t) => t.studentA,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairCountsTableAnnotationComposer(
            $db: $db,
            $table: $db.pairCounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pairCountsAsB<T extends Object>(
    Expression<T> Function($$PairCountsTableAnnotationComposer a) f,
  ) {
    final $$PairCountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pairCounts,
      getReferencedColumn: (t) => t.studentB,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairCountsTableAnnotationComposer(
            $db: $db,
            $table: $db.pairCounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> constraintsAsA<T extends Object>(
    Expression<T> Function($$GroupConstraintsTableAnnotationComposer a) f,
  ) {
    final $$GroupConstraintsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupConstraints,
      getReferencedColumn: (t) => t.studentA,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupConstraintsTableAnnotationComposer(
            $db: $db,
            $table: $db.groupConstraints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> constraintsAsB<T extends Object>(
    Expression<T> Function($$GroupConstraintsTableAnnotationComposer a) f,
  ) {
    final $$GroupConstraintsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupConstraints,
      getReferencedColumn: (t) => t.studentB,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupConstraintsTableAnnotationComposer(
            $db: $db,
            $table: $db.groupConstraints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentsTable,
          Student,
          $$StudentsTableFilterComposer,
          $$StudentsTableOrderingComposer,
          $$StudentsTableAnnotationComposer,
          $$StudentsTableCreateCompanionBuilder,
          $$StudentsTableUpdateCompanionBuilder,
          (Student, $$StudentsTableReferences),
          Student,
          PrefetchHooks Function({
            bool classId,
            bool progressRefs,
            bool confusionsShown,
            bool confusionsPicked,
            bool drawEventsRefs,
            bool absencesRefs,
            bool groupMembersRefs,
            bool pairCountsAsA,
            bool pairCountsAsB,
            bool constraintsAsA,
            bool constraintsAsB,
          })
        > {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> classId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<Uint8List> jpegBytes = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => StudentsCompanion(
                id: id,
                classId: classId,
                displayName: displayName,
                firstName: firstName,
                lastName: lastName,
                jpegBytes: jpegBytes,
                orderIndex: orderIndex,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int classId,
                required String displayName,
                required String firstName,
                required String lastName,
                required Uint8List jpegBytes,
                required int orderIndex,
                Value<bool> active = const Value.absent(),
              }) => StudentsCompanion.insert(
                id: id,
                classId: classId,
                displayName: displayName,
                firstName: firstName,
                lastName: lastName,
                jpegBytes: jpegBytes,
                orderIndex: orderIndex,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                classId = false,
                progressRefs = false,
                confusionsShown = false,
                confusionsPicked = false,
                drawEventsRefs = false,
                absencesRefs = false,
                groupMembersRefs = false,
                pairCountsAsA = false,
                pairCountsAsB = false,
                constraintsAsA = false,
                constraintsAsB = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (progressRefs) db.progress,
                    if (confusionsShown) db.confusions,
                    if (confusionsPicked) db.confusions,
                    if (drawEventsRefs) db.drawEvents,
                    if (absencesRefs) db.absences,
                    if (groupMembersRefs) db.groupMembers,
                    if (pairCountsAsA) db.pairCounts,
                    if (pairCountsAsB) db.pairCounts,
                    if (constraintsAsA) db.groupConstraints,
                    if (constraintsAsB) db.groupConstraints,
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
                        if (classId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.classId,
                                    referencedTable: $$StudentsTableReferences
                                        ._classIdTable(db),
                                    referencedColumn: $$StudentsTableReferences
                                        ._classIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (progressRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          ProgressData
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._progressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).progressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (confusionsShown)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          Confusion
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._confusionsShownTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).confusionsShown,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (confusionsPicked)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          Confusion
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._confusionsPickedTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).confusionsPicked,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.confusedWithId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (drawEventsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          DrawEvent
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._drawEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).drawEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (absencesRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          Absence
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._absencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).absencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (groupMembersRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          GroupMember
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._groupMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).groupMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pairCountsAsA)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          PairCount
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._pairCountsAsATable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).pairCountsAsA,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentA == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pairCountsAsB)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          PairCount
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._pairCountsAsBTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).pairCountsAsB,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentB == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (constraintsAsA)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          GroupConstraint
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._constraintsAsATable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).constraintsAsA,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentA == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (constraintsAsB)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          GroupConstraint
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._constraintsAsBTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).constraintsAsB,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentB == item.id,
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

typedef $$StudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentsTable,
      Student,
      $$StudentsTableFilterComposer,
      $$StudentsTableOrderingComposer,
      $$StudentsTableAnnotationComposer,
      $$StudentsTableCreateCompanionBuilder,
      $$StudentsTableUpdateCompanionBuilder,
      (Student, $$StudentsTableReferences),
      Student,
      PrefetchHooks Function({
        bool classId,
        bool progressRefs,
        bool confusionsShown,
        bool confusionsPicked,
        bool drawEventsRefs,
        bool absencesRefs,
        bool groupMembersRefs,
        bool pairCountsAsA,
        bool pairCountsAsB,
        bool constraintsAsA,
        bool constraintsAsB,
      })
    >;
typedef $$ProgressTableCreateCompanionBuilder =
    ProgressCompanion Function({
      Value<int> studentId,
      Value<int> box,
      Value<int> correct,
      Value<int> wrong,
      Value<int> streak,
      Value<DateTime?> lastSeenAt,
      Value<int> avgMs,
    });
typedef $$ProgressTableUpdateCompanionBuilder =
    ProgressCompanion Function({
      Value<int> studentId,
      Value<int> box,
      Value<int> correct,
      Value<int> wrong,
      Value<int> streak,
      Value<DateTime?> lastSeenAt,
      Value<int> avgMs,
    });

final class $$ProgressTableReferences
    extends BaseReferences<_$AppDatabase, $ProgressTable, ProgressData> {
  $$ProgressTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('progress__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ProgressTable> {
  $$ProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrong => $composableBuilder(
    column: $table.wrong,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgMs => $composableBuilder(
    column: $table.avgMs,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgressTable> {
  $$ProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrong => $composableBuilder(
    column: $table.wrong,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgMs => $composableBuilder(
    column: $table.avgMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgressTable> {
  $$ProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get box =>
      $composableBuilder(column: $table.box, builder: (column) => column);

  GeneratedColumn<int> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<int> get wrong =>
      $composableBuilder(column: $table.wrong, builder: (column) => column);

  GeneratedColumn<int> get streak =>
      $composableBuilder(column: $table.streak, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgMs =>
      $composableBuilder(column: $table.avgMs, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgressTable,
          ProgressData,
          $$ProgressTableFilterComposer,
          $$ProgressTableOrderingComposer,
          $$ProgressTableAnnotationComposer,
          $$ProgressTableCreateCompanionBuilder,
          $$ProgressTableUpdateCompanionBuilder,
          (ProgressData, $$ProgressTableReferences),
          ProgressData,
          PrefetchHooks Function({bool studentId})
        > {
  $$ProgressTableTableManager(_$AppDatabase db, $ProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> studentId = const Value.absent(),
                Value<int> box = const Value.absent(),
                Value<int> correct = const Value.absent(),
                Value<int> wrong = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<int> avgMs = const Value.absent(),
              }) => ProgressCompanion(
                studentId: studentId,
                box: box,
                correct: correct,
                wrong: wrong,
                streak: streak,
                lastSeenAt: lastSeenAt,
                avgMs: avgMs,
              ),
          createCompanionCallback:
              ({
                Value<int> studentId = const Value.absent(),
                Value<int> box = const Value.absent(),
                Value<int> correct = const Value.absent(),
                Value<int> wrong = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<int> avgMs = const Value.absent(),
              }) => ProgressCompanion.insert(
                studentId: studentId,
                box: box,
                correct: correct,
                wrong: wrong,
                streak: streak,
                lastSeenAt: lastSeenAt,
                avgMs: avgMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false}) {
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
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable: $$ProgressTableReferences
                                    ._studentIdTable(db),
                                referencedColumn: $$ProgressTableReferences
                                    ._studentIdTable(db)
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

typedef $$ProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgressTable,
      ProgressData,
      $$ProgressTableFilterComposer,
      $$ProgressTableOrderingComposer,
      $$ProgressTableAnnotationComposer,
      $$ProgressTableCreateCompanionBuilder,
      $$ProgressTableUpdateCompanionBuilder,
      (ProgressData, $$ProgressTableReferences),
      ProgressData,
      PrefetchHooks Function({bool studentId})
    >;
typedef $$ConfusionsTableCreateCompanionBuilder =
    ConfusionsCompanion Function({
      required int studentId,
      required int confusedWithId,
      Value<int> count,
      Value<int> rowid,
    });
typedef $$ConfusionsTableUpdateCompanionBuilder =
    ConfusionsCompanion Function({
      Value<int> studentId,
      Value<int> confusedWithId,
      Value<int> count,
      Value<int> rowid,
    });

final class $$ConfusionsTableReferences
    extends BaseReferences<_$AppDatabase, $ConfusionsTable, Confusion> {
  $$ConfusionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('confusions__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _confusedWithIdTable(_$AppDatabase db) =>
      db.students.createAlias('confusions__confused_with_id__students__id');

  $$StudentsTableProcessedTableManager get confusedWithId {
    final $_column = $_itemColumn<int>('confused_with_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_confusedWithIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConfusionsTableFilterComposer
    extends Composer<_$AppDatabase, $ConfusionsTable> {
  $$ConfusionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableFilterComposer get confusedWithId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.confusedWithId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConfusionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfusionsTable> {
  $$ConfusionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableOrderingComposer get confusedWithId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.confusedWithId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConfusionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfusionsTable> {
  $$ConfusionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableAnnotationComposer get confusedWithId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.confusedWithId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConfusionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfusionsTable,
          Confusion,
          $$ConfusionsTableFilterComposer,
          $$ConfusionsTableOrderingComposer,
          $$ConfusionsTableAnnotationComposer,
          $$ConfusionsTableCreateCompanionBuilder,
          $$ConfusionsTableUpdateCompanionBuilder,
          (Confusion, $$ConfusionsTableReferences),
          Confusion,
          PrefetchHooks Function({bool studentId, bool confusedWithId})
        > {
  $$ConfusionsTableTableManager(_$AppDatabase db, $ConfusionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfusionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfusionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfusionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> studentId = const Value.absent(),
                Value<int> confusedWithId = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfusionsCompanion(
                studentId: studentId,
                confusedWithId: confusedWithId,
                count: count,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int studentId,
                required int confusedWithId,
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfusionsCompanion.insert(
                studentId: studentId,
                confusedWithId: confusedWithId,
                count: count,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConfusionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false, confusedWithId = false}) {
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
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable: $$ConfusionsTableReferences
                                    ._studentIdTable(db),
                                referencedColumn: $$ConfusionsTableReferences
                                    ._studentIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (confusedWithId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.confusedWithId,
                                referencedTable: $$ConfusionsTableReferences
                                    ._confusedWithIdTable(db),
                                referencedColumn: $$ConfusionsTableReferences
                                    ._confusedWithIdTable(db)
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

typedef $$ConfusionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfusionsTable,
      Confusion,
      $$ConfusionsTableFilterComposer,
      $$ConfusionsTableOrderingComposer,
      $$ConfusionsTableAnnotationComposer,
      $$ConfusionsTableCreateCompanionBuilder,
      $$ConfusionsTableUpdateCompanionBuilder,
      (Confusion, $$ConfusionsTableReferences),
      Confusion,
      PrefetchHooks Function({bool studentId, bool confusedWithId})
    >;
typedef $$DrawEventsTableCreateCompanionBuilder =
    DrawEventsCompanion Function({
      Value<int> id,
      required int classId,
      required int studentId,
      Value<String> poolKey,
      required DateTime drawnAt,
    });
typedef $$DrawEventsTableUpdateCompanionBuilder =
    DrawEventsCompanion Function({
      Value<int> id,
      Value<int> classId,
      Value<int> studentId,
      Value<String> poolKey,
      Value<DateTime> drawnAt,
    });

final class $$DrawEventsTableReferences
    extends BaseReferences<_$AppDatabase, $DrawEventsTable, DrawEvent> {
  $$DrawEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClassesTable _classIdTable(_$AppDatabase db) =>
      db.classes.createAlias('draw_events__class_id__classes__id');

  $$ClassesTableProcessedTableManager get classId {
    final $_column = $_itemColumn<int>('class_id')!;

    final manager = $$ClassesTableTableManager(
      $_db,
      $_db.classes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('draw_events__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DrawEventsTableFilterComposer
    extends Composer<_$AppDatabase, $DrawEventsTable> {
  $$DrawEventsTableFilterComposer({
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

  ColumnFilters<String> get poolKey => $composableBuilder(
    column: $table.poolKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get drawnAt => $composableBuilder(
    column: $table.drawnAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClassesTableFilterComposer get classId {
    final $$ClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableFilterComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DrawEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $DrawEventsTable> {
  $$DrawEventsTableOrderingComposer({
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

  ColumnOrderings<String> get poolKey => $composableBuilder(
    column: $table.poolKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get drawnAt => $composableBuilder(
    column: $table.drawnAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClassesTableOrderingComposer get classId {
    final $$ClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableOrderingComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DrawEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DrawEventsTable> {
  $$DrawEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get poolKey =>
      $composableBuilder(column: $table.poolKey, builder: (column) => column);

  GeneratedColumn<DateTime> get drawnAt =>
      $composableBuilder(column: $table.drawnAt, builder: (column) => column);

  $$ClassesTableAnnotationComposer get classId {
    final $$ClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DrawEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DrawEventsTable,
          DrawEvent,
          $$DrawEventsTableFilterComposer,
          $$DrawEventsTableOrderingComposer,
          $$DrawEventsTableAnnotationComposer,
          $$DrawEventsTableCreateCompanionBuilder,
          $$DrawEventsTableUpdateCompanionBuilder,
          (DrawEvent, $$DrawEventsTableReferences),
          DrawEvent,
          PrefetchHooks Function({bool classId, bool studentId})
        > {
  $$DrawEventsTableTableManager(_$AppDatabase db, $DrawEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DrawEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DrawEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DrawEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> classId = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<String> poolKey = const Value.absent(),
                Value<DateTime> drawnAt = const Value.absent(),
              }) => DrawEventsCompanion(
                id: id,
                classId: classId,
                studentId: studentId,
                poolKey: poolKey,
                drawnAt: drawnAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int classId,
                required int studentId,
                Value<String> poolKey = const Value.absent(),
                required DateTime drawnAt,
              }) => DrawEventsCompanion.insert(
                id: id,
                classId: classId,
                studentId: studentId,
                poolKey: poolKey,
                drawnAt: drawnAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DrawEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({classId = false, studentId = false}) {
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
                    if (classId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.classId,
                                referencedTable: $$DrawEventsTableReferences
                                    ._classIdTable(db),
                                referencedColumn: $$DrawEventsTableReferences
                                    ._classIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable: $$DrawEventsTableReferences
                                    ._studentIdTable(db),
                                referencedColumn: $$DrawEventsTableReferences
                                    ._studentIdTable(db)
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

typedef $$DrawEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DrawEventsTable,
      DrawEvent,
      $$DrawEventsTableFilterComposer,
      $$DrawEventsTableOrderingComposer,
      $$DrawEventsTableAnnotationComposer,
      $$DrawEventsTableCreateCompanionBuilder,
      $$DrawEventsTableUpdateCompanionBuilder,
      (DrawEvent, $$DrawEventsTableReferences),
      DrawEvent,
      PrefetchHooks Function({bool classId, bool studentId})
    >;
typedef $$PoolResetsTableCreateCompanionBuilder =
    PoolResetsCompanion Function({
      Value<int> id,
      required int classId,
      Value<String> poolKey,
      required DateTime resetAt,
      Value<bool> auto,
    });
typedef $$PoolResetsTableUpdateCompanionBuilder =
    PoolResetsCompanion Function({
      Value<int> id,
      Value<int> classId,
      Value<String> poolKey,
      Value<DateTime> resetAt,
      Value<bool> auto,
    });

final class $$PoolResetsTableReferences
    extends BaseReferences<_$AppDatabase, $PoolResetsTable, PoolReset> {
  $$PoolResetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClassesTable _classIdTable(_$AppDatabase db) =>
      db.classes.createAlias('pool_resets__class_id__classes__id');

  $$ClassesTableProcessedTableManager get classId {
    final $_column = $_itemColumn<int>('class_id')!;

    final manager = $$ClassesTableTableManager(
      $_db,
      $_db.classes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PoolResetsTableFilterComposer
    extends Composer<_$AppDatabase, $PoolResetsTable> {
  $$PoolResetsTableFilterComposer({
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

  ColumnFilters<String> get poolKey => $composableBuilder(
    column: $table.poolKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resetAt => $composableBuilder(
    column: $table.resetAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get auto => $composableBuilder(
    column: $table.auto,
    builder: (column) => ColumnFilters(column),
  );

  $$ClassesTableFilterComposer get classId {
    final $$ClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableFilterComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PoolResetsTableOrderingComposer
    extends Composer<_$AppDatabase, $PoolResetsTable> {
  $$PoolResetsTableOrderingComposer({
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

  ColumnOrderings<String> get poolKey => $composableBuilder(
    column: $table.poolKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resetAt => $composableBuilder(
    column: $table.resetAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get auto => $composableBuilder(
    column: $table.auto,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClassesTableOrderingComposer get classId {
    final $$ClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableOrderingComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PoolResetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PoolResetsTable> {
  $$PoolResetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get poolKey =>
      $composableBuilder(column: $table.poolKey, builder: (column) => column);

  GeneratedColumn<DateTime> get resetAt =>
      $composableBuilder(column: $table.resetAt, builder: (column) => column);

  GeneratedColumn<bool> get auto =>
      $composableBuilder(column: $table.auto, builder: (column) => column);

  $$ClassesTableAnnotationComposer get classId {
    final $$ClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PoolResetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PoolResetsTable,
          PoolReset,
          $$PoolResetsTableFilterComposer,
          $$PoolResetsTableOrderingComposer,
          $$PoolResetsTableAnnotationComposer,
          $$PoolResetsTableCreateCompanionBuilder,
          $$PoolResetsTableUpdateCompanionBuilder,
          (PoolReset, $$PoolResetsTableReferences),
          PoolReset,
          PrefetchHooks Function({bool classId})
        > {
  $$PoolResetsTableTableManager(_$AppDatabase db, $PoolResetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PoolResetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PoolResetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PoolResetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> classId = const Value.absent(),
                Value<String> poolKey = const Value.absent(),
                Value<DateTime> resetAt = const Value.absent(),
                Value<bool> auto = const Value.absent(),
              }) => PoolResetsCompanion(
                id: id,
                classId: classId,
                poolKey: poolKey,
                resetAt: resetAt,
                auto: auto,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int classId,
                Value<String> poolKey = const Value.absent(),
                required DateTime resetAt,
                Value<bool> auto = const Value.absent(),
              }) => PoolResetsCompanion.insert(
                id: id,
                classId: classId,
                poolKey: poolKey,
                resetAt: resetAt,
                auto: auto,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PoolResetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({classId = false}) {
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
                    if (classId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.classId,
                                referencedTable: $$PoolResetsTableReferences
                                    ._classIdTable(db),
                                referencedColumn: $$PoolResetsTableReferences
                                    ._classIdTable(db)
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

typedef $$PoolResetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PoolResetsTable,
      PoolReset,
      $$PoolResetsTableFilterComposer,
      $$PoolResetsTableOrderingComposer,
      $$PoolResetsTableAnnotationComposer,
      $$PoolResetsTableCreateCompanionBuilder,
      $$PoolResetsTableUpdateCompanionBuilder,
      (PoolReset, $$PoolResetsTableReferences),
      PoolReset,
      PrefetchHooks Function({bool classId})
    >;
typedef $$AbsencesTableCreateCompanionBuilder =
    AbsencesCompanion Function({
      required int classId,
      required int studentId,
      required int day,
      Value<int> rowid,
    });
typedef $$AbsencesTableUpdateCompanionBuilder =
    AbsencesCompanion Function({
      Value<int> classId,
      Value<int> studentId,
      Value<int> day,
      Value<int> rowid,
    });

final class $$AbsencesTableReferences
    extends BaseReferences<_$AppDatabase, $AbsencesTable, Absence> {
  $$AbsencesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClassesTable _classIdTable(_$AppDatabase db) =>
      db.classes.createAlias('absences__class_id__classes__id');

  $$ClassesTableProcessedTableManager get classId {
    final $_column = $_itemColumn<int>('class_id')!;

    final manager = $$ClassesTableTableManager(
      $_db,
      $_db.classes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('absences__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AbsencesTableFilterComposer
    extends Composer<_$AppDatabase, $AbsencesTable> {
  $$AbsencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  $$ClassesTableFilterComposer get classId {
    final $$ClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableFilterComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AbsencesTableOrderingComposer
    extends Composer<_$AppDatabase, $AbsencesTable> {
  $$AbsencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClassesTableOrderingComposer get classId {
    final $$ClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableOrderingComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AbsencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AbsencesTable> {
  $$AbsencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  $$ClassesTableAnnotationComposer get classId {
    final $$ClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AbsencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AbsencesTable,
          Absence,
          $$AbsencesTableFilterComposer,
          $$AbsencesTableOrderingComposer,
          $$AbsencesTableAnnotationComposer,
          $$AbsencesTableCreateCompanionBuilder,
          $$AbsencesTableUpdateCompanionBuilder,
          (Absence, $$AbsencesTableReferences),
          Absence,
          PrefetchHooks Function({bool classId, bool studentId})
        > {
  $$AbsencesTableTableManager(_$AppDatabase db, $AbsencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AbsencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AbsencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AbsencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> classId = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<int> day = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AbsencesCompanion(
                classId: classId,
                studentId: studentId,
                day: day,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int classId,
                required int studentId,
                required int day,
                Value<int> rowid = const Value.absent(),
              }) => AbsencesCompanion.insert(
                classId: classId,
                studentId: studentId,
                day: day,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AbsencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({classId = false, studentId = false}) {
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
                    if (classId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.classId,
                                referencedTable: $$AbsencesTableReferences
                                    ._classIdTable(db),
                                referencedColumn: $$AbsencesTableReferences
                                    ._classIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable: $$AbsencesTableReferences
                                    ._studentIdTable(db),
                                referencedColumn: $$AbsencesTableReferences
                                    ._studentIdTable(db)
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

typedef $$AbsencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AbsencesTable,
      Absence,
      $$AbsencesTableFilterComposer,
      $$AbsencesTableOrderingComposer,
      $$AbsencesTableAnnotationComposer,
      $$AbsencesTableCreateCompanionBuilder,
      $$AbsencesTableUpdateCompanionBuilder,
      (Absence, $$AbsencesTableReferences),
      Absence,
      PrefetchHooks Function({bool classId, bool studentId})
    >;
typedef $$GroupSetsTableCreateCompanionBuilder =
    GroupSetsCompanion Function({
      Value<int> id,
      required int classId,
      required String label,
      required DateTime createdAt,
    });
typedef $$GroupSetsTableUpdateCompanionBuilder =
    GroupSetsCompanion Function({
      Value<int> id,
      Value<int> classId,
      Value<String> label,
      Value<DateTime> createdAt,
    });

final class $$GroupSetsTableReferences
    extends BaseReferences<_$AppDatabase, $GroupSetsTable, GroupSet> {
  $$GroupSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClassesTable _classIdTable(_$AppDatabase db) =>
      db.classes.createAlias('group_sets__class_id__classes__id');

  $$ClassesTableProcessedTableManager get classId {
    final $_column = $_itemColumn<int>('class_id')!;

    final manager = $$ClassesTableTableManager(
      $_db,
      $_db.classes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
  _groupMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupMembers,
    aliasName: 'group_sets__id__group_members__group_set_id',
  );

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager(
      $_db,
      $_db.groupMembers,
    ).filter((f) => f.groupSetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupSetsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupSetsTable> {
  $$GroupSetsTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClassesTableFilterComposer get classId {
    final $$ClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableFilterComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> groupMembersRefs(
    Expression<bool> Function($$GroupMembersTableFilterComposer f) f,
  ) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.groupSetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableFilterComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupSetsTable> {
  $$GroupSetsTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClassesTableOrderingComposer get classId {
    final $$ClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableOrderingComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupSetsTable> {
  $$GroupSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ClassesTableAnnotationComposer get classId {
    final $$ClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> groupMembersRefs<T extends Object>(
    Expression<T> Function($$GroupMembersTableAnnotationComposer a) f,
  ) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.groupSetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupSetsTable,
          GroupSet,
          $$GroupSetsTableFilterComposer,
          $$GroupSetsTableOrderingComposer,
          $$GroupSetsTableAnnotationComposer,
          $$GroupSetsTableCreateCompanionBuilder,
          $$GroupSetsTableUpdateCompanionBuilder,
          (GroupSet, $$GroupSetsTableReferences),
          GroupSet,
          PrefetchHooks Function({bool classId, bool groupMembersRefs})
        > {
  $$GroupSetsTableTableManager(_$AppDatabase db, $GroupSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> classId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GroupSetsCompanion(
                id: id,
                classId: classId,
                label: label,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int classId,
                required String label,
                required DateTime createdAt,
              }) => GroupSetsCompanion.insert(
                id: id,
                classId: classId,
                label: label,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GroupSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({classId = false, groupMembersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (groupMembersRefs) db.groupMembers],
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
                    if (classId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.classId,
                                referencedTable: $$GroupSetsTableReferences
                                    ._classIdTable(db),
                                referencedColumn: $$GroupSetsTableReferences
                                    ._classIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (groupMembersRefs)
                    await $_getPrefetchedData<
                      GroupSet,
                      $GroupSetsTable,
                      GroupMember
                    >(
                      currentTable: table,
                      referencedTable: $$GroupSetsTableReferences
                          ._groupMembersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GroupSetsTableReferences(
                            db,
                            table,
                            p0,
                          ).groupMembersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.groupSetId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GroupSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupSetsTable,
      GroupSet,
      $$GroupSetsTableFilterComposer,
      $$GroupSetsTableOrderingComposer,
      $$GroupSetsTableAnnotationComposer,
      $$GroupSetsTableCreateCompanionBuilder,
      $$GroupSetsTableUpdateCompanionBuilder,
      (GroupSet, $$GroupSetsTableReferences),
      GroupSet,
      PrefetchHooks Function({bool classId, bool groupMembersRefs})
    >;
typedef $$GroupMembersTableCreateCompanionBuilder =
    GroupMembersCompanion Function({
      required int groupSetId,
      required int groupIndex,
      required int studentId,
      Value<String?> role,
      Value<int> rowid,
    });
typedef $$GroupMembersTableUpdateCompanionBuilder =
    GroupMembersCompanion Function({
      Value<int> groupSetId,
      Value<int> groupIndex,
      Value<int> studentId,
      Value<String?> role,
      Value<int> rowid,
    });

final class $$GroupMembersTableReferences
    extends BaseReferences<_$AppDatabase, $GroupMembersTable, GroupMember> {
  $$GroupMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupSetsTable _groupSetIdTable(_$AppDatabase db) =>
      db.groupSets.createAlias('group_members__group_set_id__group_sets__id');

  $$GroupSetsTableProcessedTableManager get groupSetId {
    final $_column = $_itemColumn<int>('group_set_id')!;

    final manager = $$GroupSetsTableTableManager(
      $_db,
      $_db.groupSets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupSetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('group_members__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroupMembersTableFilterComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get groupIndex => $composableBuilder(
    column: $table.groupIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupSetsTableFilterComposer get groupSetId {
    final $$GroupSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupSetId,
      referencedTable: $db.groupSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupSetsTableFilterComposer(
            $db: $db,
            $table: $db.groupSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get groupIndex => $composableBuilder(
    column: $table.groupIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupSetsTableOrderingComposer get groupSetId {
    final $$GroupSetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupSetId,
      referencedTable: $db.groupSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupSetsTableOrderingComposer(
            $db: $db,
            $table: $db.groupSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get groupIndex => $composableBuilder(
    column: $table.groupIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  $$GroupSetsTableAnnotationComposer get groupSetId {
    final $$GroupSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupSetId,
      referencedTable: $db.groupSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.groupSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupMembersTable,
          GroupMember,
          $$GroupMembersTableFilterComposer,
          $$GroupMembersTableOrderingComposer,
          $$GroupMembersTableAnnotationComposer,
          $$GroupMembersTableCreateCompanionBuilder,
          $$GroupMembersTableUpdateCompanionBuilder,
          (GroupMember, $$GroupMembersTableReferences),
          GroupMember,
          PrefetchHooks Function({bool groupSetId, bool studentId})
        > {
  $$GroupMembersTableTableManager(_$AppDatabase db, $GroupMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> groupSetId = const Value.absent(),
                Value<int> groupIndex = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupMembersCompanion(
                groupSetId: groupSetId,
                groupIndex: groupIndex,
                studentId: studentId,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int groupSetId,
                required int groupIndex,
                required int studentId,
                Value<String?> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupMembersCompanion.insert(
                groupSetId: groupSetId,
                groupIndex: groupIndex,
                studentId: studentId,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GroupMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupSetId = false, studentId = false}) {
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
                    if (groupSetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.groupSetId,
                                referencedTable: $$GroupMembersTableReferences
                                    ._groupSetIdTable(db),
                                referencedColumn: $$GroupMembersTableReferences
                                    ._groupSetIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable: $$GroupMembersTableReferences
                                    ._studentIdTable(db),
                                referencedColumn: $$GroupMembersTableReferences
                                    ._studentIdTable(db)
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

typedef $$GroupMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupMembersTable,
      GroupMember,
      $$GroupMembersTableFilterComposer,
      $$GroupMembersTableOrderingComposer,
      $$GroupMembersTableAnnotationComposer,
      $$GroupMembersTableCreateCompanionBuilder,
      $$GroupMembersTableUpdateCompanionBuilder,
      (GroupMember, $$GroupMembersTableReferences),
      GroupMember,
      PrefetchHooks Function({bool groupSetId, bool studentId})
    >;
typedef $$PairCountsTableCreateCompanionBuilder =
    PairCountsCompanion Function({
      required int classId,
      required int studentA,
      required int studentB,
      Value<int> count,
      Value<DateTime?> lastAt,
      Value<int> rowid,
    });
typedef $$PairCountsTableUpdateCompanionBuilder =
    PairCountsCompanion Function({
      Value<int> classId,
      Value<int> studentA,
      Value<int> studentB,
      Value<int> count,
      Value<DateTime?> lastAt,
      Value<int> rowid,
    });

final class $$PairCountsTableReferences
    extends BaseReferences<_$AppDatabase, $PairCountsTable, PairCount> {
  $$PairCountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClassesTable _classIdTable(_$AppDatabase db) =>
      db.classes.createAlias('pair_counts__class_id__classes__id');

  $$ClassesTableProcessedTableManager get classId {
    final $_column = $_itemColumn<int>('class_id')!;

    final manager = $$ClassesTableTableManager(
      $_db,
      $_db.classes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _studentATable(_$AppDatabase db) =>
      db.students.createAlias('pair_counts__student_a__students__id');

  $$StudentsTableProcessedTableManager get studentA {
    final $_column = $_itemColumn<int>('student_a')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentATable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _studentBTable(_$AppDatabase db) =>
      db.students.createAlias('pair_counts__student_b__students__id');

  $$StudentsTableProcessedTableManager get studentB {
    final $_column = $_itemColumn<int>('student_b')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentBTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PairCountsTableFilterComposer
    extends Composer<_$AppDatabase, $PairCountsTable> {
  $$PairCountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAt => $composableBuilder(
    column: $table.lastAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClassesTableFilterComposer get classId {
    final $$ClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableFilterComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableFilterComposer get studentA {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentA,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableFilterComposer get studentB {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentB,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PairCountsTableOrderingComposer
    extends Composer<_$AppDatabase, $PairCountsTable> {
  $$PairCountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAt => $composableBuilder(
    column: $table.lastAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClassesTableOrderingComposer get classId {
    final $$ClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableOrderingComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableOrderingComposer get studentA {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentA,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableOrderingComposer get studentB {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentB,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PairCountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PairCountsTable> {
  $$PairCountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAt =>
      $composableBuilder(column: $table.lastAt, builder: (column) => column);

  $$ClassesTableAnnotationComposer get classId {
    final $$ClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableAnnotationComposer get studentA {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentA,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableAnnotationComposer get studentB {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentB,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PairCountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PairCountsTable,
          PairCount,
          $$PairCountsTableFilterComposer,
          $$PairCountsTableOrderingComposer,
          $$PairCountsTableAnnotationComposer,
          $$PairCountsTableCreateCompanionBuilder,
          $$PairCountsTableUpdateCompanionBuilder,
          (PairCount, $$PairCountsTableReferences),
          PairCount,
          PrefetchHooks Function({bool classId, bool studentA, bool studentB})
        > {
  $$PairCountsTableTableManager(_$AppDatabase db, $PairCountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PairCountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PairCountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PairCountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> classId = const Value.absent(),
                Value<int> studentA = const Value.absent(),
                Value<int> studentB = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<DateTime?> lastAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PairCountsCompanion(
                classId: classId,
                studentA: studentA,
                studentB: studentB,
                count: count,
                lastAt: lastAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int classId,
                required int studentA,
                required int studentB,
                Value<int> count = const Value.absent(),
                Value<DateTime?> lastAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PairCountsCompanion.insert(
                classId: classId,
                studentA: studentA,
                studentB: studentB,
                count: count,
                lastAt: lastAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PairCountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({classId = false, studentA = false, studentB = false}) {
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
                        if (classId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.classId,
                                    referencedTable: $$PairCountsTableReferences
                                        ._classIdTable(db),
                                    referencedColumn:
                                        $$PairCountsTableReferences
                                            ._classIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (studentA) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.studentA,
                                    referencedTable: $$PairCountsTableReferences
                                        ._studentATable(db),
                                    referencedColumn:
                                        $$PairCountsTableReferences
                                            ._studentATable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (studentB) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.studentB,
                                    referencedTable: $$PairCountsTableReferences
                                        ._studentBTable(db),
                                    referencedColumn:
                                        $$PairCountsTableReferences
                                            ._studentBTable(db)
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

typedef $$PairCountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PairCountsTable,
      PairCount,
      $$PairCountsTableFilterComposer,
      $$PairCountsTableOrderingComposer,
      $$PairCountsTableAnnotationComposer,
      $$PairCountsTableCreateCompanionBuilder,
      $$PairCountsTableUpdateCompanionBuilder,
      (PairCount, $$PairCountsTableReferences),
      PairCount,
      PrefetchHooks Function({bool classId, bool studentA, bool studentB})
    >;
typedef $$GroupConstraintsTableCreateCompanionBuilder =
    GroupConstraintsCompanion Function({
      Value<int> id,
      required int classId,
      required int studentA,
      required int studentB,
      required ConstraintKind kind,
      Value<String?> note,
    });
typedef $$GroupConstraintsTableUpdateCompanionBuilder =
    GroupConstraintsCompanion Function({
      Value<int> id,
      Value<int> classId,
      Value<int> studentA,
      Value<int> studentB,
      Value<ConstraintKind> kind,
      Value<String?> note,
    });

final class $$GroupConstraintsTableReferences
    extends
        BaseReferences<_$AppDatabase, $GroupConstraintsTable, GroupConstraint> {
  $$GroupConstraintsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ClassesTable _classIdTable(_$AppDatabase db) =>
      db.classes.createAlias('group_constraints__class_id__classes__id');

  $$ClassesTableProcessedTableManager get classId {
    final $_column = $_itemColumn<int>('class_id')!;

    final manager = $$ClassesTableTableManager(
      $_db,
      $_db.classes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _studentATable(_$AppDatabase db) =>
      db.students.createAlias('group_constraints__student_a__students__id');

  $$StudentsTableProcessedTableManager get studentA {
    final $_column = $_itemColumn<int>('student_a')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentATable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _studentBTable(_$AppDatabase db) =>
      db.students.createAlias('group_constraints__student_b__students__id');

  $$StudentsTableProcessedTableManager get studentB {
    final $_column = $_itemColumn<int>('student_b')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentBTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroupConstraintsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupConstraintsTable> {
  $$GroupConstraintsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ConstraintKind, ConstraintKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$ClassesTableFilterComposer get classId {
    final $$ClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableFilterComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableFilterComposer get studentA {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentA,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableFilterComposer get studentB {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentB,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupConstraintsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupConstraintsTable> {
  $$GroupConstraintsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClassesTableOrderingComposer get classId {
    final $$ClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableOrderingComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableOrderingComposer get studentA {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentA,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableOrderingComposer get studentB {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentB,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupConstraintsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupConstraintsTable> {
  $$GroupConstraintsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ConstraintKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$ClassesTableAnnotationComposer get classId {
    final $$ClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.classes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.classes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableAnnotationComposer get studentA {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentA,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableAnnotationComposer get studentB {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentB,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupConstraintsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupConstraintsTable,
          GroupConstraint,
          $$GroupConstraintsTableFilterComposer,
          $$GroupConstraintsTableOrderingComposer,
          $$GroupConstraintsTableAnnotationComposer,
          $$GroupConstraintsTableCreateCompanionBuilder,
          $$GroupConstraintsTableUpdateCompanionBuilder,
          (GroupConstraint, $$GroupConstraintsTableReferences),
          GroupConstraint,
          PrefetchHooks Function({bool classId, bool studentA, bool studentB})
        > {
  $$GroupConstraintsTableTableManager(
    _$AppDatabase db,
    $GroupConstraintsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupConstraintsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupConstraintsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupConstraintsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> classId = const Value.absent(),
                Value<int> studentA = const Value.absent(),
                Value<int> studentB = const Value.absent(),
                Value<ConstraintKind> kind = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => GroupConstraintsCompanion(
                id: id,
                classId: classId,
                studentA: studentA,
                studentB: studentB,
                kind: kind,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int classId,
                required int studentA,
                required int studentB,
                required ConstraintKind kind,
                Value<String?> note = const Value.absent(),
              }) => GroupConstraintsCompanion.insert(
                id: id,
                classId: classId,
                studentA: studentA,
                studentB: studentB,
                kind: kind,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GroupConstraintsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({classId = false, studentA = false, studentB = false}) {
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
                        if (classId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.classId,
                                    referencedTable:
                                        $$GroupConstraintsTableReferences
                                            ._classIdTable(db),
                                    referencedColumn:
                                        $$GroupConstraintsTableReferences
                                            ._classIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (studentA) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.studentA,
                                    referencedTable:
                                        $$GroupConstraintsTableReferences
                                            ._studentATable(db),
                                    referencedColumn:
                                        $$GroupConstraintsTableReferences
                                            ._studentATable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (studentB) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.studentB,
                                    referencedTable:
                                        $$GroupConstraintsTableReferences
                                            ._studentBTable(db),
                                    referencedColumn:
                                        $$GroupConstraintsTableReferences
                                            ._studentBTable(db)
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

typedef $$GroupConstraintsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupConstraintsTable,
      GroupConstraint,
      $$GroupConstraintsTableFilterComposer,
      $$GroupConstraintsTableOrderingComposer,
      $$GroupConstraintsTableAnnotationComposer,
      $$GroupConstraintsTableCreateCompanionBuilder,
      $$GroupConstraintsTableUpdateCompanionBuilder,
      (GroupConstraint, $$GroupConstraintsTableReferences),
      GroupConstraint,
      PrefetchHooks Function({bool classId, bool studentA, bool studentB})
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
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

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
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

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClassesTableTableManager get classes =>
      $$ClassesTableTableManager(_db, _db.classes);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$ProgressTableTableManager get progress =>
      $$ProgressTableTableManager(_db, _db.progress);
  $$ConfusionsTableTableManager get confusions =>
      $$ConfusionsTableTableManager(_db, _db.confusions);
  $$DrawEventsTableTableManager get drawEvents =>
      $$DrawEventsTableTableManager(_db, _db.drawEvents);
  $$PoolResetsTableTableManager get poolResets =>
      $$PoolResetsTableTableManager(_db, _db.poolResets);
  $$AbsencesTableTableManager get absences =>
      $$AbsencesTableTableManager(_db, _db.absences);
  $$GroupSetsTableTableManager get groupSets =>
      $$GroupSetsTableTableManager(_db, _db.groupSets);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db, _db.groupMembers);
  $$PairCountsTableTableManager get pairCounts =>
      $$PairCountsTableTableManager(_db, _db.pairCounts);
  $$GroupConstraintsTableTableManager get groupConstraints =>
      $$GroupConstraintsTableTableManager(_db, _db.groupConstraints);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
