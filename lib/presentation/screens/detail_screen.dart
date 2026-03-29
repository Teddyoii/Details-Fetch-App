import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/post_provider.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final int postId;
  const DetailScreen({super.key, required this.postId});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _enterEditMode(String currentTitle, String currentBody) {
    _titleController.text = currentTitle;
    _bodyController.text = currentBody;
    setState(() => _isEditing = true);
  }

  void _saveEdits() {
    final newTitle = _titleController.text.trim();
    final newBody = _bodyController.text.trim();

    if (newTitle.isEmpty || newBody.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and body cannot be empty.')),
      );
      return;
    }

    ref.read(postsProvider.notifier).updatePost(
          postId: widget.postId,
          newTitle: newTitle,
          newBody: newBody,
        );

    setState(() => _isEditing = false);
  }

  void _cancelEdit() => setState(() => _isEditing = false);

  @override
  Widget build(BuildContext context) {
    final post = ref.watch(postByIdProvider(widget.postId));

    if (post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: const Center(child: Text('Post not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Post #${post.id}'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => _enterEditMode(post.title, post.body),
            ),
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.check_rounded),
              tooltip: 'Save',
              onPressed: _saveEdits,
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Cancel',
              onPressed: _cancelEdit,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _isEditing
            ? _EditView(
                titleController: _titleController,
                bodyController: _bodyController,
              )
            : _ReadView(
                title: post.title,
                body: post.body,
                userId: post.userId,
              ),
      ),
    );
  }
}

// ── Read View ──────────────────────────────────────────────────────────────
class _ReadView extends StatelessWidget {
  final String title;
  final String body;
  final int userId;

  const _ReadView({
    required this.title,
    required this.body,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User chip
        Chip(
          label: Text('User $userId'),
          labelStyle:
              TextStyle(fontSize: 12, color: Colors.grey.shade700),
          backgroundColor: Colors.grey.shade100,
          side: BorderSide(color: Colors.grey.shade300),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 12),

        // Title
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 20),

        Divider(color: Colors.grey.shade200),
        const SizedBox(height: 16),

        // Body label
        Text(
          'Content',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Body text
        Text(
          body,
          style: TextStyle(
            fontSize: 15,
            height: 1.7,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}

// ── Edit View ──────────────────────────────────────────────────────────────
class _EditView extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;

  const _EditView({
    required this.titleController,
    required this.bodyController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: 'Enter title...',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        Text(
          'Content',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: bodyController,
          decoration: const InputDecoration(
            hintText: 'Enter content...',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLines: 8,
        ),
      ],
    );
  }
}