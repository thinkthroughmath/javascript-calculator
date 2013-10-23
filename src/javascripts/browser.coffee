root = window || global
root.thinkthroughmath ||= {}
require("./lib");
root.thinkthroughmath.widgets ||= {}
require("./widgets/ui_elements");
require("./widgets/math_buttons");
require("./widgets/calculator");
require("./widgets/equation_builder_rendered_mathml_modifier");
require("./widgets/mathml_display");
require("./widgets/equation_builder");

