/// Support for building a regular webapp.
library;

export 'package:tekartik_common_build/common_app_builder.dart';
export 'package:tekartik_firebase_build/firebase_deploy.dart';

export 'src/app_build_base.dart'
    show
        webdevBuild,
        webdevServe,
        buildToDeploy,
        httpDeployServe,
        webdevClean,
        webdevPubGet,
        webdevPubUpgrade;
export 'src/build_common.dart'
    show WebAppOptions, FirebaseWebAppOptions, WebAppBuildOptions;
export 'src/web_app_builder.dart'
    show
        WebAppBuilder,
        FirebaseWebAppBuilder,
        DefaultWebAppBuilder,
        SurgeWebAppBuilder,
        SurgeWebAppOptions,
        CommonWebAppBuilder;
export 'src/web_project.dart' show WebProject;
