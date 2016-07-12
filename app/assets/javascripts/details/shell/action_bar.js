var C2ActionBar;
C2ActionBar = (function() {

  function C2ActionBar(config){
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

  C2ActionBar.prototype._blastOff = function(){
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
    this._setupEvents();
  }

  C2ActionBar.prototype._overrideTestConfig = function(config){
    var opt = this.config;
    $.each(opt, function(key, item){
      if(config[key]){
        opt[key] = config[key];
      }
    });
    this.config = opt;
  }

  C2ActionBar.prototype._setupEvents = function(){
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

  /* Action Bar */

  C2ActionBar.prototype._setupActionBar = function(){
    var self = this;
    this.actionBar.el.on("action-bar-clicked:cancel", function(){
      self.detailsCancelled();
    });
    this.actionBar.el.on("action-bar-clicked:save", function(){
      self.notification.clearAll();
      // triggers save_confirm-modal
    });
    this.actionBar.el.on("action-bar-clicked:edit", function(){
      self.detailsMode('edit');
    });
  }

  C2ActionBar.prototype.enableModalButtons = function(){
    this.modals.el.find('button').attr('disabled', false).css('opacity', 1);
  }

  C2ActionBar.prototype.disableModalButtons = function(){
    this.modals.el.find('button').attr('disabled', 'disabled').css('opacity', 0.5);
  }

  C2ActionBar.prototype.checktimeout = function(l){
    var self = this;
    window.setTimeout(function(){
      if(l.ladda( 'isLoading' )){
        l.ladda( 'stop' );
        self.enableModalButtons();
      }
    }, 7500);
  }

  C2ActionBar.prototype._setupSaveModal = function(){
    var self = this;
    this.modals.el.on("save_confirm-modal:confirm", function(event, item){
      var l = $(item).ladda();
      l.ladda( 'start' );
      self.disableModalButtons();
      self.actionBar.el.trigger("action-bar-clicked:saving");
      self.detailsSave.el.trigger("details-form:save");
      self.checkTimeout(l);
    });
    this.modals.el.on("save_confirm-modal:cancel", function(event, item){
      self._closeModal();
    });
    this.modals.el.on("modal:cancel", function(){
      self.actionBar.stopLadda();
    });
  }

  C2ActionBar.prototype._setupFormSubmitModal = function(){
    var self = this,
      events = "attachment_confirm-modal:confirm observer_confirm-modal:confirm";
    this.modals.el.on(events, function(event, item, sourceEl){
      self._submitAndClose(sourceEl);
    });
  }

  C2ActionBar.prototype._submitAndClose = function(sourceEl){
    var self = this;
    $(sourceEl).parent().submit();
    self._closeModal();
  }

  C2ActionBar.prototype._closeModal = function(){
    this.modals.el.trigger("modal:close");
    this.actionBar.stopLadda();
  }
  /* End Action Bar */


  return C2ActionBar;

}());

window.C2ActionBar = C2ActionBar;

