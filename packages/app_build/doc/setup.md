## Setup

- Create a dart web package (`dart create --template web <name>`)
- Add the dependency

    In `pubspec.yaml`:
    ```yaml
    dev_dependencies:
      tekartik_app_web_build:
        git:
          url: https://github.com/tekartik/app_web_utils.dart
          path: packages/app_build

      # Needed direct dependencies
      build_runner:
      build_web_compilers:
    ```
- Add a `web/deploy.yaml` listing the files to deploy, see the
  [README](../README.md).
