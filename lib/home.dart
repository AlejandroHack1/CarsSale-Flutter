import 'dart:async';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show Response, get, post;
import 'package:proyectofinal/favorites.dart';
import 'main.dart';
import 'package:payu/payu.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Cars {
  final String? id, price;
  final String? name, description, image_url, video_url;

  Cars({
    this.id,
    this.price,
    this.name,
    this.description,
    this.image_url,
    this.video_url,
  });

  factory Cars.fromJson(Map<String, dynamic> jsonData) {
    return Cars(
        id: jsonData['idImagen'],
        name: jsonData['nombre'],
        price: jsonData['precio'],
        description: jsonData['descripcion'],
        //image_url: "http://192.168.56.1/flutter/" + jsonData['imagen_url'],
        image_url: jsonData['imagen_url'],
        video_url: jsonData['video_url']);
  }
}

class CustomListView extends StatelessWidget {
  final List<Cars> Carss;

  String id;

  CustomListView(this.Carss, this.id);

  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          children: <Widget>[
            Padding(
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                  ),
                  items: [
                    "assets/images/slide1.jpg",
                    "assets/images/slide2.jpg",
                    "assets/images/slide3.jpg",
                    "assets/images/slide4.jpg",
                    "assets/images/slide5.jpg"
                  ].map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 1.0),
                          child: new Image.asset(
                            '$i',
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                padding: EdgeInsets.all(1.0)),
            Flexible(
              child: new MasonryGridView.count(
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
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange)),
                          padding: EdgeInsets.all(5.0),
                          margin: EdgeInsets.all(5.0),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                child: Image.network(
                                  "http://192.168.56.1/flutter/" +image_url.split(',')[0],
                                  height: 200.0,
                                ),
                                padding: EdgeInsets.only(bottom: 5.0),
                              ),
                              //Row(children: <Widget>[
                              Padding(
                                  child: new Text(
                                    name,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left,
                                  ),
                                  /*padding: const EdgeInsets.only(
                            left: 110,
                          )),*/
                                  padding: EdgeInsets.all(1.0)),
                              //Text(" | "),
                              Padding(
                                  child: new Text(
                                    "Precio: \$" + formatCurrency(price),
                                    style: new TextStyle(
                                        fontStyle: FontStyle.italic),
                                    textAlign: TextAlign.left,
                                  ),
                                  padding: EdgeInsets.all(1.0)),
                              //]),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        var route = new MaterialPageRoute(
                          builder: (BuildContext context) => new SecondScreen(
                            value: Carss[index],
                            id: id,
                          ),
                        );

                        Navigator.of(context).push(route);
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatCurrency(price) {
    var currency = int.parse(price);
    var formatCO = NumberFormat.currency(
        locale: 'es_CO', name: 'COP', symbol: "", decimalDigits: 0);

    return formatCO.format(currency);
  }
}

//Future is n object representing a delayed computation.
Future<List<Cars>> downloadJSON(String text) async {
  final jsonEndpoint = "http://192.168.56.1/flutter/getAutos.php";

  final response = await get(Uri.parse(jsonEndpoint));

  if (response.statusCode == 200) {
    List cars = json.decode(response.body);

    List searchData = [];

    if (text.isEmpty) {
      print('texto' + text);

      return cars.map((cars) => new Cars.fromJson(cars)).toList();
    } else {
      cars.forEach((data) {
        if (data['nombre']
            .toString()
            .toLowerCase()
            .contains(text.toLowerCase().toString())) {
          searchData.add(
              data); // If not empty then add search data into search data list
        }
      });

      return searchData
          .map((searchData) => new Cars.fromJson(searchData))
          .toList();
    }
  } else
    throw Exception('Error al obtener los datos en JSON.');
}

class SecondScreen extends StatefulWidget {
  final Cars value;
  final String id;

  SecondScreen({Key? key, required this.value, required this.id})
      : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState(id);
}

class _SecondScreenState extends State<SecondScreen> {
  final String id;
  _SecondScreenState(this.id);

  List favorites = [];
  List searchFavorites = [];
  bool visible = false;
  bool ShowFavorites = false;

  late YoutubePlayerController _controller;

  @override
  void initState() {
    if ('${widget.value.video_url}' != '') {
      String videoId =
          YoutubePlayer.convertUrlToId('${widget.value.video_url}')!;
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          mute: false,
          autoPlay: true,
        ),
      );
      super.initState();
    }
  }

  Future<bool> getLocalJsonFavorites(String? idImagen, String idUsuario) async {
    final jsonEndpoint = "http://192.168.56.1/flutter/getFavorites.php";

    final response = await get(Uri.parse(jsonEndpoint));
    if (response.statusCode == 200) {
      List result = json.decode(response.body);

      favorites = json.decode(response.body);
    }

    favorites.forEach((data) {
      if (data['idImagen'].toString().contains(idImagen!) &&
          data['idUsuario'].toString().contains(idUsuario)) {
        searchFavorites.add(data);
      }
    });

    if (searchFavorites.length != 0) {
      ShowFavorites = true;
    } else {
      ShowFavorites = false;
    }

    return ShowFavorites;
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = '${widget.value.image_url}'.split(',');

    return new Scaffold(
      appBar: new AppBar(title: new Text('Detalles')),
      body: new Container(
        child: new Center(
          child: Column(
            children: <Widget>[
              Padding(
                child: new Text(
                  '${widget.value.name}',
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20.0),
                  textAlign: TextAlign.center,
                ),
                padding: EdgeInsets.only(top: 10.0),
              ),
              Padding(
                  child: FutureBuilder<bool>(
                    future: getLocalJsonFavorites(widget.value.id, this.id),
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.hasData)
                        return FavoriteButton(
                          isFavorite: snapshot.data,
                          valueChanged: (_isFavorite) {
                            addFavorite(_isFavorite, widget.value.id, this.id);
                          },
                        );
                      return new CircularProgressIndicator();
                    },
                  ),
                  padding: EdgeInsets.only(top: 10.0)),
              Padding(
                  child: '${widget.value.video_url}' != ''
                      ? CarouselSlider(
                          options: CarouselOptions(height: 200.0),
                          items: [
                            '${widget.value.image_url}',
                            '${widget.value.video_url}'
                          ].map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 2.0),
                                  child: '$i' == '${widget.value.image_url}'
                                      ? new Image.network(
                                          "http://192.168.56.1/flutter/" +'$i',
                                        )
                                      : YoutubePlayer(
                                          controller: _controller,
                                          showVideoProgressIndicator: true,
                                          onReady: () {
                                            print('Player is ready.');
                                          },
                                        ),
                                );
                              },
                            );
                          }).toList(),
                        )
                      : images.length > 1
                          ? CarouselSlider(
                              options: CarouselOptions(height: 200.0),
                              items: images.map((i) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 2.0),
                                        child: new Image.network(
                                          "http://192.168.56.1/flutter/" +'$i',
                                        ));
                                  },
                                );
                              }).toList(),
                            )
                          : Image.network("http://192.168.56.1/flutter/" +'${widget.value.image_url}',
                              height: 200.0),

                  /*ListView.builder(
                          itemCount: images.length,
                          itemBuilder: (context, index) =>
                              Image.network('${images[index]}', height: 200.0)),*/
                  padding: EdgeInsets.all(1.0)),
              /* Padding(
                //`widget` es la configuración actual. La configuración de un objeto State
                //es la instancia de StatefulWidget correspondiente.
                child:
                    Image.network('${widget.value.image_url}', height: 200.0),
                padding: EdgeInsets.all(12.0),
              ),
              Padding(
                  child: YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: true,
                    /*videoProgressIndicatorColor: Colors.amber,
                    progressColors: ProgressColors(
                      playedColor: Colors.amber,
                      handleColor: Colors.amberAccent,
                    ),*/
                    onReady: () {
                      print('Player is ready.');
                    },
                  ),
                  padding: EdgeInsets.all(1.0)),*/
              Padding(
                child: new Text(
                  'Precio : \$${fotmatCurrency(widget.value.price)}',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                padding: EdgeInsets.all(20.0),
              ),
              Padding(
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddCardPage()));
                      },
                      child: Text('Comprar')),
                  padding: EdgeInsets.only(top: 10.0)),
              Container(
                height: 150,
                width: 400,
                padding: const EdgeInsets.all(10),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Center(
                    child: Text(
                      '${widget.value.description}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future addFavorite(isFavorite, String? idImagen, String idUsuario) async {
    //Reistrar API URL

    String url = "http://192.168.56.1/flutter/addFavorites.php";

    // mostrar progreso.
    setState(() {
      visible = true;
    });

    // Obtener datos del controlador
    var data = {
      'idImagen': idImagen,
      'idUsuario': idUsuario,
      'isSelected': isFavorite,
    };

    //llamado web API.
    var response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(data));

    //respuesta servidor
    if (response.statusCode == 200) {
      print(response.body);
      var msg = jsonDecode(response.body);

      //Verificar Estado Registro
      if (msg['registerStatus'] == true) {
        setState(() {
          //ocultar indicador de progreso
          visible = false;
        });

        //Mostrar Mensaje.
        showMessage(msg["message"]);
      } else {
        setState(() {
          //ocultar indicador de progreso
          visible = false;

          //Mostrar Mensaje de error
          showMessage(msg["message"]);
        });
      }
    } else {
      setState(() {
        //ocultar indicador de progreso
        visible = false;

        //Mostrar Mensaje de error
        showMessage("Error Durante la Conexión al Servidor.");
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

  fotmatCurrency(price) {
    var currency = int.parse(price);
    var formatCO = NumberFormat.currency(
        locale: 'es_CO', name: 'COP', symbol: "", decimalDigits: 0);

    return formatCO.format(currency);
  }

  check() {}
}

class HomePage extends StatelessWidget {
  static const String route = '/home';

  final String name;
  final String id;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        MyMainPage.route: (context) => MyMainPage(
              title: '',
            ),
        FavoritePage.route: (context) => FavoritePage(
              id: id,
            ),
      },
      theme: new ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: SelectionScreen(name, id),
    );
  }

  const HomePage({Key? key, required this.name, required this.id})
      : super(key: key);
}

class SelectionScreen extends StatefulWidget {
  final String name;
  final String id;

  SelectionScreen(this.name, this.id);

  @override
  State<StatefulWidget> createState() {
    return _selectionScreen(name, id);
  }
}

class _selectionScreen extends State<SelectionScreen> {
  final String name;
  final String id;

  _selectionScreen(this.name, this.id);

  List fullData = [];
  List searchData = [];
  TextEditingController textEditingController = new TextEditingController();
  String query = '';

  @override
  initState() {
    super.initState();
    getLocalJsonData();
  }

  Future getLocalJsonData() async {
    final jsonEndpoint = "http://192.168.56.1/flutter/getAutos.php";

    final response = await get(Uri.parse(jsonEndpoint));

    if (response.statusCode == 200) {
      fullData = json.decode(response.body);
    }
  }

  onSearchTextChanged(String text) async {
    searchData.clear();
    if (text.isEmpty) {
      // Check textfield is empty or not
      setState(() {});
      return;
    }

    fullData.forEach((data) {
      if (data['nombre']
          .toString()
          .toLowerCase()
          .contains(text.toLowerCase().toString())) {
        searchData.add(
            data); // If not empty then add search data into search data list
      }
    });

    setState(() {});

    print(fullData);
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Bienvenido " + this.name),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepOrange,
              ),
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 60,
                      ),
                      flex: 2,
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        "${this.name}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.favorite,
              ),
              title: const Text('Lista Favoritos'),
              onTap: () {
                //Navigator.pop(context);
                Navigator.of(context).pushNamed(FavoritePage.route);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.whatsapp,
              ),
              title: const Text('Contactenos'),
              onTap: () {
                openwhatsapp();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout_rounded,
              ),
              title: const Text('Salir'),
              onTap: () {
                //Navigator.pop(context);
                Navigator.of(context).pushNamed(MyMainPage.route);
              },
            ),
          ],
        ),
      ),
      body: new Center(
        //child: new Center(
        child: Column(
          children: <Widget>[
            Padding(
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(hintText: 'Search...'),
                  onChanged: onSearchTextChanged,
                ),
                padding: EdgeInsets.all(10.0)),
            Flexible(
                //FutureBuilder es un widget que se crea a sí mismo en función de la última instantánea
                // de interacción con un Futuro.
                child: searchData.length ==
                        0 // Check SearchData list is empty or not if empty then show full data else show search data
                    ? new FutureBuilder<List<Cars>>(
                        future: downloadJSON(textEditingController.text),

                        //pasamos un BuildContext y un objeto AsyncSnapshot que es un
                        //Representación inmutable de la interacción más reciente con
                        //un cálculo asíncrono.
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Cars>? Carss = snapshot.data;
                            return new CustomListView(Carss!, id);
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }
                          //return  a circular progress indicator.
                          return new CircularProgressIndicator();
                        },
                      )
                    : new FutureBuilder<List<Cars>>(
                        future: downloadJSON(textEditingController.text),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Cars>? Carss = snapshot.data;
                            return new CustomListView(Carss!, id);
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }
                          //return  a circular progress indicator.
                          return new CircularProgressIndicator();
                        },
                      )),
          ],
        ),
        //),
      ),
    );
  }

  openwhatsapp() async {
    var whatsapp = "573202727927";

    if (Platform.isAndroid) {
      return launchUrl(Uri.parse(
          "whatsapp://send?phone=$whatsapp&text=Asesoria")); // new line

    } else {
      return launchUrl(Uri.parse(
          "whatsapp://send?phone=$whatsapp&text=Asesoria")); // new line
    }
  }
}

void main() {
  runApp(HomePage(
    name: '',
    id: '',
  ));
}

/*
class HomePage extends StatelessWidget {
  final String name;
  HomePage({Key? key, required this.name}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Bienvenido : " + name,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}*/
