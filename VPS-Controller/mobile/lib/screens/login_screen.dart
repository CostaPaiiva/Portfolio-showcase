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
  final _formKey = GlobalKey<FormState>();
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
    if (_loading || !(_formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onLogin(
          _usernameController.text.trim(), _passwordController.text);
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
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 22),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _BrandHeader(),
                      const SizedBox(height: 26),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Acessar painel',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700)),
                                const SizedBox(height: 5),
                                Text(
                                    'Entre para acompanhar sua infraestrutura.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColors.muted)),
                                const SizedBox(height: 22),
                                TextFormField(
                                  controller: _usernameController,
                                  enabled: !_loading,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.username],
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                          ? 'Informe seu usuário.'
                                          : null,
                                  decoration: const InputDecoration(
                                    labelText: 'Usuário',
                                    hintText: 'Digite seu usuário',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _passwordController,
                                  enabled: !_loading,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  onFieldSubmitted: (_) => _submit(),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Informe sua senha.'
                                          : null,
                                  decoration: InputDecoration(
                                    labelText: 'Senha',
                                    hintText: 'Digite sua senha',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      tooltip: _obscurePassword
                                          ? 'Mostrar senha'
                                          : 'Ocultar senha',
                                      icon: Icon(_obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined),
                                      onPressed: _loading
                                          ? null
                                          : () => setState(() =>
                                              _obscurePassword =
                                                  !_obscurePassword),
                                    ),
                                  ),
                                ),
                                if (widget.message != null ||
                                    _error != null) ...[
                                  const SizedBox(height: 14),
                                  _ErrorMessage(
                                      text: _error ?? widget.message!),
                                ],
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 50,
                                  child: FilledButton.icon(
                                    onPressed: _loading ? null : _submit,
                                    icon: _loading
                                        ? const SizedBox(
                                            width: 19,
                                            height: 19,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white))
                                        : const Icon(Icons.arrow_forward),
                                    label: Text(_loading
                                        ? 'Autenticando...'
                                        : 'Entrar'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _SecurityHint(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: AppColors.accentDark,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(color: Color(0x559F1D20), blurRadius: 24),
              ],
            ),
            child:
                const Icon(Icons.dns_outlined, size: 42, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text('VPS CONTROLLER',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  )),
          const SizedBox(height: 6),
          Text('Gerenciamento privado da sua VPS',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.muted)),
        ],
      );
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accentDark.withValues(alpha: .28),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.accent.withValues(alpha: .55)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.accentBright, size: 19),
            const SizedBox(width: 9),
            Expanded(
              child: Text(text,
                  style: const TextStyle(color: AppColors.text, height: 1.3)),
            ),
          ],
        ),
      );
}

class _SecurityHint extends StatelessWidget {
  const _SecurityHint();

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user_outlined,
              size: 16, color: AppColors.online),
          const SizedBox(width: 7),
          Flexible(
            child: Text('Conexão protegida • credenciais não são exibidas',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.muted)),
          ),
        ],
      );
}
