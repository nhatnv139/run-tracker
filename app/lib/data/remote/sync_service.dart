import 'package:runvie/services/supabase_service.dart';

/// Pushes local runs to Supabase. Pulls remote-only changes on demand.
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  Future<void> pushPending() async {
    if (!SupabaseService.instance.isSignedIn) return;
    // TODO: query unsynced runs (remoteId == null) and upsert to runs table.
  }

  Future<void> pull() async {
    if (!SupabaseService.instance.isSignedIn) return;
    // TODO: pull runs touched since last sync timestamp.
  }
}
