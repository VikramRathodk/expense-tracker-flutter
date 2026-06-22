import '../models/tag_model.dart';

abstract class TagRepository {
  Future<List<TagModel>> getTags();
  Future<void> renameTag({required String name, required String newName});
  Future<void> deleteTag({required String name});
}