import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'Connection.dart';
import 'config.dart';

import 'package:mqtt_dashboard/tempSwitch.dart';

import 'AccountSettings.dart';

List _temp = List();
TextEditingController _sName = TextEditingController();
TextEditingController _sTopic = TextEditingController();
TextEditingController _sTextOn = TextEditingController();
TextEditingController _sTextOff = TextEditingController();
TextEditingController _sPublishOn = TextEditingController();
TextEditingController _sPublishOff = TextEditingController();

TextEditingController _bName = TextEditingController();
TextEditingController _bTopic = TextEditingController();
TextEditingController _bTextOn = TextEditingController();
TextEditingController _bTextOff = TextEditingController();
TextEditingController _bPublishOn = TextEditingController();
TextEditingController _bPublishOff = TextEditingController();

class dashboard extends StatefulWidget {
  var _data;
  dashboard(var data) {
    this._data = data;
    if (_data != null) {
      _temp.add(_data);
    }
    //print(_temp.length);
  }
  @override
  State<StatefulWidget> createState() {
    return _dashboard(_data);
  }
}

// _incrementCounter() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   int counter = (prefs.getInt('counter') ?? 0) + 1;
//   print('Pressed $counter times.');
//   await prefs.setInt('counter', counter);
// }

class _dashboard extends State {
  var _data;
  _dashboard(var data) {
    this._data = data;
    _temp.add(_data);
  }

  List lst = List();
  int count = 0;

  @override
  void initState() {
    // _bodySwitch();
    // _bodyButton();
    super.initState();
  }

//ลบ card  ต่างๆ
  void _delete() {
    setState(() {
      lst.removeLast();
    });
  }

//card Switch

  void _bodySwitch() {
    String _name = _sName.text;
    String _valueOn = _sTextOn.text;
    String _valueOff = _sTextOff.text;
    Card bt = Card(
      child: ListTile(
        onLongPress: () {
          _menu(context);
        },
        title: Text(_name),
        // leading: Text(''),
        subtitle: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Text('_valueOn'),
            Padding(
              padding: EdgeInsets.only(right: 10),
            ),
            Icon(
              MdiIcons.toggleSwitch,
              size: 40,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
            ),
            new Text('_valueOff'),
            Padding(
              padding: EdgeInsets.only(right: 10),
            ),
          ],
        ),
        // trailing: Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: <Widget>[
        //     FlatButton(
        //       onPressed: _delete,
        //       child: Icon(MdiIcons.delete),
        //     ),
        //   ],
        // )
      ),
    );

    setState(() {
      lst.add(bt);
    });
  }

//card Button

  void _bodyButton() {
    String _name = _bName.text;
    String _valueOn = _bTextOn.text;
    String _valueOff = _bTextOff.text;
    Card bt = Card(
      child: ListTile(
        title: Text(_name),
        leading: Text(''),
        subtitle: RaisedButton(
          child: Text('$_valueOn'),
          onPressed: () {},
        ),
        trailing: FlatButton(
          onPressed: _delete,
          child: Icon(MdiIcons.delete),
        ),
      ),
    );
    setState(() {
      lst.add(bt);
    });
  }

//popup menu
  Future _menu(BuildContext context) async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {},
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 300),
                    Icon(Icons.create),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                    ),
                    const Text('Edit'),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {},
                child: Row(
                  children: <Widget>[
                    Icon(MdiIcons.delete),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                    ),
                    const Text('Delete'),
                  ],
                ),
              ),
            ],
          );
        });
  }

// popup Select Component

  Future _asyncSimpleDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            titlePadding: EdgeInsets.fromLTRB(15.0, 24.0, 24.0, 0.0),
            contentPadding: EdgeInsets.fromLTRB(0, 10.0, 12.0, 16.0),
            title: const Text('Select Component'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  _dialogButton(context);
                  _bName.clear();
                  _bTopic.clear();
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (BuildContext context) => addButton()));
                },
                child: Row(
                  children: <Widget>[
                    Icon(Icons.touch_app),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                    ),
                    const Text('Button'),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  _dialogSwtich(context);

                  // _dialogTimepicker(context);
                  _sName.clear();
                  _sTopic.clear();

                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (BuildContext context) => addSwitch()));
                },
                child: Row(
                  children: <Widget>[
                    Icon(MdiIcons.toggleSwitch),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                    ),
                    const Text('Switch'),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (BuildContext context) => addTimepicker()));
                },
                child: Row(
                  children: <Widget>[
                    Icon(Icons.av_timer),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                    ),
                    const Text('TimePicker'),
                  ],
                ),
              ),
            ],
          );
        });
  }

//_dialogButton

  Future<Null> _dialogButton(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Button'),
        contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 8),
        content: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _bName,
                  decoration: InputDecoration(
                    labelText: "Name",
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                TextFormField(
                  controller: _bTopic,
                  decoration: InputDecoration(
                    labelText: "Topic",
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Text",
                    hintText: "e.g.On,Off",
                    hintStyle: TextStyle(color: Colors.grey[300]),
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Text",
                    hintText: "e.g.On,Off",
                    hintStyle: TextStyle(color: Colors.grey[300]),
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                new Padding(padding: EdgeInsets.only(top: 8.0)),
                RaisedButton(
                  child: Text('ok'),
                  onPressed: () {
                    _bodyButton();
                    _bName.clear();
                    _bTopic.clear();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

//_dialogSwtich

  Future<Null> _dialogSwtich(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Swtich'),
        contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 8),
        content: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _sName,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                TextFormField(
                  controller: _sTopic,
                  decoration: InputDecoration(
                    labelText: "Topic",
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                TextFormField(
                  controller: _sTextOn,
                  decoration: InputDecoration(
                    labelText: "Text",
                    hintText: "e.g.On,Off",
                    hintStyle: TextStyle(color: Colors.grey[300]),
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                TextFormField(
                  controller: _sTextOff,
                  decoration: InputDecoration(
                    labelText: "Text",
                    hintText: "e.g.On,Off",
                    hintStyle: TextStyle(color: Colors.grey[300]),
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                new Padding(padding: EdgeInsets.only(top: 8.0)),
                RaisedButton(
                  child: Text('OK'),
                  onPressed: () {
                    _bodySwitch();
                    _sName.clear();
                    _sTopic.clear();
                    _sTextOn.clear();
                    _sTextOff.clear();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //dialogTimepicker

  // Future<Null> _dialogTimepicker(BuildContext context) {
  //   return showDialog(
  //     context: context,
  //     builder: (BuildContext context) => AlertDialog(
  //       title: Text('Swtich'),
  //       content: SingleChildScrollView(
  //         child: Container(
  //           child: Column(
  //             children: <Widget>[
  //               TextField(
  //                 controller: _sName,
  //                 decoration: InputDecoration(
  //                   hintText: "Name",
  //                   prefixIcon: const Icon(
  //                     Icons.create,
  //                     color: Colors.black,
  //                   ),
  //                 ),
  //               ),
  //               new Padding(padding: EdgeInsets.only(top: 5.0)),
  //               TextField(
  //                 controller: _sTopic,
  //                 decoration: InputDecoration(
  //                   hintText: "Topic",
  //                   prefixIcon: const Icon(
  //                     Icons.create,
  //                     color: Colors.black,
  //                   ),
  //                 ),
  //               ),
  //               new Padding(padding: EdgeInsets.only(top: 5.0)),
  //               TextField(
  //                 decoration: InputDecoration(
  //                   hintText: "test",
  //                   prefixIcon: const Icon(
  //                     Icons.create,
  //                     color: Colors.black,
  //                   ),
  //                 ),
  //               ),
  //               new Padding(padding: EdgeInsets.only(top: 5.0)),
  //               TextField(
  //                 decoration: InputDecoration(
  //                   hintText: "test",
  //                   prefixIcon: const Icon(
  //                     Icons.create,
  //                     color: Colors.black,
  //                   ),
  //                 ),
  //               ),
  //               new Padding(padding: EdgeInsets.only(top: 5.0)),
  //               RaisedButton(
  //                 child: Text('ok'),
  //                 onPressed: () {
  //                   // _bodySwitch();
  //                   // _sname.clear();
  //                   // _stopic.clear();
  //                   Navigator.pop(context);
  //                   Navigator.pop(context);
  //                 },
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget bodyBuild(BuildContext contex, int index) {
    return lst[index];
  }

//ส่วนข้อมูลผู้ใช้งาน

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.grey[300]),
          title: Text('Dashboard', style: TextStyle(color: Colors.grey[300])),
          backgroundColor: Colors.black,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _asyncSimpleDialog(context);
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.black,
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(3),
          itemBuilder: bodyBuild,
          itemCount: lst.length,
        ),
        drawer: new Container(
          constraints: new BoxConstraints.expand(
            width: MediaQuery.of(context).size.width - 90,
          ),
          color: Colors.white,
          alignment: Alignment.center,
          child: new ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              new DrawerHeader(
                  padding: const EdgeInsets.all(16.0),
                  child: new UserAccountsDrawerHeader(
                    accountName: new Text(
                      'Someusername',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    accountEmail: new Text(
                      'Someemail@flutter.com',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    currentAccountPicture: FlutterLogo(),
                    decoration: new BoxDecoration(
                      color: Colors.black,
                    ),
                  ),
                  decoration: new BoxDecoration(color: Colors.black)),
              new ListTile(
                  leading: new Icon(Icons.link),
                  title: new Text("Connection"),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => connectionPage()));
                  }),
              new ListTile(
                  leading: new Icon(Icons.person),
                  title: new Text("Account Settings"),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => accountSettings()));
                  }),
              new ListTile(
                  leading: new Icon(Icons.close),
                  title: new Text("Close"),
                  onTap: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        ));
  }
}
