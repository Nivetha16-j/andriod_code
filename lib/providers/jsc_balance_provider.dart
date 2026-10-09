import 'package:flutter/material.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/widgets/jsc/jsc_balance_section.dart';

class JscBalanceProvider extends ChangeNotifier {
  bool isBalancesUnlocked = false;

  String jscGoldBalance = '...';
  String jscGoldUnit = '';

  String jscSilverBalance = '...';
  String jscSilverUnit = '';

  String gspGoldBalance = '...';
  String gspGoldUnit = '';

  String gspSilverBalance = '...';
  String gspSilverUnit = '';

  void setWalletData({
    required String jscGoldBalance,
    required String jscGoldUnit,
    required String jscSilverBalance,
    required String jscSilverUnit,
    required String gspGoldBalance,
    required String gspGoldUnit,
    required String gspSilverBalance,
    required String gspSilverUnit,
  }) {
    this.jscGoldBalance = jscGoldBalance;
    this.jscGoldUnit = jscGoldUnit;

    this.jscSilverBalance = jscSilverBalance;
    this.jscSilverUnit = jscSilverUnit;

    this.gspGoldBalance = gspGoldBalance;
    this.gspGoldUnit = gspGoldUnit;

    this.gspSilverBalance = gspSilverBalance;
    this.gspSilverUnit = gspSilverUnit;

    notifyListeners();
  }

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

      final unlocked = await SessionManager.isJscBalanceUnlocked();

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

  Future<void> resetBalancesUnlocked() async {
    isBalancesUnlocked = false;

    if (balanceUnlockedNotifier.value) {
      balanceUnlockedNotifier.value = false;
    }

    await SessionManager.clearBalanceUnlocked();

    notifyListeners();

    debugPrint('JSC BalanceProvider -> balances reset successfully.');
  }

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
