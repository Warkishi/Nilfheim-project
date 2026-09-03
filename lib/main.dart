import 'package:flutter/material.dart';
import 'dart:math';

enum CharacterClass { Tank, Assassin, Mage, Healer }

class ClassAssets {
  static IconData getIcon(CharacterClass charClass) {
    switch (charClass) {
      case CharacterClass.Tank:
        return Icons.shield;
      case CharacterClass.Assassin:
        return Icons.colorize;
      case CharacterClass.Mage:
        return Icons.auto_awesome;
      case CharacterClass.Healer:
        return Icons.health_and_safety;
    }
  }

  static Color getColor(CharacterClass charClass) {
    switch (charClass) {
      case CharacterClass.Tank:
        return Colors.blueGrey;
      case CharacterClass.Assassin:
        return Colors.redAccent;
      case CharacterClass.Mage:
        return Colors.purpleAccent;
      case CharacterClass.Healer:
        return Colors.greenAccent;
    }
  }
}

enum TileType { empty, monster, chest, trap }

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
  static const Tile emptyTile = Tile(id: 'empty', name: 'Vide', type: TileType.empty, icon: Icons.crop_square, color: Colors.grey);
  static const Tile monsterTile = Tile(id: 'monster', name: 'Monstre', type: TileType.monster, icon: Icons.adb, color: Colors.redAccent);
  static const Tile chestTile = Tile(id: 'chest', name: 'Coffre', type: TileType.chest, icon: Icons.inventory_2, color: Colors.amber);
  static const Tile trapTile = Tile(id: 'trap', name: 'Piège', type: TileType.trap, icon: Icons.warning, color: Colors.purpleAccent);
}

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
      if (personality == "Arrogant") return "$name: « Regardez un pro à l'œuvre. »";
      if (personality == "Peureux") return "$name: « Es-tu sûr qu'il faut y aller...? »";
      return "$name: « Prêt au combat ! »";
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
    );
  }
}

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
        scaffoldBackgroundColor: const Color(0xFF090A0F),
        cardColor: const Color(0xFF141622),
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
    if (gems < 100) return;
    setState(() {
      gems -= 100;
      Character newHero = Character.generateRandom();
      roster.add(newHero);
    });
  }

  void interactWithTile(Tile tile, int index) {
    List<Character> alive = roster.where((c) => !c.isDead).toList();
    if (alive.isEmpty) return;
    Character hero = alive.first;

    setState(() {
      if (tile.type == TileType.monster) {
        currentFloor++;
        gems += 80;
        _generateFloorGrid();
      } else if (tile.type == TileType.chest) {
        gems += 120;
      } else if (tile.type == TileType.trap) {
        hero.hp = max(1, hero.hp - 20);
      }
      currentGrid[index] = TileRegistry.emptyTile;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Character> aliveHeroes = roster.where((c) => !c.isDead).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Étage $currentFloor"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: Colors.amber),
                const SizedBox(width: 4),
                Text("$gems", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: tile.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: tile.color),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tile.icon, color: tile.color),
                        Text(tile.name, style: TextStyle(color: tile.color, fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: summonCharacter,
            icon: const Icon(Icons.auto_awesome, color: Colors.black),
            label: const Text("Invocation (100💎)", style: TextStyle(color: Colors.black)),
          ),
          const Divider(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: aliveHeroes.length,
              itemBuilder: (ctx, i) {
                final hero = aliveHeroes[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ClassAssets.getColor(hero.charClass),
                      child: Icon(ClassAssets.getIcon(hero.charClass), color: Colors.white),
                    ),
                    title: Text("${hero.name} (${hero.charClass.name})"),
                    subtitle: Text("Niv. ${hero.level} | PV: ${hero.hp}/${hero.maxHp} | ATQ: ${hero.attack}"),
                    trailing: Text("${hero.rarity}★", style: TextStyle(color: hero.rarityColor, fontWeight: FontWeight.bold)),
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
