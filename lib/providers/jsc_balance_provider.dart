import 'package:flutter/material.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/widgets/jsc/jsc_balance_section.dart';

class JscBalanceProvider extends ChangeNotifier {
  bool isBalancesUnlocked = false;

  bool isLoading = false;

  JscBalanceProvider() {
    balanceUnlockedNotifier.addListener(_onGlobalUnlockChanged);
    loadUnlockStatus();
  }

  void _onGlobalUnlockChanged() {
    final value = balanceUnlockedNotifier.value;

    if (isBalancesUnlocked == value) return;

    isBalancesUnlocked = value;
    notifyListeners();
  }

  Future<void> loadUnlockStatus() async {
    try {
      isLoading = true;
      notifyListeners();

      final unlocked = await SessionManager.isBalanceUnlocked();

      isBalancesUnlocked = unlocked;

      if (balanceUnlockedNotifier.value != unlocked) {
        balanceUnlockedNotifier.value = unlocked;
      }
    } catch (e) {
      debugPrint('JSC BalanceProvider load error: $e');

      isBalancesUnlocked = false;

      if (balanceUnlockedNotifier.value) {
        balanceUnlockedNotifier.value = false;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setUnlocked(bool value) {
    isBalancesUnlocked = value;

    if (balanceUnlockedNotifier.value != value) {
      balanceUnlockedNotifier.value = value;
    }

    notifyListeners();
  }

  /// Reset all JSC unlock state during logout.
  Future<void> resetBalancesUnlocked() async {
    // Reset provider state
    isBalancesUnlocked = false;

    // Reset global in-memory state
    if (balanceUnlockedNotifier.value) {
      balanceUnlockedNotifier.value = false;
    }

    // Clear persisted JSC balance data
    await SessionManager.clearBalanceUnlocked();

    notifyListeners();

    debugPrint('JSC BalanceProvider -> balances reset successfully.');
  }

  // Keep this if other screens already use it.
  void clearUnlockStatus() {
    isBalancesUnlocked = false;

    if (balanceUnlockedNotifier.value) {
      balanceUnlockedNotifier.value = false;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    balanceUnlockedNotifier.removeListener(_onGlobalUnlockChanged);
    super.dispose();
  }
}
