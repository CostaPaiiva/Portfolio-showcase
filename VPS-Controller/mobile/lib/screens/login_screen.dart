import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/app_surface.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin, this.message});
  final Future<void> Function(String username, String password) onLogin;
  final String? message;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onLogin(_usernameController.text, _passwordController.text);
    } catch (_) {
      if (mounted) setState(() => _error = 'Não foi possível conectar à VPS.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: AppSurface(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: AppColors.accentDark,
                              borderRadius: BorderRadius.circular(18)),
                          child: const Icon(Icons.dns_outlined,
                              size: 42, color: Colors.white),
                        ),
                        const SizedBox(height: 18),
                        Text('VPS Controller',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 5),
                        Text('Gerenciamento privado da sua VPS',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.muted)),
                        const SizedBox(height: 28),
                        TextField(
                          controller: _usernameController,
                          obscureText: false,
                          enabled: !_loading,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          decoration: const InputDecoration(
                              labelText: 'Usuário',
                              prefixIcon: Icon(Icons.person_outline)),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          enabled: !_loading,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Mostrar senha'
                                    : 'Ocultar senha',
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              )),
                        ),
                        if (widget.message != null || _error != null) ...[
                          const SizedBox(height: 12),
                          Text(_error ?? widget.message!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.accentBright)),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _loading ? null : _submit,
                            icon: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.login),
                            label: Text(_loading ? 'Conectando...' : 'Entrar'),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
