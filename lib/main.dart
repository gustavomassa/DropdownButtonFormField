import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      theme: ThemeData.dark(),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Future<FormDependency> _dependencies;
  Model _model;

  List<Tecnology> _tecnologyList;
  Tecnology _currentTecnology;
  List<Tecnology> _currentTecnologyList;

  @override
  void initState() {
    super.initState();

    _model = Model(category: null, tecnology: null);
    _tecnologyList = null;
    _currentTecnology = null;
    _currentTecnologyList = null;

    _dependencies = _getFormDependency();
  }

  Future<FormDependency> _getFormDependency() async {
    var web = Category(id: 1, name: 'Web');
    var mobile = Category(id: 2, name: 'Mobile');
    var desktop = Category(id: 3, name: 'Desktop');

    var categoryList = [web, mobile, desktop];
    var tecnologyList = [
      Tecnology(id: 1, name: 'Angular', category: web),
      Tecnology(id: 2, name: 'React', category: web),
      Tecnology(id: 3, name: 'Vue', category: web),
      Tecnology(id: 3, name: 'Flutter', category: mobile),
      Tecnology(id: 4, name: 'Electron', category: desktop),
      Tecnology(id: 4, name: 'GTK', category: desktop),
    ];

    // Init tecnology variables
    _tecnologyList = tecnologyList;
    _currentTecnology = _tecnologyList[0];
    _currentTecnologyList = _tecnologyList
        .where((x) => x.category.id == categoryList[0].id)
        .toList();

    return FormDependency(categories: categoryList, tecnologies: tecnologyList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Material Form'),
      ),
      body: FutureBuilder<FormDependency>(
          future: _dependencies,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.only(top: 12.0, left: 5.0, right: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _buildForm(context, snapshot.data),
                  ),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  List<Widget> _buildForm(BuildContext context, FormDependency data) {
    List<Widget> form = [];

    // Category
    form.add(CustomDropDownInput<Category>(
      labelText: 'Category',
      optional: false,
      enabled: true,
      initialValue: data.categories[0],
      itemList: data.categories.map((Category category) {
        return DropdownMenuItem<Category>(
          value: category,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (newValue) {
        // Update model
        _model.category = newValue;
        _model.tecnology = null;

        // Reset tecnology dropdown value and update the item list based on the category selected
        setState(() {
          _currentTecnology =
              null; //null is passed to the dropdown build, but the internal valu of dropdown does not set the null value
          _currentTecnologyList = _tecnologyList
              .where((x) => x.category.id == newValue.id)
              .toList();
        });
      },
    ));

    // Tecnologies
    form.add(CustomDropDownInput<Tecnology>(
      labelText: 'Tecnology',
      optional: false,
      enabled: true,
      initialValue: _currentTecnology,
      itemList: (_currentTecnologyList != null)
          ? _currentTecnologyList.map((Tecnology tecnology) {
              return DropdownMenuItem<Tecnology>(
                value: tecnology,
                child: Text(tecnology.name),
              );
            }).toList()
          : null,
      onChanged: (newValue) {
        // Update model
        _model.tecnology = newValue;

        // Update initialValue
        setState(() {
          _currentTecnology = newValue;
        });
      },
    ));

    return form;
  }
}

class Category {
  final id;
  final name;

  Category({@required this.id, @required this.name});
}

class Tecnology {
  final id;
  final name;
  final Category category;

  Tecnology({@required this.id, @required this.name, @required this.category});
}

class FormDependency {
  final List<Category> categories;
  final List<Tecnology> tecnologies;

  FormDependency({@required this.categories, @required this.tecnologies});
}

class Model {
  Category category;
  Tecnology tecnology;

  Model({@required this.category, @required this.tecnology});
}

class CustomDropDownInput<T> extends StatelessWidget {
  const CustomDropDownInput({
    Key key,
    @required this.labelText,
    @required this.itemList,
    @required this.onChanged,
    this.initialValue,
    this.show,
    this.enabled,
    this.optional,
  }) : super(key: key);

  final String labelText;
  final List<DropdownMenuItem<T>> itemList;
  final ValueChanged<T> onChanged;
  final T initialValue;
  final bool show;
  final bool enabled;
  final bool optional;

  String _validateOptional(T value) {
    if (value == null) return "Campo obrigatório";

    return null;
  }

  void _handleOnChanged(T newValue) {
    if (newValue != null) {
      // Call onChanged callback if registered
      if (onChanged != null) onChanged(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return (show == null || show == true)
        ? Column(
            children: <Widget>[
              DropdownButtonFormField(
                icon: Icon(Icons.search),
                isDense: true,
                decoration: InputDecoration(
                  labelText: labelText,
                  labelStyle: TextStyle(
                    color: (optional != null && optional == false)
                        ? Colors.redAccent
                        : Colors.black38,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                  filled: false,
                  border: const OutlineInputBorder(),
                ),
                validator: (optional != null && optional == false)
                    ? _validateOptional
                    : null,
                disabledHint: (enabled != null &&
                        enabled == false &&
                        itemList != null &&
                        initialValue != null)
                    ? itemList.firstWhere((x) => x.value == initialValue).child
                    : null,
                items: (enabled != null && enabled == false) ? null : itemList,
                onChanged: _handleOnChanged,
                value: initialValue,
              ),
              const SizedBox(
                height: 20.0,
              )
            ],
          )
        : Container();
  }
}
