import 'package:flutter/material.dart';
import 'package:mercury/components/list_tile.dart';
import 'package:mercury/database/expense_database.dart';
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

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) => Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => newExpense(),
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: ListView.builder(
            itemCount: value.allExpense.length,
            itemBuilder: (context, index) {
              //* Extract individual expense
              Expense individualExpense = value.allExpense[index];

              //* return ListTile
              return MyListTile(
                //* return ListTile
                title: individualExpense.name,
                trailing: formatAmount(individualExpense.amount),
              );
            },
          )),
    );
  }
}
