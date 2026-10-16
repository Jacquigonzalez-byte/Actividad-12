import 'package:dio/dio.dart';
import 'pokemon_model.dart';

class PokemonService {
  final Dio _dio = Dio();

  // Obtener detalle de un solo Pokémon por su ID
  Future<Pokemon> fetchPokemon(int id) async {
    try {
      final response = await _dio.get('https://pokeapi.co/api/v2/pokemon/$id/');
      if (response.statusCode == 200) {
        return Pokemon.fromJson(response.data);
      } else {
        throw Exception('Error al cargar el pokémon');
      }
    } catch (e) {
      throw Exception('Ocurrió un error en la petición: $e');
    }
  }

  // Obtener la lista completa para el catálogo (primeros 151)
  Future<List<PokemonListItem>> fetchPokemonList({int limit = 151}) async {
    try {
      final response = await _dio.get('https://pokeapi.co/api/v2/pokemon?limit=$limit');
      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results.asMap().entries.map((entry) {
          final int index = entry.key + 1;
          final item = entry.value;
          return PokemonListItem(
            id: index,
            name: item['name'],
            imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$index.png',
          );
        }).toList();
      } else {
        throw Exception('Error al cargar la lista');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}