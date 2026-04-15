import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _search = '';
  String _filterType = 'Semua'; // Semua, Pengeluaran, Pemasukan
  String _filterCategory = 'Semua';

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
      return matchSearch && matchType && matchCat;
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
          backgroundColor: Colors.white,
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
                  decoration: InputDecoration(
                    hintText: 'Cari transaksi...',
                    prefixIcon: const Icon(Icons.search,
                        size: 20, color: Colors.grey),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                size: 18, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _search = '');
                            })
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF4F4F4),
                    border: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFE0E0E0))),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFE0E0E0))),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF0F62FE))),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
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
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16))),
                          builder: (ctx) => ListView(
                            shrinkWrap: true,
                            children: categories
                                .map((c) => ListTile(
                                      title: Text(c),
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

              const Divider(height: 1),

              // List
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 56, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('Tidak ada transaksi',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),
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
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
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
    final fg = active ? Colors.white : const Color(0xFF525252);
    final bg =
        active ? (color ?? const Color(0xFF0F62FE)) : const Color(0xFFF4F4F4);
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
            title: const Text('Hapus Transaksi?'),
            content: Text('Yakin ingin menghapus "${t.title}"?'),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Color(0xFFF4F4F4)))),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  const BoxDecoration(color: Color(0xFFF4F4F4)),
              child: Icon(Transaction.categoryIcon(t.category),
                  size: 20, color: const Color(0xFF161616)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
                      '${DateFormat('HH:mm', 'id_ID').format(t.date)} • ${t.category}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Text(
              '${t.isExpense ? '-' : '+'}${fmt.format(t.amount)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: t.isExpense ? cs.error : cs.tertiary,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
