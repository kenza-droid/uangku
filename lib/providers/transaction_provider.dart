import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  double _monthlyBudget = 5000000;
  String _userName = 'Pengguna';
  Map<String, double> _categoryBudgets = {};
  ThemeMode _themeMode = ThemeMode.system;

  static const _txKey = 'uangku_transactions';
  static const _budgetKey = 'uangku_budget';
  static const _nameKey = 'uangku_name';
  static const _catBudgetKey = 'uangku_cat_budgets';
  static const _themeModeKey = 'uangku_theme_mode';
  static const _uuid = Uuid();

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  double get monthlyBudget => _monthlyBudget;
  String get userName => _userName;
  Map<String, double> get categoryBudgets => Map.unmodifiable(_categoryBudgets);
  ThemeMode get themeMode => _themeMode;

  TransactionProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_txKey);
    if (raw != null) {
      final List data = jsonDecode(raw);
      _transactions = data.map((e) => Transaction.fromJson(e)).toList();
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    }

    _monthlyBudget = prefs.getDouble(_budgetKey) ?? 5000000;
    _userName = prefs.getString(_nameKey) ?? 'Pengguna';

    final catRaw = prefs.getString(_catBudgetKey);
    if (catRaw != null) {
      final Map map = jsonDecode(catRaw);
      _categoryBudgets = map.map((k, v) => MapEntry(k, (v as num).toDouble()));
    }

    final themeModeStr = prefs.getString(_themeModeKey) ?? 'system';
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == themeModeStr,
      orElse: () => ThemeMode.system,
    );

    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _txKey, jsonEncode(_transactions.map((e) => e.toJson()).toList()));
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required bool isExpense,
    String notes = '',
  }) async {
    final t = Transaction(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      category: category,
      date: date,
      isExpense: isExpense,
      notes: notes,
    );
    _transactions.add(t);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
    await _saveTransactions();
  }

  Future<void> updateTransaction(Transaction updated) async {
    final idx = _transactions.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _transactions[idx] = updated;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
      await _saveTransactions();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    await _saveTransactions();
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  Future<void> setMonthlyBudget(double budget) async {
    _monthlyBudget = budget;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, budget);
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  Future<void> setCategoryBudget(String category, double budget) async {
    if (budget <= 0) {
      _categoryBudgets.remove(category);
    } else {
      _categoryBudgets[category] = budget;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_catBudgetKey, jsonEncode(_categoryBudgets));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  // ── Computed ──────────────────────────────────────────────────────────────

  double get totalBalance {
    final income = _transactions
        .where((t) => !t.isExpense)
        .fold<double>(0, (s, t) => s + t.amount);
    final expense = _transactions
        .where((t) => t.isExpense)
        .fold<double>(0, (s, t) => s + t.amount);
    return income - expense;
  }

  double get monthlyIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            !t.isExpense &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold<double>(0, (s, t) => s + t.amount);
  }

  double get monthlyExpense {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.isExpense &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold<double>(0, (s, t) => s + t.amount);
  }

  List<Transaction> get recentTransactions => _transactions.take(5).toList();

  Map<String, double> get monthlyExpenseByCategory {
    final now = DateTime.now();
    final Map<String, double> result = {};
    for (final t in _transactions.where((t) =>
        t.isExpense &&
        t.date.year == now.year &&
        t.date.month == now.month)) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  List<double> get weeklyExpenses {
    final now = DateTime.now();
    final List<double> weeks = List.filled(5, 0);
    for (final t in _transactions) {
      if (!t.isExpense) continue;
      if (t.date.year != now.year || t.date.month != now.month) continue;
      final weekIdx = ((t.date.day - 1) ~/ 7).clamp(0, 4);
      weeks[weekIdx] += t.amount;
    }
    return weeks;
  }

  List<Map<String, double>> get last6MonthsData {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final target = DateTime(now.year, now.month - 5 + i);
      final income = _transactions
          .where((t) =>
              !t.isExpense &&
              t.date.year == target.year &&
              t.date.month == target.month)
          .fold<double>(0, (s, t) => s + t.amount);
      final expense = _transactions
          .where((t) =>
              t.isExpense &&
              t.date.year == target.year &&
              t.date.month == target.month)
          .fold<double>(0, (s, t) => s + t.amount);
      return {'income': income, 'expense': expense};
    });
  }
}
