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

      @refinement = ttm.require('lib/object_refinement').build()
      @refinement.forType(ATypeToRefine, {refined: -> 'a'})
      @refinement.forType(BTypeToRefine, {refined: -> 'b'})

      @a = new ATypeToRefine
      @b = new BTypeToRefine
      @x = new XTypeToRefine

      @ap = @refinement.refine(@a)
      @bp = @refinement.refine(@b)



    describe "added methods via refinement", ->
      it "does not add them to the unrefined object", ->
        expect(@a.refined).toEqual undefined
        expect(@b.refined).toEqual undefined

      it "adds them to the refined object", ->
        expect(@ap.refined()).toEqual "a"
        expect(@bp.refined()).toEqual "b"


    describe "without a default refinement", ->
      beforeEach ->
        @xp = @refinement.refine(@x)

      it "does nothing to a class that has no applicable refinement", ->
        expect(@xp.refined).toEqual undefined

    describe "with a default refinement", ->
      beforeEach ->
        @refinement.forDefault({refined: -> 'default'})
        @xp = @refinement.refine(@x)

      it "adds the default refinement to objects that have no refinements", ->
        expect(@xp.refined()).toEqual "default"

    it "provides a way to get the unrefined object", ->
      expect(@ap.unrefined()).toEqual @a

