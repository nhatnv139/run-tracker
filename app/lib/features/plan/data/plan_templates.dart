import 'package:runvie/features/plan/models/plan_template.dart';
import 'package:runvie/features/plan/models/plan_week.dart';
import 'package:runvie/features/plan/models/plan_workout.dart';

/// All built-in training plans. Vietnamese microcopy.
class PlanTemplates {
  PlanTemplates._();

  static PlanWorkout _restOn(int day) => PlanWorkout(
        dayOfWeek: day,
        type: WorkoutType.rest,
        description: 'Nghỉ',
        coachNote: 'Để cơ phục hồi — uống đủ nước, ngủ đủ giấc.',
      );

  /// Beginner 5K — 8 weeks, 3 sessions/week (Mon/Wed/Sat).
  static PlanTemplate beginner5k = PlanTemplate(
    id: 'beginner-5k-8w',
    name: 'Từ 0 đến 5K',
    description: 'Giáo án 8 tuần dành cho người mới chạy — đi bộ trước, chạy sau.',
    level: PlanLevel.beginner,
    goalDistanceKm: 5,
    sessionsPerWeek: 3,
    weeks: <PlanWeek>[
      PlanWeek(number: 1, workouts: <PlanWorkout>[
        _w1(1, 'Đi bộ 5 phút, lặp 5 lần 60s chạy + 90s đi bộ, đi 5 phút', null, 25),
        _restOn(2),
        _w1(3, 'Lặp lại buổi thứ 2 — đừng vội ép pace', null, 25),
        _restOn(4),
        _restOn(5),
        _w1(6, 'Buổi cuối tuần — 5 vòng intervals như buổi đầu', null, 25),
        _restOn(7),
      ]),
      PlanWeek(number: 2, workouts: <PlanWorkout>[
        _w1(1, 'Lặp 6 lần 90s chạy + 120s đi bộ + 5 phút khởi động', null, 27),
        _restOn(2), _w1(3, 'Như buổi 1', null, 27), _restOn(4), _restOn(5),
        _w1(6, 'Như buổi 1', null, 27), _restOn(7),
      ]),
      PlanWeek(number: 3, workouts: <PlanWorkout>[
        _w1(1, '90s/90s × 4, sau đó 3 phút chạy / 3 phút đi × 2', null, 28),
        _restOn(2), _w1(3, 'Như buổi 1', null, 28), _restOn(4), _restOn(5),
        _w1(6, 'Như buổi 1', null, 28), _restOn(7),
      ]),
      PlanWeek(number: 4, workouts: <PlanWorkout>[
        _w1(1, 'Chạy 5 phút / đi 3 phút / chạy 3 phút / đi 2.5 phút × 2', null, 30),
        _restOn(2), _w1(3, 'Như buổi 1', null, 30), _restOn(4), _restOn(5),
        _w1(6, 'Như buổi 1', null, 30), _restOn(7),
      ]),
      PlanWeek(number: 5, workouts: <PlanWorkout>[
        _w1(1, 'Chạy 8 phút × 2 (nghỉ đi bộ 3 phút giữa)', null, 25),
        _restOn(2),
        _w1(3, 'Chạy liên tục 5 phút × 4 (đi bộ 2 phút giữa)', null, 28),
        _restOn(4), _restOn(5),
        _w1(6, 'Chạy 20 phút liên tục — pace dễ', null, 28),
        _restOn(7),
      ]),
      PlanWeek(number: 6, workouts: <PlanWorkout>[
        _w1(1, 'Chạy 22 phút liên tục', null, 28),
        _restOn(2),
        _w1(3, 'Chạy 25 phút liên tục', null, 30),
        _restOn(4), _restOn(5),
        _w1(6, 'Chạy 22 phút liên tục', null, 28),
        _restOn(7),
      ]),
      PlanWeek(number: 7, workouts: <PlanWorkout>[
        _w1(1, 'Chạy 25 phút liên tục', null, 30),
        _restOn(2),
        _w1(3, 'Chạy 25 phút liên tục', null, 30),
        _restOn(4), _restOn(5),
        _w1(6, 'Chạy 25 phút — thử nâng pace 1 phút cuối', null, 30),
        _restOn(7),
      ]),
      PlanWeek(number: 8, workouts: <PlanWorkout>[
        _w1(1, 'Chạy 28 phút liên tục', null, 33),
        _restOn(2),
        _w1(3, 'Chạy nhẹ 20 phút', null, 22),
        _restOn(4), _restOn(5),
        PlanWorkout(
          dayOfWeek: 6,
          type: WorkoutType.race,
          targetDistanceKm: 5,
          description: 'Bài 5K test — chạy hết khả năng. Bạn đã làm được rồi!',
          coachNote: 'Hít thở đều, đừng xuất phát quá nhanh — 1km cuối mới tăng pace.',
        ),
        _restOn(7),
      ]),
    ],
  );

  /// 10K plan — 6 weeks, 4 sessions/week. Assumes already running 5K.
  static PlanTemplate tenK = PlanTemplate(
    id: 'ten-k-6w',
    name: '10K trong 6 tuần',
    description: 'Giáo án cho người đã chạy được 5K, hướng tới chinh phục 10K.',
    level: PlanLevel.intermediate,
    goalDistanceKm: 10,
    sessionsPerWeek: 4,
    weeks: <PlanWeek>[
      PlanWeek(number: 1, workouts: <PlanWorkout>[
        _easy(1, 3),
        _intervals(2, '4 × 400m nhanh + 200m đi bộ phục hồi'),
        _restOn(3),
        _easy(4, 4),
        _restOn(5),
        _restOn(6),
        _long(7, 5),
      ]),
      PlanWeek(number: 2, workouts: <PlanWorkout>[
        _easy(1, 4),
        _intervals(2, '5 × 400m + 200m đi bộ'),
        _restOn(3),
        _tempo(4, 3),
        _restOn(5), _restOn(6),
        _long(7, 6),
      ]),
      PlanWeek(number: 3, workouts: <PlanWorkout>[
        _easy(1, 4),
        _intervals(2, '6 × 400m + 200m đi bộ'),
        _restOn(3),
        _easy(4, 4),
        _restOn(5), _restOn(6),
        _long(7, 7),
      ]),
      PlanWeek(number: 4, workouts: <PlanWorkout>[
        _easy(1, 4),
        _tempo(2, 4),
        _restOn(3),
        _easy(4, 4),
        _restOn(5), _restOn(6),
        _long(7, 8),
      ]),
      PlanWeek(number: 5, workouts: <PlanWorkout>[
        _easy(1, 5),
        _intervals(2, '5 × 600m + 300m đi bộ'),
        _restOn(3),
        _easy(4, 4),
        _restOn(5), _restOn(6),
        _long(7, 9),
      ]),
      PlanWeek(number: 6, workouts: <PlanWorkout>[
        _easy(1, 4),
        _easy(3, 3),
        _restOn(4), _restOn(5), _restOn(6),
        PlanWorkout(
          dayOfWeek: 7,
          type: WorkoutType.race,
          targetDistanceKm: 10,
          description: 'Ngày đua 10K!',
          coachNote: 'Chia mục tiêu pace theo 4 chặng 2.5km. Pace đều đặn = thành công.',
        ),
        _restOn(2),
      ]),
    ],
  );

  static PlanWorkout _w1(int day, String desc, double? km, int min) {
    return PlanWorkout(
      dayOfWeek: day,
      type: WorkoutType.walk,
      targetDistanceKm: km,
      targetDurationMin: min,
      description: desc,
      coachNote: 'Đi bộ giữa các đoạn để hồi sức, đừng cố — nhịp thở phải kiểm soát.',
    );
  }

  static PlanWorkout _easy(int day, double km) => PlanWorkout(
        dayOfWeek: day,
        type: WorkoutType.easyRun,
        targetDistanceKm: km,
        description: 'Chạy nhẹ ${km.toStringAsFixed(0)} km',
        coachNote: 'Pace nói chuyện được — không ép tốc độ.',
      );

  static PlanWorkout _intervals(int day, String detail) => PlanWorkout(
        dayOfWeek: day,
        type: WorkoutType.intervals,
        targetDurationMin: 30,
        description: 'Interval: $detail',
        coachNote: 'Khởi động 10 phút trước, thả lỏng 5 phút sau.',
      );

  static PlanWorkout _tempo(int day, double km) => PlanWorkout(
        dayOfWeek: day,
        type: WorkoutType.tempo,
        targetDistanceKm: km,
        description: 'Tempo ${km.toStringAsFixed(0)} km — pace ngưỡng',
        coachNote: 'Pace nhanh nhưng kiểm soát được — không đua.',
      );

  static PlanWorkout _long(int day, double km) => PlanWorkout(
        dayOfWeek: day,
        type: WorkoutType.longRun,
        targetDistanceKm: km,
        description: 'Chạy dài ${km.toStringAsFixed(0)} km',
        coachNote: 'Pace dễ. Nghe podcast, tận hưởng đoạn đường.',
      );

  static List<PlanTemplate> all = <PlanTemplate>[beginner5k, tenK];

  static PlanTemplate? byId(String id) {
    for (final PlanTemplate t in all) {
      if (t.id == id) return t;
    }
    return null;
  }
}
