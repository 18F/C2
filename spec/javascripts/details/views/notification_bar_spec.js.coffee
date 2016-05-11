#= require jquery
#= require ladda/ladda.min
#= require ladda/ladda.jquery.min
#= require details/views/notifications
#= require details/details_helper
#= require ladda/spin.min

describe 'Notification', ->

  describe '#setup', ->
    it "set in view mode", ->
      notification = new Notifications(getNotificationContent())  
      expect(true).to.eql(false)
  
  describe '#create', ->
    it "set in view mode", ->
