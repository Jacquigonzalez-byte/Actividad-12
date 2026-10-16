import 'package:flutter/material.dart';
import 'pokemon_model.dart';
import 'pokemon_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokédex App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// Navegación principal entre pestañas (Detalle y Catálogo)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  int _selectedPokemonId = 1;

  void _onSelectPokemonFromList(int id) {
    setState(() {
      _selectedPokemonId = id;
      _currentIndex = 0; // Cambia a la pestaña de Detalle
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      PokemonDetailScreen(
        pokemonId: _selectedPokemonId,
        onIdChanged: (newId) {
          setState(() {
            _selectedPokemonId = newId;
          });
        },
      ),
      PokemonGridMenu(
        onPokemonTap: _onSelectPokemonFromList,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: 'Detalle',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Catálogo',
          ),
        ],
      ),
    );
  }
}

// PESTAÑA 1: Vista de Detalle con diseño mejorado
class PokemonDetailScreen extends StatefulWidget {
  final int pokemonId;
  final ValueChanged<int> onIdChanged;

  const PokemonDetailScreen({
    super.key,
    required this.pokemonId,
    required this.onIdChanged,
  });

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final PokemonService _service = PokemonService();
  late Future<Pokemon> _pokemonFuture;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant PokemonDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pokemonId != widget.pokemonId) {
      _fetch();
    }
  }

  void _fetch() {
    setState(() {
      _pokemonFuture = _service.fetchPokemon(widget.pokemonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex #${widget.pokemonId}'),
        centerTitle: true,
      ),
      body: FutureBuilder<Pokemon>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Sin datos'));
          }

          final pokemon = snapshot.data!;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade100,
                      Colors.purple.shade50,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge con el ID
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '#${pokemon.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Imagen con fondo circular
                      Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Image.network(
                          pokemon.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Nombre
                      Text(
                        pokemon.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.black,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tarjetas de estadísticas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatCard(
                            icon: Icons.square_foot,
                            label: 'Altura',
                            value: '${pokemon.height / 10} m',
                          ),
                          _StatCard(
                            icon: Icons.fitness_center,
                            label: 'Peso',
                            value: '${pokemon.weight / 10} kg',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.pokemonId > 1)
            FloatingActionButton(
              heroTag: 'prev',
              onPressed: () => widget.onIdChanged(widget.pokemonId - 1),
              child: const Icon(Icons.arrow_back),
            ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'next',
            onPressed: () => widget.onIdChanged(widget.pokemonId + 1),
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para mostrar las tarjetas de estadísticas
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// PESTAÑA 2: Menú con catálogo completo en cuadrícula (Grid)
class PokemonGridMenu extends StatefulWidget {
  final ValueChanged<int> onPokemonTap;

  const PokemonGridMenu({super.key, required this.onPokemonTap});

  @override
  State<PokemonGridMenu> createState() => _PokemonGridMenuState();
}

class _PokemonGridMenuState extends State<PokemonGridMenu> {
  final PokemonService _service = PokemonService();
  late Future<List<PokemonListItem>> _listFuture;

  @override
  void initState() {
    super.initState();
    _listFuture = _service.fetchPokemonList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo Pokémon'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<PokemonListItem>>(
        future: _listFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return InkWell(
                onTap: () => widget.onPokemonTap(item.id),
                borderRadius: BorderRadius.circular(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.catching_pokemon),
                          ),
                        ),
                      ),
                      Text(
                        '#${item.id}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        item.name.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}