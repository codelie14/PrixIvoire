import 'package:hive/hive.dart';
import '../models/price_alert.dart';

class PriceAlertAdapter extends TypeAdapter<PriceAlert> {
  @override
  final int typeId = 1;

  @override
  PriceAlert read(BinaryReader reader) {
    final productName = reader.readString();
    final threshold = reader.readDouble();
    final isAbove = reader.readBool();

    return PriceAlert(
      productName: productName,
      threshold: threshold,
      isAbove: isAbove,
    );
  }

  @override
  void write(BinaryWriter writer, PriceAlert obj) {
    writer.writeString(obj.productName);
    writer.writeDouble(obj.threshold);
    writer.writeBool(obj.isAbove);
  }
}
