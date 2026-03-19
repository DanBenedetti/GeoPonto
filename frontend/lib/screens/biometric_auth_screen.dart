import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geoponto/services/biometric_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BiometricAuthScreen extends StatefulWidget {
  final int? idFuncionario;
  final bool isRegistration;
  final VoidCallback? onAuthenticated; // Callback para quando o 2FA for um sucesso

  const BiometricAuthScreen({super.key, this.idFuncionario, this.isRegistration = false, this.onAuthenticated});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  CameraController? _controller;
  final BiometricService _biometricService = BiometricService();
  bool _isProcessing = false;
  String _message = "Posicione seu rosto no centro";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    // Preferir câmera frontal para biometria
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _processAction() async {
    if (_controller == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _message = "Analisando face...";
    });

    try {
      final image = await _controller!.takePicture();
      final embedding = await _biometricService.extractEmbedding(File(image.path));

      if (embedding == null) {
        throw Exception("Não foi possível extrair características da face.");
      }

      if (widget.isRegistration) {
        await _saveBiometry(embedding);
      } else {
        await _validateBiometry(embedding);
      }
    } catch (e) {
      setState(() {
        _message = "Erro: $e";
        _isProcessing = false;
      });
    }
  }

  Future<void> _saveBiometry(List<double> embedding) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = widget.idFuncionario != null 
        ? 'biometry_template_${widget.idFuncionario}' 
        : 'user_biometry';

    // Salva o vetor como uma String JSON (Simulando o backend)
    await prefs.setString(key, jsonEncode(embedding));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Biometria cadastrada com sucesso!")),
      );
      
      if (widget.onAuthenticated != null) {
        widget.onAuthenticated!();
      } else {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _validateBiometry(List<double> currentEmbedding) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = widget.idFuncionario != null 
        ? 'biometry_template_${widget.idFuncionario}' 
        : 'user_biometry';
        
    final storedData = prefs.getString(key);

    if (storedData == null) {
      setState(() {
        _message = "Biometria não cadastrada. Por favor, cadastre primeiro.";
        _isProcessing = false;
      });
      return;
    }

    final List<double> storedEmbedding = List<double>.from(jsonDecode(storedData));
    
    if (_biometricService.isSamePerson(currentEmbedding, storedEmbedding)) {
      if (mounted) {
        if (widget.onAuthenticated != null) {
          widget.onAuthenticated!();
        } else {
          // Se não houver callback, apenas fecha a tela (pop) para retornar ao fluxo anterior
          Navigator.pop(context, true);
        }
      }
    } else {
      setState(() {
        _message = "Face não reconhecida. Tente novamente em um local mais iluminado.";
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.isRegistration ? "Cadastrar Biometria" : "Verificação Facial")),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 4),
                borderRadius: BorderRadius.circular(200), // Simula um círculo para o rosto
              ),
              clipBehavior: Clip.hardEdge,
              child: CameraPreview(_controller!),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Text(_message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                if (_isProcessing)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    onPressed: _processAction,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(widget.isRegistration ? "Capturar Face" : "Validar Acesso"),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
