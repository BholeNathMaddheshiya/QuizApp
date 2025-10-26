
import 'package:bnultrasoft/theme/theme.dart';
import 'package:bnultrasoft/view/admin/manage_quizes_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bnultrasoft/model/category.dart';


class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          "Manage Categories",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: AppTheme.primaryColor, // You can replace this with AppTheme.primaryColor if defined
            onPressed: (){

            },


          ),
        ],
      ),
    body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("categories").orderBy('name').snapshots(),
        builder:(context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
              // child: Text("No data found"),
            );
          }
          final categories = snapshot.data!.docs
              .map((doc) =>
              Category.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: AppTheme.textSecondaryColor,
                  ),
                  SizedBox(height: 16),
                  Text("No categories found",
                   style: TextStyle(
                     color: AppTheme.textSecondaryColor,
                     fontSize: 18,
                   ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                      onPressed: (){

                      },
                      child: Text("Add Category"),
                  )
                ],
              ), // Column
            ); // Center
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final Category category = categories[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.category_outlined,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    category.description,

                    ),
                  trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                            value: "edit",
                            child: ListTile(
                              leading: Icon(
                                Icons.edit,
                                color: AppTheme.primaryColor,
                              ),
                              title: Text("Edit"),
                              contentPadding: EdgeInsets.zero,
                            ),
                        ),
                        PopupMenuItem(
                          value: "delete",
                          child: ListTile(
                            leading: Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            title: Text("Delete"),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    onSelected: (value){
                        _handleCategoryAction(context,value,category);
                        },
                     ),
                  onTap: (){
                    Navigator.push(
                        context,MaterialPageRoute(
                        builder: (context)=>
                            ManageQuizzesScreen()));
                  },

                  ),
                );

            },
          );
        },
      ),
    );
  }

  Future<void> _handleCategoryAction(
      BuildContext context, String action, Category category) async {
    if (action == "edit") {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => AddCategoryScreen(category: category),
      //   ),
      // );
    } else if (action == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Delete Category"),
          content: Text("Are you sure you want to delete this category?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text("Cancel"),
            ), // TextButton
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.redAccent,
                ), // TextStyle
              ), // Text
            ), // TextButton
          ],
        ), // AlertDialog
      );
      if(confirm == true){
        await _firestore.collection("categories").doc(category.id).delete();
      }
    }
  }

}