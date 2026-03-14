import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/auth_provider.dart';
import '../../relationship/domain/relationship_provider.dart';
import '../data/profile_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/bondly_theme.dart';
import '../../../core/widgets/bondly_widgets.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController.text = user?['name'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(user),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 32),
                  _buildRelationshipCodeCard(relationshipState),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Informações Pessoais'),
                  const SizedBox(height: 16),
                  BondlyCard(
                    padding: 0,
                    child: Column(
                      children: [
                        _ProfileInfoItem(
                          icon: Icons.person_outline,
                          label: 'Nome',
                          value: user?['name'] ?? 'Não informado',
                          canEdit: true,
                          onEdit: () => _showEditNameDialog(user?['name'] ?? ''),
                        ),
                        _divider(),
                        _ProfileInfoItem(
                          icon: Icons.email_outlined,
                          label: 'E-mail',
                          value: user?['email'] ?? '',
                        ),
                        _divider(),
                        _ProfileInfoItem(
                          icon: Icons.workspace_premium_outlined,
                          label: 'Plano',
                          value: (user?['role'] ?? 'Standard').toString().toUpperCase(),
                          valueColor: user?['role'] == 'premium' ? Colors.amber : Colors.white70,
                        ),
                      ],
                    ),
                  ),
                  if (user?['role'] != 'premium') ...[
                    const SizedBox(height: 24),
                    _buildPremiumCallout(),
                  ],
                  const SizedBox(height: 32),
                  _buildSectionTitle('Configurações'),
                  const SizedBox(height: 16),
                  BondlyCard(
                    padding: 0,
                    child: Column(
                      children: [
                        _ProfileInfoItem(
                          icon: Icons.language,
                          label: 'Idioma',
                          value: user?['language']?.toUpperCase() ?? 'PT',
                          canEdit: true,
                          onEdit: () => _showLanguageDialog(user?['language'] ?? 'pt'),
                          trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.white24),
                        ),
                        _divider(),
                        _ProfileInfoItem(
                          icon: Icons.notifications_none_outlined,
                          label: 'Notificações',
                          value: 'Ativadas',
                          trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.white24),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Suporte e Ajuda'),
                  const SizedBox(height: 16),
                  BondlyCard(
                    padding: 0,
                    child: Column(
                      children: [
                        _ProfileInfoItem(
                          icon: Icons.chat_outlined,
                          label: 'WhatsApp',
                          value: 'Falar com Moisés',
                          trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.greenAccent),
                          onEdit: () => _launchURL('https://wa.me/244923394229'),
                        ),
                        _divider(),
                        _ProfileInfoItem(
                          icon: Icons.support_agent_outlined,
                          label: 'E-mail',
                          value: 'moisesdematos@hotmail.com',
                          trailing: const Icon(Icons.open_in_new, size: 18, color: Color(0xFF6366F1)),
                          onEdit: () => _launchURL('mailto:moisesdematos@hotmail.com?subject=Suporte Bondly'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Zona de Perigo'),
                  const SizedBox(height: 16),
                  _buildDangerZone(user),
                  const SizedBox(height: 48),
                  _buildLogoutButton(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipCodeCard(RelationshipState state) {
    final code = state.selectedRelationship?['invite_code'];
    if (code == null) return const SizedBox.shrink();

    return BondlyCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: BondlyTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.vpn_key_outlined, color: BondlyTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Código da Relação', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código copiado! 📋')));
                },
                child: const Text('COPIAR'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              code,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4, color: BondlyTheme.primary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Envia este código ao teu parceiro para ele se juntar a ti.', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 70);

  Widget _buildSliverAppBar(Map<String, dynamic>? user) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF0F172A),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Meu Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic>? user) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF0F172A),
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFF2DD4BF), shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user?['name'] ?? 'Usuário',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            user?['email'] ?? '',
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _buildInfoCard({required List<_ProfileInfoItem> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: items.map((item) {
          final isLast = items.indexOf(item) == items.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: Colors.white60, size: 20),
                ),
                title: Text(item.label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                subtitle: Text(
                  item.value,
                  style: TextStyle(
                    color: item.valueColor ?? Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: item.trailing ?? (item.canEdit ? const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF6366F1)) : null),
                onTap: item.onEdit ?? (item.trailing != null ? () {} : null),
              ),
              if (!isLast) Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 70),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPremiumCallout() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFACC15), Color(0xFFEAB308)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.black, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Liberar Todo o Potencial',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Tenha acesso ao Coach de IA ilimitado.',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/premium'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: () {
        ref.read(authProvider.notifier).logout();
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      },
      icon: const Icon(Icons.logout),
      label: const Text('Sair da Conta', style: TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        backgroundColor: Colors.white.withOpacity(0.05),
        foregroundColor: Colors.white70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        border: BorderSide(color: Colors.white.withOpacity(0.1)),
        elevation: 0,
      ),
    );
  }

  Widget _buildDangerZone(Map<String, dynamic>? user) {
    final relationshipState = ref.watch(relationshipProvider);
    final hasRelationship = relationshipState.selectedRelationship != null;

    return Column(
      children: [
        if (hasRelationship) ...[
          _buildDangerButton(
            label: 'Encerrar Relacionamento',
            icon: Icons.heart_broken_outlined,
            onPressed: () => _confirmDeletion(
              title: 'Encerrar Relacionamento?',
              content: 'Isso apagará todo o histórico do casal, memórias e progresso do jardim. Esta ação não pode ser desfeita.',
              onConfirm: () async {
                final relId = relationshipState.selectedRelationship!['id'];
                await ref.read(relationshipProvider.notifier).deleteRelationship(relId);
                if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/relationship-setup', (route) => false);
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        _buildDangerButton(
          label: 'Excluir Minha Conta',
          icon: Icons.delete_forever_outlined,
          onPressed: () => _confirmDeletion(
            title: 'Excluir Conta Permanentemente?',
            content: 'Todos os seus dados pessoais, fotos e conexões serão removidos para sempre de nossos servidores.',
            onConfirm: () async {
              await ref.read(authProvider.notifier).deleteAccount();
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDangerButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        foregroundColor: Colors.redAccent,
        minimumSize: const Size(double.infinity, 50),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        border: BorderSide(color: Colors.redAccent.withOpacity(0.2)),
        elevation: 0,
      ),
    );
  }

  void _confirmDeletion({required String title, required String content, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Excluir', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(String currentName) {
    _nameController.text = currentName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Editar Nome', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Digite seu novo nome',
            hintStyle: TextStyle(color: Colors.white24),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = _nameController.text.trim();
              if (newName.isNotEmpty) {
                try {
                  final updatedUser = await ref.read(profileServiceProvider).updateProfile(name: newName);
                  ref.read(authProvider.notifier).updateUserState(updatedUser);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao atualizar: $e')),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            child: const Text('Salvar'),
          ),

        ],
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o link: $e')),
        );
      }
    }
  }

  void _showLanguageDialog(String currentLang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Alterar Idioma', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Português', style: TextStyle(color: Colors.white)),
              leading: Radio<String>(
                value: 'pt',
                groupValue: currentLang,
                onChanged: (val) => _updateLanguage(val!),
              ),
              onTap: () => _updateLanguage('pt'),
            ),
            ListTile(
              title: const Text('English', style: TextStyle(color: Colors.white)),
              leading: Radio<String>(
                value: 'en',
                groupValue: currentLang,
                onChanged: (val) => _updateLanguage(val!),
              ),
              onTap: () => _updateLanguage('en'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateLanguage(String lang) async {
    try {
      final updatedUser = await ref.read(profileServiceProvider).updateProfile(language: lang);
      ref.read(authProvider.notifier).updateUserState(updatedUser);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Idioma alterado para ${lang.toUpperCase()}!')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao alterar idioma: $e')),
        );
      }
    }
  }
}

class _ProfileInfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onEdit;
  final bool canEdit;
  final Color? valueColor;

  _ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onEdit,
    this.canEdit = false,
    this.valueColor,
  });
}
