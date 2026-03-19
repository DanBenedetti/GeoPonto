import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng initialPosition;
  final double initialRadius;

  const MapPickerScreen({
    super.key,
    required this.initialPosition,
    this.initialRadius = 50.0,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _selectedPosition;
  late double _selectedRadius;
  final _mapController = MapController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    _selectedRadius = widget.initialRadius;
  }

  Future<void> _searchAddress() async {
    if (_searchController.text.isEmpty) return;

    try {
      // Usar Nominatim para todos para maior confiabilidade (não depende de Google Play Services)
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
              Navigator.of(context).pop({
                'position': _selectedPosition,
                'radius': _selectedRadius,
              });
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
                    onSubmitted: (_) => _searchAddress(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchAddress,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.radar, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('Perímetro: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Slider(
                    value: _selectedRadius,
                    min: 5,
                    max: 500,
                    divisions: 99, // (500-5)/5 = 99 divisões para 5m cada
                    label: '${_selectedRadius.round()}m',
                    onChanged: (double value) {
                      setState(() {
                        _selectedRadius = value;
                      });
                    },
                  ),
                ),
                Text('${_selectedRadius.round()}m'),
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
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _selectedPosition,
                      radius: _selectedRadius,
                      useRadiusInMeter: true,
                      color: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40.0,
                      height: 40.0,
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
