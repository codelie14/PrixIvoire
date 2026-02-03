import 'package:hive/hive.dart';
import '../models/product_price.dart';

class ProductPriceAdapter extends TypeAdapter<ProductPrice> {
  @override
  final int typeId = 0;

  @override
  ProductPrice read(BinaryReader reader) {
    final productName = reader.readString();
    final price = reader.readDouble();
    final shop = reader.readString();
    final dateMilliseconds = reader.readInt();
    final date = DateTime.fromMillisecondsSinceEpoch(dateMilliseconds);

    return ProductPrice(
      productName: productName,
      price: price,
      shop: shop,
      date: date,
    );
  }

  @override
  void write(BinaryWriter writer, ProductPrice obj) {
    writer.writeString(obj.productName);
    writer.writeDouble(obj.price);
    writer.writeString(obj.shop);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
  }
}
