class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final int height;
  final int weight;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.height,
    required this.weight,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Obtenemos la imagen oficial de alta calidad
    final String image = json['sprites']['other']?['official-artwork']?['front_default'] ??
        json['sprites']['front_default'] ??
        '';

    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: image,
      height: json['height'],
      weight: json['weight'],
    );
  }
}

// Modelo para los elementos de la lista del catálogo
class PokemonListItem {
  final int id;
  final String name;
  final String imageUrl;

  PokemonListItem({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}