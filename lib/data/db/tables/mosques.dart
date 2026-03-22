import 'package:drift/drift.dart';

class Mosques extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get area => text().nullable()();

  RealColumn get latitude => real().nullable()();

  RealColumn get longitude => real().nullable()();

  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  TextColumn get notes => text().nullable()();

  TextColumn get createdAt => text()();

  TextColumn get updatedAt => text()();
}
