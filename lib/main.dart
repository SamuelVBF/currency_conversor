import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=5489a698";

void main() async {
  runApp(const MaterialApp(
    home: Home(),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;

  void _realChanged(String text) {
    if(text.isEmpty) {
      clearCoins([]);
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty) {
      clearCoins([]);
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void clearCoins(List<int> list) {
    [realController.clear(), euroController.clear(), dolarController.clear()];
  }

  void _euroChanged(String text) {
    if(text.isEmpty) {
      clearCoins([]);
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('\$ Conversor \$'),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(
                    child: Text(
                      'Carregando Dados...',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Erro ao Carregar Dados :(',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    dolar =
                        snapshot.data!['results']['currencies']['USD']['buy'];
                    euro =
                        snapshot.data!['results']['currencies']['EUR']['buy'];
                    realController.clear();
                    dolarController.clear();
                    euroController.clear();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Icon(
                            Icons.monetization_on,
                            size: 150,
                            color: Colors.amber,
                          ),
                          buildTextField(
                            'Real',
                            'R\$ ',
                            realController,
                            _realChanged,
                          ),
                          const Divider(
                            height: 2,
                          ),
                          buildTextField(
                              'Dólar', 'US\$ ', dolarController, _dolarChanged),
                          const Divider(
                            height: 2,
                          ),
                          buildTextField(
                              'Euro', '€ ', euroController, _euroChanged),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextField(String label, String prefix, TextEditingController coin,
    Function(String) coinChange) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: TextField(
      keyboardType: TextInputType.number,
      controller: coin,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.amber),
          prefixText: prefix,
          prefixStyle: const TextStyle(color: Colors.amber, fontSize: 25),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.amber,
              width: 2,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.amber,
            width: 2,
          ))),
      style: const TextStyle(
        color: Colors.amber,
        fontSize: 25,
      ),
      onChanged: coinChange
    ),
  );
}
