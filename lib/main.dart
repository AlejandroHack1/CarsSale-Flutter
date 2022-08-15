import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyectofinal/register.dart';
import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        HomePage.route: (context) => HomePage(
              name: '',
              id: '',
            ),
      },
      title: 'Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color.fromRGBO(235, 31, 42, 1),
        accentColor: Colors.orange[600],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyMainPage(title: 'Login'),
    );
  }
}

class MyMainPage extends StatefulWidget {
  static const String route = '/main';

  MyMainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyMainPage> {
  //For LinearProgressIndicator.
  bool _visible = false;

  //Textediting Controller for Username and Password Input
  final userController = TextEditingController();
  final pwdController = TextEditingController();

  Future userLogin() async {
    //Login API URL

    String url = "http://192.168.56.1/flutter/login.php";

    // Linea de progreso.
    setState(() {
      _visible = true;
    });

    // Obtener nombre y password del controlador
    var data = {
      'correo': userController.text,
      'password': pwdController.text,
    };

    //Web API Call.
    var response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(data));

    if (response.statusCode == 200) {
      print(response.body);
      var msg = jsonDecode(response.body);

      //Login Status
      if (msg['loginStatus'] == true) {
        setState(() {
          //ocultar indicador de progreso
          _visible = false;
        });

        // Navegar a página Home

        //Navigator.of(context).pushNamed(HomePage.route);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                    name: msg['userInfo']['nombre'],
                    id: msg['userInfo']['idUsuario'])));
        //HomePage()));
      } else {
        setState(() {
          //ocultar indicador de progreso
          _visible = false;

          //Mostrar Mensaje de error
          showMessage(msg["message"]);
        });
      }
    } else {
      setState(() {
        //ocultar indicador de progreso
        _visible = false;

        //Mostrar Mensaje de error
        showMessage("Error Durante Conexión al Servidor.");
      });
    }
  }

  Future<dynamic> showMessage(String msg) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(msg),
          actions: <Widget>[
            TextButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              visible: _visible,
              child: Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: LinearProgressIndicator(),
              ),
            ),
            Container(
              height: 100.0,
            ),
            new Tab(
                icon: new Image.asset("assets/images/logo.jpg"), height: 110.0),

            /*Icon(
              Icons.group,
              color: Theme.of(context).primaryColor,
              size: 80.0,
            ),*/
            SizedBox(
              height: 10.0,
            ),
            Text(
              'Ingreso',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 40.0,
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Theme(
                      data: new ThemeData(
                        primaryColor: Color.fromRGBO(84, 87, 90, 0.5),
                        primaryColorDark: Color.fromRGBO(84, 87, 90, 0.5),
                        hintColor:
                            Color.fromRGBO(84, 87, 90, 0.5), //placeholder color
                      ),
                      child: TextFormField(
                        controller: userController,
                        decoration: InputDecoration(
                          focusedBorder: new OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(84, 87, 90, 0.5),
                              style: BorderStyle.solid,
                            ),
                          ),
                          enabledBorder: new OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(84, 87, 90, 0.5),
                              style: BorderStyle.solid,
                            ),
                          ),
                          errorBorder: new OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                          labelText: 'Ingrese email',
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Color.fromRGBO(84, 87, 90, 0.5),
                          ),
                          border: new OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(84, 87, 90, 0.5),
                              style: BorderStyle.solid,
                            ),
                          ),
                          hintText: 'email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Favor Ingrese email';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Theme(
                      data: new ThemeData(
                        primaryColor: Color.fromRGBO(84, 87, 90, 0.5),
                        primaryColorDark: Color.fromRGBO(84, 87, 90, 0.5),
                        hintColor:
                            Color.fromRGBO(84, 87, 90, 0.5), //placeholder color
                      ),
                      child: TextFormField(
                        controller: pwdController,
                        obscureText: true,
                        decoration: InputDecoration(
                          focusedBorder: new OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(84, 87, 90, 0.5),
                              style: BorderStyle.solid,
                            ),
                          ),
                          enabledBorder: new OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(84, 87, 90, 0.5),
                              style: BorderStyle.solid,
                            ),
                          ),
                          errorBorder: new OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                          border: new OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(84, 87, 90, 0.5),
                              style: BorderStyle.solid,
                            ),
                          ),
                          labelText: 'Ingrese Contraseña',
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color.fromRGBO(84, 87, 90, 0.5),
                          ),
                          hintText: 'Contraseña',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Favor Ingrese Contraseña';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_formKey.currentState!.validate()) {userLogin()}
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Ingresar',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyRegisterPage(
                                        title: 'Registro',
                                      )))
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Registro',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
