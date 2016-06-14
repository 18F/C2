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
    
    it "create a notification without type", ->
      notification = new Notifications(getNotificationContent())  
      expect(notification.el.find('ul li').length).to.eql(0)
      notice = notification._prepare({type: "", content: "This is content", title: ""})
      notification._postNotification(notice)
      expect(notification.el.find('ul li').length).to.eql(1)
      expect(notification.el.find('ul li.notice-type').length).to.eql(0)
      expect(notification.el.find('ul li.notice-type-primary').length).to.eql(1)
      expect(notification.el.find('ul li .notification-content').text()).to.eql("This is content")
    
    it "create a notification with type", ->
      notification = new Notifications(getNotificationContent())  
      expect(notification.el.find('ul li').length).to.eql(0)
      notice = notification._prepare({type: "success", content: "This is content", title: ""})
      notification._postNotification(notice)
      expect(notification.el.find('ul li').length).to.eql(1)
      expect(notification.el.find('ul li.notice-type-success').length).to.eql(1)
      expect(notification.el.find('ul li.notice-type-primary').length).to.eql(0)
    
    it "create a notification with title", ->
      notification = new Notifications(getNotificationContent())  
      expect(notification.el.find('ul li').length).to.eql(0)
      notice = notification._prepare({type: "success", content: "This is content", title: "This is a title"})
      notification._postNotification(notice)
      expect(notification.el.find('ul li .notification-title').text()).to.eql("This is a title")

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
      notification = new Notifications(getNotificationContent())  
      expect(notification.el.find('ul li').length).to.eql(0)
      notice = notification._prepare({type: undefined, content: "", title: ""})
      expect($(notice).hasClass('notice-type-primary')).to.eql(true)
      expect($(notice).attr('data-timeout')).to.eql("5000")
    
    it "handle a notification with alert", ->
      notification = new Notifications(getNotificationContent())  
      expect(notification.el.find('ul li').length).to.eql(0)
      notice = notification._prepare({type: "alert", content: "", title: ""})
      expect($(notice).attr('data-timeout')).to.not.eql("5000")
      expect($(notice).attr('data-timeout')).to.eql("none")
    
    it "handle a notification without a content", ->
      notification = new Notifications(getNotificationContent())  
      expect(notification.el.find('ul li').length).to.eql(0)
      notice = notification._prepare({type: "alert", content: "", title: ""})
      expect($(notice).length).to.eql(1)
      expect($(notice).find('.notification-content').text()).to.eql("")
    
    it "handle a notification without a type", ->
      notification = new Notifications(getNotificationContent())  
      expect(notification.el.find('ul li').length).to.eql(0)
      notice = notification._prepare({type: "alert", content: "", title: ""})
      expect($(notice).length).to.eql(1)
      expect($(notice).find('.notification-title').text()).to.eql("")
    
    it "handle a notification with a timeout", ->
      notification = new Notifications(getNotificationContent())  
      expect(notification.el.find('ul li').length).to.eql(0)
      notice = notification._prepare({timeout: "10000", content: "", title: ""})
      expect($(notice).length).to.eql(1)
      expect($(notice).attr('data-timeout')).to.not.eql("5000")
      expect($(notice).attr('data-timeout')).to.eql("10000")
  
  describe '#clearAll', ->
    
    it "remove all four notifications", ->
      notification = new Notifications(getNotificationContent())  
      expect(notification.el.find('ul li').length).to.eql(0)
      notice = notification._prepare({type: "", content: "This is content", title: ""})
      notification._postNotification(notice)
      expect(notification.el.find('ul li').length).to.eql(1)
      notification._postNotification(notice)
      expect(notification.el.find('ul li').length).to.eql(2)
      notification._postNotification(notice)
      notification._postNotification(notice)
      expect(notification.el.find('ul li').length).to.eql(4)
      expect(notification.el.find('ul li').last().is(':animated')).to.eql(false)
      notification.clearAll()
      expect(notification.el.find('ul li').first().is(':animated')).to.eql(true)
      expect(notification.el.find('ul li').last().is(':animated')).to.eql(true)

  describe '#clearOne', ->
    
    it "remove a single notification", ->
        notification = new Notifications(getNotificationContent())  
      expect(notification.el.find('ul li').length).to.eql(0)
      notice = notification._prepare({type: "", content: "This is content", title: ""})
      notification._postNotification(notice)
      expect(notification.el.find('ul li').length).to.eql(1)
      expect(notification.el.find('ul li').last().is(':animated')).to.eql(false)
      notification.clearOne(notification.el.find('ul li'))
      expect(notification.el.find('ul li').last().is(':animated')).to.eql(true)
