import 'package:d4rt/d4rt.dart';

import '../../../Model/Manga.dart';

class MStatusBridge {
  final statusDefinition = BridgedEnumDefinition<Status>(
    name: 'MStatus',
    values: Status.values,
  );

  void registerBridgedEnum(D4rt interpreter) {
    interpreter.registerBridgedEnum(
      statusDefinition,
      'package:mangayomi/bridge_lib.dart',
    );
  }
}
