import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(v);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final balance = provider.totalBalance;
        final income = provider.monthlyIncome;
        final expense = provider.monthlyExpense;
        final budgetRatio = provider.monthlyBudget > 0
            ? (expense / provider.monthlyBudget).clamp(0.0, 1.0)
            : 0.0;
        final budgetPct = (budgetRatio * 100).toStringAsFixed(0);
        final budgetColor = budgetRatio < 0.7
            ? cs.tertiary
            : budgetRatio < 0.9
                ? Colors.orange
                : cs.error;

        // sorted categories
        final catEntries = provider.monthlyExpenseByCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(4)),
                  child: const Center(
                      child: Text('U',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Uangku',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18)),
                      Text(
                          DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(4)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SALDO SAAT INI',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text(_fmt(balance),
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _miniStat(
                                  'Pemasukan', _fmt(income), Icons.arrow_upward)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _miniStat('Pengeluaran', _fmt(expense),
                                  Icons.arrow_downward)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Budget progress
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('BUDGET BULANAN',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1)),
                          Text('$budgetPct% terpakai',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: budgetColor,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: budgetRatio,
                          backgroundColor: const Color(0xFFE0E0E0),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(budgetColor),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                          '${_fmt(expense)} dari ${_fmt(provider.monthlyBudget)}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Weekly chart
                const Text('Pengeluaran Mingguan',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  color: const Color(0xFFF4F4F4),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 140,
                        child: _WeeklyBarChart(
                            data: provider.weeklyExpenses, color: cs.primary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['Mg 1', 'Mg 2', 'Mg 3', 'Mg 4', 'Mg 5']
                            .map((w) => Text(w,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Income vs Expense chart
                const Text('Pemasukan vs Pengeluaran (6 Bulan)',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0))),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _legend('Pemasukan', cs.primary),
                          const SizedBox(width: 12),
                          _legend('Pengeluaran', cs.error),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: _GroupedBarChart(
                          data: provider.last6MonthsData,
                          incomeColor: cs.primary,
                          expenseColor: cs.error,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _monthLabels(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Category breakdown
                if (catEntries.isNotEmpty) ...[
                  const Text('Pengeluaran per Kategori',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...catEntries.take(5).map(
                        (e) => _categoryRow(e.key, e.value, expense, cs),
                      ),
                  const SizedBox(height: 24),
                ],

                // Recent
                const Text('Transaksi Terbaru',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                provider.recentTransactions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Belum ada transaksi',
                                  style: TextStyle(color: Colors.grey)),
                              Text('Tambahkan transaksi pertamamu!',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: provider.recentTransactions
                            .map((t) => _txRow(t, cs))
                            .toList(),
                      ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _miniStat(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
          Text(label,
              style:
                  const TextStyle(fontSize: 10, color: Colors.white70)),
        ]),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _legend(String label, Color color) {
    return Row(children: [
      Container(width: 10, height: 10, color: color),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ]);
  }

  Widget _monthLabels() {
    final now = DateTime.now();
    final months = List.generate(
        6, (i) => DateFormat('MMM', 'id_ID').format(DateTime(now.year, now.month - 5 + i)));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: months
          .map((m) =>
              Text(m, style: const TextStyle(fontSize: 10, color: Colors.grey)))
          .toList(),
    );
  }

  Widget _categoryRow(
      String cat, double amount, double total, ColorScheme cs) {
    final pct = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration:
              BoxDecoration(color: cs.surfaceVariant),
          child:
              Icon(Transaction.categoryIcon(cat), size: 18, color: cs.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(cat,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13)),
              Text(
                  NumberFormat.currency(
                          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                      .format(amount),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: cs.error)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                minHeight: 3,
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _txRow(Transaction t, ColorScheme cs) {
    final fmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF4F4F4)))),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(color: Color(0xFFF4F4F4)),
          child: Icon(Transaction.categoryIcon(t.category),
              size: 18, color: const Color(0xFF161616)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            Text(DateFormat('dd MMM, HH:mm', 'id_ID').format(t.date),
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ),
        Text(
          '${t.isExpense ? '-' : '+'}${fmt.format(t.amount)}',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: t.isExpense ? cs.error : cs.tertiary,
              fontSize: 14),
        ),
      ]),
    );
  }
}

// ── Custom Charts ─────────────────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  const _WeeklyBarChart({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarPainter(data: data, color: color),
      child: const SizedBox.expand(),
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  _BarPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = data.fold<double>(0, (m, v) => max(m, v));
    final barW = (size.width / data.length) * 0.55;
    final gap = (size.width / data.length) * 0.45;
    final chartH = size.height;

    for (int i = 0; i < data.length; i++) {
      final x = i * (barW + gap) + gap / 2;
      // bg
      canvas.drawRect(
        Rect.fromLTWH(x, 0, barW, chartH),
        Paint()..color = Colors.grey.withOpacity(0.15),
      );
      // bar
      if (maxVal > 0 && data[i] > 0) {
        final h = (data[i] / maxVal) * chartH;
        canvas.drawRect(
          Rect.fromLTWH(x, chartH - h, barW, h),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) =>
      old.data != data || old.color != color;
}

class _GroupedBarChart extends StatelessWidget {
  final List<Map<String, double>> data;
  final Color incomeColor;
  final Color expenseColor;
  const _GroupedBarChart(
      {required this.data,
      required this.incomeColor,
      required this.expenseColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GroupedPainter(
          data: data, incomeColor: incomeColor, expenseColor: expenseColor),
      child: const SizedBox.expand(),
    );
  }
}

class _GroupedPainter extends CustomPainter {
  final List<Map<String, double>> data;
  final Color incomeColor;
  final Color expenseColor;
  _GroupedPainter(
      {required this.data,
      required this.incomeColor,
      required this.expenseColor});

  @override
  void paint(Canvas canvas, Size size) {
    double maxVal = 1;
    for (final d in data) {
      maxVal = max(maxVal, max(d['income']!, d['expense']!));
    }
    final groupW = size.width / data.length;
    final barW = groupW * 0.28;
    final chartH = size.height;

    for (int i = 0; i < data.length; i++) {
      final gx = i * groupW;
      final incH = (data[i]['income']! / maxVal) * chartH;
      final expH = (data[i]['expense']! / maxVal) * chartH;

      canvas.drawRect(
        Rect.fromLTWH(gx + groupW * 0.05, chartH - incH, barW, incH),
        Paint()..color = incomeColor,
      );
      canvas.drawRect(
        Rect.fromLTWH(gx + groupW * 0.05 + barW + 2, chartH - expH, barW, expH),
        Paint()..color = expenseColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GroupedPainter old) => true;
}
