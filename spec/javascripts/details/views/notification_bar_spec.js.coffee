#= require jquery
#= require progressbar
#= require ladda/ladda.min
#= require ladda/ladda.jquery.min
#= require details/views/notifications
#= require details/details_helper
#= require ladda/spin.min

describe 'Notification', ->

  describe '#setup', ->
    
    it "sets in view mode", ->
      notification = new Notifications(getNotificationContent())  
      expect(notification instanceof Notifications).to.eql(true)
  
  describe '#_postNotification', ->
    
    it "creates a notification without type", ->
      notification = new Notifications(getNotificationContent())  
      notice = notification.create({type: "", content: "This is content", title: ""})
      expect(notification.el.find('ul li .notification-content').text()).to.eql("This is content")
    
    it "creates a notification with type", ->
      notification = new Notifications(getNotificationContent())  
      notice = notification.create({type: "success", content: "This is content", title: ""})
      expect(notification.el.find('ul li.notice-type-success').length).to.eql(1)
    
    it "creates a notification with title", ->
      notification = new Notifications(getNotificationContent())  
      notice = notification.create({type: "success", content: "This is content", title: "This is a title"})
      expect(notification.el.find('ul li .notification-title').text()).to.eql("This is a title")

  describe '#_prepareOnLoadNotifications', ->
    
    it "creates a notification for one meta tag on page load", ->
      notification = new Notifications(getNotificationContent())  
      el = $('
        <meta name="flash-message" type="success" content="Notification text here">  
      ')
      notification._prepareOnLoadNotifications(el)
      expect(notification.el.find('ul li').length).to.eql(1)

    
    it "should have all fields in notifcation based on metas tag", ->
      notification = new Notifications(getNotificationContent())  
      el = $('
        <meta name="flash-message" type="success" content="Notification text here">  
      ')
      notification._prepareOnLoadNotifications(el)
      expect(notification.el.find('ul li .notification-content').text()).to.eql("Notification text here")
      expect(notification.el.find('ul li.notice-type-success').length).to.eql(1)

  describe '#_closeButton', ->
    
    it "makes sure the close button deletes the notification", ->
      notification = new Notifications(getNotificationContent())  
      el = $('
        <meta name="flash-message" type="success" content="Notification text here">  
      ')
      notification._prepareOnLoadNotifications(el) 
      expect(notification.el.find('ul li').is(':animated')).to.eql(false)
      notification.el.find('ul li .close').trigger('click')
      expect(notification.el.find('ul li').is(':animated')).to.eql(true)
  
  describe '#_prepare', ->
    
    it "prepares a notification", ->
      notification = new Notifications(getNotificationContent())  
      expect(notification.el.find('ul li').length).to.eql(0)
      notice = notification.create({type: "", content: "", title: ""})
      notice = $(notification.data.currentNotice)
      expect($(notice).hasClass('notice-type-primary')).to.eql(true)
      expect($(notice).attr('data-timeout')).to.eql("5000")
    
    it "handles a notification with alert", ->
      notification = new Notifications(getNotificationContent())  
      expect(notification.el.find('ul li').length).to.eql(0)
      notice = notification.create({type: "alert", content: "", title: ""})
      notice = $(notification.data.currentNotice)
      expect($(notice).attr('data-timeout')).to.not.eql("5000")
      expect($(notice).attr('data-timeout')).to.eql("none")
    
    it "handles a notification without a content", ->
      notification = new Notifications(getNotificationContent())  
      notice = notification.create({type: "alert", content: "", title: ""})
      notice = $(notification.data.currentNotice)
      expect($(notice).find('.notification-content').text()).to.eql("")
    
    it "handles a notification without a type", ->
      notification = new Notifications(getNotificationContent())  
      notice = notification.create({type: "alert", content: "", title: ""})
      notice = $(notification.data.currentNotice)
      expect($(notice).find('.notification-title').text()).to.eql("")
    
    it "handles a notification with a timeout", ->
      notification = new Notifications(getNotificationContent())  
      notice = notification.create({timeout: "10000", content: "", title: ""})
      notice = $(notification.data.currentNotice)
      expect($(notice).attr('data-timeout')).to.eql("10000")
  
  describe '#clearAll', ->
    
    it "removes all two notifications", ->
      notification = new Notifications(getNotificationContent())  
      notice = notification._prepare({type: "", content: "This is content", title: ""})
      notification._postNotification(notice)
      notification._postNotification(notice)
      expect(notification.el.find('ul li').last().is(':animated')).to.eql(false)
      notification.clearAll()
      expect(notification.el.find('ul li').last().is(':animated')).to.eql(true)

  describe '#clearOne', ->
    
    it "removes a single notification", ->
      notification = new Notifications(getNotificationContent())  
      notice = notification._prepare({type: "", content: "This is content", title: ""})
      notification._postNotification(notice)
      expect(notification.el.find('ul li').last().is(':animated')).to.eql(false)
      notification.clearOne(notification.el.find('ul li'))
      expect(notification.el.find('ul li').last().is(':animated')).to.eql(true)
