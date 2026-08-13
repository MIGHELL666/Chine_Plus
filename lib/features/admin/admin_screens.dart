import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/theme.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Panel de Control',
    'Gestión de Usuarios',
    'Premios Canjeables',
    'Catálogo de Películas',
    'Catálogo de Cines',
    'Estadísticas de Usuarios',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLargeScreen = MediaQuery.of(context).size.width > 700;

    final List<Widget> screens = [
      _AdminDashboardSection(appState: appState),
      _AdminUsersSection(appState: appState),
      _AdminRewardsSection(appState: appState),
      _AdminMoviesSection(appState: appState),
      _AdminCinemasSection(appState: appState),
      _AdminUserStatsSection(appState: appState),
    ];

    Widget buildDrawer() {
      return Drawer(
        backgroundColor: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.brightness == Brightness.dark
                    ? AppTheme.darkGrey
                    : Colors.grey.shade100,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(appState.currentUser?.avatarUrl ?? ''),
                    backgroundColor: AppTheme.mediumGrey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.currentUser?.name ?? 'Admin',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Administrador',
                          style: TextStyle(fontSize: 12, color: AppTheme.jadeGreen),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: Text(_titles[0]),
              selected: _selectedIndex == 0,
              selectedColor: AppTheme.jadeGreen,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.movie_outlined),
              title: Text(_titles[3]),
              selected: _selectedIndex == 3,
              selectedColor: AppTheme.jadeGreen,
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_movies_outlined),
              title: Text(_titles[4]), selected: _selectedIndex == 4,
              onTap: () { setState(() => _selectedIndex = 4); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: Text(_titles[1]),
              selected: _selectedIndex == 1,
              selectedColor: AppTheme.jadeGreen,
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: Text(_titles[5]),
              selected: _selectedIndex == 5,
              selectedColor: AppTheme.jadeGreen,
              onTap: () {
                setState(() => _selectedIndex = 5);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard_outlined),
              title: Text(_titles[2]),
              selected: _selectedIndex == 2,
              selectedColor: AppTheme.jadeGreen,
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                appState.logout();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: Icon(
              appState.themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: colorScheme.primary,
            ),
            onPressed: () => appState.toggleTheme(),
          ),
          if (isLargeScreen)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () => appState.logout(),
            ),
        ],
      ),
      drawer: isLargeScreen ? null : buildDrawer(),
      body: Row(
        children: [
          if (isLargeScreen) ...[
            NavigationRail(
              backgroundColor: colorScheme.brightness == Brightness.dark
                  ? AppTheme.darkGrey
                  : Colors.grey.shade100,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: AppTheme.jadeGreen),
              selectedLabelTextStyle: const TextStyle(color: AppTheme.jadeGreen, fontWeight: FontWeight.bold),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.dashboard_outlined),
                  selectedIcon: const Icon(Icons.dashboard),
                  label: Text(_titles[0]),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.people_outline),
                  selectedIcon: const Icon(Icons.people),
                  label: Text(_titles[1]),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.card_giftcard_outlined),
                  selectedIcon: const Icon(Icons.card_giftcard),
                  label: Text(_titles[2]),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.movie_outlined),
                  selectedIcon: const Icon(Icons.movie),
                  label: Text(_titles[3]),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.local_movies_outlined),
                  selectedIcon: const Icon(Icons.local_movies),
                  label: Text(_titles[4]),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.bar_chart_outlined),
                  selectedIcon: const Icon(Icons.bar_chart),
                  label: Text(_titles[5]),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
          ],
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminUserStatsSection extends StatelessWidget {
  final AppState appState;

  const _AdminUserStatsSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final users = appState.users;
    final total = users.length;
    final active = users.where((user) => user.status.toLowerCase() == 'activo').length;
    final admins = users.where((user) => user.role.toLowerCase() == 'admin' || user.role.toLowerCase() == 'administrador').length;
    final regular = total - admins;
    final inactive = total - active;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Usuarios registrados', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              const Text('Resumen basado en los perfiles reales cargados desde Supabase.'),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: compact ? 2 : 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // Más altura en pantallas estrechas para evitar bottom overflow.
                childAspectRatio: compact ? 1.15 : 1.6,
                children: [
                  _statCard(context, 'Total', total, Icons.people, AppTheme.jadeGreen),
                  _statCard(context, 'Activos', active, Icons.person, Colors.blueAccent),
                  _statCard(context, 'Administradores', admins, Icons.admin_panel_settings, AppTheme.goldAccent),
                  _statCard(context, 'Inactivos', inactive, Icons.person_off, Colors.redAccent),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Distribución por rol', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _bar(context, 'Usuarios', regular, total, Colors.blueAccent),
                      const SizedBox(height: 14),
                      _bar(context, 'Administradores', admins, total, AppTheme.goldAccent),
                      if (total == 0) const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text('No hay usuarios para mostrar.'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(BuildContext context, String label, int value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, color: color),
            Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _bar(BuildContext context, String label, int value, int total, Color color) {
    final fraction = total == 0 ? 0.0 : value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Expanded(child: Text(label)), Text('$value')]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: fraction, minHeight: 12, color: color),
        ),
      ],
    );
  }
}

// --- SUB-SECTION 1: DASHBOARD ---

class _AdminDashboardSection extends StatelessWidget {
  final AppState appState;
  const _AdminDashboardSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas Generales',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              // Tarjetas más altas para que títulos largos, como
              // "Películas de catálogo", no provoquen overflow.
              childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.05 : 1.15,
              children: [
                _buildStatMetric(
                  context,
                  title: 'Usuarios',
                  value: '${appState.users.length}',
                  icon: Icons.people_outline,
                  color: Colors.blueAccent,
                ),
                _buildStatMetric(
                  context,
                  title: 'Películas de catálogo',
                  value: '${appState.adminMovies.length}',
                  icon: Icons.movie,
                  color: AppTheme.jadeGreen,
                ),
                _buildStatMetric(
                  context,
                  title: 'Premios Stock',
                  value: '${appState.rewards.fold<int>(0, (sum, r) => sum + (r.stock ?? 0))}',
                  icon: Icons.card_giftcard,
                  color: AppTheme.goldAccent,
                ),
                _buildStatMetric(
                  context,
                  title: 'Cines de catálogo',
                  value: '${appState.adminCinemas.length}',
                  icon: Icons.local_movies,
                  color: Colors.purpleAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatMetric(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return PremiumCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SUB-SECTION 2: USERS LIST ---

class _AdminUsersSection extends StatefulWidget {
  final AppState appState;
  const _AdminUsersSection({required this.appState});

  @override
  State<_AdminUsersSection> createState() => _AdminUsersSectionState();
}

class _AdminUsersSectionState extends State<_AdminUsersSection> {
  final String _searchQuery = '';
  String _roleFilter = 'Todos';

  @override
  Widget build(BuildContext context) {

    final filteredUsers = widget.appState.users.where((u) {
      final matchesSearch = u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _roleFilter == 'Todos' || u.role == _roleFilter.toLowerCase();
      return matchesSearch && matchesRole;
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search and filters
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    labelText: 'Buscar usuario...',
                    hintText: 'Nombre o correo',
                    prefixIcon: Icons.search,
                    controller: TextEditingController(text: _searchQuery)
                      ..selection = TextSelection.collapsed(offset: _searchQuery.length),
                    // Set query
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _roleFilter,
                  items: ['Todos', 'User', 'Admin'].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _roleFilter = val;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Responsive Data Table
            Expanded(
              child: filteredUsers.isEmpty
                  ? const Center(child: Text('No se encontraron usuarios.'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Foto')),
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Rol')),
                            DataColumn(label: Text('Fecha Registro')),
                            DataColumn(label: Text('Estado')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: filteredUsers.map((user) {
                            final isActive = user.status == 'Activo';
                            return DataRow(
                              cells: [
                                DataCell(CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(user.avatarUrl),
                                )),
                                DataCell(Text(user.name)),
                                DataCell(Text(user.email)),
                                DataCell(Text(user.role.toUpperCase())),
                                DataCell(Text(user.registrationDate)),
                                DataCell(Chip(
                                  label: Text(user.status, style: const TextStyle(fontSize: 10)),
                                  backgroundColor: isActive ? AppTheme.jadeGreen.withValues(alpha: 0.2) : Colors.grey.shade800,
                                )),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                        onPressed: () => _showEditUserDialog(context, user),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isActive ? Icons.toggle_on : Icons.toggle_off,
                                          color: isActive ? AppTheme.jadeGreen : Colors.grey,
                                        ),
                                        onPressed: () async {
                                          final nextStatus = isActive ? 'Inactivo' : 'Activo';
                                          try {
                                            await widget.appState.updateUserStatus(user.id, nextStatus);
                                            if (context.mounted) showAppSnackbar(context, message: 'Usuario cambiado a estado $nextStatus');
                                          } catch (error) {
                                            if (context.mounted) showAppSnackbar(context, message: 'Error de Supabase: $error');
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        onPressed: () async {
                                          try {
                                            await widget.appState.deleteUser(user.id);
                                            if (context.mounted) showAppSnackbar(context, message: 'Perfil eliminado de Supabase.');
                                          } catch (error) {
                                            if (context.mounted) showAppSnackbar(context, message: 'Error de Supabase: $error');
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, AppUser user) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Editar Usuario'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: nameController,
                  labelText: 'Nombre',
                  hintText: 'Nombre',
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: emailController,
                  labelText: 'Email',
                  hintText: 'Email',
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: ['user', 'admin'].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role.toUpperCase()));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedRole = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.jadeGreen),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updatedUser = user.copyWith(
                    name: nameController.text,
                    email: emailController.text,
                    role: selectedRole,
                  );
                  () async {
                    try {
                      await widget.appState.saveUser(updatedUser);
                      if (context.mounted) {
                        Navigator.pop(context);
                        showAppSnackbar(context, message: 'Usuario actualizado correctamente.');
                      }
                    } catch (error) {
                      if (context.mounted) showAppSnackbar(context, message: 'Error de Supabase: $error');
                    }
                  }();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SUB-SECTION 3: REWARDS CRUD ---

class _AdminRewardsSection extends StatelessWidget {
  final AppState appState;
  const _AdminRewardsSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.jadeGreen,
        foregroundColor: Colors.white,
        onPressed: () => _showRewardForm(context),
        child: const Icon(Icons.add),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemCount: appState.rewards.length,
        itemBuilder: (context, index) {
          final reward = appState.rewards[index];
          return Stack(
            children: [
              RewardCard(
                reward: reward,
                onTap: () => _showRewardForm(context, reward),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () async {
                      try {
                        await appState.deleteReward(reward.id);
                        if (context.mounted) {
                          showAppSnackbar(context, message: 'Promoción eliminada.');
                        }
                      } catch (error) {
                        if (context.mounted) {
                          showAppSnackbar(context, message: 'Error de Supabase: $error');
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRewardForm(BuildContext context, [Reward? reward]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: reward?.name ?? '');
    final descController = TextEditingController(text: reward?.description ?? '');
    final pointsController = TextEditingController(text: reward != null ? '${reward.pointsRequired}' : '300');
    final stockController = TextEditingController(text: reward != null ? '${reward.stock}' : '50');
    String status = reward?.status == 'activa' ? 'Activo' :
        reward?.status == 'inactiva' ? 'Inactivo' : (reward == null ? 'Activo' : 'Inactivo');
    final selectedCinemaIds = <String>{...?reward?.cinemaIds};
    PlatformFile? selectedImage;
    String? imageError;
    bool saving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(reward == null ? 'Crear Recompensa' : 'Editar Recompensa'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: nameController,
                    labelText: 'Nombre del artículo',
                    hintText: 'Ej. Palomitas Gratis',
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: descController,
                    labelText: 'Descripción',
                    hintText: 'Escribe una breve descripción...',
                    maxLines: 2,
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setImageState) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (selectedImage?.bytes != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(selectedImage!.bytes!, height: 150, fit: BoxFit.cover),
                          )
                        else if (reward?.imageUrl.isNotEmpty == true)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(reward!.imageUrl, height: 150, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(height: 50, child: Icon(Icons.broken_image))),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('Sin imagen seleccionada', textAlign: TextAlign.center),
                          ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.image_outlined),
                          label: Text(selectedImage == null ? 'Seleccionar imagen' : selectedImage!.name),
                          onPressed: saving ? null : () async {
                            try {
                              final result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
                                withData: true,
                              );
                              if (result == null || result.files.single.bytes == null) return;
                              setImageState(() {
                                selectedImage = result.files.single;
                                imageError = null;
                              });
                            } catch (error) {
                              setImageState(() => imageError = 'No se pudo seleccionar la imagen: $error');
                            }
                          },
                        ),
                        if (imageError != null)
                          Text(imageError!, style: const TextStyle(color: Colors.red)),
                        const Text('Formatos permitidos: JPG, PNG y WEBP.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: pointsController,
                          labelText: 'Puntos Requeridos',
                          hintText: '300',
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || int.tryParse(v) == null ? 'Inválido' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppTextField(
                          controller: stockController,
                          labelText: 'Stock Inicial',
                          hintText: '50',
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || int.tryParse(v) == null ? 'Inválido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: ['Activo', 'Inactivo'].map((st) {
                      return DropdownMenuItem(value: st, child: Text(st));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          status = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Cines donde aplica',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (appState.cinemas.isEmpty)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('No hay cines disponibles.'),
                    )
                  else
                    ...appState.cinemas.map(
                      (cinema) => CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(cinema.name),
                        value: selectedCinemaIds.contains(cinema.id),
                        onChanged: (checked) {
                          setDialogState(() {
                            if (checked == true) {
                              selectedCinemaIds.add(cinema.id);
                            } else {
                              selectedCinemaIds.remove(cinema.id);
                            }
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.jadeGreen),
              onPressed: saving ? null : () async {
                if (formKey.currentState!.validate()) {
                  setDialogState(() => saving = true);
                  try {
                    var imageUrl = reward?.imageUrl ?? '';
                    if (selectedImage != null) {
                      final extension = selectedImage!.extension?.toLowerCase();
                      if (extension == null || !['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
                        setDialogState(() {
                          imageError = 'Selecciona una imagen JPG, PNG o WEBP.';
                          saving = false;
                        });
                        return;
                      }
                      imageUrl = await appState.subirImagenPromocionAdmin(selectedImage!.bytes!, extension);
                    }
                  final newReward = Reward(
                    id: reward?.id ?? 'REW-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    description: descController.text,
                    imageUrl: imageUrl,
                    pointsRequired: int.parse(pointsController.text),
                    stock: int.tryParse(stockController.text),
                    status: status.toLowerCase() == 'activo' ? 'activa' : 'inactiva',
                    cinemaIds: selectedCinemaIds.toList(),
                  );
                    await appState.saveReward(newReward);
                    if (reward != null && selectedImage != null && reward.imageUrl != imageUrl) {
                      await appState.eliminarImagenPromocionAnteriorAdmin(reward.imageUrl);
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                      showAppSnackbar(context, message: reward == null ? 'Promoción creada con éxito.' : 'Promoción editada con éxito.');
                    }
                  } catch (error) {
                    if (context.mounted) showAppSnackbar(context, message: 'Error de Supabase/Storage: $error');
                    if (context.mounted) setDialogState(() => saving = false);
                  }
                }
              },
              child: saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMoviesSection extends StatefulWidget {
  final AppState appState;
  const _AdminMoviesSection({required this.appState});

  @override
  State<_AdminMoviesSection> createState() => _AdminMoviesSectionState();
}

class _AdminMoviesSectionState extends State<_AdminMoviesSection> {
  String _filter = 'Todas';
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final movies = widget.appState.adminMovies.where((movie) {
      return _filter == 'Todas' ||
          (_filter == 'Activas' && movie.status == 'activo') ||
          (_filter == 'Inactivas' && movie.status == 'inactivo');
    }).toList();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.jadeGreen,
        onPressed: _busy ? null : () => _showMovieForm(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: _filter,
              decoration: const InputDecoration(labelText: 'Filtrar catálogo'),
              items: ['Todas', 'Activas', 'Inactivas']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => _filter = value ?? 'Todas'),
            ),
          ),
          Expanded(
            child: movies.isEmpty
                ? const Center(child: Text('No hay películas en el catálogo.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      final active = movie.status == 'activo';
                      return Card(
                        child: ListTile(
                          leading: movie.posterUrl.isEmpty
                              ? const Icon(Icons.movie)
                              : Image.network(movie.posterUrl, width: 48, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.movie)),
                          title: Text(movie.title),
                          subtitle: Text('${movie.genre.isEmpty ? 'Sin género' : movie.genre} · ${movie.durationMinutes == 0 ? 'Duración no disponible' : '${movie.durationMinutes} min'}'),
                          trailing: Wrap(
                            children: [
                              IconButton(icon: const Icon(Icons.edit), onPressed: _busy ? null : () => _showMovieForm(context, movie)),
                              IconButton(
                                icon: Icon(active ? Icons.toggle_on : Icons.toggle_off,
                                    color: active ? AppTheme.jadeGreen : Colors.grey),
                                onPressed: _busy ? null : () => _toggleMovie(movie),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMovie(Movie movie) async {
    setState(() => _busy = true);
    try {
      await widget.appState.actualizarEstadoPeliculaAdmin(movie);
    } catch (error) {
      if (mounted) showAppSnackbar(context, message: 'Error de Supabase: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMovieForm(BuildContext context, [Movie? movie]) {
    final title = TextEditingController(text: movie?.title ?? '');
    final genre = TextEditingController(text: movie?.genre ?? '');
    final duration = TextEditingController(text: movie == null || movie.durationMinutes == 0 ? '' : '${movie.durationMinutes}');
    final description = TextEditingController(text: movie?.description ?? '');
    DateTime? releaseDate = movie?.releaseDate;
    final formKey = GlobalKey<FormState>();
    PlatformFile? selectedPoster;
    String? posterError;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        title: Text(movie == null ? 'Nueva película' : 'Editar película'),
        content: SingleChildScrollView(child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
          AppTextField(controller: title, labelText: 'Título *', hintText: 'Título de la película', validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
          const SizedBox(height: 10),
          StatefulBuilder(builder: (context, setPosterState) {
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (selectedPoster?.bytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(selectedPoster!.bytes!, height: 180, fit: BoxFit.cover),
                )
              else if (movie?.posterUrl.isNotEmpty == true)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(movie!.posterUrl, height: 180, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(height: 40, child: Icon(Icons.broken_image))),
                ),
              OutlinedButton.icon(
                icon: const Icon(Icons.image_outlined),
                label: Text(selectedPoster == null ? 'Seleccionar poster' : selectedPoster!.name),
                onPressed: () async {
                  try {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
                      withData: true,
                    );
                    if (result == null || result.files.single.bytes == null) return;
                    setPosterState(() {
                      selectedPoster = result.files.single;
                      posterError = null;
                    });
                  } catch (error) {
                    setPosterState(() => posterError = 'No se pudo seleccionar la imagen: $error');
                  }
                },
              ),
              if (posterError != null) Text(posterError!, style: const TextStyle(color: Colors.red)),
              Text(movie?.posterUrl.isNotEmpty == true && selectedPoster == null
                  ? 'Se conservará el poster actual si no seleccionas otro.'
                  : 'Formatos permitidos: JPG, PNG y WEBP.'),
            ]);
          }),
          const SizedBox(height: 10),
          AppTextField(controller: genre, labelText: 'Género', hintText: 'Género'),
          const SizedBox(height: 10),
          AppTextField(controller: duration, labelText: 'Duración en minutos', hintText: 'Ej. 120', keyboardType: TextInputType.number,
            validator: (v) => v != null && v.isNotEmpty && int.tryParse(v) == null ? 'Debe ser numérica' : null),
          const SizedBox(height: 10),
          AppTextField(controller: description, labelText: 'Descripción', hintText: 'Descripción', maxLines: 3),
          const SizedBox(height: 10),
          OutlinedButton.icon(icon: const Icon(Icons.calendar_today), label: Text(releaseDate == null ? 'Fecha de estreno' : releaseDate!.toIso8601String().split('T').first), onPressed: () async {
            final picked = await showDatePicker(context: context, firstDate: DateTime(1900), lastDate: DateTime(2100), initialDate: releaseDate ?? DateTime.now());
            if (picked != null) setDialogState(() => releaseDate = picked);
          }),
        ]))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            try {
              String? posterUrl = movie?.posterUrl;
              if (selectedPoster != null) {
                final extension = selectedPoster!.extension?.toLowerCase();
                if (extension == null || !['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
                  setDialogState(() => posterError = 'Selecciona una imagen JPG, PNG o WEBP.');
                  return;
                }
                posterUrl = await widget.appState.subirPosterAdmin(selectedPoster!.bytes!, extension);
              }
              final result = Movie(id: movie?.id ?? '', title: title.text, posterUrl: posterUrl ?? '', watchDate: '', cinemaName: '', rating: 0, genre: genre.text, durationMinutes: int.tryParse(duration.text) ?? 0, description: description.text, releaseDate: releaseDate, status: movie?.status ?? 'activo');
              if (movie == null) {
                await widget.appState.crearPeliculaAdmin(titulo: result.title, posterUrl: result.posterUrl, genero: result.genre, duracionMinutos: result.durationMinutes == 0 ? null : result.durationMinutes, descripcion: result.description, fechaEstreno: releaseDate);
              } else {
                await widget.appState.actualizarPeliculaAdmin(result);
                if (selectedPoster != null && movie.posterUrl != result.posterUrl) {
                  await widget.appState.eliminarPosterAnteriorAdmin(movie.posterUrl);
                }
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            } catch (error) {
              if (context.mounted) showAppSnackbar(context, message: 'Error de Supabase: $error');
            }
          }, child: const Text('Guardar')),
        ],
      )),
    );
  }
}

class _AdminCinemasSection extends StatefulWidget {
  final AppState appState;
  const _AdminCinemasSection({required this.appState});
  @override State<_AdminCinemasSection> createState() => _AdminCinemasSectionState();
}

class _AdminCinemasSectionState extends State<_AdminCinemasSection> {
  String _filter = 'Todas';
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final cinemas = widget.appState.adminCinemas.where((c) => _filter == 'Todas' || (_filter == 'Activos' && c.status == 'activo') || (_filter == 'Inactivos' && c.status == 'inactivo')).toList();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.jadeGreen,
        onPressed: _busy ? null : () => _showCinemaForm(context),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: DropdownButtonFormField<String>(
          initialValue: _filter,
          decoration: const InputDecoration(labelText: 'Filtrar cines'),
          items: ['Todas', 'Activos', 'Inactivos'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => _filter = v ?? 'Todas'),
        )),
        Expanded(child: cinemas.isEmpty
            ? const Center(child: Text('No hay cines en el catálogo.'))
            : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: cinemas.length, itemBuilder: (context, index) {
                final cinema = cinemas[index];
                final active = cinema.status == 'activo';
                return Card(child: ListTile(
                  leading: const Icon(Icons.local_movies),
                  title: Text(cinema.name),
                  subtitle: Text(cinema.address.isEmpty ? cinema.googlePlaceId : cinema.address),
                  trailing: Wrap(children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: _busy ? null : () => _showCinemaForm(context, cinema)),
                    IconButton(icon: Icon(active ? Icons.toggle_on : Icons.toggle_off, color: active ? AppTheme.jadeGreen : Colors.grey), onPressed: _busy ? null : () => _toggleCinema(cinema)),
                  ]),
                ));
              })),
      ]),
    );
  }

  Future<void> _toggleCinema(Cinema cinema) async {
    setState(() => _busy = true);
    try { await widget.appState.actualizarEstadoCineAdmin(cinema); }
    catch (error) { if (mounted) showAppSnackbar(context, message: 'Error de Supabase: $error'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  void _showCinemaForm(BuildContext context, [Cinema? cinema]) {
    final place = TextEditingController(text: cinema?.googlePlaceId ?? '');
    final name = TextEditingController(text: cinema?.name ?? '');
    final address = TextEditingController(text: cinema?.address ?? '');
    final latitude = TextEditingController(text: cinema == null || cinema.latitude == 0 ? '' : '${cinema.latitude}');
    final longitude = TextEditingController(text: cinema == null || cinema.longitude == 0 ? '' : '${cinema.longitude}');
    final key = GlobalKey<FormState>();
    showDialog(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(cinema == null ? 'Nuevo cine' : 'Editar cine'),
      content: SingleChildScrollView(child: Form(key: key, child: Column(mainAxisSize: MainAxisSize.min, children: [
        AppTextField(controller: place, labelText: 'Google Place ID *', hintText: 'ID de Google Maps', validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
        const SizedBox(height: 10),
        AppTextField(controller: name, labelText: 'Nombre *', hintText: 'Nombre del cine', validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
        const SizedBox(height: 10),
        AppTextField(controller: address, labelText: 'Dirección', hintText: 'Dirección'),
        const SizedBox(height: 10),
        AppTextField(controller: latitude, labelText: 'Latitud (opcional)', hintText: 'Ej. 21.88', keyboardType: TextInputType.numberWithOptions(decimal: true), validator: (v) {
          if (v == null || v.trim().isEmpty) return null;
          final value = double.tryParse(v.trim());
          return value == null || value < -90 || value > 90 ? 'Latitud inválida' : null;
        }),
        const SizedBox(height: 10),
        AppTextField(controller: longitude, labelText: 'Longitud (opcional)', hintText: 'Ej. -102.29', keyboardType: TextInputType.numberWithOptions(decimal: true), validator: (v) {
          if (v == null || v.trim().isEmpty) return null;
          final value = double.tryParse(v.trim());
          return value == null || value < -180 || value > 180 ? 'Longitud inválida' : null;
        }),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () async {
          if (!key.currentState!.validate()) return;
          try {
            if (cinema == null) {
              await widget.appState.crearCineAdmin(googlePlaceId: place.text, nombre: name.text, direccion: address.text, latitud: double.tryParse(latitude.text), longitud: double.tryParse(longitude.text));
            } else {
              await widget.appState.actualizarCineAdmin(Cinema(id: cinema.id, googlePlaceId: place.text, name: name.text, address: address.text, schedule: '', distance: '', latitude: double.tryParse(latitude.text) ?? 0, longitude: double.tryParse(longitude.text) ?? 0, status: cinema.status));
            }
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          } catch (error) { if (context.mounted) showAppSnackbar(context, message: 'Error de Supabase: $error'); }
        }, child: const Text('Guardar')),
      ],
    ));
  }
}

// --- SUB-SECTION 4: QR MGMT ---

class _AdminQRMgmtSection extends StatelessWidget {
  final AppState appState;
  const _AdminQRMgmtSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.jadeGreen,
        foregroundColor: Colors.white,
        onPressed: () => _showQRCodeForm(context),
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Códigos QR Promocionales Activos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: appState.qrCodes.isEmpty
                  ? const Center(child: Text('No hay códigos QR configurados.'))
                  : ListView.builder(
                      itemCount: appState.qrCodes.length,
                      itemBuilder: (context, index) {
                        final qr = appState.qrCodes[index];
                        final isActive = qr.status == 'Activo';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: PremiumCard(
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.jadeGreen.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.qr_code, color: AppTheme.jadeGreen),
                              ),
                              title: Text(qr.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Tipo: ${qr.type} | Expira: ${qr.expirationDate}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '+${qr.points} pts',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.goldAccent,
                                        ),
                                      ),
                                      Text(
                                        qr.status,
                                        style: TextStyle(
                                          color: isActive
                                              ? AppTheme.jadeGreen
                                              : (qr.status == 'Expirado' ? Colors.redAccent : Colors.orangeAccent),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    onSelected: (action) {
                                      if (action == 'edit') {
                                        _showQRCodeForm(context, qr);
                                      } else if (action == 'deactivate') {
                                        final nextStatus = isActive ? 'Inactivo' : 'Activo';
                                        appState.saveQRCode(qr.copyWith(status: nextStatus));
                                        showAppSnackbar(context, message: 'Código QR cambiado a $nextStatus');
                                      } else if (action == 'delete') {
                                        appState.deleteQRCode(qr.id);
                                        showAppSnackbar(context, message: 'Código QR eliminado.');
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                                      PopupMenuItem(
                                        value: 'deactivate',
                                        child: Text(isActive ? 'Desactivar' : 'Activar'),
                                      ),
                                      const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQRCodeForm(BuildContext context, [QRCode? qrCode]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: qrCode?.name ?? '');
    final pointsController = TextEditingController(text: qrCode != null ? '${qrCode.points}' : '100');
    final descController = TextEditingController(text: qrCode?.description ?? '');
    String selectedType = qrCode?.type ?? 'Boleto';
    String status = qrCode?.status ?? 'Activo';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(qrCode == null ? 'Generar Código QR' : 'Editar Código QR'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: nameController,
                    labelText: 'Identificador del QR',
                    hintText: 'Ej. Preventa Dune 2',
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: 'Tipo de Código'),
                    items: ['Boleto', 'Poster', 'Cartón promocional', 'Stand promocional', 'Evento especial'].map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedType = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: pointsController,
                    labelText: 'Puntos que Otorga',
                    hintText: '100',
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Inválido' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: descController,
                    labelText: 'Descripción / Ubicación',
                    hintText: 'Indica dónde se colocará el QR...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Estado Inicial'),
                    items: ['Activo', 'Inactivo', 'Expirado'].map((st) {
                      return DropdownMenuItem(value: st, child: Text(st));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          status = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.jadeGreen),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newQRCode = QRCode(
                    id: qrCode?.id ?? 'QR-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    type: selectedType,
                    points: int.parse(pointsController.text),
                    startDate: qrCode?.startDate ?? '26/06/2026',
                    expirationDate: qrCode?.expirationDate ?? '31/12/2026',
                    status: status,
                    description: descController.text,
                  );
                  appState.saveQRCode(newQRCode);
                  Navigator.pop(context);
                  showAppSnackbar(
                    context,
                    message: qrCode == null ? 'Código QR registrado con éxito.' : 'Código QR editado con éxito.',
                  );
                }
              },
              child: const Text('Generar'),
            ),
          ],
        ),
      ),
    );
  }
}
