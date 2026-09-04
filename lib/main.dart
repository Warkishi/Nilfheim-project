import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const AethelgardApp());
}

class AethelgardApp extends StatelessWidget {
  const AethelgardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aethelgard Chronicles',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0B14),
        primaryColor: const Color(0xFFC89B3C),
      ),
      home: const CitadelMainScreen(),
    );
  }
}

class CitadelMainScreen extends StatefulWidget {
  const CitadelMainScreen({super.key});

  @override
  State<CitadelMainScreen> createState() => _CitadelMainScreenState();
}

class _CitadelMainScreenState extends State<CitadelMainScreen> {
  int _activeTab = 0; // 0: Cité, 1: Abysses, 2: Expédition, 3: Panthéon, 4: Salons (Interactions LLM)

  // Économie & Profil
  int orichalque = 84000000;
  int cristauxAstraux = 4150;
  int puissanceEquipe = 3450000;
  int niveauInvocateur = 68;
  String nomJoueur = "Vaelen";

  // Héros avec System Prompts (LLM)
  List<Map<String, dynamic>> champions = [
    {
      'nom': 'Ignis',
      'titre': 'Lame de Cendres',
      'rang': 'Légendaire',
      'niveau': 160,
      'attaque': 8900,
      'vitalite': 42000,
      'etoiles': 5,
      'avatar': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=400&auto=format&fit=crop&q=80',
      'systemPrompt': 'Tu es Ignis, un guerrier de feu impétueux, obsédé par la force et le combat. Tu parles de manière directe, avec véhémence et enthousiasme.',
      'repliques': [
        'Par la flamme éternelle ! Rien ne résiste à ma lame.',
        'Tu parles trop, laisse parler ton acier !',
        'La victoire ne s’obtient que dans la chaleur du sang et des cendres.',
        'Encore un entraînement ? J’espère que la cible tiendra le coup cette fois.'
      ]
    },
    {
      'nom': 'Zephira',
      'titre': 'Tisseuse d’Éther',
      'rang': 'Épique',
      'niveau': 145,
      'attaque': 11200,
      'vitalite': 24000,
      'etoiles': 4,
      'avatar': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400&auto=format&fit=crop&q=80',
      'systemPrompt': 'Tu es Zephira, une archimage éthérée et pragmatique. Tu privilégies la logique, la stratégie et la magie ancestrale.',
      'repliques': [
        'Les étoiles prévoient déjà l’issue de cette rencontre.',
        'Brutalisme inutile... Un brin de magie bien placé résout tout.',
        'Garde ton calme. L’agitation trouble le flux d’éther.',
        'J’ai analysé 10 000 scénarios, celui-ci est le plus optimal.'
      ]
    },
  ];

  // Discussion interactive entre héros (Salon)
  List<Map<String, String>> chatLog = [];
  bool isThinking = false;

  // Progression Expédition
  int chapitre = 14;
  int etape = 8;
  String journalCombat = "Les troupes sont prêtes à franchir la porte des Abysses.";

  // --- MOTEUR DE SIMULATION LLM ---
  String generateLLMResponse(Map<String, dynamic> hero, String lastMessage) {
    final rng = Random();
    List<String> pool = List<String>.from(hero['repliques']);
    
    // Génération basée sur la personnalité
    if (hero['nom'] == 'Ignis' && lastMessage.contains('magie')) {
      return "La magie ? Des étincelles de lâche ! Rien ne vaut la puissance brute de mon épée !";
    } else if (hero['nom'] == 'Zephira' && lastMessage.contains('lame')) {
      return "Ta lame s'émoussera bien avant que mon bouclier d'éther ne faiblisse, Ignis.";
    }
    
    return pool[rng.nextInt(pool.length)];
  }

  void triggerHeroInteraction() {
    if (champions.length < 2) return;
    
    setState(() {
      isThinking = true;
    });

    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final rng = Random();
      
      // Sélection de 2 héros distincts
      int idx1 = rng.nextInt(champions.length);
      int idx2;
      do {
        idx2 = rng.nextInt(champions.length);
      } while (idx1 == idx2);

      var speaker1 = champions[idx1];
      var speaker2 = champions[idx2];

      String lastText = chatLog.isNotEmpty ? chatLog.last['text']! : "Préparez-vous pour la bataille.";
      String resp1 = generateLLMResponse(speaker1, lastText);
      String resp2 = generateLLMResponse(speaker2, resp1);

      setState(() {
        chatLog.add({'speaker': speaker1['nom'], 'text': resp1, 'avatar': speaker1['avatar']});
        chatLog.add({'speaker': speaker2['nom'], 'text': resp2, 'avatar': speaker2['avatar']});
        isThinking = false;
      });
    });
  }

  void invoquerChampion() {
    if (cristauxAstraux < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cristaux astraux insuffisants (300 requis).")),
      );
      return;
    }

    setState(() {
      cristauxAstraux -= 300;
      final rng = Random();
      final prenoms = ['Thalor', 'Vespera', 'Eldrin', 'Kaelen'];
      final titres = ['Ombre céleste', 'Rôdeur du néant', 'Mage de sang'];

      String nomNouveau = prenoms[rng.nextInt(prenoms.length)];
      String titreNouveau = titres[rng.nextInt(titres.length)];

      champions.add({
        'nom': nomNouveau,
        'titre': titreNouveau,
        'rang': 'Mythique',
        'niveau': 1,
        'attaque': 3200,
        'vitalite': 18000,
        'etoiles': 4,
        'avatar': 'https://images.unsplash.com/photo-1563089145-599997674d42?w=400&auto=format&fit=crop&q=80',
        'systemPrompt': 'Tu es un protecteur sombre et mystérieux.',
        'repliques': [
          'L\'obscurité est mon alliée.',
          'Rien ne peut échapper à l\'ombre.',
          'Je veille sur le groupe dans le silence.'
        ]
      });
      puissanceEquipe += 62000;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invocation réussie au Sanctuaire !")),
    );
  }

  void ameliorerChampion(int index) {
    int coutOr = champions[index]['niveau'] * 1800;
    if (orichalque >= coutOr) {
      setState(() {
        orichalque -= coutOr;
        champions[index]['niveau']++;
        champions[index]['attaque'] += 310;
        champions[index]['vitalite'] += 1400;
        puissanceEquipe += 2200;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _creerEnteteSuperieure(),
            Expanded(
              child: IndexedStack(
                index: _activeTab,
                children: [
                  _creerHubCitadelle(),
                  _creerEcranEclectique("Les Abysses", Icons.visibility_outlined),
                  _creerEcranExpedition(),
                  _creerEcranPantheon(),
                  _creerEcranInteractionsLLM(),
                ],
              ),
            ),
            _creerBarreNavigationGothique(),
          ],
        ),
      ),
    );
  }

  // --- EN-TÊTE DU PERSONNAGE & RESSOURCES ---
  Widget _creerEnteteSuperieure() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF161220),
        border: Border(bottom: BorderSide(color: Color(0xFF3B2D4A), width: 1.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC89B3C), width: 1.5),
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF2A2035),
              child: Icon(Icons.auto_awesome, color: Color(0xFFC89B3C), size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nomJoueur, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              Text("Invocateur Niv. $niveauInvocateur", style: const TextStyle(fontSize: 10, color: Color(0xFF9E8DB2))),
              Row(
                children: [
                  const Icon(Icons.flash_on, color: Color(0xFFC89B3C), size: 11),
                  const SizedBox(width: 2),
                  Text("${(puissanceEquipe / 1000).toStringAsFixed(0)}K", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC89B3C))),
                ],
              ),
            ],
          ),
          const Spacer(),
          _creerBadgetResource(Icons.hexagon_outlined, "${(orichalque / 1000000).toStringAsFixed(0)}M", const Color(0xFFC89B3C)),
          const SizedBox(width: 6),
          _creerBadgetResource(Icons.diamond_outlined, "$cristauxAstraux", Colors.purpleAccent),
        ],
      ),
    );
  }

  Widget _creerBadgetResource(IconData icone, String valeur, Color couleur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF09070D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2D2338)),
      ),
      child: Row(
        children: [
          Icon(icone, color: couleur, size: 13),
          const SizedBox(width: 4),
          Text(valeur, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  // --- HUB DE LA CITADELLE ---
  Widget _creerHubCitadelle() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1200&auto=format&fit=crop&q=80',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.5), Colors.black.withOpacity(0.2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Batiments tactiles
        SingleChildScrollView(
          child: SizedBox(
            height: 650,
            child: Stack(
              children: [
                _creerBatimentInteractive("Sanctuaire des Âmes", "Invocations", const Offset(30, 320), Colors.amber, () {
                  _ouvrirBoiteDialogueSanctuaire();
                }),
                _creerBatimentInteractive("Salons d’Aethelgard", "Interactions LLM", const Offset(170, 180), Colors.purpleAccent, () {
                  setState(() => _activeTab = 4);
                }),
                _creerBatimentInteractive("Tour d'Éther", "Ascension", const Offset(190, 340), Colors.cyanAccent, () {
                  setState(() => _activeTab = 3);
                }),
                _creerBatimentInteractive("Forge des Runes", "Équipements", const Offset(20, 180), Colors.orangeAccent, () {}),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _creerBatimentInteractive(String titre, String sousTitre, Offset position, Color couleurAccent, VoidCallback ActionTap) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: ActionTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xEE161220),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: couleurAccent.withOpacity(0.8), width: 1.2),
            boxShadow: [
              BoxShadow(color: couleurAccent.withOpacity(0.2), blurRadius: 8, spreadRadius: 1),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 2),
              Text(sousTitre, style: TextStyle(color: couleurAccent, fontSize: 9, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  // --- ECRAN INTERACTIONS LLM (SALONS) ---
  Widget _creerEcranInteractionsLLM() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("SALONS D'AETHELGARD", style: TextStyle(color: Color(0xFFC89B3C), fontWeight: FontWeight.bold, fontSize: 15)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC89B3C)),
                onPressed: isThinking ? null : triggerHeroInteraction,
                icon: const Icon(Icons.forum, color: Colors.black, size: 16),
                label: Text(isThinking ? "Réflexion..." : "Lancer échange LLM", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
              )
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF120E1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2D2338)),
              ),
              child: chatLog.isEmpty
                  ? const Center(child: Text("Appuie sur 'Lancer échange LLM' pour voir tes héros discuter entre eux.", style: TextStyle(color: Colors.grey, fontSize: 12)))
                  : ListView.builder(
                      itemCount: chatLog.length,
                      itemBuilder: (ctx, i) {
                        final msg = chatLog[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(msg['avatar']!, width: 36, height: 36, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(msg['speaker']!, style: const TextStyle(color: Color(0xFFC89B3C), fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E172A),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(msg['text']!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAVERNE / SANCTUAIRE DIALOG ---
  void _ouvrirBoiteDialogueSanctuaire() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161220),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFC89B3C), width: 1),
        ),
        title: const Text("Sanctuaire des Âmes", style: TextStyle(color: Color(0xFFC89B3C))),
        content: const Text("Tissez les liens astraux pour matérialiser un nouveau champion."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Retour", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC89B3C)),
            onPressed: () {
              Navigator.pop(ctx);
              invoquerChampion();
            },
            child: const Text("Invoquer (300 💎)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- ÉCRAN EXPÉDITION ---
  Widget _creerEcranExpedition() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text("EXPÉDITION — RIFT $chapitre", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC89B3C))),
          Text("Secteur $etape/20", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF120E1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2D2338)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_moon_outlined, size: 70, color: Color(0xFFC89B3C)),
                  const SizedBox(height: 16),
                  Text(journalCombat, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC89B3C),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        etape++;
                        if (etape > 20) {
                          chapitre++;
                          etape = 1;
                        }
                        orichalque += 85000;
                        cristauxAstraux += 15;
                        journalCombat = "Secteur franchi avec succès. Obtenu : +85K Orichalque, +15 Cristaux.";
                      });
                    },
                    child: const Text("ENGAGER LE COMBAT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- ÉCRAN PANTHÉON DES HÉROS ---
  Widget _creerEcranPantheon() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: champions.length,
      itemBuilder: (ctx, i) {
        final c = champions[i];
        int coutAmelioration = (c['niveau'] as int) * 1800;

        return Card(
          color: const Color(0xFF161220),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF2D2338)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(c['avatar'], width: 55, height: 55, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${c['nom']} (${c['rang']})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(c['titre'], style: const TextStyle(color: Color(0xFFC89B3C), fontSize: 10)),
                      const SizedBox(height: 4),
                      Text("Niv. ${c['niveau']} | ATQ: ${c['attaque']} | PV: ${c['vitalite']}", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC89B3C)),
                  onPressed: () => ameliorerChampion(i),
                  child: Text("NIV. +\n($coutAmelioration Or)", textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _creerEcranEclectique(String titre, IconData icone) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, size: 50, color: const Color(0xFFC89B3C)),
          const SizedBox(height: 12),
          Text(titre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  // --- BARRE DE NAVIGATION GOTHIQUE ---
  Widget _creerBarreNavigationGothique() {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFF161220),
        border: Border(top: BorderSide(color: Color(0xFF3B2D4A), width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _creerOngletNav(0, Icons.fort_outlined, "Citadelle"),
          _creerOngletNav(1, Icons.auto_graph_outlined, "Abysses"),
          _creerOngletNav(2, Icons.explore_outlined, "Expédition"),
          _creerOngletNav(3, Icons.style_outlined, "Panthéon"),
          _creerOngletNav(4, Icons.forum_outlined, "Salons LLM"),
        ],
      ),
    );
  }

  Widget _creerOngletNav(int index, IconData icone, String libelle) {
    bool estActif = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, color: estActif ? const Color(0xFFC89B3C) : Colors.grey, size: 20),
          const SizedBox(height: 2),
          Text(
            libelle,
            style: TextStyle(
              fontSize: 9,
              color: estActif ? const Color(0xFFC89B3C) : Colors.grey,
              fontWeight: estActif ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
