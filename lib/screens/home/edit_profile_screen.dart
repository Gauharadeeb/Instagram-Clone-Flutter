import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileResult {
  const EditProfileResult({
    required this.name,
    required this.username,
    required this.pronouns,
    required this.bio,
    required this.link,
    required this.banners,
    required this.gender,
    required this.profileImagePath,
  });

  final String name;
  final String username;
  final String pronouns;
  final String bio;
  final String link;
  final String banners;
  final String gender;
  final String? profileImagePath;
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.name,
    required this.username,
    required this.bio,
    required this.pronouns,
    required this.link,
    required this.banners,
    required this.gender,
    required this.profileImagePath,
  });

  final String name;
  final String username;
  final String bio;
  final String pronouns;
  final String link;
  final String banners;
  final String gender;
  final String? profileImagePath;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _pronounsController;
  late final TextEditingController _bioController;
  late final TextEditingController _linkController;
  late final TextEditingController _bannersController;
  late String _gender;
  String? _profileImagePath;
  final _imagePicker = ImagePicker();

  static const _background = Color(0xFF05080D);
  static const _fieldColor = Color(0xFF080C12);
  static const _borderColor = Color(0xFF252A33);
  static const _mutedText = Color(0xFFA4A7B0);
  static const _linkColor = Color(0xFFA9B5FF);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _usernameController = TextEditingController(text: widget.username);
    _pronounsController = TextEditingController(text: widget.pronouns);
    _bioController = TextEditingController(text: widget.bio);
    _linkController = TextEditingController(text: widget.link);
    _bannersController = TextEditingController(text: widget.banners);
    _gender = widget.gender;
    _profileImagePath = widget.profileImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _pronounsController.dispose();
    _bioController.dispose();
    _linkController.dispose();
    _bannersController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cannot be empty.')),
      );
      return;
    }

    Navigator.of(context).pop(
      EditProfileResult(
        name: _nameController.text.trim(),
        username: username,
        pronouns: _pronounsController.text.trim(),
        bio: _bioController.text.trim(),
        link: _linkController.text.trim(),
        banners: _bannersController.text.trim(),
        gender: _gender,
        profileImagePath: _profileImagePath,
      ),
    );
  }

  Future<void> _pickProfilePhoto() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) {
      return;
    }

    setState(() => _profileImagePath = image.path);
  }

  Future<void> _pickGender() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF10141C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              _GenderOption(label: 'Prefer not to say', value: _gender),
              _GenderOption(label: 'Female', value: _gender),
              _GenderOption(label: 'Male', value: _gender),
              _GenderOption(label: 'Custom', value: _gender),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _gender = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, size: 30),
        ),
        title: const Text(
          'Edit profile',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _saveProfile,
            icon: const Icon(Icons.check_rounded, color: _linkColor, size: 30),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundEditButton(
                  icon: Icons.camera_alt_rounded,
                  imagePath: _profileImagePath,
                  onTap: _pickProfilePhoto,
                ),
                const SizedBox(width: 26),
                _RoundEditButton(
                  icon: Icons.face_retouching_natural_rounded,
                  onTap: _pickProfilePhoto,
                ),
              ],
            ),
            const SizedBox(height: 26),
            TextButton(
              onPressed: _pickProfilePhoto,
              child: const Text(
                'Edit picture or avatar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _linkColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _ProfileField(label: 'Name', controller: _nameController),
            const SizedBox(height: 12),
            _ProfileField(label: 'Username', controller: _usernameController),
            const SizedBox(height: 12),
            _ProfileField(label: 'Pronouns', controller: _pronounsController),
            const SizedBox(height: 12),
            _ProfileField(
              label: 'Bio',
              controller: _bioController,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _SimpleEditRow(label: 'Add link', controller: _linkController),
            const SizedBox(height: 26),
            _SimpleEditRow(
              label: 'Add banners',
              helper: 'Add music, profiles and more.',
              controller: _bannersController,
            ),
            const SizedBox(height: 26),
            _GenderField(value: _gender, onTap: _pickGender),
            const SizedBox(height: 26),
            const Divider(color: Color(0xFF151A22), height: 1),
            const _SettingsRow(label: 'Switch to professional account'),
            const Divider(color: Color(0xFF151A22), height: 1),
            const _SettingsRow(label: 'Personal information settings'),
            const Divider(color: Color(0xFF151A22), height: 1),
            const _SettingsRow(label: 'Show your profile is verified'),
            const Divider(color: Color(0xFF151A22), height: 1),
          ],
        ),
      ),
    );
  }
}

class _RoundEditButton extends StatelessWidget {
  const _RoundEditButton({
    required this.icon,
    required this.onTap,
    this.imagePath,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 112,
        height: 112,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF130CB8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: hasImage
            ? Image.file(File(imagePath!), fit: BoxFit.cover)
            : Icon(icon, color: Colors.black, size: 38),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 20),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _EditProfileScreenState._mutedText),
        alignLabelWithHint: true,
        filled: true,
        fillColor: _EditProfileScreenState._fieldColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _EditProfileScreenState._borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _EditProfileScreenState._linkColor),
        ),
      ),
    );
  }
}

class _SimpleEditRow extends StatelessWidget {
  const _SimpleEditRow({
    required this.label,
    required this.controller,
    this.helper,
  });

  final String label;
  final String? helper;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 20),
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        labelStyle: const TextStyle(color: Colors.white, fontSize: 20),
        helperStyle: const TextStyle(
          color: _EditProfileScreenState._mutedText,
          fontSize: 16,
        ),
        border: InputBorder.none,
      ),
    );
  }
}

class _GenderField extends StatelessWidget {
  const _GenderField({
    required this.value,
    required this.onTap,
  });

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          color: _EditProfileScreenState._fieldColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _EditProfileScreenState._borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gender',
                    style: TextStyle(
                      color: _EditProfileScreenState._mutedText,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Text(
        label,
        style: const TextStyle(
          color: _EditProfileScreenState._linkColor,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final selected = label == value;

    return ListTile(
      onTap: () => Navigator.of(context).pop(label),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: _EditProfileScreenState._linkColor)
          : null,
    );
  }
}
