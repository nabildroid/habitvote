import 'package:habitvote/features/vote/data/models/vote_model.dart';
import 'package:sembast/sembast_io.dart';
import 'package:habitvote/core/locator.dart';

class VotesCache {
  final Database _db = locator.get();
  final _votes = stringMapStoreFactory.store("votes");

  Future<void> put(VoteModel vote) async {
    await _votes.record(vote.id).put(_db, vote.toJson());
  }

  Future<void> delete(String id) async {
    await _votes.record(id).delete(_db);
  }

  Future<VoteModel?> get(String id) async {
    final record = await _votes.record(id).get(_db);
    if (record == null) return null;
    return VoteModel.fromJson(record);
  }

  Future<List<VoteModel>> getAll() async {
    final records = await _votes.find(_db);
    return records.map((record) => VoteModel.fromJson(record.value)).toList();
  }

  Future<List<VoteModel>> getByHabitId(String habitId) async {
    final finder = Finder(
      filter: Filter.equals('habitId', habitId),
    );
    final records = await _votes.find(_db, finder: finder);
    return records.map((record) => VoteModel.fromJson(record.value)).toList();
  }

  Future<void> clear() async {
    await _votes.delete(_db);
  }
}
