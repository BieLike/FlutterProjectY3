import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/models/book.dart';
import 'package:flutter_lect2/newuxui/models/book_category.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:flutter_lect2/newuxui/widget/book_card.dart';

// ໜ້າຫຼັກສຳລັບສະແດງສິນຄ້າ
class nHomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<nHomePage> {
  // ຂໍ້ມູນໝວດໝູ່ປຶ້ມຕົວຢ່າງ
  List<BookCategory> categories = [
    BookCategory(id: 'all', name: 'ທັງໝົດ', color: Colors.blue),
    BookCategory(id: 'fiction', name: 'ນິຍາຍ', color: Colors.red),
    BookCategory(id: 'education', name: 'ການສຶກສາ', color: Colors.green),
    BookCategory(id: 'kids', name: 'ປຶ້ມເດັກ', color: Colors.orange),
    BookCategory(id: 'history', name: 'ປະຫວັດສາດ', color: Colors.purple),
    BookCategory(id: 'cooking', name: 'ອາຫານ', color: Colors.pink),
  ];

  // ຂໍ້ມູນສິນຄ້າຕົວຢ່າງ
  List<Book> allBooks = [
    Book(
      id: '1',
      title: 'ນິທານພື້ນເມືອງລາວ',
      author: 'ໄຊຊະນະ ສຸວັນທອງ',
      price: 55000,
      stock: 10,
      imageUrl:
          'https://cms.dmpcdn.com/foreign/2024/01/01/956e6730-a876-11ee-acd5-4951a913095c_webp_original.jpg',
      categoryId: 'fiction',
    ),
    Book(
      id: '2',
      title: 'ສອນຫຼານຮັກການອ່ານ',
      author: 'ເກດສະໜາ ບຸນຍາໄລ',
      price: 45000,
      stock: 15,
      imageUrl:
          'https://m.media-amazon.com/images/I/71HSQ4xp+5L._AC_UF1000,1000_QL80_.jpg',
      categoryId: 'education',
    ),
    Book(
      id: '3',
      title: 'ວັນນະຄະດີລາວ',
      author: 'ດວງໃຈ ສຸລິຍະວົງ',
      price: 75000,
      stock: 8,
      imageUrl:
          'https://cdn.asaha.com/assets/thumbs/9b1/9b11491b9826766e8fc9d95f6fc57d69.jpg',
      categoryId: 'history',
    ),
    Book(
      id: '4',
      title: 'ພາສາລາວເບື້ອງຕົ້ນ',
      author: 'ປັນຍາ ວໍລະວົງ',
      price: 60000,
      stock: 12,
      imageUrl:
          'https://m.media-amazon.com/images/I/81m9yfJOOqL._AC_UF1000,1000_QL80_.jpg',
      categoryId: 'education',
    ),
    Book(
      id: '5',
      title: 'ສິນໄຊຊາດົດ',
      author: 'ນັກປະພັນລາວ',
      price: 80000,
      stock: 5,
      imageUrl:
          'https://i.pinimg.com/736x/ed/9a/41/ed9a41c5276caad9e108da3849bc4194.jpg',
      categoryId: 'fiction',
    ),
    Book(
      id: '6',
      title: 'ອາຫານລາວພື້ນເມືອງ',
      author: 'ສົມຈິດ ວົງໄຊ',
      price: 65000,
      stock: 10,
      imageUrl:
          'https://m.media-amazon.com/images/I/91Fq9MUfVFL._AC_UF1000,1000_QL80_.jpg',
      categoryId: 'cooking',
    ),
    Book(
      id: '7',
      title: 'ຮຽນແຕ້ມຮູບເບື້ອງຕົ້ນ',
      author: 'ສີວິໄລ ພອນມະນີ',
      price: 40000,
      stock: 20,
      imageUrl:
          'https://m.media-amazon.com/images/I/81WZ6QvPZOL._AC_UF1000,1000_QL80_.jpg',
      categoryId: 'kids',
    ),
    Book(
      id: '8',
      title: 'ປະຫວັດລາວໂບຮານ',
      author: 'ຄຳຫຼ້າ ບຸນເຊີນ',
      price: 95000,
      stock: 8,
      imageUrl:
          'https://cdn1.booknode.com/book_cover/1114/full/history-of-laos-1114421.jpg',
      categoryId: 'history',
    ),
  ];

  List<Book> displayedBooks = [];
  String selectedCategoryId = 'all';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    displayedBooks = List.from(allBooks);
  }

  void filterBooksByCategory(String categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      if (categoryId == 'all') {
        displayedBooks = allBooks
            .where((book) =>
                book.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                book.author.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      } else {
        displayedBooks = allBooks
            .where((book) =>
                book.categoryId == categoryId &&
                (book.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                    book.author
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase())))
            .toList();
      }
    });
  }

  void searchBooks(String query) {
    setState(() {
      searchQuery = query;
      if (selectedCategoryId == 'all') {
        displayedBooks = allBooks
            .where((book) =>
                book.title.toLowerCase().contains(query.toLowerCase()) ||
                book.author.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        displayedBooks = allBooks
            .where((book) =>
                book.categoryId == selectedCategoryId &&
                (book.title.toLowerCase().contains(query.toLowerCase()) ||
                    book.author.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ກຳນົດຈຳນວນຖັນຕາມຂະໜາດຂອງໜ້າຈໍ
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2; // ຄ່າພື້ນຖານສຳລັບໜ້າຈໍຂະໜາດນ້ອຍ

    // ປັບຈຳນວນຖັນຕາມຂະໜາດຂອງໜ້າຈໍ
    if (screenWidth > 600 && screenWidth <= 900) {
      crossAxisCount = 3; // ຖ້າໜ້າຈໍກາງ
    } else if (screenWidth > 900) {
      crossAxisCount = 4; // ຖ້າໜ້າຈໍໃຫຍ່
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ຫນ້າຂາຍ'),
        backgroundColor: Color(0xFFE45C58),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // ຊ່ອງຄົ້ນຫາ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: searchBooks,
              decoration: InputDecoration(
                hintText: 'ຄົ້ນຫາປຶ້ມ...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // ແຖບໝວດໝູ່
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () {
                      filterBooksByCategory(categories[index].id);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: selectedCategoryId == categories[index].id
                            ? categories[index].color
                            : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: categories[index].color,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          categories[index].name,
                          style: TextStyle(
                            color: selectedCategoryId == categories[index].id
                                ? Colors.white
                                : categories[index].color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 10),

          // ແສດງຈຳນວນປຶ້ມທີ່ພົບ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'ພົບ ${displayedBooks.length} ລາຍການ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          // ລາຍການປຶ້ມ
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: displayedBooks.length,
              itemBuilder: (context, index) {
                return BookCard(book: displayedBooks[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddBookDialog();
        },
        child: Icon(Icons.add),
        tooltip: 'ເພີ່ມປຶ້ມໃໝ່',
      ),
    );
  }

  void _showAddBookDialog() {
    final _titleController = TextEditingController();
    final _authorController = TextEditingController();
    final _priceController = TextEditingController();
    final _stockController = TextEditingController();
    final _imageUrlController = TextEditingController();

    // ແກ້ໄຂບໍ່ໃຫ້ໃຊ້ຄ່າ "all" ເປັນຄ່າເລີ່ມຕົ້ນ
    String _selectedCategoryId =
        categories.firstWhere((cat) => cat.id != 'all').id;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ເພີ່ມປຶ້ມໃໝ່'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'ຊື່ປຶ້ມ',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _authorController,
                  decoration: InputDecoration(
                    labelText: 'ຊື່ຜູ້ຂຽນ',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ລາຄາ',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ຈຳນວນໃນສະຕັອກ',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'URL ຮູບພາບ',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'ໝວດໝູ່',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategoryId,
                  items: categories
                      .where((cat) => cat.id != 'all')
                      .map((cat) => DropdownMenuItem<String>(
                            value: cat.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: cat.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(cat.name),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) _selectedCategoryId = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ຍົກເລີກ'),
            ),
            ElevatedButton(
              onPressed: () {
                // ເພີ່ມປຶ້ມໃໝ່ເຂົ້າໃນລາຍການ
                if (_titleController.text.isNotEmpty &&
                    _authorController.text.isNotEmpty &&
                    _priceController.text.isNotEmpty &&
                    _stockController.text.isNotEmpty) {
                  setState(() {
                    final newBook = Book(
                      id: (allBooks.length + 1).toString(),
                      title: _titleController.text,
                      author: _authorController.text,
                      price: double.parse(_priceController.text),
                      stock: int.parse(_stockController.text),
                      imageUrl: _imageUrlController.text.isNotEmpty
                          ? _imageUrlController.text
                          : 'https://cdn.pixabay.com/photo/2018/01/03/09/09/book-3057902_1280.png',
                      categoryId: _selectedCategoryId,
                    );

                    allBooks.add(newBook);
                    filterBooksByCategory(selectedCategoryId);
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('ບັນທຶກ'),
            ),
          ],
        );
      },
    );
  }
}
