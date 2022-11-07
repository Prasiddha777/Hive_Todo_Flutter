import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_storage/models/data_model.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  //For validation
  final _formGlobalKey = GlobalKey<FormState>();

  //TextController for text fields
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  var selectedValue;

  //for dropdown list
  var metrics = [
    'Kg',
    'ltr',
    'gram',
    'dozen',
    'nos',
  ];

  //
  var box;

  //
  var items = [];
  //
  void getItems() async {
    box = await Hive.openBox('hive_box');
    setState(() {
      items = box.values.toList().reversed.toList();
    });
  }

  //
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of items'),
      ),
      body: items.length == 0
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, index) {
                return Card(
                  child: ListTile(
                      title: Text(items[index].item),
                      subtitle: Row(
                        children: [
                          Text(items[index].quantity),
                          Text(items[index].metrics.toString()),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              _showForm(context, items[index].key, index);
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () async {
                              box = await Hive.openBox('hive_box');
                              box.delete(items[index].key);
                              getItems();
                            },
                            icon: Icon(Icons.delete),
                          )
                        ],
                      )),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm(context, null, null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  //
  void _showForm(BuildContext context, var itemKey, var index) {
    if (itemKey != null) {
      _itemController.text = items[index].item;
      _quantityController.text = items[index].quantity.toString();
      selectedValue = items[index].metrics;
    }
    showModalBottomSheet(
      isDismissible: false,
      isScrollControlled: false,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 15,
          right: 15,
          left: 15,
        ),
        child: Form(
          key: _formGlobalKey,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Item
                TextFormField(
                  controller: _itemController,
                  validator: (value) {
                    if (value!.isEmpty || value == null) {
                      return 'The current field is empty';
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Item Name',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                //Quantity
                TextFormField(
                  controller: _quantityController,
                  validator: (value) {
                    if (value!.isEmpty || value == null) {
                      return 'The current field is empty';
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Item Quantity',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                //DropDown
                DropdownButtonFormField(
                  value: selectedValue,
                  hint: const Text('Select Metrics'),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  )),
                  validator: (newvalue) {
                    if (selectedValue == null) {
                      return 'Metrics is Required';
                    } else {
                      return null;
                    }
                  },
                  items: metrics.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                  },
                ),
                const SizedBox(
                  height: 10,
                ),

                //Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Exit'),
                    ),
                    //
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (_formGlobalKey.currentState!.validate()) {
                          box = await Hive.openBox('hive_box');
                          DataModel dataModel = DataModel(
                            item: _itemController.text,
                            quantity: _quantityController.text,
                            metrics: selectedValue,
                          );
                          if (itemKey == null) {
                            box.add(dataModel);
                            setState(() {
                              _itemController.text = '';
                              _quantityController.text = '';
                              selectedValue = null;
                            });
                            Navigator.pop(context);
                            // getItems();
                          } else {
                            box.put(itemKey, dataModel);
                            Navigator.pop(context);
                            setState(() {
                              _itemController.text = '';
                              _quantityController.text = '';
                              selectedValue = null;
                            });

                            // getItems();
                          }
                          getItems();
                        }
                      },
                      child: Text(itemKey == null ? 'Create new' : 'Update'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
