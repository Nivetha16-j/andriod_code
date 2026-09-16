import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String physicalOrderProductsKey = 'physicalOrderProducts';

  static const String isLoggedInKey = "isLoggedIn";
  static const String userKey = "user";
  static const String tokenKey = "token";

  static const String balanceUnlockedKey = 'balanceUnlocked';
  static const String gspBalanceUnlockedKey = 'gspBalanceUnlocked';

  static const String goldBalanceKey = 'goldBalance';
  static const String goldUnitKey = 'goldUnit';
  static const String goldMarketValueKey = 'goldMarketValue';

  static const String silverBalanceKey = 'silverBalance';
  static const String silverUnitKey = 'silverUnit';
  static const String silverMarketValueKey = 'silverMarketValue';

  static const String currencySymbolKey = 'currencySymbol';

  static Future<void> saveBalanceUnlocked() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(balanceUnlockedKey, true);

    log("JSC balance unlocked status saved.");
  }

  static Future<bool> isJscBalanceUnlocked() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(balanceUnlockedKey) ?? false;
  }

  static Future<void> saveGspBalanceUnlocked() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(gspBalanceUnlockedKey, true);

    log("GSP balance unlocked status saved.");
  }

  static Future<bool> isGspBalanceUnlocked() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(gspBalanceUnlockedKey) ?? false;
  }

  // ============================================================
  // SAVE GOLD + SILVER BALANCE DATA
  // ============================================================

  static Future<void> saveBalanceData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    final gold = data['gold'] as Map<String, dynamic>? ?? {};

    final silver = data['silver'] as Map<String, dynamic>? ?? {};

    final goldBalance = gold['balance']?.toString() ?? '0.0000';

    final goldUnit = gold['unit']?.toString() ?? 'gram';

    final goldMarketValue = gold['market_value']?.toString() ?? '0';

    final silverBalance = silver['balance']?.toString() ?? '0.0000';

    final silverUnit = silver['unit']?.toString() ?? 'gram';

    final silverMarketValue = silver['market_value']?.toString() ?? '0';

    final currencySymbol = data['currency_symbol']?.toString() ?? '';

    await prefs.setString(goldBalanceKey, goldBalance);

    await prefs.setString(goldUnitKey, goldUnit);

    await prefs.setString(goldMarketValueKey, goldMarketValue);

    await prefs.setString(silverBalanceKey, silverBalance);

    await prefs.setString(silverUnitKey, silverUnit);

    await prefs.setString(silverMarketValueKey, silverMarketValue);

    await prefs.setString(currencySymbolKey, currencySymbol);

    log("JSC balance data saved.");
    log("Gold: $goldBalance $goldUnit");
    log(
      "Gold market value: "
      "$currencySymbol$goldMarketValue",
    );
    log("Silver: $silverBalance $silverUnit");
    log(
      "Silver market value: "
      "$currencySymbol$silverMarketValue",
    );
  }

  // ============================================================
  // GET SAVED BALANCE DATA
  // ============================================================

  static Future<Map<String, String>> getSavedBalanceData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'goldBalance': prefs.getString(goldBalanceKey) ?? '...',

      'goldUnit': prefs.getString(goldUnitKey) ?? 'gram',

      'goldMarketValue': prefs.getString(goldMarketValueKey) ?? '...',

      'silverBalance': prefs.getString(silverBalanceKey) ?? '...',

      'silverUnit': prefs.getString(silverUnitKey) ?? 'gram',

      'silverMarketValue': prefs.getString(silverMarketValueKey) ?? '...',

      'currencySymbol': prefs.getString(currencySymbolKey) ?? '',
    };
  }

  // ============================================================
  // CLEAR BALANCE DATA
  // Called during logout
  // ============================================================

  static Future<void> clearBalanceUnlocked() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(balanceUnlockedKey);

    await prefs.remove(goldBalanceKey);
    await prefs.remove(goldUnitKey);
    await prefs.remove(goldMarketValueKey);

    await prefs.remove(silverBalanceKey);
    await prefs.remove(silverUnitKey);
    await prefs.remove(silverMarketValueKey);

    await prefs.remove(currencySymbolKey);

    log("JSC balance data cleared.");
  }

  static Future<void> clearGspBalanceUnlocked() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(gspBalanceUnlockedKey);

    log("GSP balance unlock state cleared.");
  }

  // ============================================================
  // PHYSICAL ORDER PRODUCTS
  // ============================================================

  static Future<void> savePhysicalOrderProducts(
    List<Map<String, dynamic>> products,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(physicalOrderProductsKey, jsonEncode(products));

    log('Physical order products saved: ${products.length} items');
  }

  static Future<List<Map<String, dynamic>>> getPhysicalOrderProducts() async {
    final prefs = await SharedPreferences.getInstance();

    final storedData = prefs.getString(physicalOrderProductsKey);

    if (storedData == null || storedData.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(storedData);

      if (decoded is List) {
        return decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      return [];
    } catch (e) {
      log('Error reading physical order products: $e');

      return [];
    }
  }

  static Future<void> clearPhysicalOrderProducts() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(physicalOrderProductsKey);

    log('Physical order products cleared.');
  }

  static Future<bool> hasPhysicalOrderProducts() async {
    final products = await getPhysicalOrderProducts();

    return products.isNotEmpty;
  }

  // ============================================================
  // SAVE LOGIN
  // ============================================================

  static Future<void> saveLogin({
    required Map<String, dynamic> user,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    log("Saving Login...");
    log("User: $user");
    log("Token: $token");

    await prefs.setBool(isLoggedInKey, true);

    await prefs.setString(userKey, jsonEncode(user));

    await prefs.setString(tokenKey, token);

    log(
      "isLoggedIn: "
      "${await prefs.getBool(isLoggedInKey)}",
    );
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(isLoggedInKey) ?? false;
  }

  // ============================================================
  // GET USER
  // ============================================================

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final user = prefs.getString(userKey);

    if (user == null) {
      return null;
    }

    return jsonDecode(user) as Map<String, dynamic>;
  }

  // ============================================================
  // GET TOKEN
  // ============================================================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(tokenKey);
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear SharedPreferences
    await prefs.clear();

    // Clear secure physical-order data
    await clearPhysicalOrderProducts();

    log(
      "User logged out. "
      "Session, JSC balance and physical order data cleared.",
    );
  }
}
