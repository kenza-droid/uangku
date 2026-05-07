import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

import '../utils/transitions.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _search = '';
  String _filterType = 'Semua'; // Semua, Pengeluaran, Pemasukan
  String _filterCategory = 'Semua';
  DateTime _selectedMonth = DateTime.now();

  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _filtered(List<Transaction> all) {
    return all.where((t) {
      final matchSearch = _search.isEmpty ||
          t.title.toLowerCase().contains(_search.toLowerCase()) ||
          t.category.toLowerCase().contains(_search.toLowerCase());
      final matchType = _filterType == 'Semua' ||
          (_filterType == 'Pengeluaran' && t.isExpense) ||
          (_filterType == 'Pemasukan' && !t.isExpense);
      final matchCat =
          _filterCategory == 'Semua' || t.category == _filterCategory;
      final matchMonth = t.date.year == _selectedMonth.year &&
          t.date.month == _selectedMonth.month;
      return matchSearch && matchType && matchCat && matchMonth;
    }).toList();
  }

  Map<String, List<Transaction>> _groupByDate(List<Transaction> txs) {
    final Map<String, List<Transaction>> grouped = {};
    for (final t in txs) {
      final key = DateFormat('dd MMMM yyyy', 'id_ID').format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    return grouped;
  }

  void _openEditScreen(Transaction t) {
    Navigator.push(
      context,
      SlideUpRoute(page: AddTransactionScreen(editTransaction: t)),
    );
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final filtered = _filtered(provider.transactions);
        final grouped = _groupByDate(filtered);
        final dateKeys = grouped.keys.toList();

        // Unique categories for filter
        final categories = ['Semua'] +
            provider.transactions.map((t) => t.category).toSet().toList();

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: const Text('Riwayat Transaksi',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _search = v),
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Cari transaksi...',
                    hintStyle: TextStyle(color: colorScheme.outline),
                    prefixIcon: Icon(Icons.search,
                        size: 20, color: colorScheme.outline),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                size: 18, color: colorScheme.outline),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _search = '');
                            })
                        : null,
                    filled: true,
                    fillColor: colorScheme.surfaceVariant,
                    border: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: colorScheme.outlineVariant)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: colorScheme.outlineVariant)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: colorScheme.primary)),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              // Month Selector
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1)),
                    ),
                    Column(
                      children: [
                        Text(
                          DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth).toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colorScheme.primary,
                            letterSpacing: 1,
                          ),
                        ),
                        if (_selectedMonth.year == DateTime.now().year && _selectedMonth.month == DateTime.now().month)
                          Text('BULAN INI', style: TextStyle(fontSize: 9, color: colorScheme.outline, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1)),
                    ),
                  ],
                ),
              ),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _filterChip('Semua',
                        active: _filterType == 'Semua',
                        onTap: () =>
                            setState(() => _filterType = 'Semua')),
                    const SizedBox(width: 8),
                    _filterChip('Pengeluaran',
                        icon: Icons.arrow_downward,
                        active: _filterType == 'Pengeluaran',
                        color: colorScheme.error,
                        onTap: () =>
                            setState(() => _filterType = 'Pengeluaran')),
                    const SizedBox(width: 8),
                    _filterChip('Pemasukan',
                        icon: Icons.arrow_upward,
                        active: _filterType == 'Pemasukan',
                        color: colorScheme.tertiary,
                        onTap: () =>
                            setState(() => _filterType = 'Pemasukan')),
                    const SizedBox(width: 8),
                    // Category dropdown
                    GestureDetector(
                      onTap: () async {
                        final picked =
                            await showModalBottomSheet<String>(
                          context: context,
                          backgroundColor: colorScheme.surface,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16))),
                          builder: (ctx) => ListView(
                            shrinkWrap: true,
                            children: categories
                                .map((c) => ListTile(
                                      title: Text(c,
                                          style: TextStyle(
                                              color: colorScheme.onSurface)),
                                      selected: _filterCategory == c,
                                      onTap: () =>
                                          Navigator.pop(ctx, c),
                                    ))
                                .toList(),
                          ),
                        );
                        if (picked != null) {
                          setState(() => _filterCategory = picked);
                        }
                      },
                      child: _filterChip(
                        _filterCategory == 'Semua'
                            ? 'Kategori'
                            : _filterCategory,
                        icon: Icons.filter_list,
                        active: _filterCategory != 'Semua',
                        onTap: null,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: colorScheme.outlineVariant),

              // List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 56, color: colorScheme.outline),
                            const SizedBox(height: 12),
                            Text('Tidak ada transaksi',
                                style: TextStyle(
                                    color: colorScheme.outline, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: dateKeys.length,
                        itemBuilder: (ctx, i) {
                          final key = dateKeys[i];
                          final txs = grouped[key]!;
                          final dayTotal = txs.fold<double>(
                              0,
                              (s, t) => t.isExpense
                                  ? s - t.amount
                                  : s + t.amount);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date header
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 12, 16, 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(key.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.outline,
                                            letterSpacing: 1.2)),
                                    Text(
                                      _fmt(dayTotal),
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: dayTotal >= 0
                                              ? colorScheme.tertiary
                                              : colorScheme.error),
                                    ),
                                  ],
                                ),
                              ),
                              ...txs.map((t) =>
                                  _buildTxItem(t, colorScheme, provider)),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(double v) {
    final fmt = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return '${v >= 0 ? '+' : ''}${fmt.format(v)}';
  }

  Widget _filterChip(String label,
      {IconData? icon,
      bool active = false,
      Color? color,
      VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = active ? Colors.white : colorScheme.onSurface.withOpacity(0.7);
    final bg =
        active ? (color ?? colorScheme.primary) : colorScheme.surfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: fg),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        active ? FontWeight.bold : FontWeight.normal,
                    color: fg)),
          ],
        ),
      ),
    );
  }

  Widget _buildTxItem(Transaction t, ColorScheme cs, TransactionProvider provider) {
    final fmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: cs.error,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: cs.surface,
            title: Text('Hapus Transaksi?',
                style: TextStyle(color: cs.onSurface)),
            content: Text('Yakin ingin menghapus "${t.title}"?',
                style: TextStyle(color: cs.onSurface)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('Hapus',
                      style: TextStyle(color: cs.error))),
            ],
          ),
        );
      },
      onDismissed: (_) => provider.deleteTransaction(t.id),
      child: InkWell(
        onTap: () => _openEditScreen(t),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.5)))),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration:
                    BoxDecoration(color: cs.surfaceVariant),
                child: Icon(Transaction.categoryIcon(t.category),
                    size: 20, color: cs.onSurface),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: cs.onSurface)),
                    Text(
                        '${DateFormat('HH:mm', 'id_ID').format(t.date)} • ${t.category}',
                        style: TextStyle(
                            color: cs.outline, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${t.isExpense ? '-' : '+'}${fmt.format(t.amount)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: t.isExpense ? cs.error : cs.tertiary,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Icon(Icons.edit_outlined, size: 14, color: cs.outline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
