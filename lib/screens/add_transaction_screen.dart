import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isExpense = true;
  String _amountDigits = '0';
  String _title = '';
  String _category = '';
  DateTime _date = DateTime.now();
  String _notes = '';

  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String get _formattedAmount {
    final num = int.tryParse(_amountDigits) ?? 0;
    return NumberFormat('#,###', 'id_ID').format(num);
  }

  double get _amountValue => double.tryParse(_amountDigits) ?? 0;

  void _onKeyTap(String key) {
    setState(() {
      if (key == '⌫') {
        _amountDigits = _amountDigits.length > 1
            ? _amountDigits.substring(0, _amountDigits.length - 1)
            : '0';
      } else {
        final appended = _amountDigits == '0' ? key : _amountDigits + key;
        if (int.tryParse(appended) != null && appended.length <= 13) {
          _amountDigits = appended;
        }
      }
    });
  }

  Future<void> _pickCategory() async {
    final categories =
        isExpense ? Transaction.expenseCategories : Transaction.incomeCategories;
    final picked = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Pilih Kategori',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const Divider(height: 1),
            ...categories.map((c) => ListTile(
                  leading: Icon(Transaction.categoryIcon(c),
                      color: const Color(0xFF0F62FE)),
                  title: Text(c),
                  onTap: () => Navigator.pop(ctx, c),
                )),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _category = picked);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTitle() async {
    final ctrl = TextEditingController(text: _title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nama Transaksi'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Contoh: Makan siang, Gaji...'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('OK')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() => _title = result.trim());
    }
  }

  Future<void> _save() async {
    if (_amountValue <= 0) {
      _snack('Masukkan jumlah transaksi');
      return;
    }
    if (_title.isEmpty) {
      _snack('Masukkan nama transaksi');
      return;
    }
    if (_category.isEmpty) {
      _snack('Pilih kategori transaksi');
      return;
    }

    await context.read<TransactionProvider>().addTransaction(
          title: _title,
          amount: _amountValue,
          category: _category,
          date: _date,
          isExpense: isExpense,
          notes: _notes,
        );

    if (mounted) {
      _snack('Transaksi berhasil disimpan!', success: true);
      setState(() {
        _amountDigits = '0';
        _title = '';
        _category = '';
        _date = DateTime.now();
        _notes = '';
        _noteController.clear();
      });
    }
  }

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? const Color(0xFF198038) : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Transaksi',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle Expense / Income
            Container(
              color: const Color(0xFFE0E0E0),
              child: Row(
                children: [
                  _buildToggle('Pengeluaran', Icons.arrow_downward, true, colorScheme),
                  _buildToggle('Pemasukan', Icons.arrow_upward, false, colorScheme),
                ],
              ),
            ),

            // Amount display
            Container(
              width: double.infinity,
              color: const Color(0xFFF4F4F4),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('JUMLAH',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Rp',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.w300)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formattedAmount,
                          style: const TextStyle(
                              fontSize: 36, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form fields
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Title
                  GestureDetector(
                    onTap: _pickTitle,
                    child: _buildFormField(
                      'NAMA TRANSAKSI',
                      _title.isEmpty ? 'Ketuk untuk mengisi...' : _title,
                      Icons.edit,
                      isEmpty: _title.isEmpty,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickCategory,
                          child: _buildFormField(
                            'KATEGORI',
                            _category.isEmpty ? 'Pilih...' : _category,
                            Icons.expand_more,
                            isEmpty: _category.isEmpty,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: _buildFormField(
                            'TANGGAL',
                            DateFormat('dd MMM yyyy', 'id_ID').format(_date),
                            Icons.calendar_today,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Notes
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F4F4),
                      border: Border(
                          bottom: BorderSide(color: Color(0xFF8D8D8D))),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CATATAN (OPSIONAL)',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 1.2)),
                        TextField(
                          controller: _noteController,
                          onChanged: (v) => _notes = v,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Tambahkan catatan...',
                            hintStyle:
                                TextStyle(fontSize: 14, color: Colors.grey),
                            isDense: true,
                            contentPadding: EdgeInsets.only(top: 4),
                          ),
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Numpad
            Container(
              color: const Color(0xFFE0E0E0),
              padding: const EdgeInsets.all(2),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 2.2,
                children: [
                  ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0']
                      .map((e) => _buildKey(e)),
                  _buildKey('⌫', isBackspace: true),
                ],
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('SIMPAN TRANSAKSI',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(
      String label, IconData icon, bool forExpense, ColorScheme colorScheme) {
    final active = isExpense == forExpense;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          isExpense = forExpense;
          _category = '';
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            border: active
                ? const Border(
                    bottom: BorderSide(color: Color(0xFF0F62FE), width: 2))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: active ? colorScheme.primary : colorScheme.secondary),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: active
                          ? colorScheme.primary
                          : colorScheme.secondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String value, IconData trailing,
      {bool isEmpty = false}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F4),
        border:
            Border(bottom: BorderSide(color: Color(0xFF8D8D8D))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                      fontSize: 14,
                      color: isEmpty ? Colors.grey : const Color(0xFF161616)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(trailing, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String label, {bool isBackspace = false}) {
    return Material(
      color: isBackspace ? const Color(0xFFF4F4F4) : Colors.white,
      child: InkWell(
        onTap: () => _onKeyTap(label),
        child: Center(
          child: isBackspace
              ? const Icon(Icons.backspace_outlined, size: 20)
              : Text(label,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
