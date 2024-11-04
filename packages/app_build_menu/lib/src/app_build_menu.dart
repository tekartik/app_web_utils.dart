import 'package:dev_build/menu/menu_io.dart';
import 'package:tekartik_app_web_build/app_build.dart';

Future main(List<String> arguments) async {
  mainMenuConsole(arguments, () => menuWebAppContent());
}

void menuWebAppContent({WebAppOptions? options, WebAppBuilder? builder}) {
  var localBuilder = builder ?? WebAppBuilder(options: options);
  menu('web_app_builder', () {
    item('build', () async {
      await localBuilder.build();
    });
    item('serve', () async {
      await localBuilder.serve();
    });
    item('clean', () async {
      await localBuilder.clean();
    });
    item('pre-deploy', () async {
      await localBuilder.build();
    });
  });
}

/// Compat
void menuFirebaseWebAppContent(
    {required List<FirebaseWebAppBuilder> builders}) {
  for (var builder in builders) {
    menu('target ${builder.target}', () {
      menuFirebaseWebAppBuilderContent(builder: builder);
    });
  }
}

void menuCommonWebAppContent({required List<CommonWebAppBuilder> builders}) {
  for (var builder in builders) {
    menu('target ${builder.target}', () {
      menuCommonWebAppBuilderContent(builder: builder);
    });
  }
}

/// Compat
void menuFirebaseWebAppBuilderContent(
    {required FirebaseWebAppBuilder builder}) {
  menuCommonWebAppBuilderContent(builder: builder);
}

void menuCommonWebAppBuilderContent({required CommonWebAppBuilder builder}) {
  item('build', () async {
    await builder.build();
  });
  item('serve', () async {
    await builder.serve();
  });
  item('clean', () async {
    await builder.clean();
  });
  item('deploy', () async {
    await builder.deploy();
  });
  item('serveDeployed', () async {
    await builder.serveDeployed();
  });
  item('buildAndServeDeployed', () async {
    await builder.build();
    await builder.serveDeployed();
  });
  item('buildAndDeploy', () async {
    await builder.build();
    await builder.deploy();
  });
}
