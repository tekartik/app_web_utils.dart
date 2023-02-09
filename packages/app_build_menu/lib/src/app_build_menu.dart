import 'package:tekartik_app_web_build/app_build.dart';
import 'package:tekartik_test_menu_io/test_menu_io.dart';

Future main(List<String> arguments) async {
  mainMenu(arguments, () => menuWebAppContent());
}

void menuWebAppContent({WebAppOptions? options}) {
  var builder = WebAppBuilder(options: options);
  menu('web_app_builder', () {
    item('build', () async {
      await builder.build();
    });
    item('serve', () async {
      await builder.serve();
    });
    item('clean', () async {
      await builder.clean();
    });
  });
}
