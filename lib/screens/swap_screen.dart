import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/widgets/swap_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

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
        if (!provider.dataLoaded) {
          return Center(child: CupertinoActivityIndicator());
        }

        return SizedBox.expand(
          child: SingleChildScrollView(
            child: Container(
              width: width,
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: Column(
                children: [
                  AvailableIncomingSwaps(provider, false),
                  AvailableOutgoingSwaps(provider)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}