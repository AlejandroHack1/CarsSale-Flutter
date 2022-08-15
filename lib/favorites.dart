import 'dart:async';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'package:proyectofinal/Home.dart';
import 'dart:convert';
import 'main.dart';

class Cars {
  final String? id, price;
  final String? name, description, image_url;

  Cars({
    this.id,
    this.price,
    this.name,
    this.description,
    this.image_url,
  });

  factory Cars.fromJson(Map<String, dynamic> jsonData) {
    return Cars(
      id: jsonData['idImagen'],
      name: jsonData['nombre'],
      price: jsonData['precio'],
      description: jsonData['descripcion'],
      image_url: "http://192.168.56.1/flutter/" + jsonData['imagen_url'],
    );
  }
}

class FavoritesListView extends StatelessWidget {
  final List<Cars> Carss;

  FavoritesListView(this.Carss);

  Widget build(context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 12,
      itemCount: Carss.length,
      itemBuilder: (context, index) {
        var image_url, name, price;

        print(Carss[index].image_url);

        if (Carss[index].image_url != null) {
          image_url = Carss[index].image_url;
          name = Carss[index].name;
          price = Carss[index].price;
        }

        return new ListTile(
          title: new Card(
            elevation: 5.0,
            child: new Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.orange)),
              padding: EdgeInsets.all(5.0),
              margin: EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    child: Image.network(
                      image_url,
                      height: 200.0,
                    ),
                    padding: EdgeInsets.only(bottom: 5.0),
                  ),
                  //Row(children: <Widget>[
                  Padding(
                      child: new Text(
                        name,
                        style: new TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      /*padding: const EdgeInsets.only(
                            left: 110,
                          )),*/
                      padding: EdgeInsets.all(1.0)),
                  //Text(" | "),
                  Padding(
                      child: new Text(
                        "Precio: " + price,
                        style: new TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.left,
                      ),
                      padding: EdgeInsets.all(1.0)),
                  //]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

//Future is n object representing a delayed computation.
Future<List<Cars>> downloadJSON(String idUsuario) async {
  final jsonEndpoint = "http://192.168.56.1/flutter/listFavorites.php";

  final response = await get(Uri.parse(jsonEndpoint));

  if (response.statusCode == 200) {
    List cars = json.decode(response.body);
    List searchData = [];

    //if (!idUsuario.isEmpty) {

    cars.forEach((data) {
      if (data['idUsuario']
          .toString()
          .toLowerCase()
          .contains(idUsuario.toLowerCase().toString())) {
        searchData.add(
            data); // If not empty then add search data into search data list
      }
    });

    return searchData
        .map((searchData) => new Cars.fromJson(searchData))
        .toList();
    //}
  } else
    throw Exception('Error al obtener los datos en JSON.');
}

class FavoritePage extends StatelessWidget {
  static const String route = '/list-favorites';
  final String id;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        MyMainPage.route: (context) => MyMainPage(
              title: '',
            ),
        HomePage.route: (context) => HomePage(
              id: '',
              name: '',
            ),
      },
      theme: new ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: SelectionScreen(id),
    );
  }

  FavoritePage({Key? key, required this.id}) : super(key: key);
}

class SelectionScreen extends StatefulWidget {
  final String id;
  SelectionScreen(this.id);

  @override
  State<StatefulWidget> createState() {
    return FavoritesScreen(id);
  }
}

class FavoritesScreen extends State<SelectionScreen> {
  final String id;
  FavoritesScreen(this.id);

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Mi Lista Favoritos"),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepOrange,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              leading: Icon(
                Icons.favorite,
              ),
              title: const Text('Home'),
              onTap: () {
                Navigator.of(context).pushNamed(HomePage.route);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout_rounded,
              ),
              title: const Text('Salir'),
              onTap: () {
                Navigator.of(context).pushNamed(MyMainPage.route);
              },
            ),
          ],
        ),
      ),
      body: new Center(

          //FutureBuilder es un widget que se crea a sí mismo en función de la última instantánea
          // de interacción con un Futuro.
          child: new FutureBuilder<List<Cars>>(
        future: downloadJSON(id),

        //pasamos un BuildContext y un objeto AsyncSnapshot que es un
        //Representación inmutable de la interacción más reciente con
        //un cálculo asíncrono.
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Cars>? Carss = snapshot.data;
            return new FavoritesListView(Carss!);
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          //return  a circular progress indicator.
          return new CircularProgressIndicator();
        },
      )),
    );
  }
}
