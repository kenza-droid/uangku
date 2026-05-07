import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? editTransaction;

  const AddTransactionScreen({super.key, this.editTransaction});

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

  bool get _isEditing => widget.editTransaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.editTransaction!;
      isExpense = t.isExpense;
      _amountDigits = t.amount.toStringAsFixed(0);
      _title = t.title;
      _category = t.category;
      _date = t.date;
      _notes = t.notes;
      _noteController.text = t.notes;
    }
  }

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
    final cs = Theme.of(context).colorScheme;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Pilih Kategori',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: cs.onSurface)),
            ),
            Divider(height: 1, color: cs.outlineVariant),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (ctx, i) {
                  final c = categories[i];
                  return ListTile(
                    leading: Icon(Transaction.categoryIcon(c),
                        color: cs.primary),
                    title: Text(c, style: TextStyle(color: cs.onSurface)),
                    onTap: () => Navigator.pop(ctx, c),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
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
    final cs = Theme.of(context).colorScheme;
    final ctrl = TextEditingController(text: _title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Nama Transaksi', style: TextStyle(color: cs.onSurface)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: cs.onSurface),
          decoration: InputDecoration(
              hintText: 'Contoh: Makan siang, Gaji...',
              hintStyle: TextStyle(color: cs.outline)),
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

    final provider = context.read<TransactionProvider>();

    if (_isEditing) {
      final updated = widget.editTransaction!.copyWith(
        title: _title,
        amount: _amountValue,
        category: _category,
        date: _date,
        isExpense: isExpense,
        notes: _notes,
      );
      await provider.updateTransaction(updated);

      if (mounted) {
        _snack('Transaksi berhasil diperbarui!', success: true);
        Navigator.pop(context, true);
      }
    } else {
      await provider.addTransaction(
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
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        leading: _isEditing
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle Expense / Income
            Container(
              color: colorScheme.outlineVariant,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('JUMLAH',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.outline,
                          letterSpacing: 2)),
                  const SizedBox(height: 12),
                  FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Rp',
                            style: TextStyle(
                                fontSize: 24,
                                color: colorScheme.primary.withOpacity(0.5),
                                fontWeight: FontWeight.w300)),
                        const SizedBox(width: 12),
                        Text(
                          _formattedAmount,
                          style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form fields
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  // Title
                  GestureDetector(
                    onTap: _pickTitle,
                    child: _buildFormField(
                      'NAMA TRANSAKSI',
                      _title.isEmpty ? 'Ketuk untuk mengisi...' : _title,
                      Icons.edit_note,
                      isEmpty: _title.isEmpty,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickCategory,
                          child: _buildFormField(
                            'KATEGORI',
                            _category.isEmpty ? 'Pilih...' : _category,
                            Icons.category_outlined,
                            isEmpty: _category.isEmpty,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: _buildFormField(
                            'TANGGAL',
                            DateFormat('dd MMM yyyy', 'id_ID').format(_date),
                            Icons.calendar_month_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Notes
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CATATAN (OPSIONAL)',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.outline,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _noteController,
                          onChanged: (v) => _notes = v,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Tambahkan catatan...',
                            hintStyle:
                                TextStyle(fontSize: 14, color: colorScheme.outline),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.8,
                children: [
                  ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0']
                      .map((e) => _buildKey(e)),
                  _buildKey('⌫', isBackspace: true),
                ],
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: colorScheme.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(
                      _isEditing ? 'SIMPAN PERUBAHAN' : 'SIMPAN TRANSAKSI',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 1.2)),
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
          if (!_isEditing) _category = '';
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? colorScheme.surface : Colors.transparent,
            border: active
                ? Border(
                    bottom: BorderSide(color: colorScheme.primary, width: 2))
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.outline,
                  letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isEmpty ? colorScheme.outline : colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(trailing, size: 18, color: colorScheme.primary.withOpacity(0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String label, {bool isBackspace = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: isBackspace ? colorScheme.surfaceVariant : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onKeyTap(label),
          child: Center(
            child: isBackspace
                ? Icon(Icons.backspace_outlined,
                    size: 20, color: colorScheme.onSurface)
                : Text(label,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface)),
          ),
        ),
      ),
    );
  }
}
