import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const PickMeUpGame());
}

class PickMeUpGame extends StatelessWidget {
  const PickMeUpGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pick Me Up',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0F17),
      ),
      home: const GameHomeScreen(),
    );
  }
}

class GameHomeScreen extends StatefulWidget {
  const GameHomeScreen({super.key});

  @override
  State<GameHomeScreen> createState() => _GameHomeScreenState();
}

class _GameHomeScreenState extends State<GameHomeScreen> {
  int currentFloor = 1;
  int gems = 300;
  List<String> tiles = ['Monster', 'Chest', 'Trap', 'Monster', 'Chest', 'Trap', 'Empty', 'Monster', 'Chest'];
  List<Map<String, dynamic>> roster = [
    {'name': 'Loki', 'class': 'Tank', 'hp': 180, 'maxHp': 180, 'atk': 18, 'stars': 3, 'color': Colors.blue},
    {'name': 'Anis', 'class': 'Mage', 'hp': 100, 'maxHp': 100, 'atk': 32, 'stars': 4, 'color': Colors.purple},
  ];

  void summon() {
    if (gems < 100) return;
    final random = Random();
    final names = ['Kael', 'Sera', 'Balthazar', 'Evelyn', 'Yuto'];
    final classes = ['Tank', 'Assassin', 'Mage', 'Healer'];
    final colors = [Colors.blue, Colors.red, Colors.purple, Colors.green];
    int idx = random.nextInt(4);

    setState(() {
      gems -= 100;
      roster.add({
        'name': names[random.nextInt(names.length)],
        'class': classes[idx],
        'hp': 120,
        'maxHp': 120,
        'atk': 25,
        'stars': random.nextInt(3) + 1,
        'color': colors[idx],
      });
    });
  }

  void interactTile(int index) {
    setState(() {
      if (tiles[index] == 'Monster') {
        currentFloor++;
        gems += 150;
      } else if (tiles[index] == 'Chest') {
        gems += 100;
      }
      tiles[index] = 'Explored';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFF161926),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Étage $currentFloor", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
                  Text("💎 $gems", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                ],
              ),
            ),
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Grille 3x3
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: tiles.length,
                      itemBuilder: (ctx, i) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF161926),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () => interactTile(i),
                          child: Text(tiles[i], style: const TextStyle(fontSize: 12, color: Colors.white)),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Bouton Invocation
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800]),
                        onPressed: summon,
                        child: const Text("INVOCATION (100 💎)", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Équipe
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("ÉQUIPE (${roster.length} Héros)", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: roster.length,
                      itemBuilder: (ctx, i) {
                        final hero = roster[i];
                        return Card(
                          color: const Color(0xFF161926),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: hero['color'] as Color,
                              child: Text((hero['class'] as String)[0], style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text("${hero['name']} (${hero['class']}) - ${hero['stars']}★"),
                            subtitle: Text("PV: ${hero['hp']}/${hero['maxHp']} | ATQ: ${hero['atk']}"),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
