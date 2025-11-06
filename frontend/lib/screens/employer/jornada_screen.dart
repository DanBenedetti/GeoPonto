import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoponto/components/editor.dart';
import 'package:geoponto/components/time_editor.dart';
import 'package:geoponto/config/api_config.dart';
import 'package:geoponto/models/colaborador.dart';
import 'package:geoponto/models/jornada.dart';
import 'package:geoponto/models/localizacao.dart';
import 'package:http/http.dart' as http;
import 'package:geoponto/screens/employer/map_picker_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoponto/services/analytics_service.dart';
import 'package:geoponto/components/analytics_button.dart';

class JornadaScreen extends StatefulWidget {
  final Colaborador colaborador;

  const JornadaScreen({super.key, required this.colaborador});

  @override
  State<JornadaScreen> createState() => _JornadaScreenState();
}

class _JornadaScreenState extends State<JornadaScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _limitarLocalizacao = false;
  Localizacao? _localizacao;

  // Standard Journey Controllers
  final _horarioEntradaController = TextEditingController();
  final _horarioSaidaIntervaloController = TextEditingController();
  final _horarioRetornoIntervaloController = TextEditingController();
  final _horarioSaidaController = TextEditingController();

  // Location Controllers
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _raioController = TextEditingController();

  // Weekday selectors
  final List<bool> _diasSemanaSelecionados = List.generate(7, (_) => false);
  final List<String> _diasSemanaNomes = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
  final List<String> _diasSemanaNomesCompletos = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];

  // Exception Journeys
  final List<JornadaExcecaoControllers> _jornadasExcecao = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _horarioEntradaController.dispose();
    _horarioSaidaIntervaloController.dispose();
    _horarioRetornoIntervaloController.dispose();
    _horarioSaidaController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _raioController.dispose();
    for (var controller in _jornadasExcecao) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jornadaResponse = await http.get(Uri.parse('${ApiConfig.baseUrl}/jornadas/funcionario/${widget.colaborador.id_funcionario}'));
      if (jornadaResponse.statusCode == 200) {
        final data = jsonDecode(jornadaResponse.body);
        final List<Jornada> jornadas = (data['jornadas'] as List).map((j) => Jornada.fromJson(j)).toList();
        _populateJornadaFields(jornadas);
      }

      final localizacaoResponse = await http.get(Uri.parse('${ApiConfig.baseUrl}/localizacoes/funcionario/${widget.colaborador.id_funcionario}'));
      if (localizacaoResponse.statusCode == 200) {
        final data = jsonDecode(localizacaoResponse.body);
        if (data['localizacao'] != null) {
          _localizacao = Localizacao.fromJson(data['localizacao']);
          _populateLocalizacaoFields();
        }
      }
    } catch (e) {
      // Handle error
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _formatTime(String time) {
    if (time == 'null' || time.isEmpty) {
      return '';
    }
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  void _populateJornadaFields(List<Jornada> jornadas) {
    if (jornadas.isEmpty) return;

    try {
      // Group journeys by schedule
      final Map<String, List<int>> schedules = {};
      for (var jornada in jornadas) {
        final schedule = '${jornada.horario_entrada}-${jornada.horario_saida_intervalo}-${jornada.horario_retorno_intervalo}-${jornada.horario_saida}';
        if (schedules.containsKey(schedule)) {
          schedules[schedule]!.add(jornada.dia_semana);
        } else {
          schedules[schedule] = [jornada.dia_semana];
        }
      }

      // Find the standard journey (the one with the most days)
      String? standardScheduleKey;
      int maxDays = 0;
      schedules.forEach((key, value) {
        if (value.length > maxDays) {
          maxDays = value.length;
          standardScheduleKey = key;
        }
      });

      // Populate standard journey fields
      if (standardScheduleKey != null) {
        final standardSchedule = standardScheduleKey!.split('-');
        _horarioEntradaController.text = _formatTime(standardSchedule[0]);
        _horarioSaidaIntervaloController.text = _formatTime(standardSchedule[1]);
        _horarioRetornoIntervaloController.text = _formatTime(standardSchedule[2]);
        _horarioSaidaController.text = _formatTime(standardSchedule[3]);
        for (var day in schedules[standardScheduleKey]!) {
          _diasSemanaSelecionados[day] = true;
        }
      }

      // Populate exception journeys
      schedules.forEach((key, value) {
        if (key != standardScheduleKey) {
          final schedule = key.split('-');
          for (var day in value) {
            final excecao = JornadaExcecaoControllers();
            excecao.diaSemana = day;
            excecao.horarioEntradaController.text = _formatTime(schedule[0]);
            excecao.horarioSaidaIntervaloController.text = _formatTime(schedule[1]);
            excecao.horarioRetornoIntervaloController.text = _formatTime(schedule[2]);
            excecao.horarioSaidaController.text = _formatTime(schedule[3]);
            _jornadasExcecao.add(excecao);
          }
        }
      });

      setState(() {});
    } catch (e) {
      print('Error populating journey fields: $e');
    }
  }

  void _populateLocalizacaoFields() {
    if (_localizacao != null) {
      setState(() {
        _limitarLocalizacao = true;
        _latitudeController.text = _localizacao!.latitude.toString();
        _longitudeController.text = _localizacao!.longitude.toString();
        _raioController.text = _localizacao!.raio_permitido.toString();
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await _saveJornada();
      await _saveLocalizacao();

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop();
    }
  }

  Future<void> _saveJornada() async {
    final List<Map<String, dynamic>> dias = [];

    // Add standard journey days
    for (int i = 0; i < 7; i++) {
      if (_diasSemanaSelecionados[i]) {
        dias.add({
          'dia_semana': i,
          'horario_entrada': _horarioEntradaController.text.isNotEmpty ? _horarioEntradaController.text : null,
          'horario_saida_intervalo': _horarioSaidaIntervaloController.text.isNotEmpty ? _horarioSaidaIntervaloController.text : null,
          'horario_retorno_intervalo': _horarioRetornoIntervaloController.text.isNotEmpty ? _horarioRetornoIntervaloController.text : null,
          'horario_saida': _horarioSaidaController.text.isNotEmpty ? _horarioSaidaController.text : null,
        });
      }
    }

    // Add exception journey days
    for (var excecao in _jornadasExcecao) {
      if (excecao.diaSemana != null) {
        dias.add({
          'dia_semana': excecao.diaSemana,
          'horario_entrada': excecao.horarioEntradaController.text.isNotEmpty ? excecao.horarioEntradaController.text : null,
          'horario_saida_intervalo': excecao.horarioSaidaIntervaloController.text.isNotEmpty ? excecao.horarioSaidaIntervaloController.text : null,
          'horario_retorno_intervalo': excecao.horarioRetornoIntervaloController.text.isNotEmpty ? excecao.horarioRetornoIntervaloController.text : null,
          'horario_saida': excecao.horarioSaidaController.text.isNotEmpty ? excecao.horarioSaidaController.text : null,
        });
      }
    }

    final payload = {
      'id_funcionario': widget.colaborador.id_funcionario,
      'jornada_diferenciada': true, // Always true, backend will handle it
      'dias': dias,
    };

    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/jornadas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveLocalizacao() async {
    if (_limitarLocalizacao) {
      final payload = {
        'id_funcionario': widget.colaborador.id_funcionario,
        'latitude': _latitudeController.text,
        'longitude': _longitudeController.text,
        'raio_permitido': _raioController.text,
      };

      try {
        if (_localizacao != null) {
          // Update existing
          await http.put(
            Uri.parse('${ApiConfig.baseUrl}/localizacoes/${_localizacao!.id_localizacao}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          );
        } else {
          // Create new
          await http.post(
            Uri.parse('${ApiConfig.baseUrl}/localizacoes'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          );
        }
      } catch (e) {
        // Handle error
      }
    } else {
      if (_localizacao != null) {
        // Delete existing
        try {
          await http.delete(Uri.parse('${ApiConfig.baseUrl}/localizacoes/${_localizacao!.id_localizacao}'));
        } catch (e) {
          // Handle error
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jornada de Trabalho'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${widget.colaborador.nome} ${widget.colaborador.sobrenome ?? ''}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      widget.colaborador.cargo ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    _buildJornadaPadraoFields(),
                    const SizedBox(height: 16),
                    _buildExcecoesSection(),
                    const SizedBox(height: 24),
                    _buildLocalizacaoSwitch(),
                    if (_limitarLocalizacao) _buildLocalizacaoFields(),
                    const SizedBox(height: 32),
                    AnalyticsButton(
                      buttonId: 'save_journey_button',
                      onPressed: _isLoading ? () {} : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Salvar Jornada'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildJornadaPadraoFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jornada Padrão', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Selecione os dias da semana para a jornada padrão:'),
        const SizedBox(height: 8),
        _buildDiasSemanaSelector(),
        const SizedBox(height: 16),
        TimeEditor(controller: _horarioEntradaController, hintText: 'Entrada (HH:MM)'),
        TimeEditor(controller: _horarioSaidaIntervaloController, hintText: 'Saída Intervalo (HH:MM) - Opcional', isRequired: false),
        TimeEditor(controller: _horarioRetornoIntervaloController, hintText: 'Retorno Intervalo (HH:MM) - Opcional', isRequired: false),
        TimeEditor(controller: _horarioSaidaController, hintText: 'Saída (HH:MM)'),
      ],
    );
  }

  Widget _buildDiasSemanaSelector() {
    return ToggleButtons(
      isSelected: _diasSemanaSelecionados,
      onPressed: (int index) {
        setState(() {
          _diasSemanaSelecionados[index] = !_diasSemanaSelecionados[index];
        });
      },
      children: List<Widget>.generate(7, (int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(_diasSemanaNomes[index]),
        );
      }),
    );
  }

  Widget _buildExcecoesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jornadas de Exceção', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _jornadasExcecao.length,
          itemBuilder: (context, index) {
            return _buildExcecaoCard(_jornadasExcecao[index], index);
          },
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Adicionar jornada de exceção'),
          onPressed: () {
            setState(() {
              _jornadasExcecao.add(JornadaExcecaoControllers());
            });
          },
        ),
      ],
    );
  }

  Widget _buildExcecaoCard(JornadaExcecaoControllers excecao, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Exceção ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    setState(() {
                      _jornadasExcecao.removeAt(index);
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: excecao.diaSemana,
              hint: const Text('Selecione o dia'),
              onChanged: (int? newValue) {
                setState(() {
                  excecao.diaSemana = newValue;
                });
              },
              items: List.generate(7, (i) => DropdownMenuItem(value: i, child: Text(_diasSemanaNomesCompletos[i]))),
            ),
            const SizedBox(height: 16),
            TimeEditor(controller: excecao.horarioEntradaController, hintText: 'Entrada (HH:MM)'),
            TimeEditor(controller: excecao.horarioSaidaIntervaloController, hintText: 'Saída Intervalo (HH:MM) - Opcional', isRequired: false),
            TimeEditor(controller: excecao.horarioRetornoIntervaloController, hintText: 'Retorno Intervalo (HH:MM) - Opcional', isRequired: false),
            TimeEditor(controller: excecao.horarioSaidaController, hintText: 'Saída (HH:MM)'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalizacaoSwitch() {
    return SwitchListTile(
      title: const Text('Limitar local de registro de ponto'),
      value: _limitarLocalizacao,
      onChanged: (bool value) {
        setState(() {
          _limitarLocalizacao = value;
        });
      },
    );
  }

  Widget _buildLocalizacaoFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Editor(controller: _latitudeController, hintText: 'Latitude', keyboardType: TextInputType.number, enabled: false)),
            const SizedBox(width: 8),
            Expanded(child: Editor(controller: _longitudeController, hintText: 'Longitude', keyboardType: TextInputType.number, enabled: false)),
          ],
        ),
        const SizedBox(height: 8),
        Editor(controller: _raioController, hintText: 'Raio em metros', keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.map_outlined),
            label: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Selecionar no Mapa'),
            ),
            onPressed: () async {
              AnalyticsService.recordButtonClick('select_on_map_button', pageName: '/employer/journey');
              final selectedPosition = await Navigator.of(context).push<LatLng>(
                MaterialPageRoute(
                  builder: (context) => MapPickerScreen(
                    initialPosition: LatLng(
                      double.tryParse(_latitudeController.text) ?? -20.5937, // Default to a central location in Brazil
                      double.tryParse(_longitudeController.text) ?? -47.3969,
                    ),
                  ),
                  settings: const RouteSettings(name: '/employer/map-picker'),
                ),
              );

              if (selectedPosition != null) {
                setState(() {
                  _latitudeController.text = selectedPosition.latitude.toString();
                  _longitudeController.text = selectedPosition.longitude.toString();
                });
              }
            },
          ),
        ),
      ],
    );
  }
}

class JornadaExcecaoControllers {
  int? diaSemana;
  final TextEditingController horarioEntradaController = TextEditingController();
  final TextEditingController horarioSaidaIntervaloController = TextEditingController();
  final TextEditingController horarioRetornoIntervaloController = TextEditingController();
  final TextEditingController horarioSaidaController = TextEditingController();

  void dispose() {
    horarioEntradaController.dispose();
    horarioSaidaIntervaloController.dispose();
    horarioRetornoIntervaloController.dispose();
    horarioSaidaController.dispose();
  }
}