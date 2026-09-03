import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const NilfheimApp());
}

class NilfheimApp extends StatelessWidget {
  const NilfheimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nilfheim RPG',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0C14),
        primaryColor: Colors.amber,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  int gems = 1500;
  int currentFloor = 1;
  int pityCounter = 0;

  // Modèle des personnages
  List<Map<String, dynamic>> roster = [
    {
      'name': 'Loki',
      'class': 'Guerrier',
      'level': 1,
      'hp': 350,
      'maxHp': 350,
      'atk': 35,
      'stars': 3,
      'imageUrl': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=300&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Sera',
      'class': 'Mage',
      'level': 1,
      'hp': 180,
      'maxHp': 180,
      'atk': 60,
      'stars': 4,
      'imageUrl': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=300&auto=format&fit=crop&q=60',
    },
  ];

  // Grille aventure
  List<String> tiles = ['Monster', 'Chest', 'Trap', 'Monster', 'Boss', 'Trap', 'Heal', 'Monster', 'Chest'];
  bool autoBattle = false;
  Timer? autoBattleTimer;
  String combatLog = "Prêt pour la bataille.";
  String lastDamageText = "";
  Color damageColor = Colors.white;

  @override
  void dispose() {
    autoBattleTimer?.cancel();
    super.dispose();
  }

  void triggerDamageEffect(String text, Color color) {
    setState(() {
      lastDamageText = text;
      damageColor = color;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => lastDamageText = "");
    });
  }

  // --- LOGIQUE AVOIR / ENTRAÎNEMENT ---
  void trainHero(int index) {
    int cost = roster[index]['level'] * 150;
    if (gems >= cost) {
      setState(() {
        gems -= cost;
        roster[index]['level']++;
        roster[index]['atk'] += 10;
        roster[index]['maxHp'] += 40;
        roster[index]['hp'] = roster[index]['maxHp'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${roster[index]['name']} est monté au Niveau ${roster[index]['level']} !")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pas assez de gemmes pour l'entraînement.")),
      );
    }
  }

  // --- LOGIQUE GACHA ---
  void performSummon() {
    if (gems < 100) return;

    final random = Random();
    setState(() {
      gems -= 100;
      pityCounter++;
    });

    int stars = 3;
    if (pityCounter >= 10 || random.nextInt(100) < 10) {
      stars = 5;
      pityCounter = 0;
    } else if (random.nextInt(100) < 30) {
      stars = 4;
    }

    final names = ['Kael', 'Balthazar', 'Evelyn', 'Ragnar', 'Freya', 'Lyra'];
    final classes = ['Guerrier', 'Assassin', 'Mage', 'Soin'];
    final avatarUrls = [
      'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=300&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1563089145-599997674d42?w=300&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=300&auto=format&fit=crop&q=60',
    ];

    String hName = names[random.nextInt(names.length)];
    String hClass = classes[random.nextInt(classes.length)];
    String hImg = avatarUrls[random.nextInt(avatarUrls.length)];

    setState(() {
      roster.add({
        'name': hName,
        'class': hClass,
        'level': 1,
        'hp': 120 * stars,
        'maxHp': 120 * stars,
        'atk': 20 * stars,
        'stars': stars,
        'imageUrl': hImg,
      });
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161926),
        title: Text("Invocation $stars★ !", style: const TextStyle(color: Colors.amber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(hImg, width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
            Text("$hName ($hClass)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
        ],
      ),
    );
  }

  // --- LOGIQUE COMBAT ---
  void interactTile(int index) {
    if (roster.isEmpty || tiles[index] == 'Explored') return;

    final random = Random();
    String type = tiles[index];

    setState(() {
      if (type == 'Monster' || type == 'Boss') {
        bool isCrit = random.nextInt(100) < 30;
        int damageDealt = (roster[0]['atk'] as int) * (isCrit ? 2 : 1);
        int monsterAtk = (type == 'Boss' ? 50 : 20) * currentFloor;

        roster[0]['hp'] = max(0, (roster[0]['hp'] as int) - monsterAtk);
        triggerDamageEffect(
          isCrit ? "CRIT! -$damageDealt" : "-$damageDealt",
          isCrit ? Colors.amber : Colors.redAccent,
        );

        if ((roster[0]['hp'] as int) > 0) {
          gems += (type == 'Boss' ? 200 : 60);
          combatLog = "Combat gagné: +$damageDealt dmg.";
        } else {
          combatLog = "K.O. Repli stratégique !";
          autoBattle = false;
          autoBattleTimer?.cancel();
        }
      } else if (type == 'Chest') {
        gems += 100;
        triggerDamageEffect("+100 💎", Colors.cyanAccent);
        combatLog = "Trésor ouvert !";
      } else if (type == 'Heal') {
        roster[0]['hp'] = roster[0]['maxHp'];
        triggerDamageEffect("SOIN MAX", Colors.greenAccent);
        combatLog = "Équipe soignée.";
      } else if (type == 'Trap') {
        roster[0]['hp'] = max(1, (roster[0]['hp'] as int) - 25);
        triggerDamageEffect("-25 PV", Colors.purpleAccent);
        combatLog = "Piège déclenché !";
      }
      tiles[index] = 'Explored';
    });
  }

  void toggleAutoBattle() {
    setState(() => autoBattle = !autoBattle);
    if (autoBattle) {
      autoBattleTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        if (!autoBattle || roster.isEmpty) {
          timer.cancel();
          return;
        }
        int nextIndex = tiles.indexWhere((t) => t != 'Explored');
        if (nextIndex != -1) {
          interactTile(nextIndex);
        } else {
          setState(() {
            tiles = ['Monster', 'Chest', 'Trap', 'Monster', 'Boss', 'Trap', 'Heal', 'Monster', 'Chest'];
            currentFloor++;
          });
        }
      });
    } else {
      autoBattleTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildBasePage(),
      _buildAdventurePage(),
      _buildGachaPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF161926),
        title: const Text("NILFHEIM RPG", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: Colors.cyanAccent, size: 20),
                const SizedBox(width: 4),
                Text("$gems", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
              ],
            ),
          )
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: const Color(0xFF161926),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.castle), label: "Base"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Aventure"),
          BottomNavigationBarItem(icon: Icon(Icons.style), label: "Gestion & Gacha"),
        ],
      ),
    );
  }

  // --- ONGLET 1: LA BASE ---
  Widget _buildBasePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("CENTRE D'ENTRAÎNEMENT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
        const SizedBox(height: 8),
        const Text("Faites progresser vos héros individuellement contre des gemmes.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        ...roster.asMap().entries.map((entry) {
          int idx = entry.key;
          var hero = entry.value;
          int trainCost = (hero['level'] as int) * 150;

          return Card(
            color: const Color(0xFF161926),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(hero['imageUrl'], width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${hero['name']} (Niv. ${hero['level']})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text("Classe: ${hero['class']} | ${hero['stars']}★", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text("ATQ: ${hero['atk']} | PV: ${hero['maxHp']}", style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    onPressed: () => trainHero(idx),
                    child: Text("Entraîner\n($trainCost 💎)", textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- ONGLET 2: AVENTURE ---
  Widget _buildAdventurePage() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF161926),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ÉTAGE $currentFloor", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: autoBattle ? Colors.green : Colors.grey[800]),
                onPressed: toggleAutoBattle,
                child: Text(autoBattle ? "AUTO : ON" : "AUTO : OFF", style: const TextStyle(color: Colors.white, fontSize: 12)),
              )
            ],
          ),
        ),

        // Console d'état
        Container(
          height: 35,
          color: Colors.black,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(combatLog, style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'monospace')),
              if (lastDamageText.isNotEmpty)
                Text(lastDamageText, style: TextStyle(color: damageColor, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
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
                    backgroundColor: isExplored ? Colors.grey[900] : const Color(0xFF161926),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => interactTile(i),
                  child: Text(isExplored ? "✓" : tiles[i], style: TextStyle(color: isExplored ? Colors.grey : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- ONGLET 3: GESTION & GACHA ---
  Widget _buildGachaPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Banners Gacha
        Card(
          color: const Color(0xFF161926),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text("PORTAIL D'INVOCATION", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                const SizedBox(height: 4),
                Text("Pity 5★ : $pityCounter / 10", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: performSummon,
                  child: const Text("INVOKER (100 💎)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Text("COLLECTION DE HÉROS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),

        // Grille des personnages avec illustrations
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: roster.length,
          itemBuilder: (ctx, i) {
            final hero = roster[i];
            return Card(
              color: const Color(0xFF161926),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.network(
                      hero['imageUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${hero['name']} (${hero['stars']}★)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text("${hero['class']} - Niv. ${hero['level']}", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
