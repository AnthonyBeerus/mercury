import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:mercury/models/expense.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];

  //* S E T U P

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  //* G E T T E R S
  List<Expense> get allExpense => _allExpenses;

  /* 
  
  O P E R A T I O N S
  
  */

  //* create- add a new expense
  Future<void> createNewExpense(Expense newExpense) async {
    //* add to isar
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    await readExpenses();
  }

  //* read- get all expenses
  Future<void> readExpenses() async {
    //* fetch all exisiting expenses from db
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    //* give to local expense list
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    //* update UI
    notifyListeners();
  }

  //* update- update an expense
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    //* make sure new expense has the same id as the old one
    updatedExpense.id = id;

    //* update in db
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    //* update UI
    await readExpenses();
  }

  //* delete- delete an expense
  Future<void> deleteExpense(int id) async {
    //* delete from db
    await isar.writeTxn(() => isar.expenses.delete(id));

    //* update UI
    await readExpenses();
  }

  /* 
  
  H E L P E R   F U N C T I O N S 
  
  */

  //* calculate total expenses for each month
  Future<Map<int, double>> calculateMonthlySummary() async {
    //* ensure the expense read from db
    await readExpenses();

    //* create a map to keep track of total expenses for each month
    Map<int, double> monthlyTotals = {};

    //* iterate over all expenses
    for (var expense in _allExpenses) {
      //* get the month of the expense
      int month = expense.date.month;

      //* add the expense amount to the total for that month
      if (monthlyTotals.containsKey(month)) {
        monthlyTotals[month] = 0;
      }

      //* add the expense amount to the total for that month
      monthlyTotals[month] = monthlyTotals[month]! + expense.amount;
    }

    return monthlyTotals;
  }

  //* get start month
  int getStartMonth() {
    //* get the first expense
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
    }

    //* sort the expenses by date
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.month;
  }


  //* get start year
  int getStartYear() {
    //* get the first expense
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
    }

    //* sort the expenses by date
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.year;
  }
}
