import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../core/constants/app_colors.dart';
import '../../models/post.dart';
import '../../services/feed_api_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({
    super.key,
    this.onPostCreated,
    this.onClose,
  });

  final ValueChanged<Post>? onPostCreated;
  final VoidCallback? onClose;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const _blue = Color(0xFF0095F6);

  final ImagePicker _picker = ImagePicker();
  final FeedApiService _apiService = FeedApiService();
  final TextEditingController _captionController = TextEditingController();

  XFile? _selectedImage;
  List<XFile> _galleryImages = [];
  bool _isDetailsStep = false;
  bool _isLoadingGallery = true;
  bool _hasGalleryPermission = true;
  bool _isUploading = false;
  bool _aiLabelEnabled = false;
  String _selectedTab = 'POST';

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: InstagramColors.background(context),
      body: SafeArea(
        child: _isDetailsStep ? _buildDetailsStep() : _buildPickerStep(),
      ),
    );
  }

  Widget _buildPickerStep() {
    return Column(
      children: [
        _CreateTopBar(
          title: 'New post',
          leadingIcon: Icons.close,
          onLeadingPressed: _closeCreateFlow,
          actionText: 'Next',
          actionEnabled: _selectedImage != null,
          onActionPressed: () => setState(() => _isDetailsStep = true),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _SelectedImagePreview(image: _selectedImage),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
                child: Row(
                  children: [
                    Text(
                      'Recents',
                      style: TextStyle(
                        color: InstagramColors.textPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, color: InstagramColors.icon(context), size: 21),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _pickFromGallery,
                      style: TextButton.styleFrom(
                        backgroundColor: InstagramColors.elevatedSurface(context),
                        foregroundColor: InstagramColors.textPrimary(context),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.photo_library_outlined, size: 17),
                      label: const Text(
                        'Select',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              _GalleryGrid(
                selectedImage: _selectedImage,
                images: _galleryImages,
                isLoading: _isLoadingGallery,
                hasPermission: _hasGalleryPermission,
                onCameraTap: _pickFromCamera,
                onImageTap: _selectGalleryImage,
                onOpenPicker: _pickFromGallery,
              ),
            ],
          ),
        ),
        _CreateModeTabs(
          selectedTab: _selectedTab,
          onChanged: (tab) => setState(() => _selectedTab = tab),
        ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      children: [
        _CreateTopBar(
          title: 'New post',
          leadingIcon: Icons.arrow_back,
          onLeadingPressed: () => setState(() => _isDetailsStep = false),
        ),
        Expanded(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 82,
                      height: 82,
                      child: _selectedImage == null
                          ? ColoredBox(color: InstagramColors.elevatedSurface(context))
                          : Image.file(
                              File(_selectedImage!.path),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      cursorColor: InstagramColors.textPrimary(context),
                      minLines: 4,
                      maxLines: 7,
                      style: TextStyle(color: InstagramColors.textPrimary(context), fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Add a caption...',
                        hintStyle: TextStyle(color: InstagramColors.textSecondary(context)),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: InstagramColors.border(context)),
              _DetailsRow(icon: Icons.music_note_outlined, label: 'Add audio'),
              _DetailsRow(icon: Icons.person_add_alt_outlined, label: 'Tag people'),
              _DetailsRow(icon: Icons.location_on_outlined, label: 'Add location'),
              _DetailsSwitchRow(
                label: 'Add AI label',
                value: _aiLabelEnabled,
                onChanged: (value) => setState(() => _aiLabelEnabled = value),
              ),
              _DetailsRow(icon: Icons.group_outlined, label: 'Audience', trailing: 'Everyone'),
              _DetailsRow(icon: Icons.share_outlined, label: 'Also share on'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _selectedImage == null || _isUploading ? null : _sharePost,
              style: FilledButton.styleFrom(
                backgroundColor: _blue,
                disabledBackgroundColor: const Color(0xFF26303B),
                foregroundColor: Colors.white,
                disabledForegroundColor: const Color(0xFF9AA3AF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Share'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );
    if (image == null || !mounted) {
      return;
    }
    setState(() {
      _selectedImage = image;
      _galleryImages = [
        image,
        ..._galleryImages.where((item) => item.path != image.path),
      ];
    });
  }

  Future<void> _pickFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
    );
    if (image == null || !mounted) {
      return;
    }
    setState(() {
      _selectedImage = image;
      _galleryImages = [
        image,
        ..._galleryImages.where((item) => item.path != image.path),
      ];
    });
  }

  Future<void> _loadGalleryImages() async {
    setState(() {
      _isLoadingGallery = true;
      _hasGalleryPermission = true;
    });

    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingGallery = false;
        _hasGalleryPermission = false;
      });
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    if (albums.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _galleryImages = [];
        _selectedImage = null;
        _isLoadingGallery = false;
      });
      return;
    }

    final assets = await albums.first.getAssetListPaged(page: 0, size: 48);
    final images = <XFile>[];
    for (final asset in assets) {
      final file = await asset.file;
      if (file != null) {
        images.add(XFile(file.path));
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _galleryImages = images;
      _selectedImage ??= images.isNotEmpty ? images.first : null;
      _isLoadingGallery = false;
      _hasGalleryPermission = true;
    });
  }

  void _selectGalleryImage(XFile image) {
    setState(() => _selectedImage = image);
  }

  Future<void> _sharePost() async {
    final image = _selectedImage;
    if (image == null || _isUploading) {
      return;
    }

    setState(() => _isUploading = true);

    try {
      final post = await _apiService.createPost(
        imagePath: image.path,
        caption: _captionController.text.trim(),
      );

      _captionController.clear();
      setState(() {
        _selectedImage = null;
        _isDetailsStep = false;
        _selectedTab = 'POST';
      });
      widget.onPostCreated?.call(post);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post shared')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _closeCreateFlow() {
    widget.onClose?.call();
  }
}

class _CreateTopBar extends StatelessWidget {
  const _CreateTopBar({
    required this.title,
    required this.leadingIcon,
    required this.onLeadingPressed,
    this.actionText,
    this.actionEnabled = false,
    this.onActionPressed,
  });

  final String title;
  final IconData leadingIcon;
  final VoidCallback onLeadingPressed;
  final String? actionText;
  final bool actionEnabled;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            onPressed: onLeadingPressed,
            icon: Icon(leadingIcon, color: InstagramColors.icon(context), size: 27),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstagramColors.textPrimary(context),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            width: 74,
            child: actionText == null
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: actionEnabled ? onActionPressed : null,
                    child: Text(
                      actionText!,
                      style: TextStyle(
                        color: actionEnabled
                            ? _CreatePostScreenState._blue
                            : InstagramColors.disabled(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SelectedImagePreview extends StatelessWidget {
  const _SelectedImagePreview({required this.image});

  final XFile? image;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: const Color(0xFF111820),
            child: image == null
                ? const Center(
                    child: Icon(Icons.photo_library_outlined, color: Color(0xFF7B838F), size: 54),
                  )
                : Image.file(File(image!.path), fit: BoxFit.cover),
          ),
          const _CropGridOverlay(),
        ],
      ),
    );
  }
}

class _CropGridOverlay extends StatelessWidget {
  const _CropGridOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          for (var row = 0; row < 3; row++)
            Expanded(
              child: Row(
                children: [
                  for (var column = 0; column < 3; column++)
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24, width: 0.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  const _GalleryGrid({
    required this.selectedImage,
    required this.images,
    required this.isLoading,
    required this.hasPermission,
    required this.onCameraTap,
    required this.onImageTap,
    required this.onOpenPicker,
  });

  final XFile? selectedImage;
  final List<XFile> images;
  final bool isLoading;
  final bool hasPermission;
  final VoidCallback onCameraTap;
  final ValueChanged<XFile> onImageTap;
  final VoidCallback onOpenPicker;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 260,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              InstagramColors.textPrimary(context),
            ),
          ),
        ),
      );
    }

    if (!hasPermission) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
        child: Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              color: InstagramColors.textSecondary(context),
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              'Allow gallery access to choose photos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstagramColors.textPrimary(context),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onOpenPicker,
              child: const Text('Open picker'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: images.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        if (index == 0) {
          return InkWell(
            onTap: onCameraTap,
            child: ColoredBox(
              color: InstagramColors.elevatedSurface(context),
              child: Icon(Icons.photo_camera_outlined, color: InstagramColors.icon(context), size: 30),
            ),
          );
        }

        final image = images[index - 1];
        final isSelected = selectedImage?.path == image.path;

        return InkWell(
          onTap: () => onImageTap(image),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(image.path),
                fit: BoxFit.cover,
              ),
              if (isSelected)
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _CreatePostScreenState._blue,
                      width: 2,
                    ),
                  ),
                ),
              if (isSelected)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: _CreatePostScreenState._blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CreateModeTabs extends StatelessWidget {
  const _CreateModeTabs({
    required this.selectedTab,
    required this.onChanged,
  });

  final String selectedTab;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const tabs = ['POST', 'STORY', 'REEL', 'LIVE'];

    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final tab in tabs)
            TextButton(
              onPressed: () => onChanged(tab),
              child: Text(
                tab,
                style: TextStyle(
                  color: selectedTab == tab
                      ? InstagramColors.textPrimary(context)
                      : InstagramColors.textSecondary(context),
                  fontSize: 13,
                  fontWeight: selectedTab == tab ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({
    required this.icon,
    required this.label,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Icon(icon, color: InstagramColors.icon(context), size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: InstagramColors.textPrimary(context), fontSize: 15),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(color: InstagramColors.textSecondary(context), fontSize: 14),
            ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: InstagramColors.textSecondary(context), size: 22),
        ],
      ),
    );
  }
}

class _DetailsSwitchRow extends StatelessWidget {
  const _DetailsSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Icon(Icons.label_outline, color: InstagramColors.icon(context), size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: InstagramColors.textPrimary(context), fontSize: 15),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: _CreatePostScreenState._blue,
          ),
        ],
      ),
    );
  }
}
