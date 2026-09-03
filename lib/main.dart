import 'package:flutter/material.dart';
import 'dart:async';
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
      title: 'Nilfheim RPG',
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
  bool autoBattle = false;
  Timer? autoBattleTimer;

  String combatLog = "Système de combat initialisé.";
  String lastDamageText = "";
  Color damageColor = Colors.white;

  List<String> tiles = ['Monster', 'Chest', 'Trap', 'Monster', 'Boss', 'Trap', 'Heal', 'Monster', 'Chest'];

  List<Map<String, dynamic>> roster = [
    {'name': 'Loki', 'class': 'Tank', 'hp': 300, 'maxHp': 300, 'atk': 25, 'stars': 3, 'colorIndex': 0},
    {'name': 'Sera', 'class': 'Mage', 'hp': 150, 'maxHp': 150, 'atk': 45, 'stars': 4, 'colorIndex': 2},
  ];

  final List<Color> classColors = [
    Colors.blue,
    Colors.red,
    Colors.purple,
    Colors.green,
    Colors.amber,
  ];

  @override
  void dispose() {
    autoBattleTimer?.cancel();
    super.dispose();
  }

  void log(String msg) {
    setState(() {
      combatLog = msg;
    });
  }

  void triggerDamageEffect(String text, Color color) {
    setState(() {
      lastDamageText = text;
      damageColor = color;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          lastDamageText = "";
        });
      }
    });
  }

  void toggleAutoBattle() {
    setState(() {
      autoBattle = !autoBattle;
    });

    if (autoBattle) {
      log("MODE AUTO-BATTLE ACTIVÉ");
      autoBattleTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
        if (!autoBattle || roster.isEmpty) {
          timer.cancel();
          return;
        }
        int nextIndex = tiles.indexWhere((t) => t != 'Explored');
        if (nextIndex != -1) {
          interactTile(nextIndex);
        } else {
          resetGrid();
        }
      });
    } else {
      autoBattleTimer?.cancel();
      log("MODE AUTO-BATTLE DÉSACTIVÉ");
    }
  }

  void resetGrid() {
    setState(() {
      tiles = ['Monster', 'Chest', 'Trap', 'Monster', 'Boss', 'Trap', 'Heal', 'Monster', 'Chest'];
      currentFloor++;
    });
    log("Nouveau niveau ! Étage $currentFloor");
  }

  void summon() {
    if (gems < 100) {
      log("Gemmes insuffisantes pour l'invocation.");
      return;
    }

    final random = Random();
    pityCounter++;
    gems -= 100;

    int stars = 3;
    if (pityCounter >= 10 || random.nextInt(100) < 10) {
      stars = 5;
      pityCounter = 0;
    } else if (random.nextInt(100) < 30) {
      stars = 4;
    }

    final names = ['Kael', 'Balthazar', 'Evelyn', 'Yuto', 'Ragnar', 'Freya'];
    final classes = ['Tank', 'Assassin', 'Mage', 'Healer'];
    int idx = random.nextInt(4);

    String heroName = names[random.nextInt(names.length)];
    roster.add({
      'name': heroName,
      'class': classes[idx],
      'hp': 120 * stars,
      'maxHp': 120 * stars,
      'atk': 20 * stars,
      'stars': stars,
      'colorIndex': stars == 5 ? 4 : idx,
    });

    log("GACHA ($stars★) : $heroName rejoint l'escouade !");
  }

  void interactTile(int index) {
    if (roster.isEmpty || tiles[index] == 'Explored') return;

    final random = Random();
    String type = tiles[index];

    setState(() {
      if (type == 'Monster' || type == 'Boss') {
        bool isCrit = random.nextInt(100) < 35;
        int damageDealt = (roster[0]['atk'] as int) * (isCrit ? 2 : 1);
        int monsterAtk = (type == 'Boss' ? 60 : 25) * currentFloor;

        roster[0]['hp'] = max(0, (roster[0]['hp'] as int) - monsterAtk);
        triggerDamageEffect(
          isCrit ? "CRIT! -$damageDealt" : "-$damageDealt",
          isCrit ? Colors.amber : Colors.redAccent,
        );

        if ((roster[0]['hp'] as int) > 0) {
          gems += (type == 'Boss' ? 250 : 75);
          log("VICTOIRE : $damageDealt dégâts infligés.");
        } else {
          log("DÉFAITE : Votre héros est K.O.");
          autoBattle = false;
          autoBattleTimer?.cancel();
        }
      } else if (type == 'Chest') {
        gems += 120;
        triggerDamageEffect("+120 💎", Colors.cyanAccent);
        log("TRÉSOR : +120 Gemmes obtenues.");
      } else if (type == 'Heal') {
        roster[0]['hp'] = roster[0]['maxHp'];
        triggerDamageEffect("SOIN MAX", Colors.greenAccent);
        log("SOIN : PV restaurés au maximum.");
      } else if (type == 'Trap') {
        roster[0]['hp'] = max(1, (roster[0]['hp'] as int) - 30);
        triggerDamageEffect("-30 PV", Colors.purpleAccent);
        log("PIÈGE : L'équipe subit des dégâts.");
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
            // Barre supérieure
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF161926),
                border: Border(bottom: BorderSide(color: Colors.amber, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ÉSTAGE $currentFloor", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                  Text("💎 $gems", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                  Text("Pity 5★: $pityCounter/10", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),

            // Logs & Animation Dégâts
            Container(
              width: double.infinity,
              height: 40,
              color: Colors.black,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(combatLog, style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace')),
                  if (lastDamageText.isNotEmpty)
                    Text(
                      lastDamageText,
                      style: TextStyle(color: damageColor, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                ],
              ),
            ),

            // Zone Principale
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
                        bool isExplored = tiles[i] == 'Explored';
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isExplored
                                ? Colors.grey[900]
                                : (tiles[i] == 'Boss' ? Colors.red[900] : const Color(0xFF161926)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => interactTile(i),
                          child: Text(
                            isExplored ? "✓" : tiles[i],
                            style: TextStyle(
                              fontSize: 11,
                              color: isExplored ? Colors.grey : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                            onPressed: summon,
                            child: const Text("GACHA (100 💎)", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: autoBattle ? Colors.green[700] : Colors.blueGrey[800],
                            ),
                            onPressed: toggleAutoBattle,
                            child: Text(
                              autoBattle ? "AUTO : ON" : "AUTO : OFF",
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Liste Équipe
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
                        int colorIdx = hero['colorIndex'] as int;
                        return Card(
                          color: const Color(0xFF161926),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: classColors[colorIdx],
                              child: Text("${hero['stars']}★", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
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
