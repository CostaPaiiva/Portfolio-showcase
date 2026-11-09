import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../core/app_theme.dart';
import 'user_manual_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          // Banner de Perfil / Usuário
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2228), Color(0xFF16191E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentBright.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 26,
                    color: AppColors.accentBright,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ADMINISTRADOR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: AppColors.muted,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'thiagopaiva',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.online.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.online.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'Ativo',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.online,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Conexões
          _ConnectionCard(),

          const SizedBox(height: 18),

          // Grupo de Permissões & IA
          _Group(
            title: 'Permissões do Copiloto IA',
            children: const [
              _SettingTile(
                icon: Icons.folder_special_rounded,
                iconColor: AppColors.online,
                title: 'Acesso a Arquivos e Pastas',
                subtitle: 'A IA tem autorização para criar e excluir pastas e documentos na VPS.',
              ),
              Divider(height: 1, indent: 56),
              _SettingTile(
                icon: Icons.layers_rounded,
                iconColor: AppColors.online,
                title: 'Controle de Containers Docker',
                subtitle: 'Autorizada a gerenciar start, stop e restart de containers.',
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Grupo de Ajuda
          _Group(
            title: 'Documentação & Suporte',
            children: [
              _SettingTile(
                icon: Icons.menu_book_rounded,
                iconColor: AppColors.accentBright,
                title: 'Manual do Usuário',
                subtitle: 'Entenda métricas, alertas, Docker e ações de automação.',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserManualScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Grupo Sobre
          _Group(
            title: 'Informações do Sistema',
            children: const [
              _SettingTile(
                icon: Icons.info_outline_rounded,
                title: 'VPS Controller Mobile',
                subtitle: 'Versão 0.2.0 • Build com IA Copilot',
              ),
              Divider(height: 1, indent: 56),
              _SettingTile(
                icon: Icons.sensors_rounded,
                title: 'WebSocket Realtime',
                subtitle: 'Eventos ao vivo recebidos com baixa latência.',
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Botão Sair Moderno
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentBright.withValues(alpha: 0.25)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentBright.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.accentBright, size: 20),
              ),
              title: const Text(
                'Encerrar Sessão',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentBright),
              ),
              subtitle: const Text(
                'Desconectar e limpar credenciais salvas neste dispositivo',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              onTap: onLogout,
            ),
          ),
        ],
      );
}

class _ConnectionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.hub_rounded, color: AppColors.accentBright, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  'Conexão de Rede',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Endpoint(
              label: 'API REST',
              value: AppConfig.apiBaseUrl,
              icon: Icons.link_rounded,
            ),
            const SizedBox(height: 12),
            _Endpoint(
              label: 'WebSocket Realtime',
              value: AppConfig.wsUrl,
              icon: Icons.sensors_rounded,
            ),
          ],
        ),
      );
}

class _Endpoint extends StatelessWidget {
  const _Endpoint({required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      );
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(children: children),
          ),
        ],
      );
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title, subtitle;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: iconColor ?? AppColors.muted, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.3),
        ),
        trailing: trailing,
        onTap: onTap,
      );
}
