import 'package:flutter/material.dart';

import 'mimi_text.dart';

extension MimiThemeContext on BuildContext {
  MimiText get text =>
      Theme.of(this).extension<MimiText>() ?? MimiText.standard;
}
