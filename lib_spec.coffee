#= require lib
describe "lib/object_refinement", ->
  describe "example usage", ->
    beforeEach ->
      class ATypeToRefine
        normal: -> 'a'
      class BTypeToRefine
        normal: -> 'b'
      class XTypeToRefine
        normal: -> 'x'

      refinement = ttm.require('lib/object_refinement').build()
      refinement.forType(ATypeToRefine, {refined: -> 'a'})
      refinement.forType(BTypeToRefine, {refined: -> 'b'})

      @a = new ATypeToRefine
      @b = new BTypeToRefine
      @x = new XTypeToRefine

      @ap = refinement.refine(@a)
      @bp = refinement.refine(@b)
      @xp = refinement.refine(@x)



    describe "added methods via refinement", ->
      it "does not add them to the unrefined object", ->
        expect(@a.refined).toEqual undefined
        expect(@b.refined).toEqual undefined

      it "adds them to the refined object", ->
        expect(@ap.refined()).toEqual "a"
        expect(@bp.refined()).toEqual "b"

    it "does nothing to a class that has no applicable refinement", ->
      expect(@xp.refined).toEqual undefined
