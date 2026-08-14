import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:junubullion/providers/convert_physical_provider.dart';

class JscConvertPhysicalSection extends StatelessWidget {
  const JscConvertPhysicalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConvertPhysicalProvider>(
      builder: (context, provider, child) {
        final bool apiLoaded = provider.balancesUnlocked;

        debugPrint(
          'PHYSICAL UI -> '
          'unlocked: ${provider.balancesUnlocked}, '
          'gold: ${provider.goldBalance}, '
          'silver: ${provider.silverBalance}',
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFEF9),
            border: Border.all(color: const Color(0xFFD20D2D), width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 2),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Convert to Physical',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.13),
                      blurRadius: 3,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                child: Text(
                  apiLoaded
                      ? 'Convert part or all of your digital holdings into '
                            'physical products. Minimum balance to convert: '
                            '${provider.goldThresholdLabel} of gold or '
                            '${provider.silverThresholdLabel} of silver. After '
                            'starting a conversion, add eligible products to your '
                            'cart and send the order without payment.'
                      : 'Convert part or all of your digital holdings into '
                            'physical products. Minimum balance to convert: '
                            '50 g of gold or 1 kg of silver.',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(height: 9),

              // GOLD
              _convertRow(
                metal: 'Gold',
                available: apiLoaded
                    ? 'Available: ${provider.goldAvailableText} · '
                          'Min: ${provider.goldThresholdLabel}'
                    : 'Available: .... · Min: 50 g',
                buttonText: apiLoaded
                    ? provider.canConvertGold
                          ? 'Convert to physical gold'
                          : 'Reach ${provider.goldThresholdLabel} '
                                'to unlock physical conversion.'
                    : 'Unlock your balances to check physical '
                          'conversion eligibility.',
                enabled: apiLoaded && provider.canConvertGold,
                onPressed: apiLoaded && provider.canConvertGold
                    ? _openGoldConversion
                    : null,
              ),

              const SizedBox(height: 8),

              // SILVER
              _convertRow(
                metal: 'Silver',
                available: apiLoaded
                    ? 'Available: ${provider.silverAvailableText} · '
                          'Min: ${provider.silverThresholdLabel}'
                    : 'Available: .... · Min: 1 kg',
                buttonText: apiLoaded
                    ? provider.canConvertSilver
                          ? 'Convert to physical silver'
                          : 'Reach ${provider.silverThresholdLabel} '
                                'to unlock physical conversion.'
                    : 'Unlock your balances to check physical '
                          'conversion eligibility.',
                enabled: apiLoaded && provider.canConvertSilver,
                onPressed: apiLoaded && provider.canConvertSilver
                    ? _openSilverConversion
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _convertRow({
    required String metal,
    required String available,
    required String buttonText,
    required bool enabled,
    VoidCallback? onPressed,
  }) {
    final bool isGold = metal == 'Gold';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              metal,
              style: TextStyle(
                fontSize: 10,
                color: isGold
                    ? const Color.fromRGBO(200, 157, 8, 1)
                    : const Color.fromRGBO(149, 152, 154, 1),
                fontWeight: FontWeight.w600,
              ),
            ),

            Flexible(
              child: Text(
                available,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(120, 112, 112, 1),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        SizedBox(
          width: double.infinity,
          height: 27,
          child: OutlinedButton(
            onPressed: enabled ? onPressed : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              backgroundColor: const Color(0xFFFFFBF0),
              side: BorderSide(
                color: isGold
                    ? const Color.fromRGBO(200, 157, 8, 1)
                    : const Color.fromRGBO(149, 152, 154, 1),
                width: 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF555555),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openGoldConversion() {
    // TODO
  }

  void _openSilverConversion() {
    // TODO
  }
}
