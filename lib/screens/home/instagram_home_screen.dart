import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class InstagramHomeScreen extends StatelessWidget {
  const InstagramHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'gauhar_official',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.menu_rounded),
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
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.textSecondary,
                        ),
                      ),
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
              const Text(
                'Gauhar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Digital creator\nSharing smiles, style, and daily moments.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
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
