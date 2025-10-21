// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 5;

  @override
  Budget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Budget(
      id: fields[0] as String,
      totalAmount: fields[1] as double,
      categoryBudgets: (fields[2] as Map).cast<String, double>(),
      month: fields[3] as DateTime,
      budgetType: fields[4] as BudgetType?,
      startDate: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.totalAmount)
      ..writeByte(2)
      ..write(obj.categoryBudgets)
      ..writeByte(3)
      ..write(obj.month)
      ..writeByte(4)
      ..write(obj.budgetType)
      ..writeByte(5)
      ..write(obj.startDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BudgetTypeAdapter extends TypeAdapter<BudgetType> {
  @override
  final int typeId = 6;

  @override
  BudgetType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BudgetType.monthly;
      case 1:
        return BudgetType.yearly;
      default:
        return BudgetType.monthly;
    }
  }

  @override
  void write(BinaryWriter writer, BudgetType obj) {
    switch (obj) {
      case BudgetType.monthly:
        writer.writeByte(0);
        break;
      case BudgetType.yearly:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
