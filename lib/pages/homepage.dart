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
                    
                    if (
                      nameController.text.isNotEmpty ||  amountController.text.isNotEmpty
                    ) {
                      //*pop box
                      Navigator.pop(context);

                      //*create new updated expense
                      Expense updatedExpense = Expense(
                        name: nameController.text.isNotEmpty ? nameController.text : existingName,
                        amount: amountController.text.isNotEmpty ? double.parse(amountController.text) : double.parse(existingAmount),
                        date: DateTime.now()
                      );

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
      )
    );
  }

  //* delete expense dialob box
  void openDeleteBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
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
                onEditPressed: (context) => openEditBox(individualExpense, context),
                onDeletePressed: (context) => openDeleteBox,
              );
            },
          )),
    );
  }
}
