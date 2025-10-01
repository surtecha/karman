import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class NameDescriptionSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final FocusNode nameFocusNode;

  const NameDescriptionSection({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.nameFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return CupertinoFormSection.insetGrouped(
          backgroundColor: AppColorScheme.backgroundSecondary(theme),
          children: [
            CupertinoTextFormFieldRow(
              controller: nameController,
              focusNode: nameFocusNode,
              placeholder: 'Name',
              textCapitalization: TextCapitalization.sentences,
            ),
            CupertinoTextFormFieldRow(
              controller: descriptionController,
              placeholder: 'Description',
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        );
      },
    );
  }
}
