#= require jquery
#= require progressbar
#= require ladda/ladda.min
#= require ladda/ladda.jquery.min
#= require details/views/notifications
#= require details/details_helper
#= require ladda/spin.min

describe 'Notification', ->

  describe '#setup', ->
    it "set in view mode", ->
      notification = new Notifications(getNotificationContent())  
      expect(notification instanceof Notifications).to.eql(true)
  
  describe '#_postNotification', ->
    it "create a notification", ->
  
  describe '#_prepareOnLoadNotifications', ->
    it "on page load, create a notification for each meta tag", ->
      notification = new Notifications(getNotificationContent())  
      el = $('
        <meta name="flash-message" type="success" content="Notification text here">  
      ')
      notification._prepareOnLoadNotifications(el)
      expect(notification.el.find('ul li').length).to.eql(1)
      notification._prepareOnLoadNotifications(el)
      expect(notification.el.find('ul li').length).to.eql(2)

    it "meta tag based notification should have all fields", ->
      notification = new Notifications(getNotificationContent())  
      el = $('
        <meta name="flash-message" type="success" content="Notification text here">  
      ')
      notification._prepareOnLoadNotifications(el)
      expect(notification.el.find('ul li .notification-content').text()).to.eql("Notification text here")
      expect(notification.el.find('ul li.notice-type-success').length).to.eql(1)

  describe '#_closeButton', ->
    it "make sure the close button deletes the notification", ->
      notification = new Notifications(getNotificationContent())  
      el = $('
        <meta name="flash-message" type="success" content="Notification text here">  
      ')
      notification._prepareOnLoadNotifications(el)
      expect(notification.el.find('ul li').length).to.eql(1) 
      expect(notification.el.find('ul li').is(':animated')).to.eql(false)
      notification.el.find('ul li .close').trigger('click')
      expect(notification.el.find('ul li').is(':animated')).to.eql(true)
  describe '#_prepare', ->
    it "prepare a notification", ->
    it "handle a notification without a title", ->
    it "handle a notification without a content", ->
    it "handle a notification without a type", ->
    it "handle a notification with a timeout", ->
  
  describe '#clearAll', ->
    it "remove all four notifications", ->
  
  describe '#clearOne', ->
    it "remove a single notification", ->
  
  describe '#initClose', ->
    it "make sure notification bar closes after the init period with timeout", ->
    it "cancel the auto close on click of the notification", ->

  describe '#generate', ->
    it "create the expected notification bar", ->
    it "change params without timeout", ->
    it "change params without title", ->
    it "change params without type", ->
