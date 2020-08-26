import 'package:Spacekraft1/httprequest/db_request.dart';
import 'package:Spacekraft1/sharedpreference/sharedutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Spacekraft1/battleships.dart';
import 'package:Spacekraft1/game.dart';
import 'package:flame/util.dart';
import 'package:Spacekraft1/sqlite/userdata.dart';


void main() async {
  Util flameUtil = Util();
  WidgetsFlutterBinding.ensureInitialized();// to Bind the Utility flame widgets
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.landscapeLeft);
  runApp(MyApp());

}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spacekraft',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/':(context)=>Main(),
        '/ships':(context)=>Ships(),
        '/game':(context)=>Game(context).widget,
      },
    );
  }
}

class Main extends StatefulWidget {
  @override
  MainMenu createState() => MainMenu();
}

class MainMenu extends State<Main>{
final SharedUtil pref = new SharedUtil();
TextEditingController username = TextEditingController();
TextEditingController password = TextEditingController();
ScrollController _scrollController;
final formKey = new GlobalKey<FormState>();
bool access = false;
List<UserData> userData;

MainMenu(){
  init();
}

void init() async {
  await pref.hasCacheData() ? await DbRequest.updateData() : pref.setDefault();
}

  Widget _menuButton(num h,num w,String txt,double size,String destination){
    return Container(
      margin: EdgeInsets.only(top: 5.0,bottom: 5.0),
      height: h/1,
      width: w/1,
      child: RaisedButton(
        onPressed: (){_nav(destination);},
        child: Text(txt,style: TextStyle(fontSize: size),),
        color: Color.fromRGBO(92, 92, 92, 1),
      ),
    );
  }

  Widget buttonAccount(){
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: Color.fromRGBO(92, 92, 92, 1),
      overlayOpacity:0,
      children: [
        SpeedDialChild(
          child: Icon(Icons.account_circle),
          backgroundColor: Color.fromRGBO(92, 92, 92, 1),
          onTap: (){modalLogin(context);},
        ),
        SpeedDialChild(
          child: Icon(Icons.person_add),
          backgroundColor: Color.fromRGBO(92, 92, 92, 1),
          onTap: (){modalRegister(context);},
        ),
        SpeedDialChild(
          child: Icon(Icons.poll),
          backgroundColor: Color.fromRGBO(92, 92, 92, 1),
          onTap: (){modalLeader(context);},
        ),
      ],
    );
  }

  Future<bool> modalLogin(context){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context){
        return AlertDialog(
          content: form(context),
        );
      }
    );
  }

  Future<bool> modalRegister(context){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context){
        return AlertDialog(
          content: form2(),
        );
      }
    );
  }

  Future<bool> modalLeader(context){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context){
        return AlertDialog(
          content: leaderboard(),
        );
      }
    );
  }

  Widget form(BuildContext context){
    return SingleChildScrollView(
      controller: _scrollController,
        child: Column(
          children: <Widget>[
            Container(
              child: Text("LOGIN",textScaleFactor: 2.0,),
            ),
            Form(
              key: formKey,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: TextFormField(
                        controller: username,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(labelText: 'Username'),
                        validator: (val) => !access ? 'Invalid Username' : null,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: TextFormField(
                        controller: password,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(labelText: 'Password'),
                        validator: (val) => !access ? 'Invalid Password' : null,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            color: Colors.blue,
                            margin: EdgeInsets.all(5.0),
                            child: FlatButton(
                              onPressed: validateLogin,
                              child: Text('Login'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.green,
                            margin: EdgeInsets.all(5.0),
                            child: FlatButton(
                              onPressed: (){Navigator.pop(context);cleartxt();},
                              child: Text('Cancel'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget form2(){
    return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Text("REGISTER",textScaleFactor: 2.0,),
            ),
            Form(
              key: formKey,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: TextFormField(
                        controller: username,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(labelText: 'Username'),
                        validator: (val) => val.length==0 ? 'Invalid Username' : null,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: TextFormField(
                        controller: password,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(labelText: 'Password'),
                        validator: (val) => val.length<6 ? 'Invalid Password' : null,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            color: Colors.blue,
                            margin: EdgeInsets.all(5.0),
                            child: FlatButton(
                              onPressed: validateReg,
                              child: Text('Register'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.red,
                            margin: EdgeInsets.all(5.0),
                            child: FlatButton(
                              onPressed: (){Navigator.pop(context);cleartxt();},
                              child: Text('Cancel'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }
  Widget leaderboard(){
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(1),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(3),
                    decoration: BoxDecoration(),
                    child: Text('LeaderBoard',
                           textAlign: TextAlign.center,
                           style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold),),
                  ),
                ),
              ],
            ),
            leaderData(),
          ],
        ),
      ),
    );
  }

  Widget leaderData(){
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          FutureBuilder<List<UserData>>(
            future: DbRequest.getByHiScore(),
            builder: (_,snapshot){
              if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                return DataTable(
                  columns: [
                    DataColumn(label: Text('Name',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,decorationColor: Colors.black))),
                    DataColumn(label: Text('HighScores',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,decorationColor: Colors.black))),
                  ], 
                  rows: snapshot.data.map((data) => DataRow(
                    cells: [
                      DataCell(Center(child:Text(data.username))),
                      DataCell(Center(child: Text(data.hiScore)))
                    ]
                    )
                  ).toList()
                );
              }
              return Center(child: CircularProgressIndicator(),);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
            color: Color.fromRGBO(124, 124, 124, 0.5),
            child: Center(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 30.0,bottom: 5.0),
                      child: Text("Spacekraft",
                      style: TextStyle(fontSize: 100.0,fontWeight: FontWeight.w900)
                      ),
                    ),
                    _menuButton(60, 150, "Start",20.0,"/game"),
                    _menuButton(60, 150, "BattleShips",20.0,"/ships"),
                    _menuButton(60, 150, "Quit",20.0,"quit"),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: buttonAccount(),
    );
  }

  cleartxt(){
    setState(() {
      username.text='';
      password.text='';
    });
  }

  validateLogin() async {
    await DbRequest.checkAcess(username.text,password.text)? access = true : access = false;
    if(formKey.currentState.validate() && access){
      formKey.currentState.save();
      await pref.setName(username.text);
      Navigator.popAndPushNamed(context, '/');
    }
  }
  validateReg() async{
    if(formKey.currentState.validate()){
      await DbRequest.saveAccount(username.text,password.text);
      formKey.currentState.save();
      cleartxt();
      Navigator.popAndPushNamed(context, '/');
    }
  }
  

  void _nav(String destination){
    destination != "quit" ? Navigator.pushNamed(context, destination) : SystemNavigator.pop();
  }
}
