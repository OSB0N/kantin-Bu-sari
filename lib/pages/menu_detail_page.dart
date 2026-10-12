import 'package:flutter/material.dart';

import 'menu_list_page.dart';

/// Halaman detail menu.
/// Data menu diterima lewat `Navigator.pushNamed(..., arguments: menu)`,
/// sehingga konstruktornya tetap `const MenuDetailPage()` seperti di main.dart.
class MenuDetailPage extends StatefulWidget {
  const MenuDetailPage({super.key});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  int _variantIndex = 0; // opsi utama yang dipilih (mis. level pedas)
  int _qty = 1; // jumlah porsi
  final Set<int> _selectedAddOns = <int>{}; // index tambahan yang dicentang
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Mengambil data menu dari arguments route.
  /// Jika halaman dibuka tanpa arguments (mis. refresh browser),
  /// pakai menu pertama agar aplikasi tidak error.
  MenuModel _resolveMenu(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is MenuModel) return args;
    return kMenuItems.first;
  }

  /// Harga satu porsi = harga menu + tambahan yang dicentang.
  int _unitPrice(MenuModel menu) {
    final addOnTotal = _selectedAddOns.fold<int>(
      0,
      (sum, index) => sum + menu.addOns[index].price,
    );
    return menu.price + addOnTotal;
  }

  /// Memasukkan pesanan ke keranjang.
  /// - goToOrder = false : kembali ke daftar menu + SnackBar konfirmasi
  /// - goToOrder = true  : langsung buka halaman keranjang/pesanan
  void _submit(MenuModel menu, {required bool goToOrder}) {
    final selectedAddOns =
        (_selectedAddOns.toList()..sort()).map((i) => menu.addOns[i]).toList();

    CartController.instance.add(
      CartItem(
        menu: menu,
        variant: menu.variants[_variantIndex],
        addOns: selectedAddOns,
        note: _noteController.text.trim(),
        qty: _qty,
      ),
    );

    final navigator = Navigator.of(context);

    if (goToOrder) {
      // Ganti halaman detail dengan halaman pesanan,
      // sehingga tombol back dari keranjang kembali ke daftar menu.
      navigator.pushReplacementNamed('/pesan');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    navigator.pop();
    showAddedToCartSnackBar(
      messenger,
      navigator,
      '${_qty}x ${menu.name} ditambahkan ke keranjang',
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = _resolveMenu(context);
    final unitPrice = _unitPrice(menu);

    return Scaffold(
      backgroundColor: kPageBackground,

      // AppBar dengan ikon keranjang + lencana jumlah item.
      appBar: AppBar(
        title: const Text('Detail Menu'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: const [CartIconButton(), SizedBox(width: 4)],
      ),

      // Body dapat di-scroll; lebar dibatasi agar rapi di layar lebar (Chrome).
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroImage(menu),
                const SizedBox(height: 16),
                _buildTitleRow(menu),
                const SizedBox(height: 12),
                _buildInfoChips(menu),
                const SizedBox(height: 16),
                _buildDescriptionCard(menu),
                const SizedBox(height: 20),
                _buildSectionTitle(menu.variantTitle, Icons.tune),
                const SizedBox(height: 10),
                _buildVariantChips(menu),
                if (menu.addOns.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildSectionTitle('Tambahan (opsional)', Icons.add_circle),
                  const SizedBox(height: 10),
                  _buildAddOnList(menu),
                ],
                const SizedBox(height: 20),
                _buildSectionTitle('Catatan untuk Penjual', Icons.notes),
                const SizedBox(height: 10),
                _buildNoteField(),
              ],
            ),
          ),
        ),
      ),

      // Bar bawah: jumlah, total harga, dan tombol aksi.
      bottomNavigationBar: _buildBottomBar(menu, unitPrice),
    );
  }

  // ---------------------------------------------------------------
  // Gambar utama (Stack: gambar + label kategori di atasnya)
  // ---------------------------------------------------------------
  Widget _buildHeroImage(MenuModel menu) {
    return Stack(
      children: [
        // Hero: tag sama dengan di daftar menu -> transisi animasi mulus.
        Hero(
          tag: 'menu-${menu.id}',
          child: MenuThumb(
            menu: menu,
            width: double.infinity,
            height: 220,
            radius: 20,
            emojiSize: 96,
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              menu.category,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Nama menu + harga dasar
  // ---------------------------------------------------------------
  Widget _buildTitleRow(MenuModel menu) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            menu.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          formatRupiah(menu.price),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Info singkat: rating, terjual, waktu penyajian
  // ---------------------------------------------------------------
  Widget _buildInfoChips(MenuModel menu) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _infoChip(
          Icons.star_rounded,
          '${menu.rating.toStringAsFixed(1)} rating',
          Colors.amber,
        ),
        _infoChip(
          Icons.local_fire_department,
          '${menu.sold}+ terjual',
          Colors.deepOrange,
        ),
        _infoChip(Icons.timer_outlined, menu.prepTime, Colors.teal),
      ],
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Kartu deskripsi
  // ---------------------------------------------------------------
  Widget _buildDescriptionCard(MenuModel menu) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deskripsi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              menu.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepOrange),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Opsi utama (ChoiceChip) — hanya satu yang bisa dipilih
  // ---------------------------------------------------------------
  Widget _buildVariantChips(MenuModel menu) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(menu.variants.length, (index) {
        final selected = _variantIndex == index;
        return ChoiceChip(
          label: Text(menu.variants[index]),
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
          onSelected: (_) => setState(() => _variantIndex = index),
        );
      }),
    );
  }

  // ---------------------------------------------------------------
  // Tambahan/topping (CheckboxListTile) — boleh pilih lebih dari satu
  // ---------------------------------------------------------------
  Widget _buildAddOnList(MenuModel menu) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          for (var i = 0; i < menu.addOns.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            CheckboxListTile(
              value: _selectedAddOns.contains(i),
              activeColor: Colors.deepOrange,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(menu.addOns[i].name),
              secondary: Text(
                '+ ${formatRupiah(menu.addOns[i].price)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedAddOns.add(i);
                  } else {
                    _selectedAddOns.remove(i);
                  }
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Catatan pesanan (TextField)
  // ---------------------------------------------------------------
  Widget _buildNoteField() {
    return TextField(
      controller: _noteController,
      maxLines: 2,
      maxLength: 80,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: 'Contoh: tanpa bawang goreng, es dipisah',
        filled: true,
        fillColor: Colors.white,
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
    );
  }

  // ---------------------------------------------------------------
  // Bar bawah: stepper jumlah, total harga, dan tombol aksi
  // ---------------------------------------------------------------
  Widget _buildBottomBar(MenuModel menu, int unitPrice) {
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    const buttonPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 14);

    return Material(
      elevation: 12,
      color: Colors.white,
      child: SafeArea(
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      QtyStepper(
                        quantity: _qty,
                        onDecrease:
                            _qty > 1 ? () => setState(() => _qty--) : null,
                        onIncrease:
                            _qty < 20 ? () => setState(() => _qty++) : null,
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            formatRupiah(unitPrice * _qty),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _submit(menu, goToOrder: false),
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text('Keranjang'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepOrange,
                            side: const BorderSide(color: Colors.deepOrange),
                            padding: buttonPadding,
                            shape: buttonShape,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _submit(menu, goToOrder: true),
                          icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                          label: const Text('Pesan Sekarang'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            padding: buttonPadding,
                            shape: buttonShape,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
