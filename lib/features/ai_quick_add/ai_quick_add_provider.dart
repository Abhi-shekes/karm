import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'ai_quick_add_service.dart';

part 'ai_quick_add_provider.g.dart';

@Riverpod(keepAlive: true)
AiQuickAddService aiQuickAddService(Ref ref) => AiQuickAddService.create();
