#= require lib/dashboard_poller
#= require mock-ajax

describe "Dashboard Poller", ->
  beforeEach ->
    jasmine.Ajax.useMock()
    @dashboard = ttm.lib.DashboardPoller.build()

  describe "when the report is ready on the first iteration", ->
    it "should return the dashboard data", ->
      that = this

      @dashboard.getData { type: 'lesson_leaders' }, (data) ->
        that.data = data

      request = mostRecentAjaxRequest()
      expect(request.url).toBe('/dashboard/queries')
      expect(request.method).toBe('POST')
      request.response { status: 200, responseText: '{"id": "REPORT_ID" }' }

      waits(1000)

      runs ->
        request = mostRecentAjaxRequest()
        expect(request.url).toBe('/dashboard/queries/REPORT_ID/ready')
        expect(request.method).toBe('GET')
        request.response { status: 200, responseText: '{"is_ready": true, "data":"{ \\"key\\": \\"DATA\\" }" }' }

        expect(that.data.key).toEqual 'DATA'
