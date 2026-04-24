import 'package:flutter/material.dart';
import 'package:halaph/models/plan.dart';
import 'package:halaph/models/destination.dart';

class SimplePlanService {
  static final Map<String, TravelPlan> _plans = {};
  static int _planIdCounter = 1;

  static List<TravelPlan> getUserPlans() {
    return _plans.values.where((p) => p.createdBy == 'current_user').toList();
  }

  static TravelPlan createPlan({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required List<Destination> destinations,
    String createdBy = 'current_user',
    String? bannerImage,
  }) {
    final id = 'plan$_planIdCounter';
    _planIdCounter++;
    
    final itinerary = _buildItinerary(startDate, endDate, destinations);
    
    final plan = TravelPlan(
      id: id,
      title: title,
      startDate: startDate,
      endDate: endDate,
      participantIds: [createdBy],
      createdBy: createdBy,
      itinerary: itinerary,
      isShared: false,
      bannerImage: bannerImage,
    );
    
    _plans[id] = plan;
    return plan;
  }

  static TravelPlan? getPlanById(String id) => _plans[id];

  static bool updatePlan({
    required String planId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    List<Destination>? destinations,
    String? bannerImage,
  }) {
    final existing = _plans[planId];
    if (existing == null) return false;

    final newItinerary = destinations != null
        ? _buildItinerary(startDate ?? existing.startDate, endDate ?? existing.endDate, destinations)
        : existing.itinerary;

    final updated = TravelPlan(
      id: existing.id,
      title: title ?? existing.title,
      startDate: startDate ?? existing.startDate,
      endDate: endDate ?? existing.endDate,
      participantIds: existing.participantIds,
      createdBy: existing.createdBy,
      itinerary: newItinerary,
      isShared: existing.isShared,
      bannerImage: bannerImage ?? existing.bannerImage,
    );

    _plans[planId] = updated;
    return true;
  }

  static bool deletePlan(String id) => _plans.remove(id) != null;

  static List<TravelPlan> getAllPlans() => _plans.values.toList();

  static TravelPlan savePlan({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required Map<int, List<Destination>> itinerary,
    Map<String, String>? destinationTimes,
    String createdBy = 'current_user',
    String? bannerImage,
  }) {
    final id = 'plan$_planIdCounter';
    _planIdCounter++;

    final dayItineraries = <DayItinerary>[];
    final totalDays = endDate.difference(startDate).inDays + 1;

    for (int day = 0; day < totalDays; day++) {
      final date = startDate.add(Duration(days: day));
      final dests = itinerary[day + 1] ?? [];
      if (dests.isEmpty) continue;

      final items = <ItineraryItem>[];
      for (int i = 0; i < dests.length; i++) {
        final dest = dests[i];
        final timeStr = destinationTimes?[dest.id] ?? '10:00 AM';
        final (hour, minute) = _parseTime(timeStr);

        items.add(ItineraryItem(
          id: '${id}_item_${day}_$i',
          destination: dest,
          startTime: TimeOfDay(hour: hour, minute: minute),
          endTime: TimeOfDay(hour: (hour + 1) % 24, minute: minute),
          dayNumber: day + 1,
          notes: 'Visit ${dest.name}',
        ));
      }

      dayItineraries.add(DayItinerary(date: date, items: items));
    }

    final banner = bannerImage ?? 'https://picsum.photos/seed/${title.hashCode}_${startDate.millisecondsSinceEpoch}/400/200';
    
    final plan = TravelPlan(
      id: id,
      title: title,
      startDate: startDate,
      endDate: endDate,
      participantIds: [createdBy],
      createdBy: createdBy,
      itinerary: dayItineraries,
      isShared: false,
      bannerImage: banner,
    );

    _plans[id] = plan;
    return plan;
  }

  static void clearAllPlans() {
    _plans.clear();
    _planIdCounter = 1;
  }

  static List<DayItinerary> _buildItinerary(DateTime start, DateTime end, List<Destination> dests) {
    final days = end.difference(start).inDays + 1;
    final itineraries = <DayItinerary>[];

    for (int d = 0; d < days; d++) {
      final date = start.add(Duration(days: d));
      final perDay = (dests.length / days).ceil();
      final startIdx = d * perDay;
      final endIdx = (startIdx + perDay).clamp(0, dests.length);

      final items = <ItineraryItem>[];
      for (int i = startIdx; i < endIdx; i++) {
        final dest = dests[i];
        final hour = 9 + (i % 4) * 2;
        items.add(ItineraryItem(
          id: 'item_${DateTime.now().millisecondsSinceEpoch}_$i',
          destination: dest,
          startTime: TimeOfDay(hour: hour, minute: 0),
          endTime: TimeOfDay(hour: hour + 2, minute: 0),
          dayNumber: d + 1,
          notes: 'Visit ${dest.name}',
        ));
      }

      if (items.isNotEmpty) {
        itineraries.add(DayItinerary(date: date, items: items));
      }
    }

    return itineraries;
  }

  static (int, int) _parseTime(String timeStr) {
    try {
      final cleaned = timeStr.trim().replaceAll(RegExp(r'\s+'), ' ');
      final parts = cleaned.split(' ');
      final hm = parts[0].split(':');
      var hour = int.parse(hm[0]);
      final minute = int.parse(hm[1]);

      if (parts.length > 1) {
        final period = parts[1].toUpperCase();
        if (period == 'PM' && hour != 12) hour += 12;
        else if (period == 'AM' && hour == 12) hour = 0;
      }
      return (hour, minute);
    } catch (_) {
      return (10, 0);
    }
  }
}