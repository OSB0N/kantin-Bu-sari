import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'menu_list_page.dart';

/// Pilihan metode pembayaran (hanya simulasi, tidak ada pembayaran asli).
class _PaymentMethod {
  final String name;
  final String description;
  final IconData icon;

  const _PaymentMethod(this.name, this.description, this.icon);
}

/// Halaman keranjang, data pemesan, pembayaran, dan struk pesanan.
/// Satu halaman punya 3 tampilan: keranjang kosong, keranjang berisi,
/// dan struk setelah pesanan dikonfirmasi.
class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  static const int _packagingFeePerItem = 1000;

  static const List<_PaymentMethod> _paymentMethods = [
    _PaymentMethod(
      'Tunai di Kasir',
      'Bayar langsung saat mengambil pesanan',
      Icons.payments_outlined,
    ),
    _PaymentMethod(
      'QRIS',
      'Scan kode QR di kasir lewat e-wallet / m-banking',
      Icons.qr_code_2,
    ),
    _PaymentMethod(
      'Transfer Bank',
      'Transfer ke rekening Kantin Bu Sari',
      Icons.account_balance_outlined,
    ),
  ];

  final CartController _cart = CartController.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tableController = TextEditingController();

  bool _isDineIn = true; // true = makan di tempat, false = bawa pulang
  int _paymentIndex = 0;
  bool _confirmed = false; // true = tampilkan struk

  // Salinan data untuk struk (keranjang dikosongkan setelah konfirmasi).
  List<CartItem> _receiptItems = [];
  int _receiptSubtotal = 0;
  int _receiptPackaging = 0;
  int _receiptTotal = 0;
  String _receiptNumber = '';
  String _receiptTime = '';
  String _receiptName = '';
  String _receiptPlace = '';
  String _receiptPayment = '';

  @override
  void dispose() {
    _nameController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  // Biaya kemasan hanya berlaku untuk pesanan bawa pulang.
  int get _packagingFee => _isDineIn ? 0 : _cart.totalQty * _packagingFeePerItem;
  int get _grandTotal => _cart.subtotal + _packagingFee;

  String _two(int value) => value.toString().padLeft(2, '0');

  /// Kembali ke daftar menu (halaman pertama).
  void _goToMenu() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    } else {
      navigator.pushReplacementNamed('/');
    }
  }

  /// Validasi form -> simpan data struk -> kosongkan keranjang.
  void _confirmOrder() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Lengkapi data pemesan dulu ya.')),
        );
      return;
    }

    final now = DateTime.now();
    setState(() {
      _receiptItems = List<CartItem>.from(_cart.items);
      _receiptSubtotal = _cart.subtotal;
      _receiptPackaging = _packagingFee;
      _receiptTotal = _grandTotal;
      _receiptNumber = 'A-${100 + now.millisecondsSinceEpoch % 900}';
      _receiptTime = '${_two(now.day)}/${_two(now.month)}/${now.year}  '
          '${_two(now.hour)}:${_two(now.minute)}';
      _receiptName = _nameController.text.trim();
      _receiptPlace = _isDineIn
          ? 'Makan di tempat • Meja ${_tableController.text.trim()}'
          : 'Bawa pulang';
      _receiptPayment = _paymentMethods[_paymentIndex].name;
      _confirmed = true;
    });
    _cart.clear();
  }

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder: halaman ikut ter-update saat isi keranjang berubah.
    return ListenableBuilder(
      listenable: _cart,
      builder: (context, _) {
        final hasItems = !_cart.isEmpty;

        // PopScope: setelah struk tampil, tombol back diarahkan ke menu
        // agar pengguna tidak kembali ke halaman keranjang yang sudah kosong.
        return PopScope(
          canPop: !_confirmed,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && _confirmed) _goToMenu();
          },
          child: Scaffold(
            backgroundColor: kPageBackground,
            appBar: AppBar(
              title: Text(_confirmed ? 'Struk Pesanan' : 'Keranjang Pesanan'),
              automaticallyImplyLeading: !_confirmed,
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            body: _confirmed
                ? _buildReceipt()
                : (hasItems ? _buildCartContent() : _buildEmptyCart()),
            bottomNavigationBar:
                (!_confirmed && hasItems) ? _buildCheckoutBar() : null,
          ),
        );
      },
    );
  }

  // =================================================================
  // TAMPILAN 1 — KERANJANG KOSONG
  // =================================================================
  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 56,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Keranjang masih kosong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Yuk pilih menu favoritmu dulu di Kantin Bu Sari.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _goToMenu,
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Lihat Daftar Menu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================================================================
  // TAMPILAN 2 — KERANJANG BERISI (daftar pesanan, form, pembayaran)
  // =================================================================
  Widget _buildCartContent() {
    final items = _cart.items;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard(
                  title: 'Pesanan Kamu (${_cart.totalQty} item)',
                  icon: Icons.shopping_bag_outlined,
                  child: Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const Divider(height: 24),
                        _buildCartItemTile(items[i]),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Data Pemesan',
                  icon: Icons.person_outline,
                  child: _buildCustomerForm(),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Metode Pembayaran',
                  icon: Icons.payments_outlined,
                  child: _buildPaymentOptions(),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Ringkasan Pembayaran',
                  icon: Icons.receipt_long,
                  child: _buildSummary(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Kartu pembungkus section: judul + ikon + isi.
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  /// Satu baris item keranjang: gambar, nama, opsi, hapus, dan stepper jumlah.
  Widget _buildCartItemTile(CartItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MenuThumb(
              menu: item.menu,
              width: 56,
              height: 56,
              radius: 12,
              emojiSize: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.menu.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.detailText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                  ),
                  if (item.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Catatan: ${item.note}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatRupiah(item.unitPrice)} / porsi',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            // Tombol hapus item dari keranjang.
            IconButton(
              tooltip: 'Hapus',
              onPressed: () => _cart.remove(item),
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 68),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatRupiah(item.lineTotal),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              QtyStepper(
                quantity: item.qty,
                onDecrease: () => _cart.decrease(item),
                onIncrease: item.qty < 20 ? () => _cart.increase(item) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: border(Colors.grey.shade300),
      enabledBorder: border(Colors.grey.shade300),
      focusedBorder: border(Colors.deepOrange, 1.6),
      errorBorder: border(Colors.red.shade400),
      focusedErrorBorder: border(Colors.red.shade400, 1.6),
    );
  }

  /// Form data pemesan: nama, jenis pesanan, dan nomor meja.
  Widget _buildCustomerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Nama Pemesan',
            hint: 'Contoh: Budi',
            icon: Icons.person_outline,
          ),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Nama pemesan wajib diisi'
              : null,
        ),
        const SizedBox(height: 16),
        const Text(
          'Jenis Pesanan',
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTypeChip(
              label: 'Makan di Tempat',
              icon: Icons.restaurant,
              selected: _isDineIn,
              onTap: () => setState(() => _isDineIn = true),
            ),
            _buildTypeChip(
              label: 'Bawa Pulang',
              icon: Icons.takeout_dining,
              selected: !_isDineIn,
              onTap: () => setState(() => _isDineIn = false),
            ),
          ],
        ),
        if (_isDineIn) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _tableController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _inputDecoration(
              label: 'Nomor Meja',
              hint: 'Contoh: 7',
              icon: Icons.table_restaurant,
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Nomor meja wajib diisi'
                : null,
          ),
        ] else ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Pesanan bawa pulang dikenakan biaya kemasan '
                  '${formatRupiah(_packagingFeePerItem)} per item.',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTypeChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? Colors.white : Colors.deepOrange,
      ),
      label: Text(label),
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
      onSelected: (_) => onTap(),
    );
  }

  /// Pilihan metode pembayaran (ListTile yang bisa dipilih).
  Widget _buildPaymentOptions() {
    return Column(
      children: List.generate(_paymentMethods.length, (index) {
        final method = _paymentMethods[index];
        final selected = _paymentIndex == index;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == _paymentMethods.length - 1 ? 0 : 8,
          ),
          child: ListTile(
            onTap: () => setState(() => _paymentIndex = index),
            selected: selected,
            selectedColor: Colors.deepOrange,
            selectedTileColor: Colors.deepOrange.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: selected ? Colors.deepOrange : Colors.grey.shade300,
                width: selected ? 1.6 : 1,
              ),
            ),
            leading: Icon(method.icon),
            title: Text(
              method.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              method.description,
              style: const TextStyle(fontSize: 12.5),
            ),
            trailing: Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
            ),
          ),
        );
      }),
    );
  }

  /// Ringkasan harga: subtotal, biaya kemasan, dan total bayar.
  Widget _buildSummary() {
    return Column(
      children: [
        _summaryRow(
          'Subtotal (${_cart.totalQty} item)',
          formatRupiah(_cart.subtotal),
        ),
        const SizedBox(height: 8),
        _summaryRow(
          'Biaya kemasan',
          _packagingFee == 0 ? 'Gratis' : formatRupiah(_packagingFee),
        ),
        const Divider(height: 24),
        _summaryRow('Total Bayar', formatRupiah(_grandTotal), bold: true),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: bold ? Colors.deepOrange : Colors.black87,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 12),
        Text(value, style: style),
      ],
    );
  }

  /// Bar bawah: total bayar + tombol konfirmasi.
  Widget _buildCheckoutBar() {
    return Material(
      elevation: 12,
      color: Colors.white,
      child: SafeArea(
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Bayar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        formatRupiah(_grandTotal),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _confirmOrder,
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text('Konfirmasi & Bayar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =================================================================
  // TAMPILAN 3 — STRUK SETELAH PESANAN DIKONFIRMASI
  // =================================================================
  Widget _buildReceipt() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 52, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pesanan Diterima!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Tunjukkan struk ini ke kasir Bu Sari.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              _buildReceiptCard(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _goToMenu,
                  icon: const Icon(Icons.home),
                  label: const Text('Kembali ke Daftar Menu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptCard() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'KANTIN BU SARI',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Center(
              child: Text(
                'Struk Pemesanan',
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 14),

            // Nomor antrian (disorot agar mudah dibaca kasir).
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'No. Antrian',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                  ),
                  Text(
                    _receiptNumber,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _DashedDivider(),
            const SizedBox(height: 12),
            _infoRow('Waktu', _receiptTime),
            const SizedBox(height: 6),
            _infoRow('Pemesan', _receiptName),
            const SizedBox(height: 6),
            _infoRow('Jenis', _receiptPlace),
            const SizedBox(height: 6),
            _infoRow('Pembayaran', _receiptPayment),
            const SizedBox(height: 12),
            const _DashedDivider(),
            const SizedBox(height: 12),

            // Daftar item pesanan.
            for (final item in _receiptItems) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.qty}x ${item.menu.name}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          item.detailText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (item.note.isNotEmpty)
                          Text(
                            'Catatan: ${item.note}',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    formatRupiah(item.lineTotal),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 2),
            const _DashedDivider(),
            const SizedBox(height: 12),
            _summaryRow('Subtotal', formatRupiah(_receiptSubtotal)),
            const SizedBox(height: 6),
            _summaryRow(
              'Biaya kemasan',
              _receiptPackaging == 0 ? 'Gratis' : formatRupiah(_receiptPackaging),
            ),
            const SizedBox(height: 10),
            _summaryRow('TOTAL', formatRupiah(_receiptTotal), bold: true),
            const SizedBox(height: 14),
            const _DashedDivider(),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Terima kasih sudah makan di Kantin Bu Sari!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Garis putus-putus ala struk kasir.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (index) => Container(
              width: 4,
              height: 1.2,
              color: Colors.grey.shade400,
            ),
          ),
        );
      },
    );
  }
}
