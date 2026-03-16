import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/account_profile_provider.dart';

class AccountProfileScreen extends StatefulWidget {
  const AccountProfileScreen({super.key});

  @override
  State<AccountProfileScreen> createState() => _AccountProfileScreenState();
}

class _AccountProfileScreenState extends State<AccountProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _avatarController = TextEditingController();
  final _bioController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _avatarController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _fillForm(AccountProfileProvider provider) {
    final profile = provider.profile;
    if (_initialized || profile == null) {
      return;
    }

    _nameController.text = profile.displayName;
    _phoneController.text = profile.phoneNumber;
    _addressController.text = profile.shippingAddress;
    _avatarController.text = profile.avatarUrl;
    _bioController.text = profile.bio;
    _initialized = true;
  }

  Future<void> _save(AccountProfileProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await provider.saveProfile(
      displayName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      shippingAddress: _addressController.text.trim(),
      avatarUrl: _avatarController.text.trim(),
      bio: _bioController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật hồ sơ cá nhân')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProfileProvider>();
    final profile = provider.profile;
    _fillForm(provider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý tài khoản cá nhân')),
      body: provider.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : profile == null
              ? const Center(child: Text('Chưa có dữ liệu tài khoản'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 44,
                            backgroundImage: _avatarController.text.trim().isEmpty
                                ? null
                                : NetworkImage(_avatarController.text.trim()),
                            child: _avatarController.text.trim().isEmpty
                                ? Text(
                                    (_nameController.text.trim().isNotEmpty
                                            ? _nameController.text.trim()[0]
                                            : 'U')
                                        .toUpperCase(),
                                    style: const TextStyle(fontSize: 28),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên hiển thị',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên hiển thị';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: profile.email,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Số điện thoại',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Địa chỉ nhận hàng',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _avatarController,
                          decoration: const InputDecoration(
                            labelText: 'Ảnh đại diện (URL)',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _bioController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Tiểu sử giới thiệu',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _save(provider),
                            child: const Text('Lưu thay đổi'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
