import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/auth_provider.dart';
import '../data/profile_service.dart';


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
                  _buildSectionTitle('Informações Pessoais'),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    items: [
                      _ProfileInfoItem(
                        icon: Icons.person_outline,
                        label: 'Nome',
                        value: user?['name'] ?? 'Não informado',
                        canEdit: true,
                        onEdit: () => _showEditNameDialog(user?['name'] ?? ''),
                      ),
                      _ProfileInfoItem(
                        icon: Icons.email_outlined,
                        label: 'E-mail',
                        value: user?['email'] ?? '',
                      ),
                      _ProfileInfoItem(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Plano',
                        value: (user?['role'] ?? 'Standard').toString().toUpperCase(),
                        valueColor: user?['role'] == 'premium' ? Colors.amber : Colors.white70,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Configurações'),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    items: [
                      _ProfileInfoItem(
                        icon: Icons.language,
                        label: 'Idioma',
                        value: user?['language']?.toUpperCase() ?? 'PT-BR',
                        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.white24),
                      ),
                      _ProfileInfoItem(
                        icon: Icons.notifications_none_outlined,
                        label: 'Notificações',
                        value: 'Ativadas',
                        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.white24),
                      ),
                      _ProfileInfoItem(
                        icon: Icons.security_outlined,
                        label: 'Privacidade',
                        value: 'Configurar',
                        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.white24),
                      ),
                    ],
                  ),
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
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        foregroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        border: BorderSide(color: Colors.redAccent.withOpacity(0.2)),
        elevation: 0,
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
