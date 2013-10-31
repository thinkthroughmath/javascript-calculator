
# TTM Coffeescript Utilities

Coffeescript helpers developed internally at TTM. The specifics of
each component are included below.


## Getting Started

Download the [production version][min] or the [development version][max].

[min]: https://raw.github.com/thinkthroughmath/jquery-ttm-coffeescript-utilities/master/dist/jquery.ttm-coffeescript-utilities.min.js
[max]: https://raw.github.com/thinkthroughmath/jquery-ttm-coffeescript-utilities/master/dist/jquery.ttm-coffeescript-utilities.js

In your web page:

```html
<script src="path/to/ttm-coffeescript-utilities.min.js"></script>
<script>
    // use anything provided by the library, such as the
    // class mixer
    function MyClass(){  }
    thinkthroughmath.class_mixer(MyClass)
</script>
```

In node, loading the library will attach things to the `global`
object instead of `window`. You can still just reference the library
through `thinkthroughmath`, though.


## Documentation
TODO document class_mixer, refinements, and logger


## Release History

10/29/13 - Initial release

