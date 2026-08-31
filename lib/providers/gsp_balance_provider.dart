import 'package:flutter/material.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/widgets/gsp/gsp_balance_section.dart';

class GspBalanceProvider extends ChangeNotifier {
  // ============================================================
  // UNLOCK STATE
  // ============================================================

  bool isBalancesUnlocked = false;

  bool isLoading = false;

  // ============================================================
  // WALLET DATA
  // ============================================================

  String? goldBalance;
  String? goldUnit;
  String? goldMarketValue;

  String? silverBalance;
  String? silverUnit;
  String? silverMarketValue;

  String? currency;
  String? currencySymbol;

  GspBalanceProvider() {
    balanceUnlockedNotifier.addListener(_onGlobalUnlockChanged);
    loadUnlockStatus();
  }

  // ============================================================
  // GLOBAL UNLOCK LISTENER
  // ============================================================

  void _onGlobalUnlockChanged() {
    final bool value = balanceUnlockedNotifier.value;

    if (isBalancesUnlocked == value) {
      return;
    }

    isBalancesUnlocked = value;

    if (!value) {
      clearWalletData();
    }

    notifyListeners();
  }

  // ============================================================
  // LOAD SAVED UNLOCK STATE
  // ============================================================

  Future<void> loadUnlockStatus() async {
    try {
      isLoading = true;
      notifyListeners();

      final bool unlocked = await SessionManager.isGspBalanceUnlocked();

      isBalancesUnlocked = unlocked;

      if (balanceUnlockedNotifier.value != unlocked) {
        balanceUnlockedNotifier.value = unlocked;
      }

      // IMPORTANT:
      // Do not load wallet values from SharedPreferences.
      // Wallet values must come from backend.
      if (!unlocked) {
        clearWalletData();
      }
    } catch (e) {
      debugPrint('Gsp BalanceProvider load error: $e');

      isBalancesUnlocked = false;

      if (balanceUnlockedNotifier.value) {
        balanceUnlockedNotifier.value = false;
      }

      clearWalletData();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // SET UNLOCKED
  // ============================================================

  void setUnlocked(bool value) {
    isBalancesUnlocked = value;

    if (balanceUnlockedNotifier.value != value) {
      balanceUnlockedNotifier.value = value;
    }

    if (!value) {
      clearWalletData();
    }

    notifyListeners();
  }

  // ============================================================
  // SET WALLET DATA
  // ============================================================

  void setWalletData(Map<String, dynamic> data) {
    goldBalance = data['goldBalance']?.toString();
    goldUnit = data['goldUnit']?.toString();
    goldMarketValue = data['goldMarketValue']?.toString();

    silverBalance = data['silverBalance']?.toString();
    silverUnit = data['silverUnit']?.toString();
    silverMarketValue = data['silverMarketValue']?.toString();

    currency = data['currency']?.toString();
    currencySymbol = data['currencySymbol']?.toString();

    notifyListeners();
  }

  // ============================================================
  // CLEAR WALLET DATA
  // ============================================================

  void clearWalletData() {
    goldBalance = null;
    goldUnit = null;
    goldMarketValue = null;

    silverBalance = null;
    silverUnit = null;
    silverMarketValue = null;

    currency = null;
    currencySymbol = null;

    notifyListeners();
  }

  // ============================================================
  // RESET EVERYTHING
  // ============================================================

  Future<void> resetBalancesUnlocked() async {
    isBalancesUnlocked = false;

    if (balanceUnlockedNotifier.value) {
      balanceUnlockedNotifier.value = false;
    }

    clearWalletData();

    await SessionManager.clearGspBalanceUnlocked();

    notifyListeners();

    debugPrint('Gsp BalanceProvider -> balances reset successfully.');
  }

  // ============================================================
  // CLEAR UNLOCK STATUS
  // ============================================================

  void clearUnlockStatus() {
    isBalancesUnlocked = false;

    if (balanceUnlockedNotifier.value) {
      balanceUnlockedNotifier.value = false;
    }

    clearWalletData();

    notifyListeners();
  }

  @override
  void dispose() {
    balanceUnlockedNotifier.removeListener(_onGlobalUnlockChanged);

    super.dispose();
  }
}
