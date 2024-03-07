import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mercury/bar%20graph/bar_graph.dart';
import 'package:mercury/components/list_tile.dart';
import 'package:mercury/database/expense_database.dart';
import 'package:mercury/helper%20functions/calculate_month_count.dart';
import 'package:mercury/helper%20functions/currency_format.dart';
import 'package:mercury/models/expense.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  //* future for bar graph
  Future<Map<int, double>>? _monthlyTotalsFuture;

  @override
  void initState() {
    //* refresh graph data
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    //*refresh graph data
    refreshGraphData();

    super.initState();
  }

  //*Refreash graph data
  void refreshGraphData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlySummary();
  }

  //* new expense bottom sheet
  void newExpense() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Set this to true if you want the bottom sheet to be scrollable
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize
                .max, // Use this to prevent the column from overflowing
            children: [
              TextField(
                decoration: const InputDecoration(hintText: 'Name'),
                controller: nameController,
              ),
              TextField(
                decoration: const InputDecoration(hintText: 'Amount'),
                keyboardType: TextInputType.number,
                controller: amountController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      //* only save if both fields are filled
                      if (nameController.text.isNotEmpty &&
                          amountController.text.isNotEmpty) {
                        //*pop box
                        Navigator.pop(context);

                        //*create new db
                        Expense newExpense = Expense(
                            name: nameController.text,
                            amount: double.parse(amountController.text),
                            date: DateTime.now());

                        //*save to db
                        await context
                            .read<ExpenseDatabase>()
                            .createNewExpense(newExpense);

                        //*clear text fields
                        nameController.clear();
                        amountController.clear();
                      }
                    },
                    child: const Text('Add Expense'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  //* edit expense dialog box
  void openEditBox(Expense expense, BuildContext context) {
    //* pre-load text fields with current values
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    //* show dialog to edit expense
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Edit Expense'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: existingName),
                    controller: nameController,
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: existingAmount),
                    keyboardType: TextInputType.number,
                    controller: amountController,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          //* save as long as one field is filled

                          if (nameController.text.isNotEmpty ||
                              amountController.text.isNotEmpty) {
                            //*pop box
                            Navigator.pop(context);

                            //*create new updated expense
                            Expense updatedExpense = Expense(
                                name: nameController.text.isNotEmpty
                                    ? nameController.text
                                    : existingName,
                                amount: amountController.text.isNotEmpty
                                    ? double.parse(amountController.text)
                                    : double.parse(existingAmount),
                                date: DateTime.now());

                            //* old expense id
                            int existingId = expense.id;

                            //*save to db
                            await context
                                .read<ExpenseDatabase>()
                                .updateExpense(existingId, updatedExpense);

                            //*clear text fields
                            nameController.clear();
                            amountController.clear();
                          }
                        },
                        child: const Text('Save'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ));
  }

  //* delete expense dialob box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          //*delete option
          _deleteButton(expense.id),

          //*cancel option
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      //* get dates
      int startMonth = value.getStartMonth();
      int startYear = value.getStartYear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      //* calculate number of months since first month
      int monthCount =
          calculateMonthCount(startYear, startMonth, currentMonth, currentYear);

      //* Only display expenses for the current month

      return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => newExpense(),
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      'Expenses',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                //* Bar graph
                SizedBox(
                  height: 300,
                  child: FutureBuilder(
                    future: _monthlyTotalsFuture,
                    builder: (context, snapshot) {
                      //*data is loaded
                      if (snapshot.connectionState == ConnectionState.done) {
                        final monthlyTotals = snapshot.data ?? {};
                  
                        //* create list of monthly summary
                        List<double> monthlySummary = List.generate(monthCount,
                            (index) => monthlyTotals[startMonth + index] ?? 0.0);
                  
                        return MyBarGraph(
                          monthlySummary: monthlySummary,
                          startMonth: startMonth,
                        );
                      } else {
                        return const Center(child: Text('Loading...'),);
                      }
                    },
                  ),
                ),
            
                //* List of expenses
                Expanded(
                  child: ListView.builder(
                    itemCount: value.allExpense.length,
                    itemBuilder: (context, index) {
                      //* Extract individual expense
                      Expense individualExpense = value.allExpense[index];
            
                      //* return ListTile
                      return MyListTile(
                        //* return ListTile
                        title: individualExpense.name,
                        trailing: formatAmount(individualExpense.amount),
                        onEditPressed: (context) =>
                            openEditBox(individualExpense, context),
                        onDeletePressed: (context) =>
                            openDeleteBox(individualExpense),
                      );
                    },
                  ),
                ),
              ],
            ),
          ));
    });
  }

  //* delete expense button
  Widget _deleteButton(int id) {
    return ElevatedButton(
      onPressed: () async {
        //* pop box
        Navigator.pop(context);

        //* delete from db
        await context.read<ExpenseDatabase>().deleteExpense(id);
      },
      child: const Text('Delete'),
    );
  }
}
