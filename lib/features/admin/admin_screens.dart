import 'package:flutter/material.dart';
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
    'Generador de Códigos QR',
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
      _AdminQRMgmtSection(appState: appState),
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
              leading: const Icon(Icons.card_giftcard_outlined),
              title: Text(_titles[2]),
              selected: _selectedIndex == 2,
              selectedColor: AppTheme.jadeGreen,
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_outlined),
              title: Text(_titles[3]),
              selected: _selectedIndex == 3,
              selectedColor: AppTheme.jadeGreen,
              onTap: () {
                setState(() => _selectedIndex = 3);
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
                  icon: const Icon(Icons.qr_code_outlined),
                  selectedIcon: const Icon(Icons.qr_code),
                  label: Text(_titles[3]),
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

// --- SUB-SECTION 1: DASHBOARD ---

class _AdminDashboardSection extends StatelessWidget {
  final AppState appState;
  const _AdminDashboardSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final totalPoints = appState.scanHistory.fold(0, (sum, scan) => sum + scan.points);

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
              childAspectRatio: 1.3,
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
                  title: 'QR Activos',
                  value: '${appState.qrCodes.where((q) => q.status == 'Activo').length}',
                  icon: Icons.qr_code,
                  color: AppTheme.jadeGreen,
                ),
                _buildStatMetric(
                  context,
                  title: 'Premios Stock',
                  value: '${appState.rewards.fold(0, (sum, r) => sum + r.stock)}',
                  icon: Icons.card_giftcard,
                  color: AppTheme.goldAccent,
                ),
                _buildStatMetric(
                  context,
                  title: 'Puntos Otorgados',
                  value: '$totalPoints',
                  icon: Icons.stars_outlined,
                  color: Colors.purpleAccent,
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Actividades Recientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appState.scanHistory.length > 5 ? 5 : appState.scanHistory.length,
              itemBuilder: (context, index) {
                final scan = appState.scanHistory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.history_toggle_off, color: AppTheme.jadeGreen),
                    title: Text('Escaneo registrado en: ${scan.place}'),
                    subtitle: Text('Fecha: ${scan.date}'),
                    trailing: Text(
                      '+${scan.points} pts',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
                    ),
                  ),
                );
              },
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
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                                        onPressed: () {
                                          final nextStatus = isActive ? 'Inactivo' : 'Activo';
                                          widget.appState.updateUserStatus(user.id, nextStatus);
                                          showAppSnackbar(
                                            context,
                                            message: 'Usuario cambiado a estado $nextStatus',
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        onPressed: () {
                                          widget.appState.deleteUser(user.id);
                                          showAppSnackbar(context, message: 'Usuario eliminado.');
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
                  widget.appState.saveUser(updatedUser);
                  Navigator.pop(context);
                  showAppSnackbar(context, message: 'Usuario actualizado correctamente.');
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
                    onPressed: () {
                      appState.deleteReward(reward.id);
                      showAppSnackbar(context, message: 'Recompensa eliminada.');
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
    String status = reward?.status ?? 'Activo';

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
                  final newReward = Reward(
                    id: reward?.id ?? 'REW-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    description: descController.text,
                    imageUrl: reward?.imageUrl ?? 'https://images.unsplash.com/photo-1578244182942-18427f3caca6?w=200',
                    pointsRequired: int.parse(pointsController.text),
                    stock: int.parse(stockController.text),
                    status: status,
                  );
                  appState.saveReward(newReward);
                  Navigator.pop(context);
                  showAppSnackbar(
                    context,
                    message: reward == null ? 'Recompensa creada con éxito.' : 'Recompensa editada con éxito.',
                  );
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
