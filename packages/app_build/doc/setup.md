## Setup

- Create a dart package project
- Add dependency

    In `pubspec.yaml`:
    ```yaml
    dev_dependencies:
      tekartik_app_web_build:
        git:
          url: https://github.com/tekartik/app_web_utils.dart
          path: packages/app_build
          ref: dart3a
        version: '>=0.1.0'
    
      # Needed direct dependencies
      build_runner:
      build_web_compilers:
    ```
