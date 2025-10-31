import 'package:get_it/get_it.dart';
import 'service_locator.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  await ServiceLocator.setup();
}
