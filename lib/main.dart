import 'package:flutter/material.dart';
import 'dart:math';

enum CharacterClass { Tank, Assassin, Mage, Healer }

class ClassAssets {
  static IconData getIcon(CharacterClass charClass) {
    switch (charClass) {
      case CharacterClass.Tank:
        return Icons.shield_sharp;
      case CharacterClass.Assassin:
        return Icons.hardware;
      case CharacterClass.Mage:
        return Icons.auto_awesome;
      case CharacterClass.Healer:
        return Icons.favorite;
    }
  }

  static Color getColor(CharacterClass charClass) {
    switch (charClass) {
      case CharacterClass.Tank:
        return const Color(0xFF3B82F6);
      case CharacterClass.Assassin:
        return const Color(0xFFEF4444);
      case CharacterClass.Mage:
        return const Color(0xFFA855F7);
      case CharacterClass.Healer:
        return const Color(0xFF10B981);
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
  static const Tile emptyTile = Tile(id: 'empty', name: 'Exploré', type: TileType.empty, icon: Icons.crop_square, color: Color(0xFF4B5563));
  static const Tile monsterTile = Tile(id: 'monster', name: 'Ennemi', type: TileType.monster, icon: Icons.coronavirus, color: Color(0xFFDC2626));
  static const Tile chestTile = Tile(id: 'chest', name: 'Trésor', type: TileType.chest, icon: Icons.all_out_sharp, color: Color(0xFFF59E0B));
  static const Tile trapTile = Tile(id: 'trap', name: 'Piège', type: TileType.trap, icon: Icons.bolt, color: Color(0xFF9333EA));
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
  });

  Color get rarityColor {
    switch (rarity) {
      case 5: return const Color(0xFFF59E0B);
      case 4: return const Color(0xFFC084FC);
      case 3: return const Color(0xFF60A5FA);
      default: return const Color(0xFF9CA3AF);
    }
  }

  static Character generateRandom() {
    final random = Random();
    final names = ["Loki", "Anis", "Evelyn", "Kael", "Yuto", "Sera", "Balthazar"];

    int rarityRoll = random.nextInt(100);
    int rarity = 1;
    if (rarityRoll > 92) rarity = 5;
    else if (rarityRoll > 75) rarity = 4;
    else if (rarityRoll > 50) rarity = 3;
    else if (rarityRoll > 25) rarity = 2;

    CharacterClass selectedClass = CharacterClass.values[random.nextInt(CharacterClass.values.length)];
    int baseHp = (selectedClass == CharacterClass.Tank) ? 180 : 100;
    int baseAtk = (selectedClass == CharacterClass.Assassin) ? 32 : 18;

    return Character(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: names[random.nextInt(names.length)],
      charClass: selectedClass,
      rarity: rarity,
      hp: baseHp * rarity,
      maxHp: baseHp * rarity,
      attack: baseAtk * rarity,
      defense: 5 * rarity,
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
  List<Character> roster = [];
  int currentFloor = 1;
  int gems = 300;
  List<Tile> currentGrid = [];

  @override
  void initState() {
    super.initState();
    _generateFloorGrid();
    roster.add(Character.generateRandom());
  }

  void _generateFloorGrid() {
    final random = Random();
    List<Tile> possibleTiles = [
      TileRegistry.monsterTile,
      TileRegistry.chestTile,
      TileRegistry.trapTile,
      TileRegistry.monsterTile,
    ];
    setState(() {
      currentGrid = List.generate(9, (_) => possibleTiles[random.nextInt(possibleTiles.length)]);
    });
  }

  void summonCharacter() {
    if (gems < 100) return;
    setState(() {
      gems -= 100;
      roster.add(Character.generateRandom());
    });
  }

  void interactWithTile(Tile tile, int index) {
    if (tile.type == TileType.empty) return;
    List<Character> alive = roster.where((c) => !c.isDead).toList();
    if (alive.isEmpty) return;

    setState(() {
      if (tile.type == TileType.monster) {
        currentFloor++;
        gems += 150;
        _generateFloorGrid();
      } else if (tile.type == TileType.chest) {
        gems += 100;
        currentGrid[index] = TileRegistry.emptyTile;
      } else if (tile.type == TileType.trap) {
        for (var hero in alive) {
          hero.hp = max(1, hero.hp - 15);
        }
        currentGrid[index] = TileRegistry.emptyTile;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF161926),
                border: Border(bottom: BorderSide(color: Color(0xFF2A2E45), width: 2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("DONJON", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 2)),
                      Text("Étage $currentFloor", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.black, color: Colors.amber)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0F17),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.diamond, color: Colors.cyanAccent, size: 18),
                        const SizedBox(width: 6),
                        Text("$gems", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contenu scrollable global
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grille du Donjon
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: currentGrid.length,
                      itemBuilder: (ctx, i) {
                        final tile = currentGrid[i];
                        return InkWell(
                          onTap: () => interactWithTile(tile, i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF161926),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: tile.color.withOpacity(0.8), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: tile.color.withOpacity(0.15),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(tile.icon, color: tile.color, size: 28),
                                const SizedBox(height: 4),
                                Text(
                                  tile.name.toUpperCase(),
                                  style: TextStyle(color: tile.color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Bouton Invocation
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 4,
                        ),
                        onPressed: summonCharacter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.auto_awesome, color: Colors.white),
                            SizedBox(width: 8),
                            Text("INVOCATION (100 💎)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section Équipe
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("VOTRE ÉQUIPE", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
                        Text("${roster.length} Héros", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Liste des héros
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: roster.length,
                      itemBuilder: (ctx, i) {
                        final hero = roster[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161926),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: hero.rarityColor.withOpacity(0.6), width: 1.5),
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: ClassAssets.getColor(hero.charClass).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: ClassAssets.getColor(hero.charClass)),
                                ),
                                child: Icon(ClassAssets.getIcon(hero.charClass), color: ClassAssets.getColor(hero.charClass), size: 22),
                              ),
                              const SizedBox(width: 12),
                              // Infos
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(hero.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        const SizedBox(width: 6),
                                        Text("${hero.rarity}★", style: TextStyle(color: hero.rarityColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Barre de PV
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: hero.hp / hero.maxHp,
                                        backgroundColor: Colors.black38,
                                        color: ClassAssets.getColor(hero.charClass),
                                        minHeight: 6,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text("Niv. ${hero.level} | ATQ: ${hero.attack} | PV: ${hero.hp}/${hero.maxHp}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
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
