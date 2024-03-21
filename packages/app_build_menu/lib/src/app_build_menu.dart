import 'package:dev_build/menu/menu_io.dart';
import 'package:tekartik_app_web_build/app_build.dart';

Future main(List<String> arguments) async {
  mainMenuConsole(arguments, () => menuWebAppContent());
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
