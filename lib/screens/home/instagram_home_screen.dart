import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/auth_api_service.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class InstagramHomeScreen extends StatefulWidget {
  const InstagramHomeScreen({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<InstagramHomeScreen> createState() => _InstagramHomeScreenState();
}

class _InstagramHomeScreenState extends State<InstagramHomeScreen> {
  final AuthApiService _authApi = AuthApiService();

  late String _name;
  late String _username;
  String _pronouns = '';
  String _bio = 'Digital creator\nSharing smiles, style, and daily moments.';
  String _link = '';
  String _banners = '';
  String _gender = 'Prefer not to say';
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _name = widget.username;
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.of(context).push<EditProfileResult>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          name: _name,
          username: _username,
          bio: _bio,
          pronouns: _pronouns,
          link: _link,
          banners: _banners,
          gender: _gender,
          profileImagePath: _profileImagePath,
        ),
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _name = result.name.isEmpty ? result.username : result.name;
      _username = result.username;
      _pronouns = result.pronouns;
      _bio = result.bio;
      _link = result.link;
      _banners = result.banners;
      _gender = result.gender;
      _profileImagePath = result.profileImagePath;
    });
  }

  void _openProfileMenu() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_add_alt_1_rounded),
                  title: const Text('Add account'),
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Add account option selected.'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.red),
                  title: const Text(
                    'Log out',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _authApi.logout();
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _username,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: _openProfileMenu,
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'Profile menu',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFEDA75),
                          Color(0xFFFA7E1E),
                          Color(0xFFD62976),
                          Color(0xFF962FBF),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _ProfileAvatar(imagePath: _profileImagePath),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _ProfileStat(count: '5', label: 'Posts'),
                        _ProfileStat(count: '1167', label: 'Followers'),
                        _ProfileStat(count: '123', label: 'Following'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                _name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _bio.isEmpty ? 'Add your bio from Edit profile.' : _bio,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              if (_pronouns.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  _pronouns,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (_link.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  _link,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF264E86),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _openEditProfile,
                      child: const Text('Edit profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Share profile'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Icon(Icons.grid_on_rounded, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Posts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 0.78,
                children: const [
                  _PostTile(color: Color(0xFFFFD9DE), icon: Icons.favorite),
                  _PostTile(color: Color(0xFFD9F0FF), icon: Icons.camera_alt),
                  _PostTile(color: Color(0xFFE9DEFF), icon: Icons.wb_sunny),
                  _PostTile(color: Color(0xFFFFE7C7), icon: Icons.celebration),
                  _PostTile(color: Color(0xFFDDF5E8), icon: Icons.music_note),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.count, required this.label});

  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: hasImage
          ? Image.file(
              File(imagePath!),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            )
          : const Icon(
              Icons.person,
              size: 50,
              color: AppColors.textSecondary,
            ),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 34,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
