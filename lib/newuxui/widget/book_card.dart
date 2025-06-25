import 'package:flutter/material.dart';
import '../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ສ່ວນສະແດງຮູບພາບປຶ້ມ
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Container(
              height: 150,
              width: double.infinity,
              child: _buildBookCover(),
            ),
          ),
          _buildBookInfo(),
          Spacer(),
          _buildAddToCartButton(context),
        ],
      ),
    );
  }

  // ສ້າງສ່ວນຮູບປົກປຶ້ມ
  Widget _buildBookCover() {
    return Image.network(
      book.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (ctx, err, _) => Container(
        color: Colors.blue.shade100,
        child: Icon(Icons.book, size: 50, color: Colors.blue),
      ),
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }

  // ສ້າງສ່ວນຂໍ້ມູນປຶ້ມ
  Widget _buildBookInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            'ໂດຍ: ${book.author}',
            style: TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${book.price.toStringAsFixed(0)} ກີບ',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              Text('ເຫຼືອ: ${book.stock}',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // ສ້າງປຸ່ມເພີ່ມເຂົ້າຈອງ
  Widget _buildAddToCartButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFE45C58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
        ),
        onPressed: () => _showAddToCartDialog(context),
        child: Text('ເພີ່ມເຂົ້າຈອງ', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddToCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ເພີ່ມເຂົ້າຈອງ'),
          content: Text('ເພີ່ມ "${book.title}" ເຂົ້າໃນຈອງແລ້ວ'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ຕົກລົງ'),
            ),
          ],
        );
      },
    );
  }
}