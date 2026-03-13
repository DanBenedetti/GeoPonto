import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng initialPosition;

  const MapPickerScreen({super.key, required this.initialPosition});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _selectedPosition;
  final _mapController = MapController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
  }

  Future<void> _searchAddress() async {
    if (_searchController.text.isEmpty) return;

    try {
      if (kIsWeb) {
        // Solução para Web: Nominatim (OpenStreetMap)
        final url = Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(_searchController.text)}&format=json&limit=1');
        
        final response = await http.get(url, headers: {
          'User-Agent': 'GeoPontoApp_PI_Fatec',
        });

        if (response.statusCode == 200) {
          final List<dynamic> results = json.decode(response.body);
          if (results.isNotEmpty) {
            final lat = double.parse(results[0]['lat']);
            final lon = double.parse(results[0]['lon']);
            setState(() {
              _selectedPosition = LatLng(lat, lon);
              _mapController.move(_selectedPosition, 15.0);
            });
            return;
          }
        }
      } else {
        // Solução para Android/iOS: Geocoding Nativo
        final locations = await geocoding.locationFromAddress(_searchController.text);
        if (locations.isNotEmpty) {
          final location = locations.first;
          setState(() {
            _selectedPosition = LatLng(location.latitude, location.longitude);
            _mapController.move(_selectedPosition, 15.0);
          });
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endereço não encontrado.')),
        );
      }
    } catch (e) {
      debugPrint('Erro na busca: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao pesquisar o endereço.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione a Localização'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(_selectedPosition);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Pesquisar endereço',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchAddress,
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedPosition,
                initialZoom: 15.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedPosition = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'geoponto',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _selectedPosition,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
