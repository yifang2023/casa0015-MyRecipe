import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Empty widget
class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: 100,
            height: 100,
            child: SvgPicture.asset("asset/empty_data.svg",
                semanticsLabel: 'empty_data')),
        const Text(
          "No recipes yet. Start creating your\nrecipe now!",
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
