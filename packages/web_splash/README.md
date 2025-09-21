## Setup

```yaml
tekartik_web_splash:
  git:
    url: https://github.com/tekartik/app_web_utils.dart
    path: packages/web_splash
  version: '>=0.1.0'
```

## Usage 

Define you splash in the html/css:

```html
<body>
    ...
    
    <!-- add at the end to be above all with the proper id app_flahs-->
    <div id="app_splash"  class="app-loading">
</div>
```

For testing, you can control the splash by adding the `?splash` parameter in the Uri.
- `?splash`: splash never hides.
- `?splash=5000`: wait for 5000 ms before hiding the splash.

## Usage compat

Define you splash in the html/css:

```html
<!-- set app-loading class on body -->
<body class="app-loading">

    ...
    
    <!-- add at the end to be above all with the proper id app_flahs-->
    <div id="app_splash">
</div>
```
