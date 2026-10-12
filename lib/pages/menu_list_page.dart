import 'package:flutter/material.dart';

// =====================================================================
// BAGIAN 1 — DATA, MODEL, DAN STATE KERANJANG
// Dipakai bersama oleh menu_list_page, menu_detail_page, dan order_page.
// Semua data bersifat lokal (tanpa backend) sesuai ketentuan tugas.
// =====================================================================

/// Warna latar halaman (krem hangat) agar kartu putih terlihat menonjol.
const Color kPageBackground = Color(0xFFFFF8F3);

/// Mengubah angka menjadi format Rupiah. Contoh: 12500 -> "Rp 12.500".
String formatRupiah(int value) {
  final digits = value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (match) => '${match[1]}.',
      );
  return 'Rp $digits';
}

/// Tambahan (topping/lauk) yang bisa dipilih pada sebuah menu.
class AddOn {
  final String name;
  final int price;

  const AddOn(this.name, this.price);
}

/// Data satu menu makanan/minuman.
class MenuModel {
  final int id;
  final String name;
  final String description;
  final String category; // 'Makanan' | 'Minuman' | 'Snack'
  final int price;
  final double rating;
  final int sold;
  final String prepTime;
  final String emoji; // emoji makanan sebagai pengganti foto
  final MaterialColor color; // warna tema kartu menu
  final String variantTitle; // judul opsi, mis. "Level Pedas"
  final List<String> variants; // pilihan opsi, mis. Sedang / Pedas
  final List<AddOn> addOns;

  const MenuModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.sold,
    required this.prepTime,
    required this.emoji,
    required this.color,
    required this.variantTitle,
    required this.variants,
    required this.addOns,
  });
}

/// Daftar kategori untuk filter di halaman menu.
const List<String> kCategories = ['Semua', 'Makanan', 'Minuman', 'Snack'];

/// Data menu Kantin Bu Sari (dummy lokal).
const List<MenuModel> kMenuItems = [
  // ---------------------------- MAKANAN ----------------------------
  MenuModel(
    id: 1,
    name: 'Nasi Goreng Spesial',
    description:
        'Nasi goreng bumbu rempah dengan ayam suwir, acar segar, dan kerupuk renyah.',
    category: 'Makanan',
    price: 18000,
    rating: 4.8,
    sold: 320,
    prepTime: '10 mnt',
    emoji: '🍚',
    color: Colors.orange,
    variantTitle: 'Level Pedas',
    variants: ['Tidak Pedas', 'Sedang', 'Pedas'],
    addOns: [
      AddOn('Telur Mata Sapi', 4000),
      AddOn('Sate Ayam (2 tusuk)', 8000),
      AddOn('Kerupuk Tambahan', 2000),
    ],
  ),
  MenuModel(
    id: 2,
    name: 'Ayam Geprek Sambal Bawang',
    description:
        'Ayam crispy digeprek dengan sambal bawang segar, disajikan bersama nasi hangat dan lalapan.',
    category: 'Makanan',
    price: 16000,
    rating: 4.7,
    sold: 280,
    prepTime: '12 mnt',
    emoji: '🍗',
    color: Colors.red,
    variantTitle: 'Level Pedas',
    variants: ['Sedang', 'Pedas', 'Extra Pedas'],
    addOns: [
      AddOn('Keju Mozzarella', 5000),
      AddOn('Telur Dadar', 4000),
      AddOn('Tahu & Tempe Goreng', 3000),
    ],
  ),
  MenuModel(
    id: 3,
    name: 'Soto Ayam Lamongan',
    description:
        'Soto kuah kuning gurih dengan suwiran ayam, tauge, seledri, dan taburan koya.',
    category: 'Makanan',
    price: 15000,
    rating: 4.6,
    sold: 210,
    prepTime: '8 mnt',
    emoji: '🍲',
    color: Colors.amber,
    variantTitle: 'Pilihan Nasi',
    variants: ['Nasi Putih', 'Lontong', 'Tanpa Nasi'],
    addOns: [
      AddOn('Telur Rebus', 3000),
      AddOn('Perkedel Kentang', 3000),
      AddOn('Koya Tambahan', 2000),
    ],
  ),
  MenuModel(
    id: 4,
    name: 'Mie Ayam Bakso',
    description:
        'Mie kenyal dengan topping ayam kecap, bakso sapi, sawi hijau, dan pangsit goreng.',
    category: 'Makanan',
    price: 14000,
    rating: 4.7,
    sold: 265,
    prepTime: '9 mnt',
    emoji: '🍜',
    color: Colors.deepOrange,
    variantTitle: 'Pilihan Sambal',
    variants: ['Tanpa Sambal', 'Sambal Sedikit', 'Sambal Banyak'],
    addOns: [
      AddOn('Bakso Tambahan (3 pcs)', 5000),
      AddOn('Pangsit Goreng', 4000),
      AddOn('Ceker Ayam', 4000),
    ],
  ),
  MenuModel(
    id: 5,
    name: 'Gado-Gado Betawi',
    description:
        'Sayuran rebus segar dengan lontong, tahu, tempe, telur, dan siraman bumbu kacang.',
    category: 'Makanan',
    price: 13000,
    rating: 4.5,
    sold: 150,
    prepTime: '7 mnt',
    emoji: '🥗',
    color: Colors.lightGreen,
    variantTitle: 'Level Pedas',
    variants: ['Tidak Pedas', 'Sedang', 'Pedas'],
    addOns: [
      AddOn('Lontong Tambahan', 3000),
      AddOn('Telur Rebus', 3000),
      AddOn('Kerupuk', 2000),
    ],
  ),
  // ---------------------------- MINUMAN ----------------------------
  MenuModel(
    id: 6,
    name: 'Es Teh Manis',
    description:
        'Teh melati seduh segar dengan es batu, pelepas dahaga andalan anak kampus.',
    category: 'Minuman',
    price: 5000,
    rating: 4.9,
    sold: 540,
    prepTime: '2 mnt',
    emoji: '🥤',
    color: Colors.brown,
    variantTitle: 'Tingkat Manis',
    variants: ['Normal', 'Kurang Manis', 'Tanpa Gula'],
    addOns: [
      AddOn('Irisan Lemon', 2000),
      AddOn('Nata de Coco', 3000),
    ],
  ),
  MenuModel(
    id: 7,
    name: 'Es Jeruk Peras',
    description:
        'Jeruk peras asli tanpa pengawet, segar dan sedikit asam manis.',
    category: 'Minuman',
    price: 7000,
    rating: 4.6,
    sold: 300,
    prepTime: '3 mnt',
    emoji: '🍊',
    color: Colors.orange,
    variantTitle: 'Pilihan Suhu',
    variants: ['Dingin', 'Hangat'],
    addOns: [
      AddOn('Madu', 3000),
      AddOn('Nata de Coco', 3000),
    ],
  ),
  MenuModel(
    id: 8,
    name: 'Kopi Susu Gula Aren',
    description:
        'Espresso, susu segar, dan gula aren asli. Creamy, manis pas, bikin semangat kuliah.',
    category: 'Minuman',
    price: 12000,
    rating: 4.8,
    sold: 410,
    prepTime: '4 mnt',
    emoji: '☕',
    color: Colors.brown,
    variantTitle: 'Pilihan Suhu',
    variants: ['Dingin', 'Panas'],
    addOns: [
      AddOn('Extra Shot Espresso', 4000),
      AddOn('Whipped Cream', 3000),
    ],
  ),
  MenuModel(
    id: 9,
    name: 'Jus Alpukat',
    description:
        'Alpukat mentega kental yang diblender halus, disajikan dingin dengan susu cokelat.',
    category: 'Minuman',
    price: 14000,
    rating: 4.7,
    sold: 190,
    prepTime: '5 mnt',
    emoji: '🥑',
    color: Colors.green,
    variantTitle: 'Tambahan Sirup',
    variants: ['Sirup Cokelat', 'Tanpa Sirup'],
    addOns: [
      AddOn('Susu Kental Manis', 2000),
      AddOn('Es Krim Vanilla', 5000),
    ],
  ),
  // ----------------------------- SNACK -----------------------------
  MenuModel(
    id: 10,
    name: 'Pisang Goreng Krispi',
    description:
        'Pisang kepok digoreng dengan tepung krispi, renyah di luar dan lembut di dalam.',
    category: 'Snack',
    price: 8000,
    rating: 4.6,
    sold: 230,
    prepTime: '6 mnt',
    emoji: '🍌',
    color: Colors.amber,
    variantTitle: 'Pilihan Topping',
    variants: ['Original', 'Cokelat Meses', 'Keju'],
    addOns: [
      AddOn('Susu Kental Manis', 2000),
      AddOn('Es Krim Vanilla', 5000),
    ],
  ),
  MenuModel(
    id: 11,
    name: 'Risoles Mayo',
    description:
        'Kulit risoles renyah berisi sayuran, smoked beef, dan mayones. Satu porsi isi 2 pcs.',
    category: 'Snack',
    price: 6000,
    rating: 4.4,
    sold: 180,
    prepTime: '5 mnt',
    emoji: '🥟',
    color: Colors.deepOrange,
    variantTitle: 'Pilihan Saus',
    variants: ['Saus Sambal', 'Saus Mayo', 'Tanpa Saus'],
    addOns: [
      AddOn('Tambah 1 pcs', 3000),
    ],
  ),
  MenuModel(
    id: 12,
    name: 'Roti Bakar Cokelat Keju',
    description:
        'Roti tawar tebal dipanggang dengan selai cokelat dan parutan keju melimpah.',
    category: 'Snack',
    price: 10000,
    rating: 4.7,
    sold: 205,
    prepTime: '7 mnt',
    emoji: '🍞',
    color: Colors.brown,
    variantTitle: 'Pilihan Rasa',
    variants: ['Cokelat Keju', 'Cokelat Kacang', 'Strawberry'],
    addOns: [
      AddOn('Susu Kental Manis', 2000),
      AddOn('Es Krim Vanilla', 5000),
    ],
  ),
];

/// Satu baris pesanan di keranjang (menu + opsi yang dipilih + jumlah).
class CartItem {
  final MenuModel menu;
  final String variant;
  final List<AddOn> addOns;
  final String note;
  int qty;

  CartItem({
    required this.menu,
    required this.variant,
    this.addOns = const [],
    this.note = '',
    this.qty = 1,
  });

  /// Harga satu porsi = harga menu + total harga tambahan.
  int get unitPrice =>
      menu.price + addOns.fold<int>(0, (sum, addOn) => sum + addOn.price);

  /// Harga satu baris = harga satu porsi x jumlah.
  int get lineTotal => unitPrice * qty;

  /// Ringkasan opsi, contoh: "Pedas • Telur Mata Sapi, Kerupuk Tambahan".
  String get detailText {
    final parts = <String>[variant];
    if (addOns.isNotEmpty) {
      parts.add(addOns.map((addOn) => addOn.name).join(', '));
    }
    return parts.join(' • ');
  }

  String get _addOnKey =>
      (addOns.map((addOn) => addOn.name).toList()..sort()).join('|');

  /// Dua baris dianggap sama jika menu, opsi, tambahan, dan catatannya sama
  /// (jumlahnya cukup digabung agar keranjang tidak berantakan).
  bool isSameOrder(CartItem other) {
    return menu.id == other.menu.id &&
        variant == other.variant &&
        note == other.note &&
        _addOnKey == other._addOnKey;
  }
}

/// Pengelola keranjang sederhana. Memakai ChangeNotifier sehingga halaman
/// yang memakai ListenableBuilder otomatis ter-update saat keranjang berubah.
class CartController extends ChangeNotifier {
  CartController._();

  static final CartController instance = CartController._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get totalQty => _items.fold<int>(0, (sum, item) => sum + item.qty);
  int get subtotal => _items.fold<int>(0, (sum, item) => sum + item.lineTotal);

  void add(CartItem newItem) {
    final index = _items.indexWhere((item) => item.isSameOrder(newItem));
    if (index >= 0) {
      _items[index].qty += newItem.qty;
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  void increase(CartItem item) {
    item.qty++;
    notifyListeners();
  }

  void decrease(CartItem item) {
    if (item.qty > 1) {
      item.qty--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

/// Menampilkan SnackBar "berhasil ditambahkan" lengkap dengan tombol LIHAT
/// yang membuka halaman keranjang.
void showAddedToCartSnackBar(
  ScaffoldMessengerState messenger,
  NavigatorState navigator,
  String message,
) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'LIHAT',
          textColor: Colors.orange.shade200,
          onPressed: () => navigator.pushNamed('/pesan'),
        ),
      ),
    );
}

// =====================================================================
// BAGIAN 2 — WIDGET BERSAMA (reusable)
// =====================================================================

/// Gambar menu berupa kotak gradasi + emoji makanan yang sesuai nama menu.
/// (Dipakai sebagai pengganti foto agar aplikasi tetap jalan tanpa asset.)
class MenuThumb extends StatelessWidget {
  final MenuModel menu;
  final double width;
  final double height;
  final double radius;
  final double emojiSize;

  const MenuThumb({
    super.key,
    required this.menu,
    this.width = 88,
    this.height = 88,
    this.radius = 16,
    this.emojiSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [menu.color.shade100, menu.color.shade300],
        ),
      ),
      // decoration: none -> mencegah garis bawah kuning saat animasi Hero.
      child: Text(
        menu.emoji,
        style: TextStyle(fontSize: emojiSize, decoration: TextDecoration.none),
      ),
    );
  }
}

/// Tombol jumlah (- 1 +). Jika onDecrease null, tombol minus dinonaktifkan.
class QtyStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  const QtyStepper({
    super.key,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(Icons.remove, onDecrease),
          SizedBox(
            width: 30,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          _buildButton(Icons.add, onIncrease),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? Colors.grey.shade400 : Colors.deepOrange,
        ),
      ),
    );
  }
}

/// Ikon keranjang di AppBar dengan lencana jumlah item.
class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartController.instance,
      builder: (context, _) {
        final qty = CartController.instance.totalQty;
        return IconButton(
          tooltip: 'Lihat keranjang',
          onPressed: () => Navigator.pushNamed(context, '/pesan'),
          icon: Badge(
            isLabelVisible: qty > 0,
            label: Text('$qty'),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        );
      },
    );
  }
}

// =====================================================================
// BAGIAN 3 — HALAMAN DAFTAR MENU
// =====================================================================

class MenuListPage extends StatefulWidget {
  const MenuListPage({super.key});

  @override
  State<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Menu yang tampil setelah difilter kategori + kata kunci pencarian.
  List<MenuModel> get _filteredMenus {
    final keyword = _query.trim().toLowerCase();
    return kMenuItems.where((menu) {
      final matchCategory =
          _selectedCategory == 'Semua' || menu.category == _selectedCategory;
      final matchQuery = keyword.isEmpty ||
          menu.name.toLowerCase().contains(keyword) ||
          menu.description.toLowerCase().contains(keyword);
      return matchCategory && matchQuery;
    }).toList();
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Makanan':
        return Icons.restaurant;
      case 'Minuman':
        return Icons.local_cafe;
      case 'Snack':
        return Icons.cookie;
      default:
        return Icons.apps;
    }
  }

  /// Tambah cepat (tombol +) memakai opsi default (pilihan pertama).
  void _quickAdd(MenuModel menu) {
    CartController.instance.add(
      CartItem(menu: menu, variant: menu.variants.first),
    );
    showAddedToCartSnackBar(
      ScaffoldMessenger.of(context),
      Navigator.of(context),
      '${menu.name} ditambahkan ke keranjang',
    );
  }

  @override
  Widget build(BuildContext context) {
    final menus = _filteredMenus;

    return Scaffold(
      backgroundColor: kPageBackground,

      // AppBar: judul toko + ikon keranjang dengan lencana jumlah item.
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront),
            SizedBox(width: 8),
            Text('Kantin Bu Sari'),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: const [CartIconButton(), SizedBox(width: 4)],
      ),

      // Body: seluruh konten dibungkus CustomScrollView agar aman di layar
      // kecil/keyboard, dan dibatasi lebarnya supaya rapi di Chrome.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildSearchField()),
              SliverToBoxAdapter(child: _buildCategoryChips()),
              SliverToBoxAdapter(child: _buildSectionTitle(menus.length)),
              if (menus.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildMenuCard(menus[index]),
                      childCount: menus.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      // Bar keranjang di bawah: muncul hanya jika keranjang berisi.
      bottomNavigationBar: _buildCartBar(),
    );
  }

  // ---------------------------------------------------------------
  // Banner sambutan (Container + gradasi + Row/Column)
  // ---------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF7043), Color(0xFFE64A19)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang di\nKantin Bu Sari!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.white70),
                    SizedBox(width: 6),
                    Text(
                      'Buka 07.00 – 16.00 WIB',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu,
              size: 34,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Kolom pencarian (TextField) — filter berjalan saat mengetik
  // ---------------------------------------------------------------
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Cari nasi goreng, es teh, dan lainnya...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.deepOrange, width: 1.6),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Filter kategori (ListView horizontal + ChoiceChip)
  // ---------------------------------------------------------------
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: kCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = kCategories[index];
          final selected = category == _selectedCategory;
          return ChoiceChip(
            avatar: Icon(
              _categoryIcon(category),
              size: 18,
              color: selected ? Colors.white : Colors.deepOrange,
            ),
            label: Text(category),
            selected: selected,
            showCheckmark: false,
            selectedColor: Colors.deepOrange,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected ? Colors.deepOrange : Colors.grey.shade300,
            ),
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => setState(() => _selectedCategory = category),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        children: [
          const Text(
            'Daftar Menu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            '$count menu',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Kartu menu (Card + InkWell + Row) — tap untuk membuka detail
  // ---------------------------------------------------------------
  Widget _buildMenuCard(MenuModel menu) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        // Kirim data menu ke halaman detail lewat arguments.
        onTap: () => Navigator.pushNamed(context, '/detail', arguments: menu),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero: animasi transisi gambar menu menuju halaman detail.
              Hero(tag: 'menu-${menu.id}', child: MenuThumb(menu: menu)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      menu.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.3,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          menu.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${menu.sold}+ terjual',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatRupiah(menu.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        // Tombol tambah cepat ke keranjang.
                        IconButton.filled(
                          tooltip: 'Tambah ke keranjang',
                          onPressed: () => _quickAdd(menu),
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(36, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Tampilan saat hasil pencarian kosong
  // ---------------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'Menu tidak ditemukan',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Coba kata kunci lain atau pilih kategori yang berbeda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Bar keranjang melayang di bagian bawah
  // ---------------------------------------------------------------
  Widget _buildCartBar() {
    return ListenableBuilder(
      listenable: CartController.instance,
      builder: (context, _) {
        final cart = CartController.instance;
        if (cart.isEmpty) return const SizedBox.shrink();

        return SafeArea(
          child: Align(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Material(
                  color: Colors.deepOrange,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pushNamed(context, '/pesan'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${cart.totalQty} item di keranjang',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            formatRupiah(cart.subtotal),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
