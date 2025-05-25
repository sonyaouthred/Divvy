import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/widgets/swap_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays information about a given swap
class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // Get data from the provider

        return Scaffold(
          backgroundColor: DivvyTheme.background,
          appBar: AppBar(
            title: Text("Swap", style: DivvyTheme.screenTitle),
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: DivvyTheme.background,
          ),
          body: SizedBox.expand(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      displayOpenSwaps(provider, spacing),
                      displayPendingSwaps(provider, spacing),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // // Indicates invalid data
  // Widget _invalidDataScreen() {
  //   return Scaffold(
  //     backgroundColor: DivvyTheme.background,
  //     appBar: AppBar(
  //       title: Text("Swap not found", style: DivvyTheme.screenTitle),
  //       centerTitle: true,
  //       scrolledUnderElevation: 0,
  //       backgroundColor: DivvyTheme.background,
  //     ),
  //     body: SizedBox.expand(child: CupertinoActivityIndicator()),
  //   );
  // }
}
