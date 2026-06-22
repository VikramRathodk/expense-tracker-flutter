import '../../domain/models/tag_model.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/tag_remote_datasource.dart';

class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl(this._dataSource);

  final TagRemoteDataSource _dataSource;

  @override
  Future<List<TagModel>> getTags() => _dataSource.getTags();

  @override
  Future<void> renameTag({required String name, required String newName}) =>
      _dataSource.renameTag(name: name, newName: newName);

  @override
  Future<void> deleteTag({required String name}) =>
      _dataSource.deleteTag(name: name);
}