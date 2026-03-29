import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../repositories/post_repository.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});


class PostsNotifier extends AsyncNotifier<List<Post>> {

  final Map<int, Post> _localEdits = {};

  @override
  Future<List<Post>> build() async {
    return _fetchAndMerge();
  }

  Future<List<Post>> _fetchFromApi() {
    final repository = ref.read(postRepositoryProvider);
    return repository.fetchPosts();
  }

  Future<List<Post>> _fetchAndMerge() async {
    final freshPosts = await _fetchFromApi();
    return freshPosts.map((post) {
      return _localEdits[post.id] ?? post;
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAndMerge);
  }


  void updatePost({
    required int postId,
    required String newTitle,
    required String newBody,
  }) {
    final currentData = state.asData?.value;
    if (currentData == null) return;

    final updatedList = currentData.map((post) {
      if (post.id == postId) {
        final edited = post.copyWith(title: newTitle, body: newBody);
        _localEdits[postId] = edited; 
        return edited;
      }
      return post;
    }).toList();

    state = AsyncData(updatedList);
  }
}


final postsProvider = AsyncNotifierProvider<PostsNotifier, List<Post>>(
  PostsNotifier.new,
);


final postByIdProvider = Provider.family<Post?, int>((ref, id) {
  final postsAsync = ref.watch(postsProvider);
  return postsAsync.asData?.value.firstWhere(
    (p) => p.id == id,
    orElse: () => throw StateError('Post $id not found'),
  );
});


final groupedPostsProvider = Provider<Map<int, List<Post>>>((ref) {
  final posts = ref.watch(postsProvider).asData?.value ?? [];

  final Map<int, List<Post>> grouped = {};
  for (final post in posts) {
    grouped.putIfAbsent(post.userId, () => []).add(post);
  }
  return grouped;
});