import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../service/auth_service.dart';
import 'package:keybook/service/theme_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userDetails = AuthService.getUserDetails();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userDetails = await AuthService.getUserDetails();
    setState(() {
      _userDetails = Future.value(userDetails);
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF232323),
            title: Text(
              'Sair da conta?',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            content: Text(
              'Tem certeza que deseja sair?',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context);
                  await _performLogout(context);
                },
                child: Text(
                  'Sair',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);

    try {
      scaffold.showSnackBar(
        const SnackBar(content: Text('Encerrando sessão...')),
      );

      await AuthService.logout();

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Erro ao sair: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.instance;
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardColor;
    final textColor = colorScheme.onBackground;
    final mutedColor = textColor.withOpacity(0.7);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Perfil',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              tooltip:
                  themeController.isDarkMode
                      ? 'Ativar modo claro'
                      : 'Ativar modo escuro',
              icon: Icon(
                themeController.isDarkMode
                    ? Icons.dark_mode
                    : Icons.wb_sunny_outlined,
              ),
              onPressed: () => themeController.toggleTheme(),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _userDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar perfil: ${snapshot.error}'),
              );
            }

            final userData = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: mutedColor,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    userData['nome'] ?? 'Usuário',
                    style: GoogleFonts.inter(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _ProfileActionTile(
                  icon: Icons.person,
                  label: 'Conta',
                  iconColor: textColor,
                  textColor: textColor,
                  backgroundColor: cardColor,
                  trailing: Icon(Icons.chevron_right, color: mutedColor),
                  onTap: () async {
                    final updatedUser = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileDetailsScreen(userData: userData),
                      ),
                    );

                    if (updatedUser != null) {
                      setState(() {
                        _userDetails = Future.value(updatedUser);
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                _ProfileActionTile(
                  icon: Icons.logout,
                  label: 'Log out',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  backgroundColor: cardColor,
                  onTap: () => _showLogoutDialog(context),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}

// NOVA TELA: Detalhes do Perfil
class ProfileDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileDetailsScreen({super.key, required this.userData});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isEditingPassword = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.userData['nome']);
    emailController = TextEditingController(text: widget.userData['email']);
    passwordController = TextEditingController(text: '********');
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF232323),
            title: Text(
              'Deletar Conta?',
              style: GoogleFonts.inter(color: Colors.red),
            ),
            content: Text(
              'Tem certeza que deseja deletar sua conta? Esta ação não pode ser desfeita.',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context);
                  await _performAccountDeletion(context);
                },
                child: Text(
                  'Deletar',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _performAccountDeletion(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      scaffold.showSnackBar(
        const SnackBar(content: Text('Deletando conta...')),
      );

      await AuthService.deleteAccount();

      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Conta deletada com sucesso'),
          backgroundColor: Colors.green,
        ),
      );

      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Erro ao deletar conta: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      await AuthService.updateUser(
        nome: usernameController.text,
        email: emailController.text,
        password: isEditingPassword && passwordController.text != '********'
            ? passwordController.text
            : null,
      );

      // Se o email foi alterado, faça logout e peça novo login
      if (emailController.text != widget.userData['email']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email alterado! Faça login novamente.'),
              backgroundColor: Colors.orange,
            ),
          );
          await AuthService.logout();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          return;
        }
      }

      if (mounted) {
        // Atualiza os dados locais após salvar
        final updatedUser = await AuthService.getUserDetails();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Retorna os dados atualizados para a tela anterior
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF181818),
        appBar: AppBar(
          backgroundColor: const Color(0xFF181818),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _saveChanges,
              child:
                  _isSaving
                      ? const CircularProgressIndicator()
                      : Text(
                        'Salvar',
                        style: GoogleFonts.inter(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            // Avatar do usuário
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color(0xFF232323),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white38,
                    size: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: usernameController,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nome de usuário',
                labelStyle: GoogleFonts.inter(color: Colors.white70),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: emailController,
              style: GoogleFonts.inter(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: GoogleFonts.inter(color: Colors.white70),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: passwordController,
              style: GoogleFonts.inter(color: Colors.white),
              obscureText: !isEditingPassword,
              decoration: InputDecoration(
                labelText: 'Senha',
                labelStyle: GoogleFonts.inter(color: Colors.white70),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isEditingPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white54,
                  ),
                  onPressed: () {
                    setState(() {
                      isEditingPassword = !isEditingPassword;
                      if (!isEditingPassword &&
                          passwordController.text != '********') {
                        passwordController.text = '********';
                      } else if (isEditingPassword &&
                          passwordController.text == '********') {
                        passwordController.clear();
                      }
                    });
                  },
                ),
              ),
              onTap: () {
                if (!isEditingPassword) {
                  setState(() {
                    isEditingPassword = true;
                    passwordController.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.delete, color: Colors.white),
              label: Text(
                'Deletar Conta',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: _showDeleteAccountDialog,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProfileActionTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textColor,
    required this.backgroundColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
