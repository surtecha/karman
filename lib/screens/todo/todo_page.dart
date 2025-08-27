import 'package:flutter/cupertino.dart';
import 'package:karman/components/floating_action_button.dart';
import 'package:karman/components/pill_button.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: PillButton(
                        options: ['Today', 'Upcoming', 'Completed'],
                        counts: [5, 12, 8],
                        onSelectionChanged: (index) {

                        },
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Todo Page',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: constraints.maxHeight > 600 ? 20 : 16,
                  right: constraints.maxWidth < 350 ? 16 : 20,
                  child: CustomFloatingActionButton(
                    onPressed: () {

                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}