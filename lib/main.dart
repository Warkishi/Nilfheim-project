import 'package:flutter/material.dart';
import 'dart:math';

// ==================== 1. SYSTÈME D'ILLUSTRATIONS & CLASSES ====================

enum CharacterClass { Tank, Assassin, Mage, Healer }

class ClassAssets {
  static String getImageUrl(CharacterClass charClass) {
    switch (charClass) {
      case CharacterClass.Tank:
        return 'https://encrypted-tbn0.gstatic.com/licensed-image?q=tbn:ANd9GcSgg9tSz6mxfatpfZVlJH0pYzPxD4Xmd1moyHTj1QbFBcHafCX_fziXbyjhgCw9sPe6BbrDuk0HG282xcQ';
      case CharacterClass.Assassin:
        return 'https://imgcdn.stablediffusionweb.com/2024/11/15/c261e6db-cfaa-4acc-a4c9-5f53cd01ea44.jpg';
      case CharacterClass.Mage:
        return 'https://encrypted-tbn3.gstatic.com/licensed-image?q=tbn:ANd9GcRWbxn8MfGr9V5aKjrVgV-sye4ATDtPGfwMUsxS-oOfPXTscb-LIu_S7SfwVaNPazK0o5-hUdJvOkod3uA';
      case CharacterClass.Healer:
        return 'https://media.craiyon.com/2023-10-22/6315156f27f449ba8b17aa6931b8e22b.webp';
    }
  }
}

// ==================== 2. TUILES DE L'ÉTAGE ====================

enum TileType { empty, monster, chest, trap, boss }

class Tile {
  final String id;
  final String name;
  final TileType type;
  final IconData icon;
  final Color color;

  const Tile({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });
}

class TileRegistry {
  static const Tile emptyTile = Tile(id: 'empty', name: 'Zone Clère', type: TileType.empty, icon: Icons.check_box_outline_blank, color: Colors.grey);
  static const Tile monsterTile = Tile(id: 'monster', name: 'Monstre', type: TileType.monster, icon: Icons.adb, color: Colors.redAccent);
  static const Tile chestTile = Tile(id: 'chest', name: 'Coffre', type: TileType.chest, icon: Icons.inventory_2, color: Colors.amber);
  static const Tile trapTile = Tile(id: 'trap', name: 'Piège', type: TileType.trap, icon: Icons.warning, color: Colors.purpleAccent);
}

// ==================== 3. MODÈLE PERSONNAGE ====================

class Character {
  final String id;
  final String name;
  final CharacterClass charClass;
  final int rarity;
  int level;
  int hp;
  int maxHp;
  int attack;
  int defense;
  bool isDead;
  final String personality;
  final String imageUrl;

  Character({
    required this.id,
    required this.name,
    required this.charClass,
    required this.rarity,
    this.level = 1,
    required this.hp,
    required this.maxHp,
    required this.attack,
    required this.defense,
    this.isDead = false,
    required this.personality,
    required this.imageUrl,
  });

  Color get rarityColor {
    switch (rarity) {
      case 5: return Colors.amber;
      case 4: return Colors.purpleAccent;
      case 3: return Colors.blueAccent;
      default: return Colors.grey;
    }
  }

  String speak(String context) {
    if (context == "battle_start") {
      if (personality == "Arrogant") return "$name: « Observez un vrai maître au travail. »";
      if (personality == "Peureux") return "$name: « Es-tu sûr qu'on doit entrer là-dedans...? »";
      return "$name: « Arme parée. En avant ! »";
    }
    if (context == "death") {
      return "$name: « Non... la Tour m'a eu... »";
    }
    return "$name: « ... »";
  }

  static Character generateRandom() {
    final random = Random();
    final names = ["Loki", "Anis", "Evelyn", "Kael", "Yuto", "Sera", "Balthazar"];
    final personalities = ["Arrogant", "Peureux", "Loyal", "Froid", "Sanguinaire"];

    int rarityRoll = random.nextInt(100);
    int rarity = 1;
    if (rarityRoll > 95) rarity = 5;
    else if (rarityRoll > 80) rarity = 4;
    else if (rarityRoll > 60) rarity = 3;
    else if (rarityRoll > 30) rarity = 2;

    CharacterClass selectedClass = CharacterClass.values[random.nextInt(CharacterClass.values.length)];
    int baseHp = (selectedClass == CharacterClass.Tank) ? 160 : 90;
    int baseAtk = (selectedClass == CharacterClass.Assassin) ? 28 : 16;

    return Character(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: names[random.nextInt(names.length)],
      charClass: selectedClass,
      rarity: rarity,
      hp: baseHp * rarity,
      maxHp: baseHp * rarity,
      attack: baseAtk * rarity,
      defense: 4 * rarity,
      personality: personalities[random.nextInt(personalities.length)],
      imageUrl: ClassAssets.getImageUrl(selectedClass),
    );
  }
}

// ==================== 4. INTERFACE JEU ====================

void main() {
  runApp(const PickMeUpGame());
}

class PickMeUpGame extends StatelessWidget {
  const PickMeUpGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pick Me Up Mobile',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090A0F),
        cardColor: const Color(0xFF141622),
        colorScheme: const ColorScheme.dark(primary: Colors.amber, secondary: Colors.redAccent),
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
  List<Character> roster = [];
  List<Character> graveyard = [];
  int currentFloor = 1;
  int gems = 500;
  List<Tile> currentGrid = [];

  @override
  void initState() {
    super.initState();
    _generateFloorGrid();
  }

  void _generateFloorGrid() {
    final random = Random();
    List<Tile> possibleTiles = [
      TileRegistry.emptyTile,
      TileRegistry.monsterTile,
      TileRegistry.chestTile,
      TileRegistry.trapTile,
    ];
    setState(() {
      currentGrid = List.generate(9, (_) => possibleTiles[random.nextInt(possibleTiles.length)]);
    });
  }

  void summonCharacter() {
    if (gems < 100) {
      _showDialog("Erreur", "Gemmes insuffisantes !");
      return;
    }
    setState(() {
      gems -= 100;
      Character newHero = Character.generateRandom();
      roster.add(newHero);
      _showHeroCardDialog(newHero, "NOUVELLE INVOCATION !");
    });
  }

  void interactWithTile(Tile tile, int index) {
    List<Character> alive = roster.where((c) => !c.isDead).toList();
    if (alive.isEmpty) {
      _showDialog("Avertissement", "Aucun héros vivant disponible dans votre armée !");
      return;
    }

    Character hero = alive.first;

    setState(() {
      if (tile.type == TileType.monster) {
        _startBattle(hero);
      } else if (tile.type == TileType.chest) {
        gems += 120;
        _showDialog("Coffre Ouvert", "Vous obtenez 120 Gemmes !");
      } else if (tile.type == TileType.trap) {
        hero.hp = max(1, hero.hp - 25);
        _showDialog("Piège !", "${hero.name} perd 25 PV en marchant sur une rune.");
      } else {
        _showDialog("Exploration", "Rien à signaler sur cette case.");
      }
      currentGrid[index] = TileRegistry.emptyTile;
    });
  }

  void _startBattle(Character hero) {
    int enemyHp = currentFloor * 75;
    int enemyAtk = currentFloor * 12;
    List<String> log = [hero.speak("battle_start")];

    while (hero.hp > 0 && enemyHp > 0) {
      enemyHp -= hero.attack;
      log.add("${hero.name} frappe (-${hero.attack} PV).");
      if (enemyHp <= 0) break;

      int dmg = max(1, enemyAtk - hero.defense);
      hero.hp -= dmg;
      log.add("L'ennemi réplique (-$dmg PV).");
    }

    if (hero.hp <= 0) {
      hero.isDead = true;
      roster.remove(hero);
      graveyard.add(hero);
      _showDialog("DÉFAITE - HÉROS MORT", "${hero.speak('death')}\n\n${hero.name} est mort et à jamais effacé du jeu.\n\nJournal :\n${log.join('\n')}");
    } else {
      currentFloor++;
      gems += 80;
      _generateFloorGrid();
      _showDialog("ÉSTAGE NETTOYÉ !", "Victoire ! L'armée grimpe à l'étage $currentFloor.\n\nJournal :\n${log.join('\n')}");
    }
  }

  void _showHeroCardDialog(Character hero, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141622),
        title: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.amber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                hero.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 80),
              ),
            ),
            const SizedBox(height: 12),
            Text("${hero.name} (${hero.charClass.name})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("${hero.rarity} ★", style: TextStyle(color: hero.rarityColor, fontSize: 16)),
            const SizedBox(height: 8),
            Text(hero.speak("battle_start"), style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("OK")),
        ],
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141622),
        title: Text(title, style: const TextStyle(color: Colors.amber)),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Character> aliveHeroes = roster.where((c) => !c.isDead).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1018),
        title: Text("Étage $currentFloor"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.diamond, color: Colors.amber, size: 18),
                  const SizedBox(width: 6),
                  Text("$gems", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // --- PLATEAU DE TUILES DE L'ÉTAGE ---
          Container(
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF141622),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: currentGrid.length,
              itemBuilder: (ctx, i) {
                final tile = currentGrid[i];
                return InkWell(
                  onTap: () => interactWithTile(tile, i),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tile.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: tile.color.withOpacity(0.4)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tile.icon, color: tile.color, size: 26),
                        const SizedBox(height: 4),
                        Text(tile.name, style: TextStyle(color: tile.color, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // --- BOUTON GACHA ---
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            onPressed: summonCharacter,
            icon: const Icon(Icons.auto_awesome, color: Colors.black),
            label: const Text("Invocation Gacha (100💎)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 24),
          // --- ROSTER AVEC PORTRAITS ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Escouade Active (${aliveHeroes.length})", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Morts : ${graveyard.length}", style: const TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),
          Expanded(
            child: aliveHeroes.isEmpty
                ? const Center(child: Text("Aucun personnage vivant. Lancez une invocation !"))
                : ListView.builder(
                    itemCount: aliveHeroes.length,
                    itemBuilder: (ctx, i) {
                      final hero = aliveHeroes[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              hero.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.person),
                            ),
                          ),
                          title: Text("${hero.name} (${hero.charClass.name})"),
                          subtitle: Text("Niv. ${hero.level} | PV: ${hero.hp}/${hero.maxHp} | ATQ: ${hero.attack}"),
                          trailing: Text("${hero.rarity}★", style: TextStyle(color: hero.rarityColor, fontWeight: FontWeight.bold, fontSize: 16)),
                          onTap: () => _showHeroCardDialog(hero, "Fiche du Héros"),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
