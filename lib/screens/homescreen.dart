import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> futureData;

  // Fetch data from the new API
  Future<List<dynamic>> fetchData() async {
    final response =
        await http.get(Uri.parse('https://narutodb.xyz/api/character'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['characters'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Naruto Characters"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var character = snapshot.data![index];
                return CharacterTile(character: character);
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

class CharacterTile extends StatefulWidget {
  final dynamic character;

  const CharacterTile({super.key, required this.character});

  @override
  State<CharacterTile> createState() => _CharacterTileState();
}

class _CharacterTileState extends State<CharacterTile> {
  bool _isExpanded = false;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    var character = widget.character;

    return GestureDetector(
      onTap: _toggleExpansion,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Column(
          children: [
            ListTile(
              title: Text(character['name'] ?? 'Unknown Character'),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  if (character['images'] != null &&
                      character['images'].isNotEmpty)
                    Image.network(character['images'][0]), // Character Image
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(character['description'] ??
                        'No description available'), // Character Description
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Jutsu: ${(character['jutsu'] ?? []).join(', ')}",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Unique Traits: ${(character['uniqueTraits'] ?? []).join(', ')}",
                    ),
                  ),
                  // Display debut information
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Novel: ${character['debut']?['novel'] ?? 'N/A'}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Movie: ${character['debut']?['movie'] ?? 'N/A'}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Appears In: ${character['debut']?['appearsIn'] ?? 'N/A'}"),
                      ),
                    ],
                  ),
                  // Display family (if available)
                  if (character['family'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "Incarnation with: ${character['family']?['incarnation with the god tree'] ?? 'N/A'}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "Depowered form: ${character['family']?['depowered form'] ?? 'N/A'}"),
                        ),
                      ],
                    ),
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
