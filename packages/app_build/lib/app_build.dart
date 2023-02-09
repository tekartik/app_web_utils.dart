/// Support for building a regular webapp.
library tekartik_app_web_build;

export 'src/app_build_base.dart'
    show
        webdevBuild,
        webdevServe,
        buildToDeploy,
        httpDeployServe,
        webdevClean,
        webdevPubGet,
        webdevPubUpgrade;
export 'src/build_common.dart' show WebAppOptions;
export 'src/web_app_builder.dart' show WebAppBuilder;
export 'src/web_project.dart' show WebProject;
