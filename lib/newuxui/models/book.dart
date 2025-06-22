// ຄລາສສຳລັບຂໍ້ມູນປຶ້ມ
class Book {
  final String id;
  final String title;
  final String author;
  final double price;
  final int stock;
  final String imageUrl;
  final String categoryId;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.categoryId,
  });
}
