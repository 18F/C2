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
      summaryBar:     '#summary-card',
      approvalCard:   '#card-for-approvals'
    }
    this.lastNotice = {};
    this._overrideTestConfig(config);
    this._blastOff();
  }

  C2.prototype._blastOff = function(){
    console.log('c2.js: Running _blastOff');
    var config = this.config;
    // Data
    this.detailsSave = new DetailsSave(config.detailsSave, config.detailsSaveAll);
    this.updateView = new UpdateView(config.updateView);

    // State
    this.editMode = new EditStateController(config.editMode);
    this.formState = new FormChangeState(config.formState);

    // Views
    this.detailsRequestCard = new DetailsRequestCard(config.detailsForm);
    this.attachmentCardController = new AttachmentCardController(config.attachmentCard);
    this.observerCardController = new ObserverCardController(config.observerCard);
    this.activityCardController = new ActivityCardController(config.activityCard);
    this.approvalCardController = new ApprovalCardController(config.approvalCard);
    this.modals = new ModalController(config.modalCard);
    this.actionBar = new ActionBar(config.actionBar);
    this.notification = new Notifications(config.notifications);
    this.summaryBar = new SummaryBar(config.summaryBar);

    this.actionBridge = new ActionBarBridge();

    this._setupEvents();
  }

  C2.prototype._overrideTestConfig = function(config){
    console.log('c2.js: Running _overrideTestConfig');
    var opt = this.config;
    $.each(opt, function(key, item){
      if(config[key]){
        opt[key] = config[key];
      }
    });
    this.config = opt;
  }

  C2.prototype._setupEvents = function(){
    console.log('c2.js: Running _setupEvents');
    this._setupEditToggle();
    this._setupDetailsData();
    this._setupDetailsForm();
    this._setupEditMode();
    this._setupNotifications();
    this._setupAttachmentEvent();
    this._setupObserverEvent();
    this._setupViewUpdate();
  }

  /* Form */

  C2.prototype._setupEditMode = function(){
    console.log('c2.js: Running _setupEditMode');
    var self = this;
    this.formState.el.on('form:dirty', function(){
      self.actionBar.barState('.save-button', false);
    });
    this.formState.el.on('form:clean', function(){
      self.actionBar.barState('.save-button', "disabled");
    });
    this.editMode.el.on('details:edit-mode', function(){
      self.detailsMode('edit');
    });
    this.editMode.el.on('details:cancelled', function(){
      self.detailsCancelled();
    });
  }

  C2.prototype._setupDetailsForm = function(){
    console.log('c2.js: Running _setupDetailsForm');
    var self = this;
    this.detailsRequestCard.el.on('form:updated', function(event, data){
      console.log('Form updates running');
      console.log(data);
      self.detailsSaved(data);
      self.checkClientSpecific(data);
    });
  }

  C2.prototype.checkClientSpecific = function(data){
    console.log('c2.js: Running checkClientSpecific');
    var self = this;
    var total, params;
    if(data['quantity'] !== undefined && data['cost_per_unit'] !== undefined){
      total = parseFloat(data['quantity'], 10) * parseFloat(data['cost_per_unit'], 10);
      params = { field: ".total_price-wrapper .detail-value", value: total.toFixed(2) };
      self.updateView.el.trigger("update:textfield", params);
    }
  }

  C2.prototype._setupEditToggle = function(){
    console.log('c2.js: Running _setupEditToggle');
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
    console.log('c2.js: Running _setupViewUpdateEvents');
    var self = this;
    $(item).on(jevent, function(event, data){
      self.updateView.el.trigger(jevent, data);
    });
  }

  C2.prototype._setupViewUpdate = function(){
    console.log('c2.js: Running _setupViewUpdate');
    var self = this;
    $.each([ self.summaryBar.el.selector, self.detailsRequestCard.el.selector ], function(i, item){
      $.each([ "update:textfield", "update:checkbox" ], function(j, jevent){
        self._setupViewUpdateEvents(item, jevent);
      });
    });
  }

  C2.prototype.detailsCancelled = function(){
    console.log('c2.js: Running detailsCancelled');
    this.detailsMode('view');
    var message;
    if(this.formState.el.dirrty("isDirty")){
      message = "Your modifications have not been saved. Click modify to continue.";
    } else {
      message = "Modification canceled. No changes were made.";
    }
    this.createNotification(message, "", "notice");
  }

  C2.prototype.detailsSaved = function(data){
    console.log('c2.js: Running detailsSaved');
    this.formState.initDirrty();
    this.detailsMode('view');
    this.actionBar.el.trigger("action-bar-clicked:saved");
    this.activityCardController.el.trigger('activity-card:update');
    this.approvalCardController.el.trigger('status-card:update');
    this.createNotification("Your updates have been saved.", "", "success");
  }

  C2.prototype.triggerDirtyCheck = function(){
    console.log('c2.js: Running triggerDirtyCheck');
    var dirtyCheck = this.formState.el.dirrty("isDirty");
    if(dirtyCheck){
      this.formState.el.trigger('form:dirty');
    } else {
      this.formState.el.trigger('form:clean');
    }
  }

  C2.prototype.detailsMode = function(mode){
    console.log('c2.js: Running detailsMode');
    this.triggerDirtyCheck()
    this.detailsRequestCard.toggleMode(mode)
    this.editMode.stateTo(mode);
    this.actionBar.setMode(mode);
  }

  /* End Form */

  /* Notice */
  C2.prototype._setupNotifications = function(){
    console.log('c2.js: Running _setupNotifications');
    var notice = this.notification;
    this.notification.el.on('notification:create', function(event, data){
      notice.create(data);
    });
  }

  C2.prototype._setupDetailsData = function(){
    console.log('c2.js: Running _setupDetailsData');
    var self = this;
    this.detailsSave.el.on('details-form:success', function(event, data){
      self.summaryBar.updateViewContent(data);
      self.detailsRequestCard.updateViewModeContent(data);
      self.modals.el.trigger("modal:close");
    });

    this.detailsSave.el.on('details-form:error', function(event, data){
      data['timeout'] = "none";
      self.handleSaveError(data);
      self.modals.el.trigger("modal:close");
    });
  }

  C2.prototype.handleSaveError = function(data){
    console.log('c2.js: Running handleSaveError');
    console.log(data);
    var response = data['response'];
    for (var i = response.length - 1; i >= 0; i--) {
      response[i]['timeout'] = data['timeout'] || 7500;
      this.createNotification(response[i], "", "alert");
    }
  }

  C2.prototype.createNotification = function(title, content, type){
    console.log('c2.js: Running createNotification');
    var param = {
      title: title,
      content: content,
      type: type
    }
    var stringParam = JSON.stringify(param);
    if ( this.lastNotice !== stringParam){
      this.lastNotice = stringParam;
      this.notification.el.trigger('notification:create', param);
    }
  }

  /* End Notice */


  /* Activity */

  C2.prototype._setupAttachmentEvent = function(){
    console.log('c2.js: Running _setupAttachmentEvent');
    var self = this;
    this.attachmentCardController.el.on("attachment-card:updated", function(event, data){
      self.activityCardController.el.trigger('activity-card:update');
      self.createAttachmentNotification(data);
    });
  }

  C2.prototype.createAttachmentNotification = function(data){
    console.log('c2.js: Running createAttachmentNotification');
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
    console.log('c2.js: Running _setupObserverEvent');
    var self = this;
    this.observerCardController.el.on("observer-card:updated", function(event, data){
      self.createObserverNotification(data);
    });
  }

  C2.prototype.createObserverNotification = function(data){
    console.log('c2.js: Running createObserverNotification');
    var params = {
      title: "Observer " + data.actionType+". ",
      type: data.noticeType,
      content: data.response
    };
    this.notification.el.trigger('notification:create', params);
  }

  /* End Activity */


  return C2;

}());

window.C2 = C2;

