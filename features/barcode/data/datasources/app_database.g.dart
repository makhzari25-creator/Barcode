// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<String> salt = GeneratedColumn<String>(
      'salt', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 2, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 5, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, username, passwordHash, salt, fullName, role, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UserRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('salt')) {
      context.handle(
          _saltMeta, salt.isAcceptableOrUnknown(data['salt']!, _saltMeta));
    } else if (isInserting) {
      context.missing(_saltMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {username},
      ];
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash'])!,
      salt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}salt'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final int id;
  final String username;
  final String passwordHash;
  final String salt;
  final String fullName;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  const UserRow(
      {required this.id,
      required this.username,
      required this.passwordHash,
      required this.salt,
      required this.fullName,
      required this.role,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['password_hash'] = Variable<String>(passwordHash);
    map['salt'] = Variable<String>(salt);
    map['full_name'] = Variable<String>(fullName);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      passwordHash: Value(passwordHash),
      salt: Value(salt),
      fullName: Value(fullName),
      role: Value(role),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory UserRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      salt: serializer.fromJson<String>(json['salt']),
      fullName: serializer.fromJson<String>(json['fullName']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'salt': serializer.toJson<String>(salt),
      'fullName': serializer.toJson<String>(fullName),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserRow copyWith(
          {int? id,
          String? username,
          String? passwordHash,
          String? salt,
          String? fullName,
          String? role,
          bool? isActive,
          DateTime? createdAt}) =>
      UserRow(
        id: id ?? this.id,
        username: username ?? this.username,
        passwordHash: passwordHash ?? this.passwordHash,
        salt: salt ?? this.salt,
        fullName: fullName ?? this.fullName,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      salt: data.salt.present ? data.salt.value : this.salt,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('salt: $salt, ')
          ..write('fullName: $fullName, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, username, passwordHash, salt, fullName, role, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.username == this.username &&
          other.passwordHash == this.passwordHash &&
          other.salt == this.salt &&
          other.fullName == this.fullName &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> passwordHash;
  final Value<String> salt;
  final Value<String> fullName;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.salt = const Value.absent(),
    this.fullName = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String passwordHash,
    required String salt,
    required String fullName,
    required String role,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : username = Value(username),
        passwordHash = Value(passwordHash),
        salt = Value(salt),
        fullName = Value(fullName),
        role = Value(role);
  static Insertable<UserRow> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? passwordHash,
    Expression<String>? salt,
    Expression<String>? fullName,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (salt != null) 'salt': salt,
      if (fullName != null) 'full_name': fullName,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? username,
      Value<String>? passwordHash,
      Value<String>? salt,
      Value<String>? fullName,
      Value<String>? role,
      Value<bool>? isActive,
      Value<DateTime>? createdAt}) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (salt.present) {
      map['salt'] = Variable<String>(salt.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('salt: $salt, ')
          ..write('fullName: $fullName, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ImportBatchesTable extends ImportBatches
    with TableInfo<$ImportBatchesTable, ImportBatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalRecordsMeta =
      const VerificationMeta('totalRecords');
  @override
  late final GeneratedColumn<int> totalRecords = GeneratedColumn<int>(
      'total_records', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _replacedMeta =
      const VerificationMeta('replaced');
  @override
  late final GeneratedColumn<bool> replaced = GeneratedColumn<bool>(
      'replaced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("replaced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _importedAtMeta =
      const VerificationMeta('importedAt');
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
      'imported_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, fileName, totalRecords, replaced, importedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_batches';
  @override
  VerificationContext validateIntegrity(Insertable<ImportBatchRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('total_records')) {
      context.handle(
          _totalRecordsMeta,
          totalRecords.isAcceptableOrUnknown(
              data['total_records']!, _totalRecordsMeta));
    }
    if (data.containsKey('replaced')) {
      context.handle(_replacedMeta,
          replaced.isAcceptableOrUnknown(data['replaced']!, _replacedMeta));
    }
    if (data.containsKey('imported_at')) {
      context.handle(
          _importedAtMeta,
          importedAt.isAcceptableOrUnknown(
              data['imported_at']!, _importedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportBatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportBatchRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      totalRecords: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_records'])!,
      replaced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}replaced'])!,
      importedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}imported_at'])!,
    );
  }

  @override
  $ImportBatchesTable createAlias(String alias) {
    return $ImportBatchesTable(attachedDatabase, alias);
  }
}

class ImportBatchRow extends DataClass implements Insertable<ImportBatchRow> {
  final int id;
  final int userId;
  final String fileName;
  final int totalRecords;
  final bool replaced;
  final DateTime importedAt;
  const ImportBatchRow(
      {required this.id,
      required this.userId,
      required this.fileName,
      required this.totalRecords,
      required this.replaced,
      required this.importedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['file_name'] = Variable<String>(fileName);
    map['total_records'] = Variable<int>(totalRecords);
    map['replaced'] = Variable<bool>(replaced);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  ImportBatchesCompanion toCompanion(bool nullToAbsent) {
    return ImportBatchesCompanion(
      id: Value(id),
      userId: Value(userId),
      fileName: Value(fileName),
      totalRecords: Value(totalRecords),
      replaced: Value(replaced),
      importedAt: Value(importedAt),
    );
  }

  factory ImportBatchRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportBatchRow(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      totalRecords: serializer.fromJson<int>(json['totalRecords']),
      replaced: serializer.fromJson<bool>(json['replaced']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'fileName': serializer.toJson<String>(fileName),
      'totalRecords': serializer.toJson<int>(totalRecords),
      'replaced': serializer.toJson<bool>(replaced),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  ImportBatchRow copyWith(
          {int? id,
          int? userId,
          String? fileName,
          int? totalRecords,
          bool? replaced,
          DateTime? importedAt}) =>
      ImportBatchRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        fileName: fileName ?? this.fileName,
        totalRecords: totalRecords ?? this.totalRecords,
        replaced: replaced ?? this.replaced,
        importedAt: importedAt ?? this.importedAt,
      );
  ImportBatchRow copyWithCompanion(ImportBatchesCompanion data) {
    return ImportBatchRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      totalRecords: data.totalRecords.present
          ? data.totalRecords.value
          : this.totalRecords,
      replaced: data.replaced.present ? data.replaced.value : this.replaced,
      importedAt:
          data.importedAt.present ? data.importedAt.value : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatchRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('fileName: $fileName, ')
          ..write('totalRecords: $totalRecords, ')
          ..write('replaced: $replaced, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, fileName, totalRecords, replaced, importedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportBatchRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.fileName == this.fileName &&
          other.totalRecords == this.totalRecords &&
          other.replaced == this.replaced &&
          other.importedAt == this.importedAt);
}

class ImportBatchesCompanion extends UpdateCompanion<ImportBatchRow> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> fileName;
  final Value<int> totalRecords;
  final Value<bool> replaced;
  final Value<DateTime> importedAt;
  const ImportBatchesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.totalRecords = const Value.absent(),
    this.replaced = const Value.absent(),
    this.importedAt = const Value.absent(),
  });
  ImportBatchesCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String fileName,
    this.totalRecords = const Value.absent(),
    this.replaced = const Value.absent(),
    this.importedAt = const Value.absent(),
  })  : userId = Value(userId),
        fileName = Value(fileName);
  static Insertable<ImportBatchRow> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? fileName,
    Expression<int>? totalRecords,
    Expression<bool>? replaced,
    Expression<DateTime>? importedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (fileName != null) 'file_name': fileName,
      if (totalRecords != null) 'total_records': totalRecords,
      if (replaced != null) 'replaced': replaced,
      if (importedAt != null) 'imported_at': importedAt,
    });
  }

  ImportBatchesCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<String>? fileName,
      Value<int>? totalRecords,
      Value<bool>? replaced,
      Value<DateTime>? importedAt}) {
    return ImportBatchesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fileName: fileName ?? this.fileName,
      totalRecords: totalRecords ?? this.totalRecords,
      replaced: replaced ?? this.replaced,
      importedAt: importedAt ?? this.importedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (totalRecords.present) {
      map['total_records'] = Variable<int>(totalRecords.value);
    }
    if (replaced.present) {
      map['replaced'] = Variable<bool>(replaced.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatchesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('fileName: $fileName, ')
          ..write('totalRecords: $totalRecords, ')
          ..write('replaced: $replaced, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }
}

class $BarcodesTable extends Barcodes
    with TableInfo<$BarcodesTable, BarcodeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BarcodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _productCodeMeta =
      const VerificationMeta('productCode');
  @override
  late final GeneratedColumn<String> productCode = GeneratedColumn<String>(
      'product_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<String> size = GeneratedColumn<String>(
      'size', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _importedBatchMeta =
      const VerificationMeta('importedBatch');
  @override
  late final GeneratedColumn<int> importedBatch = GeneratedColumn<int>(
      'imported_batch', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES import_batches (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        code,
        productName,
        productCode,
        category,
        size,
        color,
        importedBatch,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'barcodes';
  @override
  VerificationContext validateIntegrity(Insertable<BarcodeRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    }
    if (data.containsKey('product_code')) {
      context.handle(
          _productCodeMeta,
          productCode.isAcceptableOrUnknown(
              data['product_code']!, _productCodeMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('imported_batch')) {
      context.handle(
          _importedBatchMeta,
          importedBatch.isAcceptableOrUnknown(
              data['imported_batch']!, _importedBatchMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {code},
      ];
  @override
  BarcodeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BarcodeRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name']),
      productCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_code']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      size: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}size']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      importedBatch: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}imported_batch']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BarcodesTable createAlias(String alias) {
    return $BarcodesTable(attachedDatabase, alias);
  }
}

class BarcodeRow extends DataClass implements Insertable<BarcodeRow> {
  final int id;
  final String code;
  final String? productName;
  final String? productCode;
  final String? category;
  final String? size;
  final String? color;
  final int? importedBatch;
  final DateTime createdAt;
  const BarcodeRow(
      {required this.id,
      required this.code,
      this.productName,
      this.productCode,
      this.category,
      this.size,
      this.color,
      this.importedBatch,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || productName != null) {
      map['product_name'] = Variable<String>(productName);
    }
    if (!nullToAbsent || productCode != null) {
      map['product_code'] = Variable<String>(productCode);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<String>(size);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || importedBatch != null) {
      map['imported_batch'] = Variable<int>(importedBatch);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BarcodesCompanion toCompanion(bool nullToAbsent) {
    return BarcodesCompanion(
      id: Value(id),
      code: Value(code),
      productName: productName == null && nullToAbsent
          ? const Value.absent()
          : Value(productName),
      productCode: productCode == null && nullToAbsent
          ? const Value.absent()
          : Value(productCode),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      importedBatch: importedBatch == null && nullToAbsent
          ? const Value.absent()
          : Value(importedBatch),
      createdAt: Value(createdAt),
    );
  }

  factory BarcodeRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BarcodeRow(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      productName: serializer.fromJson<String?>(json['productName']),
      productCode: serializer.fromJson<String?>(json['productCode']),
      category: serializer.fromJson<String?>(json['category']),
      size: serializer.fromJson<String?>(json['size']),
      color: serializer.fromJson<String?>(json['color']),
      importedBatch: serializer.fromJson<int?>(json['importedBatch']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'productName': serializer.toJson<String?>(productName),
      'productCode': serializer.toJson<String?>(productCode),
      'category': serializer.toJson<String?>(category),
      'size': serializer.toJson<String?>(size),
      'color': serializer.toJson<String?>(color),
      'importedBatch': serializer.toJson<int?>(importedBatch),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BarcodeRow copyWith(
          {int? id,
          String? code,
          Value<String?> productName = const Value.absent(),
          Value<String?> productCode = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<String?> size = const Value.absent(),
          Value<String?> color = const Value.absent(),
          Value<int?> importedBatch = const Value.absent(),
          DateTime? createdAt}) =>
      BarcodeRow(
        id: id ?? this.id,
        code: code ?? this.code,
        productName: productName.present ? productName.value : this.productName,
        productCode: productCode.present ? productCode.value : this.productCode,
        category: category.present ? category.value : this.category,
        size: size.present ? size.value : this.size,
        color: color.present ? color.value : this.color,
        importedBatch:
            importedBatch.present ? importedBatch.value : this.importedBatch,
        createdAt: createdAt ?? this.createdAt,
      );
  BarcodeRow copyWithCompanion(BarcodesCompanion data) {
    return BarcodeRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      productCode:
          data.productCode.present ? data.productCode.value : this.productCode,
      category: data.category.present ? data.category.value : this.category,
      size: data.size.present ? data.size.value : this.size,
      color: data.color.present ? data.color.value : this.color,
      importedBatch: data.importedBatch.present
          ? data.importedBatch.value
          : this.importedBatch,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BarcodeRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('productName: $productName, ')
          ..write('productCode: $productCode, ')
          ..write('category: $category, ')
          ..write('size: $size, ')
          ..write('color: $color, ')
          ..write('importedBatch: $importedBatch, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, productName, productCode, category,
      size, color, importedBatch, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BarcodeRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.productName == this.productName &&
          other.productCode == this.productCode &&
          other.category == this.category &&
          other.size == this.size &&
          other.color == this.color &&
          other.importedBatch == this.importedBatch &&
          other.createdAt == this.createdAt);
}

class BarcodesCompanion extends UpdateCompanion<BarcodeRow> {
  final Value<int> id;
  final Value<String> code;
  final Value<String?> productName;
  final Value<String?> productCode;
  final Value<String?> category;
  final Value<String?> size;
  final Value<String?> color;
  final Value<int?> importedBatch;
  final Value<DateTime> createdAt;
  const BarcodesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.productName = const Value.absent(),
    this.productCode = const Value.absent(),
    this.category = const Value.absent(),
    this.size = const Value.absent(),
    this.color = const Value.absent(),
    this.importedBatch = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BarcodesCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    this.productName = const Value.absent(),
    this.productCode = const Value.absent(),
    this.category = const Value.absent(),
    this.size = const Value.absent(),
    this.color = const Value.absent(),
    this.importedBatch = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : code = Value(code);
  static Insertable<BarcodeRow> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? productName,
    Expression<String>? productCode,
    Expression<String>? category,
    Expression<String>? size,
    Expression<String>? color,
    Expression<int>? importedBatch,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (productName != null) 'product_name': productName,
      if (productCode != null) 'product_code': productCode,
      if (category != null) 'category': category,
      if (size != null) 'size': size,
      if (color != null) 'color': color,
      if (importedBatch != null) 'imported_batch': importedBatch,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BarcodesCompanion copyWith(
      {Value<int>? id,
      Value<String>? code,
      Value<String?>? productName,
      Value<String?>? productCode,
      Value<String?>? category,
      Value<String?>? size,
      Value<String?>? color,
      Value<int?>? importedBatch,
      Value<DateTime>? createdAt}) {
    return BarcodesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      category: category ?? this.category,
      size: size ?? this.size,
      color: color ?? this.color,
      importedBatch: importedBatch ?? this.importedBatch,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (productCode.present) {
      map['product_code'] = Variable<String>(productCode.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (importedBatch.present) {
      map['imported_batch'] = Variable<int>(importedBatch.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BarcodesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('productName: $productName, ')
          ..write('productCode: $productCode, ')
          ..write('category: $category, ')
          ..write('size: $size, ')
          ..write('color: $color, ')
          ..write('importedBatch: $importedBatch, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ScansTable extends Scans with TableInfo<$ScansTable, ScanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scannedAtMeta =
      const VerificationMeta('scannedAt');
  @override
  late final GeneratedColumn<DateTime> scannedAt = GeneratedColumn<DateTime>(
      'scanned_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dateOnlyMeta =
      const VerificationMeta('dateOnly');
  @override
  late final GeneratedColumn<String> dateOnly = GeneratedColumn<String>(
      'date_only', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timeOnlyMeta =
      const VerificationMeta('timeOnly');
  @override
  late final GeneratedColumn<String> timeOnly = GeneratedColumn<String>(
      'time_only', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceInfoMeta =
      const VerificationMeta('deviceInfo');
  @override
  late final GeneratedColumn<String> deviceInfo = GeneratedColumn<String>(
      'device_info', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, barcode, status, scannedAt, dateOnly, timeOnly, deviceInfo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scans';
  @override
  VerificationContext validateIntegrity(Insertable<ScanRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('scanned_at')) {
      context.handle(_scannedAtMeta,
          scannedAt.isAcceptableOrUnknown(data['scanned_at']!, _scannedAtMeta));
    }
    if (data.containsKey('date_only')) {
      context.handle(_dateOnlyMeta,
          dateOnly.isAcceptableOrUnknown(data['date_only']!, _dateOnlyMeta));
    } else if (isInserting) {
      context.missing(_dateOnlyMeta);
    }
    if (data.containsKey('time_only')) {
      context.handle(_timeOnlyMeta,
          timeOnly.isAcceptableOrUnknown(data['time_only']!, _timeOnlyMeta));
    } else if (isInserting) {
      context.missing(_timeOnlyMeta);
    }
    if (data.containsKey('device_info')) {
      context.handle(
          _deviceInfoMeta,
          deviceInfo.isAcceptableOrUnknown(
              data['device_info']!, _deviceInfoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      scannedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scanned_at'])!,
      dateOnly: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_only'])!,
      timeOnly: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time_only'])!,
      deviceInfo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_info']),
    );
  }

  @override
  $ScansTable createAlias(String alias) {
    return $ScansTable(attachedDatabase, alias);
  }
}

class ScanRow extends DataClass implements Insertable<ScanRow> {
  final int id;
  final int userId;
  final String barcode;
  final String status;
  final DateTime scannedAt;
  final String dateOnly;
  final String timeOnly;
  final String? deviceInfo;
  const ScanRow(
      {required this.id,
      required this.userId,
      required this.barcode,
      required this.status,
      required this.scannedAt,
      required this.dateOnly,
      required this.timeOnly,
      this.deviceInfo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['barcode'] = Variable<String>(barcode);
    map['status'] = Variable<String>(status);
    map['scanned_at'] = Variable<DateTime>(scannedAt);
    map['date_only'] = Variable<String>(dateOnly);
    map['time_only'] = Variable<String>(timeOnly);
    if (!nullToAbsent || deviceInfo != null) {
      map['device_info'] = Variable<String>(deviceInfo);
    }
    return map;
  }

  ScansCompanion toCompanion(bool nullToAbsent) {
    return ScansCompanion(
      id: Value(id),
      userId: Value(userId),
      barcode: Value(barcode),
      status: Value(status),
      scannedAt: Value(scannedAt),
      dateOnly: Value(dateOnly),
      timeOnly: Value(timeOnly),
      deviceInfo: deviceInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceInfo),
    );
  }

  factory ScanRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanRow(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      barcode: serializer.fromJson<String>(json['barcode']),
      status: serializer.fromJson<String>(json['status']),
      scannedAt: serializer.fromJson<DateTime>(json['scannedAt']),
      dateOnly: serializer.fromJson<String>(json['dateOnly']),
      timeOnly: serializer.fromJson<String>(json['timeOnly']),
      deviceInfo: serializer.fromJson<String?>(json['deviceInfo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'barcode': serializer.toJson<String>(barcode),
      'status': serializer.toJson<String>(status),
      'scannedAt': serializer.toJson<DateTime>(scannedAt),
      'dateOnly': serializer.toJson<String>(dateOnly),
      'timeOnly': serializer.toJson<String>(timeOnly),
      'deviceInfo': serializer.toJson<String?>(deviceInfo),
    };
  }

  ScanRow copyWith(
          {int? id,
          int? userId,
          String? barcode,
          String? status,
          DateTime? scannedAt,
          String? dateOnly,
          String? timeOnly,
          Value<String?> deviceInfo = const Value.absent()}) =>
      ScanRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        barcode: barcode ?? this.barcode,
        status: status ?? this.status,
        scannedAt: scannedAt ?? this.scannedAt,
        dateOnly: dateOnly ?? this.dateOnly,
        timeOnly: timeOnly ?? this.timeOnly,
        deviceInfo: deviceInfo.present ? deviceInfo.value : this.deviceInfo,
      );
  ScanRow copyWithCompanion(ScansCompanion data) {
    return ScanRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      status: data.status.present ? data.status.value : this.status,
      scannedAt: data.scannedAt.present ? data.scannedAt.value : this.scannedAt,
      dateOnly: data.dateOnly.present ? data.dateOnly.value : this.dateOnly,
      timeOnly: data.timeOnly.present ? data.timeOnly.value : this.timeOnly,
      deviceInfo:
          data.deviceInfo.present ? data.deviceInfo.value : this.deviceInfo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('barcode: $barcode, ')
          ..write('status: $status, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('dateOnly: $dateOnly, ')
          ..write('timeOnly: $timeOnly, ')
          ..write('deviceInfo: $deviceInfo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, userId, barcode, status, scannedAt, dateOnly, timeOnly, deviceInfo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.barcode == this.barcode &&
          other.status == this.status &&
          other.scannedAt == this.scannedAt &&
          other.dateOnly == this.dateOnly &&
          other.timeOnly == this.timeOnly &&
          other.deviceInfo == this.deviceInfo);
}

class ScansCompanion extends UpdateCompanion<ScanRow> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> barcode;
  final Value<String> status;
  final Value<DateTime> scannedAt;
  final Value<String> dateOnly;
  final Value<String> timeOnly;
  final Value<String?> deviceInfo;
  const ScansCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.barcode = const Value.absent(),
    this.status = const Value.absent(),
    this.scannedAt = const Value.absent(),
    this.dateOnly = const Value.absent(),
    this.timeOnly = const Value.absent(),
    this.deviceInfo = const Value.absent(),
  });
  ScansCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String barcode,
    required String status,
    this.scannedAt = const Value.absent(),
    required String dateOnly,
    required String timeOnly,
    this.deviceInfo = const Value.absent(),
  })  : userId = Value(userId),
        barcode = Value(barcode),
        status = Value(status),
        dateOnly = Value(dateOnly),
        timeOnly = Value(timeOnly);
  static Insertable<ScanRow> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? barcode,
    Expression<String>? status,
    Expression<DateTime>? scannedAt,
    Expression<String>? dateOnly,
    Expression<String>? timeOnly,
    Expression<String>? deviceInfo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (barcode != null) 'barcode': barcode,
      if (status != null) 'status': status,
      if (scannedAt != null) 'scanned_at': scannedAt,
      if (dateOnly != null) 'date_only': dateOnly,
      if (timeOnly != null) 'time_only': timeOnly,
      if (deviceInfo != null) 'device_info': deviceInfo,
    });
  }

  ScansCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<String>? barcode,
      Value<String>? status,
      Value<DateTime>? scannedAt,
      Value<String>? dateOnly,
      Value<String>? timeOnly,
      Value<String?>? deviceInfo}) {
    return ScansCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      barcode: barcode ?? this.barcode,
      status: status ?? this.status,
      scannedAt: scannedAt ?? this.scannedAt,
      dateOnly: dateOnly ?? this.dateOnly,
      timeOnly: timeOnly ?? this.timeOnly,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (scannedAt.present) {
      map['scanned_at'] = Variable<DateTime>(scannedAt.value);
    }
    if (dateOnly.present) {
      map['date_only'] = Variable<String>(dateOnly.value);
    }
    if (timeOnly.present) {
      map['time_only'] = Variable<String>(timeOnly.value);
    }
    if (deviceInfo.present) {
      map['device_info'] = Variable<String>(deviceInfo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScansCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('barcode: $barcode, ')
          ..write('status: $status, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('dateOnly: $dateOnly, ')
          ..write('timeOnly: $timeOnly, ')
          ..write('deviceInfo: $deviceInfo')
          ..write(')'))
        .toString();
  }
}

class $PickingSessionsTable extends PickingSessions
    with TableInfo<$PickingSessionsTable, PickingSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PickingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _sourceFileMeta =
      const VerificationMeta('sourceFile');
  @override
  late final GeneratedColumn<String> sourceFile = GeneratedColumn<String>(
      'source_file', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalItemsMeta =
      const VerificationMeta('totalItems');
  @override
  late final GeneratedColumn<int> totalItems = GeneratedColumn<int>(
      'total_items', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pickedCountMeta =
      const VerificationMeta('pickedCount');
  @override
  late final GeneratedColumn<int> pickedCount = GeneratedColumn<int>(
      'picked_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _skippedCountMeta =
      const VerificationMeta('skippedCount');
  @override
  late final GeneratedColumn<int> skippedCount = GeneratedColumn<int>(
      'skipped_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        name,
        sourceFile,
        totalItems,
        pickedCount,
        skippedCount,
        status,
        startedAt,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'picking_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<PickingSessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source_file')) {
      context.handle(
          _sourceFileMeta,
          sourceFile.isAcceptableOrUnknown(
              data['source_file']!, _sourceFileMeta));
    } else if (isInserting) {
      context.missing(_sourceFileMeta);
    }
    if (data.containsKey('total_items')) {
      context.handle(
          _totalItemsMeta,
          totalItems.isAcceptableOrUnknown(
              data['total_items']!, _totalItemsMeta));
    }
    if (data.containsKey('picked_count')) {
      context.handle(
          _pickedCountMeta,
          pickedCount.isAcceptableOrUnknown(
              data['picked_count']!, _pickedCountMeta));
    }
    if (data.containsKey('skipped_count')) {
      context.handle(
          _skippedCountMeta,
          skippedCount.isAcceptableOrUnknown(
              data['skipped_count']!, _skippedCountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PickingSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PickingSessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sourceFile: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_file'])!,
      totalItems: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_items'])!,
      pickedCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}picked_count'])!,
      skippedCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}skipped_count'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $PickingSessionsTable createAlias(String alias) {
    return $PickingSessionsTable(attachedDatabase, alias);
  }
}

class PickingSessionRow extends DataClass
    implements Insertable<PickingSessionRow> {
  final int id;
  final int userId;
  final String name;
  final String sourceFile;
  final int totalItems;
  final int pickedCount;
  final int skippedCount;
  final String status;
  final DateTime startedAt;
  final DateTime? completedAt;
  const PickingSessionRow(
      {required this.id,
      required this.userId,
      required this.name,
      required this.sourceFile,
      required this.totalItems,
      required this.pickedCount,
      required this.skippedCount,
      required this.status,
      required this.startedAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['name'] = Variable<String>(name);
    map['source_file'] = Variable<String>(sourceFile);
    map['total_items'] = Variable<int>(totalItems);
    map['picked_count'] = Variable<int>(pickedCount);
    map['skipped_count'] = Variable<int>(skippedCount);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  PickingSessionsCompanion toCompanion(bool nullToAbsent) {
    return PickingSessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      sourceFile: Value(sourceFile),
      totalItems: Value(totalItems),
      pickedCount: Value(pickedCount),
      skippedCount: Value(skippedCount),
      status: Value(status),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory PickingSessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PickingSessionRow(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      sourceFile: serializer.fromJson<String>(json['sourceFile']),
      totalItems: serializer.fromJson<int>(json['totalItems']),
      pickedCount: serializer.fromJson<int>(json['pickedCount']),
      skippedCount: serializer.fromJson<int>(json['skippedCount']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'name': serializer.toJson<String>(name),
      'sourceFile': serializer.toJson<String>(sourceFile),
      'totalItems': serializer.toJson<int>(totalItems),
      'pickedCount': serializer.toJson<int>(pickedCount),
      'skippedCount': serializer.toJson<int>(skippedCount),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  PickingSessionRow copyWith(
          {int? id,
          int? userId,
          String? name,
          String? sourceFile,
          int? totalItems,
          int? pickedCount,
          int? skippedCount,
          String? status,
          DateTime? startedAt,
          Value<DateTime?> completedAt = const Value.absent()}) =>
      PickingSessionRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        sourceFile: sourceFile ?? this.sourceFile,
        totalItems: totalItems ?? this.totalItems,
        pickedCount: pickedCount ?? this.pickedCount,
        skippedCount: skippedCount ?? this.skippedCount,
        status: status ?? this.status,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  PickingSessionRow copyWithCompanion(PickingSessionsCompanion data) {
    return PickingSessionRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      sourceFile:
          data.sourceFile.present ? data.sourceFile.value : this.sourceFile,
      totalItems:
          data.totalItems.present ? data.totalItems.value : this.totalItems,
      pickedCount:
          data.pickedCount.present ? data.pickedCount.value : this.pickedCount,
      skippedCount: data.skippedCount.present
          ? data.skippedCount.value
          : this.skippedCount,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PickingSessionRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('sourceFile: $sourceFile, ')
          ..write('totalItems: $totalItems, ')
          ..write('pickedCount: $pickedCount, ')
          ..write('skippedCount: $skippedCount, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, name, sourceFile, totalItems,
      pickedCount, skippedCount, status, startedAt, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PickingSessionRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.sourceFile == this.sourceFile &&
          other.totalItems == this.totalItems &&
          other.pickedCount == this.pickedCount &&
          other.skippedCount == this.skippedCount &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class PickingSessionsCompanion extends UpdateCompanion<PickingSessionRow> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> name;
  final Value<String> sourceFile;
  final Value<int> totalItems;
  final Value<int> pickedCount;
  final Value<int> skippedCount;
  final Value<String> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  const PickingSessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.sourceFile = const Value.absent(),
    this.totalItems = const Value.absent(),
    this.pickedCount = const Value.absent(),
    this.skippedCount = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  PickingSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String name,
    required String sourceFile,
    this.totalItems = const Value.absent(),
    this.pickedCount = const Value.absent(),
    this.skippedCount = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  })  : userId = Value(userId),
        name = Value(name),
        sourceFile = Value(sourceFile);
  static Insertable<PickingSessionRow> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? name,
    Expression<String>? sourceFile,
    Expression<int>? totalItems,
    Expression<int>? pickedCount,
    Expression<int>? skippedCount,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (sourceFile != null) 'source_file': sourceFile,
      if (totalItems != null) 'total_items': totalItems,
      if (pickedCount != null) 'picked_count': pickedCount,
      if (skippedCount != null) 'skipped_count': skippedCount,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  PickingSessionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<String>? name,
      Value<String>? sourceFile,
      Value<int>? totalItems,
      Value<int>? pickedCount,
      Value<int>? skippedCount,
      Value<String>? status,
      Value<DateTime>? startedAt,
      Value<DateTime?>? completedAt}) {
    return PickingSessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      sourceFile: sourceFile ?? this.sourceFile,
      totalItems: totalItems ?? this.totalItems,
      pickedCount: pickedCount ?? this.pickedCount,
      skippedCount: skippedCount ?? this.skippedCount,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sourceFile.present) {
      map['source_file'] = Variable<String>(sourceFile.value);
    }
    if (totalItems.present) {
      map['total_items'] = Variable<int>(totalItems.value);
    }
    if (pickedCount.present) {
      map['picked_count'] = Variable<int>(pickedCount.value);
    }
    if (skippedCount.present) {
      map['skipped_count'] = Variable<int>(skippedCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PickingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('sourceFile: $sourceFile, ')
          ..write('totalItems: $totalItems, ')
          ..write('pickedCount: $pickedCount, ')
          ..write('skippedCount: $skippedCount, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $PickingItemsTable extends PickingItems
    with TableInfo<$PickingItemsTable, PickingItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PickingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES picking_sessions (id)'));
  static const VerificationMeta _locationWarehouseMeta =
      const VerificationMeta('locationWarehouse');
  @override
  late final GeneratedColumn<String> locationWarehouse =
      GeneratedColumn<String>('location_warehouse', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationHallMeta =
      const VerificationMeta('locationHall');
  @override
  late final GeneratedColumn<String> locationHall = GeneratedColumn<String>(
      'location_hall', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _productCodeMeta =
      const VerificationMeta('productCode');
  @override
  late final GeneratedColumn<String> productCode = GeneratedColumn<String>(
      'product_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _designMeta = const VerificationMeta('design');
  @override
  late final GeneratedColumn<String> design = GeneratedColumn<String>(
      'design', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<String> size = GeneratedColumn<String>(
      'size', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _scannedBarcodeMeta =
      const VerificationMeta('scannedBarcode');
  @override
  late final GeneratedColumn<String> scannedBarcode = GeneratedColumn<String>(
      'scanned_barcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pickedAtMeta =
      const VerificationMeta('pickedAt');
  @override
  late final GeneratedColumn<DateTime> pickedAt = GeneratedColumn<DateTime>(
      'picked_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        locationWarehouse,
        locationHall,
        color,
        productCode,
        productName,
        quantity,
        gender,
        design,
        size,
        barcode,
        sortOrder,
        status,
        scannedBarcode,
        pickedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'picking_items';
  @override
  VerificationContext validateIntegrity(Insertable<PickingItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('location_warehouse')) {
      context.handle(
          _locationWarehouseMeta,
          locationWarehouse.isAcceptableOrUnknown(
              data['location_warehouse']!, _locationWarehouseMeta));
    } else if (isInserting) {
      context.missing(_locationWarehouseMeta);
    }
    if (data.containsKey('location_hall')) {
      context.handle(
          _locationHallMeta,
          locationHall.isAcceptableOrUnknown(
              data['location_hall']!, _locationHallMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('product_code')) {
      context.handle(
          _productCodeMeta,
          productCode.isAcceptableOrUnknown(
              data['product_code']!, _productCodeMeta));
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('design')) {
      context.handle(_designMeta,
          design.isAcceptableOrUnknown(data['design']!, _designMeta));
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('scanned_barcode')) {
      context.handle(
          _scannedBarcodeMeta,
          scannedBarcode.isAcceptableOrUnknown(
              data['scanned_barcode']!, _scannedBarcodeMeta));
    }
    if (data.containsKey('picked_at')) {
      context.handle(_pickedAtMeta,
          pickedAt.isAcceptableOrUnknown(data['picked_at']!, _pickedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PickingItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PickingItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      locationWarehouse: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}location_warehouse'])!,
      locationHall: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_hall']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      productCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_code']),
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name']),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
      design: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}design']),
      size: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}size']),
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      scannedBarcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scanned_barcode']),
      pickedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}picked_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PickingItemsTable createAlias(String alias) {
    return $PickingItemsTable(attachedDatabase, alias);
  }
}

class PickingItemRow extends DataClass implements Insertable<PickingItemRow> {
  final int id;
  final int sessionId;
  final String locationWarehouse;
  final String? locationHall;
  final String? color;
  final String? productCode;
  final String? productName;
  final int quantity;
  final String? gender;
  final String? design;
  final String? size;
  final String barcode;
  final int sortOrder;
  final String status;
  final String? scannedBarcode;
  final DateTime? pickedAt;
  final DateTime createdAt;
  const PickingItemRow(
      {required this.id,
      required this.sessionId,
      required this.locationWarehouse,
      this.locationHall,
      this.color,
      this.productCode,
      this.productName,
      required this.quantity,
      this.gender,
      this.design,
      this.size,
      required this.barcode,
      required this.sortOrder,
      required this.status,
      this.scannedBarcode,
      this.pickedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['location_warehouse'] = Variable<String>(locationWarehouse);
    if (!nullToAbsent || locationHall != null) {
      map['location_hall'] = Variable<String>(locationHall);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || productCode != null) {
      map['product_code'] = Variable<String>(productCode);
    }
    if (!nullToAbsent || productName != null) {
      map['product_name'] = Variable<String>(productName);
    }
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || design != null) {
      map['design'] = Variable<String>(design);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<String>(size);
    }
    map['barcode'] = Variable<String>(barcode);
    map['sort_order'] = Variable<int>(sortOrder);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || scannedBarcode != null) {
      map['scanned_barcode'] = Variable<String>(scannedBarcode);
    }
    if (!nullToAbsent || pickedAt != null) {
      map['picked_at'] = Variable<DateTime>(pickedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PickingItemsCompanion toCompanion(bool nullToAbsent) {
    return PickingItemsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      locationWarehouse: Value(locationWarehouse),
      locationHall: locationHall == null && nullToAbsent
          ? const Value.absent()
          : Value(locationHall),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      productCode: productCode == null && nullToAbsent
          ? const Value.absent()
          : Value(productCode),
      productName: productName == null && nullToAbsent
          ? const Value.absent()
          : Value(productName),
      quantity: Value(quantity),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      design:
          design == null && nullToAbsent ? const Value.absent() : Value(design),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      barcode: Value(barcode),
      sortOrder: Value(sortOrder),
      status: Value(status),
      scannedBarcode: scannedBarcode == null && nullToAbsent
          ? const Value.absent()
          : Value(scannedBarcode),
      pickedAt: pickedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pickedAt),
      createdAt: Value(createdAt),
    );
  }

  factory PickingItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PickingItemRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      locationWarehouse: serializer.fromJson<String>(json['locationWarehouse']),
      locationHall: serializer.fromJson<String?>(json['locationHall']),
      color: serializer.fromJson<String?>(json['color']),
      productCode: serializer.fromJson<String?>(json['productCode']),
      productName: serializer.fromJson<String?>(json['productName']),
      quantity: serializer.fromJson<int>(json['quantity']),
      gender: serializer.fromJson<String?>(json['gender']),
      design: serializer.fromJson<String?>(json['design']),
      size: serializer.fromJson<String?>(json['size']),
      barcode: serializer.fromJson<String>(json['barcode']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      status: serializer.fromJson<String>(json['status']),
      scannedBarcode: serializer.fromJson<String?>(json['scannedBarcode']),
      pickedAt: serializer.fromJson<DateTime?>(json['pickedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'locationWarehouse': serializer.toJson<String>(locationWarehouse),
      'locationHall': serializer.toJson<String?>(locationHall),
      'color': serializer.toJson<String?>(color),
      'productCode': serializer.toJson<String?>(productCode),
      'productName': serializer.toJson<String?>(productName),
      'quantity': serializer.toJson<int>(quantity),
      'gender': serializer.toJson<String?>(gender),
      'design': serializer.toJson<String?>(design),
      'size': serializer.toJson<String?>(size),
      'barcode': serializer.toJson<String>(barcode),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'status': serializer.toJson<String>(status),
      'scannedBarcode': serializer.toJson<String?>(scannedBarcode),
      'pickedAt': serializer.toJson<DateTime?>(pickedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PickingItemRow copyWith(
          {int? id,
          int? sessionId,
          String? locationWarehouse,
          Value<String?> locationHall = const Value.absent(),
          Value<String?> color = const Value.absent(),
          Value<String?> productCode = const Value.absent(),
          Value<String?> productName = const Value.absent(),
          int? quantity,
          Value<String?> gender = const Value.absent(),
          Value<String?> design = const Value.absent(),
          Value<String?> size = const Value.absent(),
          String? barcode,
          int? sortOrder,
          String? status,
          Value<String?> scannedBarcode = const Value.absent(),
          Value<DateTime?> pickedAt = const Value.absent(),
          DateTime? createdAt}) =>
      PickingItemRow(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        locationWarehouse: locationWarehouse ?? this.locationWarehouse,
        locationHall:
            locationHall.present ? locationHall.value : this.locationHall,
        color: color.present ? color.value : this.color,
        productCode: productCode.present ? productCode.value : this.productCode,
        productName: productName.present ? productName.value : this.productName,
        quantity: quantity ?? this.quantity,
        gender: gender.present ? gender.value : this.gender,
        design: design.present ? design.value : this.design,
        size: size.present ? size.value : this.size,
        barcode: barcode ?? this.barcode,
        sortOrder: sortOrder ?? this.sortOrder,
        status: status ?? this.status,
        scannedBarcode:
            scannedBarcode.present ? scannedBarcode.value : this.scannedBarcode,
        pickedAt: pickedAt.present ? pickedAt.value : this.pickedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  PickingItemRow copyWithCompanion(PickingItemsCompanion data) {
    return PickingItemRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      locationWarehouse: data.locationWarehouse.present
          ? data.locationWarehouse.value
          : this.locationWarehouse,
      locationHall: data.locationHall.present
          ? data.locationHall.value
          : this.locationHall,
      color: data.color.present ? data.color.value : this.color,
      productCode:
          data.productCode.present ? data.productCode.value : this.productCode,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      gender: data.gender.present ? data.gender.value : this.gender,
      design: data.design.present ? data.design.value : this.design,
      size: data.size.present ? data.size.value : this.size,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      status: data.status.present ? data.status.value : this.status,
      scannedBarcode: data.scannedBarcode.present
          ? data.scannedBarcode.value
          : this.scannedBarcode,
      pickedAt: data.pickedAt.present ? data.pickedAt.value : this.pickedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PickingItemRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('locationWarehouse: $locationWarehouse, ')
          ..write('locationHall: $locationHall, ')
          ..write('color: $color, ')
          ..write('productCode: $productCode, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('gender: $gender, ')
          ..write('design: $design, ')
          ..write('size: $size, ')
          ..write('barcode: $barcode, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('status: $status, ')
          ..write('scannedBarcode: $scannedBarcode, ')
          ..write('pickedAt: $pickedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sessionId,
      locationWarehouse,
      locationHall,
      color,
      productCode,
      productName,
      quantity,
      gender,
      design,
      size,
      barcode,
      sortOrder,
      status,
      scannedBarcode,
      pickedAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PickingItemRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.locationWarehouse == this.locationWarehouse &&
          other.locationHall == this.locationHall &&
          other.color == this.color &&
          other.productCode == this.productCode &&
          other.productName == this.productName &&
          other.quantity == this.quantity &&
          other.gender == this.gender &&
          other.design == this.design &&
          other.size == this.size &&
          other.barcode == this.barcode &&
          other.sortOrder == this.sortOrder &&
          other.status == this.status &&
          other.scannedBarcode == this.scannedBarcode &&
          other.pickedAt == this.pickedAt &&
          other.createdAt == this.createdAt);
}

class PickingItemsCompanion extends UpdateCompanion<PickingItemRow> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> locationWarehouse;
  final Value<String?> locationHall;
  final Value<String?> color;
  final Value<String?> productCode;
  final Value<String?> productName;
  final Value<int> quantity;
  final Value<String?> gender;
  final Value<String?> design;
  final Value<String?> size;
  final Value<String> barcode;
  final Value<int> sortOrder;
  final Value<String> status;
  final Value<String?> scannedBarcode;
  final Value<DateTime?> pickedAt;
  final Value<DateTime> createdAt;
  const PickingItemsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.locationWarehouse = const Value.absent(),
    this.locationHall = const Value.absent(),
    this.color = const Value.absent(),
    this.productCode = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.gender = const Value.absent(),
    this.design = const Value.absent(),
    this.size = const Value.absent(),
    this.barcode = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.status = const Value.absent(),
    this.scannedBarcode = const Value.absent(),
    this.pickedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PickingItemsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String locationWarehouse,
    this.locationHall = const Value.absent(),
    this.color = const Value.absent(),
    this.productCode = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.gender = const Value.absent(),
    this.design = const Value.absent(),
    this.size = const Value.absent(),
    required String barcode,
    this.sortOrder = const Value.absent(),
    this.status = const Value.absent(),
    this.scannedBarcode = const Value.absent(),
    this.pickedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : sessionId = Value(sessionId),
        locationWarehouse = Value(locationWarehouse),
        barcode = Value(barcode);
  static Insertable<PickingItemRow> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? locationWarehouse,
    Expression<String>? locationHall,
    Expression<String>? color,
    Expression<String>? productCode,
    Expression<String>? productName,
    Expression<int>? quantity,
    Expression<String>? gender,
    Expression<String>? design,
    Expression<String>? size,
    Expression<String>? barcode,
    Expression<int>? sortOrder,
    Expression<String>? status,
    Expression<String>? scannedBarcode,
    Expression<DateTime>? pickedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (locationWarehouse != null) 'location_warehouse': locationWarehouse,
      if (locationHall != null) 'location_hall': locationHall,
      if (color != null) 'color': color,
      if (productCode != null) 'product_code': productCode,
      if (productName != null) 'product_name': productName,
      if (quantity != null) 'quantity': quantity,
      if (gender != null) 'gender': gender,
      if (design != null) 'design': design,
      if (size != null) 'size': size,
      if (barcode != null) 'barcode': barcode,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (status != null) 'status': status,
      if (scannedBarcode != null) 'scanned_barcode': scannedBarcode,
      if (pickedAt != null) 'picked_at': pickedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PickingItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionId,
      Value<String>? locationWarehouse,
      Value<String?>? locationHall,
      Value<String?>? color,
      Value<String?>? productCode,
      Value<String?>? productName,
      Value<int>? quantity,
      Value<String?>? gender,
      Value<String?>? design,
      Value<String?>? size,
      Value<String>? barcode,
      Value<int>? sortOrder,
      Value<String>? status,
      Value<String?>? scannedBarcode,
      Value<DateTime?>? pickedAt,
      Value<DateTime>? createdAt}) {
    return PickingItemsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      locationWarehouse: locationWarehouse ?? this.locationWarehouse,
      locationHall: locationHall ?? this.locationHall,
      color: color ?? this.color,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      gender: gender ?? this.gender,
      design: design ?? this.design,
      size: size ?? this.size,
      barcode: barcode ?? this.barcode,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      scannedBarcode: scannedBarcode ?? this.scannedBarcode,
      pickedAt: pickedAt ?? this.pickedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (locationWarehouse.present) {
      map['location_warehouse'] = Variable<String>(locationWarehouse.value);
    }
    if (locationHall.present) {
      map['location_hall'] = Variable<String>(locationHall.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (productCode.present) {
      map['product_code'] = Variable<String>(productCode.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (design.present) {
      map['design'] = Variable<String>(design.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (scannedBarcode.present) {
      map['scanned_barcode'] = Variable<String>(scannedBarcode.value);
    }
    if (pickedAt.present) {
      map['picked_at'] = Variable<DateTime>(pickedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PickingItemsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('locationWarehouse: $locationWarehouse, ')
          ..write('locationHall: $locationHall, ')
          ..write('color: $color, ')
          ..write('productCode: $productCode, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('gender: $gender, ')
          ..write('design: $design, ')
          ..write('size: $size, ')
          ..write('barcode: $barcode, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('status: $status, ')
          ..write('scannedBarcode: $scannedBarcode, ')
          ..write('pickedAt: $pickedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ImportBatchesTable importBatches = $ImportBatchesTable(this);
  late final $BarcodesTable barcodes = $BarcodesTable(this);
  late final $ScansTable scans = $ScansTable(this);
  late final $PickingSessionsTable pickingSessions =
      $PickingSessionsTable(this);
  late final $PickingItemsTable pickingItems = $PickingItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [users, importBatches, barcodes, scans, pickingSessions, pickingItems];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  required String username,
  required String passwordHash,
  required String salt,
  required String fullName,
  required String role,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<String> username,
  Value<String> passwordHash,
  Value<String> salt,
  Value<String> fullName,
  Value<String> role,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, UserRow> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ImportBatchesTable, List<ImportBatchRow>>
      _importBatchesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.importBatches,
              aliasName:
                  $_aliasNameGenerator(db.users.id, db.importBatches.userId));

  $$ImportBatchesTableProcessedTableManager get importBatchesRefs {
    final manager = $$ImportBatchesTableTableManager($_db, $_db.importBatches)
        .filter((f) => f.userId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_importBatchesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ScansTable, List<ScanRow>> _scansRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.scans,
          aliasName: $_aliasNameGenerator(db.users.id, db.scans.userId));

  $$ScansTableProcessedTableManager get scansRefs {
    final manager = $$ScansTableTableManager($_db, $_db.scans)
        .filter((f) => f.userId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_scansRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PickingSessionsTable, List<PickingSessionRow>>
      _pickingSessionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.pickingSessions,
              aliasName:
                  $_aliasNameGenerator(db.users.id, db.pickingSessions.userId));

  $$PickingSessionsTableProcessedTableManager get pickingSessionsRefs {
    final manager =
        $$PickingSessionsTableTableManager($_db, $_db.pickingSessions)
            .filter((f) => f.userId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_pickingSessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> importBatchesRefs(
      Expression<bool> Function($$ImportBatchesTableFilterComposer f) f) {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.importBatches,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImportBatchesTableFilterComposer(
              $db: $db,
              $table: $db.importBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> scansRefs(
      Expression<bool> Function($$ScansTableFilterComposer f) f) {
    final $$ScansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.scans,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScansTableFilterComposer(
              $db: $db,
              $table: $db.scans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pickingSessionsRefs(
      Expression<bool> Function($$PickingSessionsTableFilterComposer f) f) {
    final $$PickingSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pickingSessions,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PickingSessionsTableFilterComposer(
              $db: $db,
              $table: $db.pickingSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => column);

  GeneratedColumn<String> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> importBatchesRefs<T extends Object>(
      Expression<T> Function($$ImportBatchesTableAnnotationComposer a) f) {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.importBatches,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImportBatchesTableAnnotationComposer(
              $db: $db,
              $table: $db.importBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> scansRefs<T extends Object>(
      Expression<T> Function($$ScansTableAnnotationComposer a) f) {
    final $$ScansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.scans,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScansTableAnnotationComposer(
              $db: $db,
              $table: $db.scans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pickingSessionsRefs<T extends Object>(
      Expression<T> Function($$PickingSessionsTableAnnotationComposer a) f) {
    final $$PickingSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pickingSessions,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PickingSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.pickingSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    UserRow,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserRow, $$UsersTableReferences),
    UserRow,
    PrefetchHooks Function(
        {bool importBatchesRefs, bool scansRefs, bool pickingSessionsRefs})> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> passwordHash = const Value.absent(),
            Value<String> salt = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            username: username,
            passwordHash: passwordHash,
            salt: salt,
            fullName: fullName,
            role: role,
            isActive: isActive,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String username,
            required String passwordHash,
            required String salt,
            required String fullName,
            required String role,
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            username: username,
            passwordHash: passwordHash,
            salt: salt,
            fullName: fullName,
            role: role,
            isActive: isActive,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {importBatchesRefs = false,
              scansRefs = false,
              pickingSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (importBatchesRefs) db.importBatches,
                if (scansRefs) db.scans,
                if (pickingSessionsRefs) db.pickingSessions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (importBatchesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._importBatchesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .importBatchesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (scansRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._scansRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).scansRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (pickingSessionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$UsersTableReferences
                            ._pickingSessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .pickingSessionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    UserRow,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserRow, $$UsersTableReferences),
    UserRow,
    PrefetchHooks Function(
        {bool importBatchesRefs, bool scansRefs, bool pickingSessionsRefs})>;
typedef $$ImportBatchesTableCreateCompanionBuilder = ImportBatchesCompanion
    Function({
  Value<int> id,
  required int userId,
  required String fileName,
  Value<int> totalRecords,
  Value<bool> replaced,
  Value<DateTime> importedAt,
});
typedef $$ImportBatchesTableUpdateCompanionBuilder = ImportBatchesCompanion
    Function({
  Value<int> id,
  Value<int> userId,
  Value<String> fileName,
  Value<int> totalRecords,
  Value<bool> replaced,
  Value<DateTime> importedAt,
});

final class $$ImportBatchesTableReferences
    extends BaseReferences<_$AppDatabase, $ImportBatchesTable, ImportBatchRow> {
  $$ImportBatchesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.importBatches.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id($_item.userId));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$BarcodesTable, List<BarcodeRow>>
      _barcodesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.barcodes,
              aliasName: $_aliasNameGenerator(
                  db.importBatches.id, db.barcodes.importedBatch));

  $$BarcodesTableProcessedTableManager get barcodesRefs {
    final manager = $$BarcodesTableTableManager($_db, $_db.barcodes)
        .filter((f) => f.importedBatch.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_barcodesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ImportBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalRecords => $composableBuilder(
      column: $table.totalRecords, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get replaced => $composableBuilder(
      column: $table.replaced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> barcodesRefs(
      Expression<bool> Function($$BarcodesTableFilterComposer f) f) {
    final $$BarcodesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.barcodes,
        getReferencedColumn: (t) => t.importedBatch,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarcodesTableFilterComposer(
              $db: $db,
              $table: $db.barcodes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ImportBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalRecords => $composableBuilder(
      column: $table.totalRecords,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get replaced => $composableBuilder(
      column: $table.replaced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ImportBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get totalRecords => $composableBuilder(
      column: $table.totalRecords, builder: (column) => column);

  GeneratedColumn<bool> get replaced =>
      $composableBuilder(column: $table.replaced, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> barcodesRefs<T extends Object>(
      Expression<T> Function($$BarcodesTableAnnotationComposer a) f) {
    final $$BarcodesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.barcodes,
        getReferencedColumn: (t) => t.importedBatch,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarcodesTableAnnotationComposer(
              $db: $db,
              $table: $db.barcodes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ImportBatchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ImportBatchesTable,
    ImportBatchRow,
    $$ImportBatchesTableFilterComposer,
    $$ImportBatchesTableOrderingComposer,
    $$ImportBatchesTableAnnotationComposer,
    $$ImportBatchesTableCreateCompanionBuilder,
    $$ImportBatchesTableUpdateCompanionBuilder,
    (ImportBatchRow, $$ImportBatchesTableReferences),
    ImportBatchRow,
    PrefetchHooks Function({bool userId, bool barcodesRefs})> {
  $$ImportBatchesTableTableManager(_$AppDatabase db, $ImportBatchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> fileName = const Value.absent(),
            Value<int> totalRecords = const Value.absent(),
            Value<bool> replaced = const Value.absent(),
            Value<DateTime> importedAt = const Value.absent(),
          }) =>
              ImportBatchesCompanion(
            id: id,
            userId: userId,
            fileName: fileName,
            totalRecords: totalRecords,
            replaced: replaced,
            importedAt: importedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required String fileName,
            Value<int> totalRecords = const Value.absent(),
            Value<bool> replaced = const Value.absent(),
            Value<DateTime> importedAt = const Value.absent(),
          }) =>
              ImportBatchesCompanion.insert(
            id: id,
            userId: userId,
            fileName: fileName,
            totalRecords: totalRecords,
            replaced: replaced,
            importedAt: importedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ImportBatchesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false, barcodesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (barcodesRefs) db.barcodes],
              addJoins: <
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
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$ImportBatchesTableReferences._userIdTable(db),
                    referencedColumn:
                        $$ImportBatchesTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (barcodesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ImportBatchesTableReferences
                            ._barcodesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ImportBatchesTableReferences(db, table, p0)
                                .barcodesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.importedBatch == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ImportBatchesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ImportBatchesTable,
    ImportBatchRow,
    $$ImportBatchesTableFilterComposer,
    $$ImportBatchesTableOrderingComposer,
    $$ImportBatchesTableAnnotationComposer,
    $$ImportBatchesTableCreateCompanionBuilder,
    $$ImportBatchesTableUpdateCompanionBuilder,
    (ImportBatchRow, $$ImportBatchesTableReferences),
    ImportBatchRow,
    PrefetchHooks Function({bool userId, bool barcodesRefs})>;
typedef $$BarcodesTableCreateCompanionBuilder = BarcodesCompanion Function({
  Value<int> id,
  required String code,
  Value<String?> productName,
  Value<String?> productCode,
  Value<String?> category,
  Value<String?> size,
  Value<String?> color,
  Value<int?> importedBatch,
  Value<DateTime> createdAt,
});
typedef $$BarcodesTableUpdateCompanionBuilder = BarcodesCompanion Function({
  Value<int> id,
  Value<String> code,
  Value<String?> productName,
  Value<String?> productCode,
  Value<String?> category,
  Value<String?> size,
  Value<String?> color,
  Value<int?> importedBatch,
  Value<DateTime> createdAt,
});

final class $$BarcodesTableReferences
    extends BaseReferences<_$AppDatabase, $BarcodesTable, BarcodeRow> {
  $$BarcodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ImportBatchesTable _importedBatchTable(_$AppDatabase db) =>
      db.importBatches.createAlias(
          $_aliasNameGenerator(db.barcodes.importedBatch, db.importBatches.id));

  $$ImportBatchesTableProcessedTableManager? get importedBatch {
    if ($_item.importedBatch == null) return null;
    final manager = $$ImportBatchesTableTableManager($_db, $_db.importBatches)
        .filter((f) => f.id($_item.importedBatch!));
    final item = $_typedResult.readTableOrNull(_importedBatchTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BarcodesTableFilterComposer
    extends Composer<_$AppDatabase, $BarcodesTable> {
  $$BarcodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productCode => $composableBuilder(
      column: $table.productCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ImportBatchesTableFilterComposer get importedBatch {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.importedBatch,
        referencedTable: $db.importBatches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImportBatchesTableFilterComposer(
              $db: $db,
              $table: $db.importBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BarcodesTableOrderingComposer
    extends Composer<_$AppDatabase, $BarcodesTable> {
  $$BarcodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productCode => $composableBuilder(
      column: $table.productCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ImportBatchesTableOrderingComposer get importedBatch {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.importedBatch,
        referencedTable: $db.importBatches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImportBatchesTableOrderingComposer(
              $db: $db,
              $table: $db.importBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BarcodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BarcodesTable> {
  $$BarcodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get productCode => $composableBuilder(
      column: $table.productCode, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ImportBatchesTableAnnotationComposer get importedBatch {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.importedBatch,
        referencedTable: $db.importBatches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImportBatchesTableAnnotationComposer(
              $db: $db,
              $table: $db.importBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BarcodesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BarcodesTable,
    BarcodeRow,
    $$BarcodesTableFilterComposer,
    $$BarcodesTableOrderingComposer,
    $$BarcodesTableAnnotationComposer,
    $$BarcodesTableCreateCompanionBuilder,
    $$BarcodesTableUpdateCompanionBuilder,
    (BarcodeRow, $$BarcodesTableReferences),
    BarcodeRow,
    PrefetchHooks Function({bool importedBatch})> {
  $$BarcodesTableTableManager(_$AppDatabase db, $BarcodesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BarcodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BarcodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BarcodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String?> productName = const Value.absent(),
            Value<String?> productCode = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> size = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<int?> importedBatch = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BarcodesCompanion(
            id: id,
            code: code,
            productName: productName,
            productCode: productCode,
            category: category,
            size: size,
            color: color,
            importedBatch: importedBatch,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String code,
            Value<String?> productName = const Value.absent(),
            Value<String?> productCode = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> size = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<int?> importedBatch = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BarcodesCompanion.insert(
            id: id,
            code: code,
            productName: productName,
            productCode: productCode,
            category: category,
            size: size,
            color: color,
            importedBatch: importedBatch,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BarcodesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({importedBatch = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (importedBatch) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.importedBatch,
                    referencedTable:
                        $$BarcodesTableReferences._importedBatchTable(db),
                    referencedColumn:
                        $$BarcodesTableReferences._importedBatchTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BarcodesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BarcodesTable,
    BarcodeRow,
    $$BarcodesTableFilterComposer,
    $$BarcodesTableOrderingComposer,
    $$BarcodesTableAnnotationComposer,
    $$BarcodesTableCreateCompanionBuilder,
    $$BarcodesTableUpdateCompanionBuilder,
    (BarcodeRow, $$BarcodesTableReferences),
    BarcodeRow,
    PrefetchHooks Function({bool importedBatch})>;
typedef $$ScansTableCreateCompanionBuilder = ScansCompanion Function({
  Value<int> id,
  required int userId,
  required String barcode,
  required String status,
  Value<DateTime> scannedAt,
  required String dateOnly,
  required String timeOnly,
  Value<String?> deviceInfo,
});
typedef $$ScansTableUpdateCompanionBuilder = ScansCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<String> barcode,
  Value<String> status,
  Value<DateTime> scannedAt,
  Value<String> dateOnly,
  Value<String> timeOnly,
  Value<String?> deviceInfo,
});

final class $$ScansTableReferences
    extends BaseReferences<_$AppDatabase, $ScansTable, ScanRow> {
  $$ScansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias($_aliasNameGenerator(db.scans.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id($_item.userId));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ScansTableFilterComposer extends Composer<_$AppDatabase, $ScansTable> {
  $$ScansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scannedAt => $composableBuilder(
      column: $table.scannedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateOnly => $composableBuilder(
      column: $table.dateOnly, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeOnly => $composableBuilder(
      column: $table.timeOnly, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceInfo => $composableBuilder(
      column: $table.deviceInfo, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScansTableOrderingComposer
    extends Composer<_$AppDatabase, $ScansTable> {
  $$ScansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scannedAt => $composableBuilder(
      column: $table.scannedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateOnly => $composableBuilder(
      column: $table.dateOnly, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeOnly => $composableBuilder(
      column: $table.timeOnly, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceInfo => $composableBuilder(
      column: $table.deviceInfo, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScansTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScansTable> {
  $$ScansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get scannedAt =>
      $composableBuilder(column: $table.scannedAt, builder: (column) => column);

  GeneratedColumn<String> get dateOnly =>
      $composableBuilder(column: $table.dateOnly, builder: (column) => column);

  GeneratedColumn<String> get timeOnly =>
      $composableBuilder(column: $table.timeOnly, builder: (column) => column);

  GeneratedColumn<String> get deviceInfo => $composableBuilder(
      column: $table.deviceInfo, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScansTable,
    ScanRow,
    $$ScansTableFilterComposer,
    $$ScansTableOrderingComposer,
    $$ScansTableAnnotationComposer,
    $$ScansTableCreateCompanionBuilder,
    $$ScansTableUpdateCompanionBuilder,
    (ScanRow, $$ScansTableReferences),
    ScanRow,
    PrefetchHooks Function({bool userId})> {
  $$ScansTableTableManager(_$AppDatabase db, $ScansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> barcode = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> scannedAt = const Value.absent(),
            Value<String> dateOnly = const Value.absent(),
            Value<String> timeOnly = const Value.absent(),
            Value<String?> deviceInfo = const Value.absent(),
          }) =>
              ScansCompanion(
            id: id,
            userId: userId,
            barcode: barcode,
            status: status,
            scannedAt: scannedAt,
            dateOnly: dateOnly,
            timeOnly: timeOnly,
            deviceInfo: deviceInfo,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required String barcode,
            required String status,
            Value<DateTime> scannedAt = const Value.absent(),
            required String dateOnly,
            required String timeOnly,
            Value<String?> deviceInfo = const Value.absent(),
          }) =>
              ScansCompanion.insert(
            id: id,
            userId: userId,
            barcode: barcode,
            status: status,
            scannedAt: scannedAt,
            dateOnly: dateOnly,
            timeOnly: timeOnly,
            deviceInfo: deviceInfo,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ScansTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable: $$ScansTableReferences._userIdTable(db),
                    referencedColumn:
                        $$ScansTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ScansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScansTable,
    ScanRow,
    $$ScansTableFilterComposer,
    $$ScansTableOrderingComposer,
    $$ScansTableAnnotationComposer,
    $$ScansTableCreateCompanionBuilder,
    $$ScansTableUpdateCompanionBuilder,
    (ScanRow, $$ScansTableReferences),
    ScanRow,
    PrefetchHooks Function({bool userId})>;
typedef $$PickingSessionsTableCreateCompanionBuilder = PickingSessionsCompanion
    Function({
  Value<int> id,
  required int userId,
  required String name,
  required String sourceFile,
  Value<int> totalItems,
  Value<int> pickedCount,
  Value<int> skippedCount,
  Value<String> status,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
});
typedef $$PickingSessionsTableUpdateCompanionBuilder = PickingSessionsCompanion
    Function({
  Value<int> id,
  Value<int> userId,
  Value<String> name,
  Value<String> sourceFile,
  Value<int> totalItems,
  Value<int> pickedCount,
  Value<int> skippedCount,
  Value<String> status,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
});

final class $$PickingSessionsTableReferences extends BaseReferences<
    _$AppDatabase, $PickingSessionsTable, PickingSessionRow> {
  $$PickingSessionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
      $_aliasNameGenerator(db.pickingSessions.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id($_item.userId));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PickingItemsTable, List<PickingItemRow>>
      _pickingItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.pickingItems,
              aliasName: $_aliasNameGenerator(
                  db.pickingSessions.id, db.pickingItems.sessionId));

  $$PickingItemsTableProcessedTableManager get pickingItemsRefs {
    final manager = $$PickingItemsTableTableManager($_db, $_db.pickingItems)
        .filter((f) => f.sessionId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_pickingItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PickingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PickingSessionsTable> {
  $$PickingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceFile => $composableBuilder(
      column: $table.sourceFile, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalItems => $composableBuilder(
      column: $table.totalItems, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pickedCount => $composableBuilder(
      column: $table.pickedCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get skippedCount => $composableBuilder(
      column: $table.skippedCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> pickingItemsRefs(
      Expression<bool> Function($$PickingItemsTableFilterComposer f) f) {
    final $$PickingItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pickingItems,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PickingItemsTableFilterComposer(
              $db: $db,
              $table: $db.pickingItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PickingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PickingSessionsTable> {
  $$PickingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceFile => $composableBuilder(
      column: $table.sourceFile, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalItems => $composableBuilder(
      column: $table.totalItems, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pickedCount => $composableBuilder(
      column: $table.pickedCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get skippedCount => $composableBuilder(
      column: $table.skippedCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PickingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PickingSessionsTable> {
  $$PickingSessionsTableAnnotationComposer({
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

  GeneratedColumn<String> get sourceFile => $composableBuilder(
      column: $table.sourceFile, builder: (column) => column);

  GeneratedColumn<int> get totalItems => $composableBuilder(
      column: $table.totalItems, builder: (column) => column);

  GeneratedColumn<int> get pickedCount => $composableBuilder(
      column: $table.pickedCount, builder: (column) => column);

  GeneratedColumn<int> get skippedCount => $composableBuilder(
      column: $table.skippedCount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> pickingItemsRefs<T extends Object>(
      Expression<T> Function($$PickingItemsTableAnnotationComposer a) f) {
    final $$PickingItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pickingItems,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PickingItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.pickingItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PickingSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PickingSessionsTable,
    PickingSessionRow,
    $$PickingSessionsTableFilterComposer,
    $$PickingSessionsTableOrderingComposer,
    $$PickingSessionsTableAnnotationComposer,
    $$PickingSessionsTableCreateCompanionBuilder,
    $$PickingSessionsTableUpdateCompanionBuilder,
    (PickingSessionRow, $$PickingSessionsTableReferences),
    PickingSessionRow,
    PrefetchHooks Function({bool userId, bool pickingItemsRefs})> {
  $$PickingSessionsTableTableManager(
      _$AppDatabase db, $PickingSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PickingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PickingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PickingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> sourceFile = const Value.absent(),
            Value<int> totalItems = const Value.absent(),
            Value<int> pickedCount = const Value.absent(),
            Value<int> skippedCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
          }) =>
              PickingSessionsCompanion(
            id: id,
            userId: userId,
            name: name,
            sourceFile: sourceFile,
            totalItems: totalItems,
            pickedCount: pickedCount,
            skippedCount: skippedCount,
            status: status,
            startedAt: startedAt,
            completedAt: completedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required String name,
            required String sourceFile,
            Value<int> totalItems = const Value.absent(),
            Value<int> pickedCount = const Value.absent(),
            Value<int> skippedCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
          }) =>
              PickingSessionsCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            sourceFile: sourceFile,
            totalItems: totalItems,
            pickedCount: pickedCount,
            skippedCount: skippedCount,
            status: status,
            startedAt: startedAt,
            completedAt: completedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PickingSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false, pickingItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (pickingItemsRefs) db.pickingItems],
              addJoins: <
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
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$PickingSessionsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$PickingSessionsTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pickingItemsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$PickingSessionsTableReferences
                            ._pickingItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PickingSessionsTableReferences(db, table, p0)
                                .pickingItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PickingSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PickingSessionsTable,
    PickingSessionRow,
    $$PickingSessionsTableFilterComposer,
    $$PickingSessionsTableOrderingComposer,
    $$PickingSessionsTableAnnotationComposer,
    $$PickingSessionsTableCreateCompanionBuilder,
    $$PickingSessionsTableUpdateCompanionBuilder,
    (PickingSessionRow, $$PickingSessionsTableReferences),
    PickingSessionRow,
    PrefetchHooks Function({bool userId, bool pickingItemsRefs})>;
typedef $$PickingItemsTableCreateCompanionBuilder = PickingItemsCompanion
    Function({
  Value<int> id,
  required int sessionId,
  required String locationWarehouse,
  Value<String?> locationHall,
  Value<String?> color,
  Value<String?> productCode,
  Value<String?> productName,
  Value<int> quantity,
  Value<String?> gender,
  Value<String?> design,
  Value<String?> size,
  required String barcode,
  Value<int> sortOrder,
  Value<String> status,
  Value<String?> scannedBarcode,
  Value<DateTime?> pickedAt,
  Value<DateTime> createdAt,
});
typedef $$PickingItemsTableUpdateCompanionBuilder = PickingItemsCompanion
    Function({
  Value<int> id,
  Value<int> sessionId,
  Value<String> locationWarehouse,
  Value<String?> locationHall,
  Value<String?> color,
  Value<String?> productCode,
  Value<String?> productName,
  Value<int> quantity,
  Value<String?> gender,
  Value<String?> design,
  Value<String?> size,
  Value<String> barcode,
  Value<int> sortOrder,
  Value<String> status,
  Value<String?> scannedBarcode,
  Value<DateTime?> pickedAt,
  Value<DateTime> createdAt,
});

final class $$PickingItemsTableReferences
    extends BaseReferences<_$AppDatabase, $PickingItemsTable, PickingItemRow> {
  $$PickingItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PickingSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.pickingSessions.createAlias($_aliasNameGenerator(
          db.pickingItems.sessionId, db.pickingSessions.id));

  $$PickingSessionsTableProcessedTableManager get sessionId {
    final manager =
        $$PickingSessionsTableTableManager($_db, $_db.pickingSessions)
            .filter((f) => f.id($_item.sessionId));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PickingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PickingItemsTable> {
  $$PickingItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationWarehouse => $composableBuilder(
      column: $table.locationWarehouse,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationHall => $composableBuilder(
      column: $table.locationHall, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productCode => $composableBuilder(
      column: $table.productCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get design => $composableBuilder(
      column: $table.design, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scannedBarcode => $composableBuilder(
      column: $table.scannedBarcode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get pickedAt => $composableBuilder(
      column: $table.pickedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$PickingSessionsTableFilterComposer get sessionId {
    final $$PickingSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.pickingSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PickingSessionsTableFilterComposer(
              $db: $db,
              $table: $db.pickingSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PickingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PickingItemsTable> {
  $$PickingItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationWarehouse => $composableBuilder(
      column: $table.locationWarehouse,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationHall => $composableBuilder(
      column: $table.locationHall,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productCode => $composableBuilder(
      column: $table.productCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get design => $composableBuilder(
      column: $table.design, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scannedBarcode => $composableBuilder(
      column: $table.scannedBarcode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get pickedAt => $composableBuilder(
      column: $table.pickedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$PickingSessionsTableOrderingComposer get sessionId {
    final $$PickingSessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.pickingSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PickingSessionsTableOrderingComposer(
              $db: $db,
              $table: $db.pickingSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PickingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PickingItemsTable> {
  $$PickingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get locationWarehouse => $composableBuilder(
      column: $table.locationWarehouse, builder: (column) => column);

  GeneratedColumn<String> get locationHall => $composableBuilder(
      column: $table.locationHall, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get productCode => $composableBuilder(
      column: $table.productCode, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get design =>
      $composableBuilder(column: $table.design, builder: (column) => column);

  GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get scannedBarcode => $composableBuilder(
      column: $table.scannedBarcode, builder: (column) => column);

  GeneratedColumn<DateTime> get pickedAt =>
      $composableBuilder(column: $table.pickedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PickingSessionsTableAnnotationComposer get sessionId {
    final $$PickingSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.pickingSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PickingSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.pickingSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PickingItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PickingItemsTable,
    PickingItemRow,
    $$PickingItemsTableFilterComposer,
    $$PickingItemsTableOrderingComposer,
    $$PickingItemsTableAnnotationComposer,
    $$PickingItemsTableCreateCompanionBuilder,
    $$PickingItemsTableUpdateCompanionBuilder,
    (PickingItemRow, $$PickingItemsTableReferences),
    PickingItemRow,
    PrefetchHooks Function({bool sessionId})> {
  $$PickingItemsTableTableManager(_$AppDatabase db, $PickingItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PickingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PickingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PickingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<String> locationWarehouse = const Value.absent(),
            Value<String?> locationHall = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> productCode = const Value.absent(),
            Value<String?> productName = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<String?> design = const Value.absent(),
            Value<String?> size = const Value.absent(),
            Value<String> barcode = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> scannedBarcode = const Value.absent(),
            Value<DateTime?> pickedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PickingItemsCompanion(
            id: id,
            sessionId: sessionId,
            locationWarehouse: locationWarehouse,
            locationHall: locationHall,
            color: color,
            productCode: productCode,
            productName: productName,
            quantity: quantity,
            gender: gender,
            design: design,
            size: size,
            barcode: barcode,
            sortOrder: sortOrder,
            status: status,
            scannedBarcode: scannedBarcode,
            pickedAt: pickedAt,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionId,
            required String locationWarehouse,
            Value<String?> locationHall = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> productCode = const Value.absent(),
            Value<String?> productName = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<String?> design = const Value.absent(),
            Value<String?> size = const Value.absent(),
            required String barcode,
            Value<int> sortOrder = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> scannedBarcode = const Value.absent(),
            Value<DateTime?> pickedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PickingItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            locationWarehouse: locationWarehouse,
            locationHall: locationHall,
            color: color,
            productCode: productCode,
            productName: productName,
            quantity: quantity,
            gender: gender,
            design: design,
            size: size,
            barcode: barcode,
            sortOrder: sortOrder,
            status: status,
            scannedBarcode: scannedBarcode,
            pickedAt: pickedAt,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PickingItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$PickingItemsTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$PickingItemsTableReferences._sessionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PickingItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PickingItemsTable,
    PickingItemRow,
    $$PickingItemsTableFilterComposer,
    $$PickingItemsTableOrderingComposer,
    $$PickingItemsTableAnnotationComposer,
    $$PickingItemsTableCreateCompanionBuilder,
    $$PickingItemsTableUpdateCompanionBuilder,
    (PickingItemRow, $$PickingItemsTableReferences),
    PickingItemRow,
    PrefetchHooks Function({bool sessionId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db, _db.importBatches);
  $$BarcodesTableTableManager get barcodes =>
      $$BarcodesTableTableManager(_db, _db.barcodes);
  $$ScansTableTableManager get scans =>
      $$ScansTableTableManager(_db, _db.scans);
  $$PickingSessionsTableTableManager get pickingSessions =>
      $$PickingSessionsTableTableManager(_db, _db.pickingSessions);
  $$PickingItemsTableTableManager get pickingItems =>
      $$PickingItemsTableTableManager(_db, _db.pickingItems);
}
