import 'package:hive/hive.dart';
import '../models/product_price.dart';

class ProductPriceAdapter extends TypeAdapter<ProductPrice> {
  @override
  final int typeId = 0;

  @override
  ProductPrice read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };

    return ProductPrice(
      productName: fields[0] as String? ?? '',
      price: fields[1] as double? ?? 0.0,
      shop: fields[2] as String? ?? '',
      date: fields[3] != null
          ? DateTime.fromMillisecondsSinceEpoch(fields[3] as int)
          : DateTime.now(),
      categoryId: fields[4] as String?,
      isFavorite: fields[5] as bool? ?? false,
      notes: fields[6] as String?,
      imageUrl: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductPrice obj) {
    writer
      ..writeByte(8) // Nombre de champs
      ..writeByte(0)
      ..write(obj.productName)
      ..writeByte(1)
      ..write(obj.price)
      ..writeByte(2)
      ..write(obj.shop)
      ..writeByte(3)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.isFavorite)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.imageUrl);
  }
}
