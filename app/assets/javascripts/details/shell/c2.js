var C2;
C2 = (function() {

  function C2(config){
    config = config || {};
    this.config = {
      actionBar:      '#action-bar-wrapper',
      attachmentCard: '#card-for-attachments',
      detailsForm:    '#request-details-card',
      detailsSave:    '#request-details-card',
      detailsSaveAll: '#request-details-card, #summary-card',
      activityCard:   '#card-for-activity',
      editMode:       '#mode-parent',
      formState:      '#request-details-card form, #proposal-title-wrapper form',
      notifications:  '#action-bar-status',
      observerCard:   '#card-for-observers',
      modalCard:      '#modal-wrapper',
      updateView:     '#mode-parent',
      summaryBar:     '#summary-card'
    }
    this._overrideTestConfig(config);
    this._blastOff();
  }

  C2.prototype._blastOff = function(){
    this._setupStates();
    this._setupViews();
    this._setupData();
    this._setupEvents();
  }

  C2.prototype._overrideTestConfig = function(config){
    var opt = this.config;
    $.each(opt, function(key, item){
      if(config[key]){
        opt[key] = config[key];
      }
    });
    this.config = opt;
  }

  C2.prototype._setupData = function(){
    var config = this.config;
    this.detailsSave = new DetailsSave(config.detailsSave, config.detailsSaveAll);
    this.updateView = new UpdateView(config.updateView);
  }

  C2.prototype._setupStates = function(){
    var config = this.config;
    this.editMode = new EditStateController(config.editMode);
    this.formState = new FormChangeState(config.formState);
  }

  C2.prototype._setupViews = function(){
    var config = this.config;
    this.detailsRequestCard = new DetailsRequestCard(config.detailsForm);
    this.attachmentCardController = new AttachmentCardController(config.attachmentCard);
    this.observerCardController = new ObserverCardController(config.observerCard);
    this.activityCardController = new ActivityCardController(config.activityCard);
    this.modals = new ModalController(config.modalCard);
    this.actionBar = new ActionBar(config.actionBar);
    this.notification = new Notifications(config.notifications);
    this.summaryBar = new SummaryBar(config.summaryBar);
  }

  C2.prototype._setupEvents = function(){
    this._setupActionBar();
    this._setupEditToggle();
    this._setupDetailsData();
    this._setupDetailsForm();
    this._setupEditMode();
    this._setupNotifications();
    this._setupAttachmentEvent();
    this._setupObserverEvent();
    this._setupSaveModal();
    this._setupFormSubmitModal();
    this._setupViewUpdate();
  }

  /* Form */

  C2.prototype._setupEditMode = function(){
    var self = this;
    this.formState.el.on('form:dirty', function(){
      self.actionBar.barState('.save-button', false);
    });
    this.formState.el.on('form:clean', function(){
      self.actionBar.barState('.save-button', "disabled");
    });
  }

  C2.prototype._setupDetailsForm = function(){
    var self = this;
    this.detailsRequestCard.el.on('form:updated', function(event, data){
      self.detailsSaved(data);
    });
  }

  C2.prototype._setupEditToggle = function(){
    var self = this;
    this.detailsRequestCard.el.on('edit-toggle:trigger', function(){
      if(!self.editMode.getState()){
        self.detailsMode('edit');
      } else {
        if(self.detailsRequestCard.el.is){
          self.detailsCancelled();
        } else {
          self.detailsMode('view');
        }
      }
    });
  }

  C2.prototype._setupViewUpdateEvents = function(item, jevent){
    var self = this;
    $(item).on(jevent, function(event, data){
      self.updateView.el.trigger(jevent, data);
    });
  }

  C2.prototype._setupViewUpdate = function(){
    var self = this;
    $.each([ self.summaryBar.el.selector, self.detailsRequestCard.el.selector ], function(i, item){
      $.each([ "update:textfield", "update:checkbox" ], function(j, jevent){
        self._setupViewUpdateEvents(item, jevent);
      });
    });
  }

  C2.prototype.detailsCancelled = function(){
    this.detailsMode('view');
    this.createNotification("Your changes have been discarded.", "", "notice");
  }

  C2.prototype.detailsSaved = function(data){
    this.formState.initDirrty();
    this.detailsMode('view');
    this.actionBar.el.trigger("action-bar-clicked:saved");
    this.activityCardController.el.trigger('activity-card:update');
    this.createNotification("Your updates have been saved.", "", "success");
  }

  C2.prototype.triggerDirtyCheck = function(){
    var dirtyCheck = this.formState.el.dirrty("isDirty");
    if(dirtyCheck){
      this.formState.el.trigger('form:dirty');
    } else {
      this.formState.el.trigger('form:clean');
    }
  }

  C2.prototype.detailsMode = function(mode){
    this.triggerDirtyCheck()
    this.detailsRequestCard.toggleMode(mode)
    this.editMode.stateTo(mode);
    this.actionBar.setMode(mode);
  }

  /* End Form */

  /* Notice */

  C2.prototype._setupNotifications = function(){
    var notice = this.notification;
    this.notification.el.on('notification:create', function(event, data){
      notice.create(data);
    });
  }

  C2.prototype._setupDetailsData = function(){
    var self = this;
    this.detailsSave.el.on('details-form:success', function(event, data){
      self.summaryBar.updateViewContent(data);
      self.detailsRequestCard.updateViewModeContent(data);
      self.modals.el.trigger("modal:close");
    });

    this.detailsSave.el.on('details-form:error', function(event, data){
      self.handleSaveError(data);
      self.modals.el.trigger("modal:close");
    });
  }

  C2.prototype.handleSaveError = function(data){
    var response = data['response'];
    for (var i = response.length - 1; i >= 0; i--) {
      response[i]['timeout'] = 7500;
      this.createNotification(response[i], "", "alert");
    }
  }

  C2.prototype.createNotification = function(title, content, type){
    var param = {
      title: title,
      content: content,
      type: type
    }
    this.notification.el.trigger('notification:create', param);
  }

  /* End Notice */


  /* Activity */

  C2.prototype._setupAttachmentEvent = function(){
    var self = this;
    this.attachmentCardController.el.on("attachment-card:updated", function(event, data){
      self.activityCardController.el.trigger('activity-card:update');
      self.createAttachmentNotification(data);
    });
  }

  C2.prototype.createAttachmentNotification = function(data){
    var content;
    if (data.actionType === "delete"){
      content = data.response + " was deleted successfully.";
    } else if (data.actionType === "create"){
      content = data.response + " was uploaded successfully.";
    }

    if (data.actionType === "error"){
      this.handleSaveError(data);
    } else{
      this.createNotification("Attachment ", content, data.noticeType);
    }

  }

  /* End Activity */

  /* Observer Activity */

  C2.prototype._setupObserverEvent = function(){
    var self = this;
    this.observerCardController.el.on("observer-card:updated", function(event, data){
      self.createObserverNotification(data);
    });
  }

  C2.prototype.createObserverNotification = function(data){
    var params = {
      title: "Observer " + data.actionType+". ",
      type: data.noticeType, 
      content: data.response
    }; 
    this.notification.el.trigger('notification:create', params);
  }

  /* End Activity */

   /* Action Bar */

  C2.prototype._setupActionBar = function(){
    var self = this;
    this.actionBar.el.on("action-bar-clicked:cancel", function(){
      self.detailsCancelled();
    });
    this.actionBar.el.on("action-bar-clicked:save", function(){
      // triggers save_confirm-modal
    });
    this.actionBar.el.on("action-bar-clicked:edit", function(){
      self.detailsMode('edit');
    });
  }

  C2.prototype._setupSaveModal = function(){
    var self = this;
    this.modals.el.on("save_confirm-modal:confirm", function(event, item){
      var l = $(item).ladda();
      l.ladda( 'start' );
      self.modals.el.find('button').attr('disabled', 'disabled').css('opacity', 0.5);
      self.actionBar.el.trigger("action-bar-clicked:saving");
      self.detailsSave.el.trigger("details-form:save");
    });
    this.modals.el.on("save_confirm-modal:cancel", function(event, item){
      self._closeModal();
    });
    this.modals.el.on("modal:cancel", function(){
      self.actionBar.stopLadda();
    });
  }

  C2.prototype._setupFormSubmitModal = function(){
    var self = this,
      events = "attachment_confirm-modal:confirm observer_confirm-modal:confirm";
    this.modals.el.on(events, function(event, item, sourceEl){
      self._submitAndClose(sourceEl);
    });
  }

  C2.prototype._submitAndClose = function(sourceEl){
    var self = this;
    $(sourceEl).parent().submit();
    self._closeModal();
  }

  C2.prototype._closeModal = function(){
    this.modals.el.trigger("modal:close");
    this.actionBar.stopLadda();
  }
  /* End Action Bar */

  return C2;

}());

window.C2 = C2;
