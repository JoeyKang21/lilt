import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule.dart';
import 'schedule_repository.dart';
import '../../core/constants/app_constants.dart';

/// Firestore 实现的日程数据仓库
class FirestoreScheduleRepository implements ScheduleRepository {
  final FirebaseFirestore _firestore;

  FirestoreScheduleRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _schedules(String userId) =>
      _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.schedulesCollection);

  @override
  Stream<List<Schedule>> getSchedules(String userId) {
    return _schedules(userId)
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Schedule.fromFirestore(doc.id, doc.data()))
              .toList();
        });
  }

  @override
  Future<List<Schedule>> getSchedulesOnce(String userId) async {
    final snapshot = await _schedules(userId)
        .orderBy('startTime', descending: false)
        .get();
    return snapshot.docs
        .map((doc) => Schedule.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<String> addSchedule(String userId, Schedule schedule) async {
    final docRef = await _schedules(userId).add(schedule.toMap());
    return docRef.id;
  }

  @override
  Future<void> updateSchedule(
    String userId,
    String scheduleId,
    Map<String, dynamic> data,
  ) {
    return _schedules(userId).doc(scheduleId).update(data);
  }

  @override
  Future<void> deleteSchedule(String userId, String scheduleId) {
    return _schedules(userId).doc(scheduleId).delete();
  }

  @override
  Future<void> createUserDocument(String userId, String email) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .set({
      'email': email,
      'displayName': email.split('@').first,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
