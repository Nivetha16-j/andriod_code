import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:junubullion/providers/address_provider.dart';
import 'package:junubullion/providers/language_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';

class AddressSection extends StatefulWidget {
  const AddressSection({super.key});

  @override
  State<AddressSection> createState() => _AddressSectionState();
}

class _AddressSectionState extends State<AddressSection> {
  final TextEditingController addressController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 3;
  bool isEditing = false;

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().fetchAddress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(
                "Addresses",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 4),

              TranslatedText(
                "Shipping Address",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 18),

              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(10),
              //     border: Border.all(color: const Color(0xffE7CACA), width: 1),
              //   ),
              //   child: TextField(
              //     controller: addressController,
              //     maxLines: 5,
              //     decoration: const InputDecoration(
              //       contentPadding: EdgeInsets.all(16),
              //       border: InputBorder.none,
              //       hintText: "Enter your shipping address",
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 16),
              Consumer<AddressProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final hasAddress = provider.hasAddress;

                  if (hasAddress && !isEditing) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffE7CACA)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TranslatedText(
                              provider.address!,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _editAddress(provider.address ?? "");
                            },
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xffE7CACA)),
                        ),
                        child: TextField(
                          controller: addressController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            hintText: "Enter your shipping address",
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff8F2424),
                          ),
                          onPressed: () async {
                            if (addressController.text.trim().isEmpty) return;

                            log(
                              "Updating address: ${addressController.text.trim()}",
                            );

                            final success = await provider.updateAddress(
                              addressController.text.trim(),
                            );

                            if (success) {
                              setState(() {
                                isEditing = false;
                              });

                              addressController.clear();
                            }
                          },
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const TranslatedText(
                                  "Save Address",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editAddress(String address) async {
    final languageProvider = context.read<LanguageProvider>();

    // English → use original address
    if (languageProvider.selectedLanguage == TranslateLanguage.english) {
      setState(() {
        addressController.text = address;
        isEditing = true;
      });
      return;
    }

    // Open edit mode immediately
    setState(() {
      isEditing = true;
      addressController.text = address;
    });

    try {
      final translatedAddress = await languageProvider.translate(address);

      if (!mounted) return;

      // Make sure language didn't change while translation was running
      if (context.read<LanguageProvider>().selectedLanguage !=
          languageProvider.selectedLanguage) {
        return;
      }

      setState(() {
        addressController.text = translatedAddress;
      });
    } catch (e) {
      log('Address translation failed: $e');

      if (!mounted) return;

      setState(() {
        addressController.text = address;
      });
    }
  }
}
