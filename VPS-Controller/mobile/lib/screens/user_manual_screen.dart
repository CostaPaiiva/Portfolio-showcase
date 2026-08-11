import 'package:flutter/material.dart';
import '../data/user_manual_content.dart';
import '../models/manual_section.dart';
import '../widgets/app_surface.dart';

class UserManualScreen extends StatefulWidget {
  const UserManualScreen({super.key});

  @override
  State<UserManualScreen> createState() => _UserManualScreenState();
}

class _UserManualScreenState extends State<UserManualScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ManualSection> get _filteredSections {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return userManualSections;
    return userManualSections
        .where(
            (section) => section.searchableText.toLowerCase().contains(query))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final sections = _filteredSections;
    return Scaffold(
      appBar: AppBar(title: const Text('Manual do Usuário')),
      body: AppSurface(
          child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          if (sections.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Nenhum assunto encontrado.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              sliver: SliverList.builder(
                itemCount: sections.length,
                itemBuilder: (context, index) => _SectionTile(
                  section: sections[index],
                  initiallyExpanded: _query.trim().isNotEmpty,
                ),
              ),
            ),
        ],
      )),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aprenda a monitorar e administrar sua VPS com segurança.',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                labelText: 'Pesquisar no manual...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      );
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.section, required this.initiallyExpanded});

  final ManualSection section;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Icon(section.icon),
          title: Text(section.title),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            ...section.paragraphs.map((text) => _Paragraph(text: text)),
            if (section.bullets.isNotEmpty)
              ...section.bullets.map((text) => _Bullet(text: text)),
            if (section.warning != null) _Warning(text: section.warning!),
          ],
        ),
      );
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•  '),
            Expanded(child: Text(text)),
          ],
        ),
      );
}

class _Warning extends StatelessWidget {
  const _Warning({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.errorContainer;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('ATENÇÃO\n$text'),
    );
  }
}
