ttm = thinkthroughmath

class MathJaxGateway
  renderMathMLInElement: (mathml, jquery_element, after_render)->
    MathJax.Hub.Queue ->
      elem = MathJax.Hub.getAllJax(jquery_element[0])[0]
      if elem
        window.setTimeout((->
          MathJax.Hub.Queue(
            ["Text", elem, mathml],
            ["Rerender", MathJax.Hub],
            after_render
          )), 1)
ttm.widgets.MathJaxGateway = ttm.class_mixer(MathJaxGateway)

