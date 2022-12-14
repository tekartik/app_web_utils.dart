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
