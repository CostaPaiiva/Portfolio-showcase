import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin, this.message});
  final Future<void> Function(String token) onLogin;
  final String? message;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onLogin(_controller.text);
    } catch (_) {
      if (mounted) setState(() => _error = 'Não foi possível conectar à VPS.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.dns_rounded, size: 64),
                    const SizedBox(height: 12),
                    Text('VPS Controller',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const Text('Server Management'),
                    const SizedBox(height: 28),
                    TextField(
                        controller: _controller,
                        obscureText: true,
                        enabled: !_loading,
                        decoration: const InputDecoration(
                            labelText: 'Token de acesso',
                            border: OutlineInputBorder())),
                    if (widget.message != null || _error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error ?? widget.message!,
                          style: const TextStyle(color: Colors.orange)),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Entrar')),
                  ]),
                ))),
      );
}
