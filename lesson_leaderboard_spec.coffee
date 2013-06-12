#= require lib
#= require lib/ranks
#= require handlebars.runtime
#= require handlebars.helpers
#= require templates/student_dashboard/leaderboard
#= require templates/shared/_leaderboard_entry
#= require decorators/lesson_leaderboard
#= require mock-ajax

class FakeBunchball
  classId: ->
    'classroom'

  schoolId: ->
    'school'

  stateCode: ->
    'PA'

  avatarFor: (username)->
    username

class FakePoller
  getData: ->
    {}

describe "Lesson Leaderboard", ->
  beforeEach ->
    @poller = new FakePoller
    @pollerSpy = spyOn(@poller, 'getData')

    @leaderboard = window.ttm.decorators.LessonLeaderboard.build {
      bunchball: new FakeBunchball
      poller: @poller
    }

  describe "When there are lesson leaders", ->
    beforeEach ->
      @leaders = { rows: [
        {
          student_name: 'first last'
          student_first_name: 'first'
          student_last_name: 'last'
          bunchball_username: 'bunchball'
          lessons_completed: 10
        }
      ] }

    describe "When building the top 3", ->
      beforeEach ->
        f """
          <div id='lessons'>
            <div class='lesson_leaders'>
              <div class='replaceable'>
                Loading...
              </div
            </div>
          </div>
        """

        @leaderboard.buildTop3()
        @pollerSpy.mostRecentCall.args[1](@leaders)

      it "should replace the loading content", ->
        expect($('#lessons .lesson_leaders .replaceable').length).toEqual(0)

      it "should render the first place kid", ->
        expect($('#lessons .lesson_leaders .row .first_place').length).toEqual(1)
