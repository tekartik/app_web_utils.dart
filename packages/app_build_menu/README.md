# tekartik_app_web_build_menu

Flutter build utils in a menu

## Setup

In `pubspec.yaml`:

```yaml
dev_dependencies:
  tekartik_app_web_build_menu:
    git: 
        url: https://github.com/tekartik/app_web_utils.dart
        ref: dart3a
        path: packages/app_build_menu
    version: '>=0.3.0'
    
  ...
  
  # Needed direct dependencies
  build_runner:
  build_web_compilers:
```
      
## wbm command

To activate

```shell
dart pub global activate -s path .
```

Run `wbm` to see the menu

See [app_build setup](../app_build/README.md) for more info