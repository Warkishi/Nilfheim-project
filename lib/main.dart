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
      title: 'Pick Me Up RPG',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0C14),
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
  int gems = 1000;
  int pityCounter = 0;
  String combatLog = "Bienvenue dans le Donjon de Nilfheim !";
  
  List<String> tiles = ['Ennemi', 'Trésor', 'Piège', 'Ennemi', 'Boss', 'Piège', 'Soin', 'Ennemi', 'Trésor'];
  
  List<Map<String, dynamic>> roster = [
    {'name': 'Loki', 'class': 'Tank', 'hp': 250, 'maxHp': 250, 'atk': 20, 'stars': 3, 'color': Colors.blue},
  ];

  void log(String msg) {
    setState(() {
      combatLog = msg;
    });
  }

  void summon() {
    if (gems < 100) {
      log("Pas assez de gemmes !");
      return;
    }
    
    final random = Random();
    pityCounter++;
    gems -= 100;

    int stars = 3;
    if (pityCounter >= 10 || random.nextInt(100) < 10) {
      stars = 5; // SSR / 5-Etoiles
      pityCounter = 0;
    } else if (random.nextInt(100) < 30) {
      stars = 4;
    }

    final names = ['Kael', 'Sera', 'Balthazar', 'Evelyn', 'Yuto', 'Ragnar'];
    final classes = ['Tank', 'Assassin', 'Mage', 'Healer'];
    final colors = [Colors.blue, Colors.red, Colors.purple, Colors.green];
    int idx = random.nextInt(4);

    String heroName = names[random.nextInt(names.length)];
    roster.add({
      'name': heroName,
      'class': classes[idx],
      'hp': 100 * stars,
      'maxHp': 100 * stars,
      'atk': 15 * stars,
      'stars': stars,
      'color': stars == 5 ? Colors.amber : colors[idx],
    });

    log("INVOCATION : $heroName ($stars★) a rejoint l'équipe !");
  }

  void interactTile(int index) {
    if (roster.isEmpty) return;
    
    final random = Random();
    String type = tiles[index];

    setState(() {
      if (type == 'Ennemi' || type == 'Boss') {
        int damage = (type == 'Boss' ? 50 : 20) * currentFloor;
        bool isCrit = random.nextInt(100) < 30;
        int dealtAtk = roster[0]['atk'] * (isCrit ? 2 : 1);

        roster[0]['hp'] = max(0, roster[0]['hp'] - damage);
        
        if (roster[0]['hp'] > 0) {
          gems += (type == 'Boss' ? 300 : 80);
          currentFloor++;
          log("COMBAT : Dégâts infligés $dealtAtk ${isCrit ? 'CRITIQUE !' : ''}. Victoire !");
        } else {
          log("DÉFAITE : Votre héros est tombé au combat.");
        }
      } else if (type == 'Trésor') {
        gems += 150;
        log("TRÉSOR : +150 Gemmes trouvées !");
      } else if (type == 'Soin') {
        roster[0]['hp'] = roster[0]['maxHp'];
        log("FONTAINE : Héros entièrement soigné !");
      }
      tiles[index] = 'Exploré';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar Pro
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF161926),
                border: Border(bottom: BorderSide(color: Colors.amber, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ÉSTAGE $currentFloor", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
                  Text("💎 $gems", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                  Text("Pity 5★: $pityCounter/10", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            
            // Console de combat
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(combatLog, style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontFamily: 'monospace'), textAlign: TextAlign.center),
            ),

            // Contenu
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
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
                            backgroundColor: tiles[i] == 'Boss' ? Colors.red[900] : const Color(0xFF161926),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => interactTile(i),
                          child: Text(tiles[i], style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                        onPressed: summon,
                        child: const Text("INVOCATION GACHA (100 💎)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("ÉQUIPE DE COMBAT (${roster.length})", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(height: 8),
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
                              child: Text("${hero['stars']}★", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            title: Text("${hero['name']} (${hero['class']})"),
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
