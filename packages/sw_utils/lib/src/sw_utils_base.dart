import 'package:service_worker/window.dart' as sw;
import 'package:tekartik_browser_utils/arguments_option.dart';

Future appInitServiceWorker() async {
  if (optionNoServiceWorker.has() ?? false) {
    print('No service worker');
  } else {
    try {
      // devPrint('ServiceWorker isSupported');
      if (sw.isSupported) {
        // devPrint('ServiceWorker supported.');
        await sw.register('sw.js').timeout(const Duration(milliseconds: 500));
        print('ServiceWorker registered.');
      } else {
        print('ServiceWorkers are not supported.');
      }
    } catch (e) {
      print('Service worker error $e');
    }
  }
}

var optionNoServiceWorker = ArgumentsOption('no-sw');
