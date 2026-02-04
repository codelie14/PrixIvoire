import 'package:hive/hive.dart';
import '../models/app_settings.dart';

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 10;

  @override
  AppSettings read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };

    return AppSettings(
      themeMode: fields[0] as String? ?? 'system',
      onboardingCompleted: fields[1] as bool? ?? false,
      viewedTooltips: fields[2] != null
          ? List<String>.from(fields[2] as List)
          : [],
      defaultCurrency: fields[3] as String? ?? 'FCFA',
      maxHistoryEntries: fields[4] as int? ?? 1000,
      enableNotifications: fields[5] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(6) // Nombre de champs
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.onboardingCompleted)
      ..writeByte(2)
      ..write(obj.viewedTooltips)
      ..writeByte(3)
      ..write(obj.defaultCurrency)
      ..writeByte(4)
      ..write(obj.maxHistoryEntries)
      ..writeByte(5)
      ..write(obj.enableNotifications);
  }
}
