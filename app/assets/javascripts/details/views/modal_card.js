var ModalController;

ModalController = (function(){

  function ModalController(el, opts){
    this.el = $(el);
    this.data = {
      id: 1,
      modal: {
        cancel: ".cancel-modal-content",
        after_cancel: ".after-cancel-modal-content",
        save_confirm: ".save_confirm-modal-content",
        attachment_confirm: ".attachment-modal-content",
        observer_confirm: ".observer-modal-content"
      }
    }
    this._setup(el, opts);
    return this;
  }

  ModalController.prototype._setup = function(el, opts){
    console.log("modalController: _setup");
    $.extend(this, opts);
    this._initTriggers();
  }

  ModalController.prototype._initTriggers = function(){
    console.log("modalController: _initTriggers");
    var self = this;
    $('html').on('click','[data-modal-type]',function(e){
      self._prepModal();
    });
    this.el.on("modal:close", function(){
      self._closeModal();
    });
  }

  ModalController.prototype._prepModal = function(e){
    var self = this;
    self.sourceEl = this;
    var preventDefault = $(self.sourceEl).attr('data-modal-default') !== "true";
    if(preventDefault){
      e.preventDefault();
    }
    var modalType = $(self.sourceEl).attr('data-modal-type');
    self.create(modalType);
  }

  ModalController.prototype._modalEvents = function(el, modalType){
    console.log("modalController: _modalEvents");
    this._undoButtonSetup(el);
    this._buttonDependence(el);
    this._createCustomEvents(el, modalType);
  }

  ModalController.prototype._createCustomEvents = function(el, modalType){
    console.log("modalController: _createCustomEvents");
    var self = this;
    $(el).find('[data-modal-event]').each(function(i, item){
      var event = $(item).attr('data-modal-event');
      $(item).on('click', function(){
        var eventName = modalType + '-modal:' + event;
        self.el.trigger(eventName, [item, self.sourceEl]);
      });
    });
  }

  ModalController.prototype._buttonDependence = function(el){
    console.log("modalController: _buttonDependence");
    checkRequiredForSubmit();
  }

  ModalController.prototype._undoButtonSetup = function(el){
    console.log("modalController: _undoButtonSetup");
    var self = this;
    $(el).find('.cancel-cancel-link').on('click', function(){
      self._closeModal();
      return false;
    })
  }

  ModalController.prototype.clear = function(){
    console.log("modalController: clear");
    $('#modal-wrapper').html("");
  }

  ModalController.prototype.getId = function(){
    console.log("modalController: getId");
    var id = this.data.id;
    this.data.id = this.data.id + 1;
    return id;
  }

  ModalController.prototype._closeModal = function(){
    console.log("modalController: _closeModal");
    var self = this;
    this.el.trigger('modal:cancel');
    $('#modal-wrapper').addClass('animated fadeOut');
    $('#modal-wrapper').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
      $('#modal-wrapper').removeClass('visible');
      self.clear();
      $('#modal-wrapper').removeClass('animated fadeOut');
    });
  }

  ModalController.prototype._animate = function(){
    console.log("modalController: _animate");
    $('#modal-wrapper').addClass('animated fadeIn');
    $('#modal-wrapper').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
      $('#modal-wrapper').removeClass('animated fadeIn');
    });
  }

  ModalController.prototype._setupModal = function(modalType){
    console.log("modalController: _setupModal");
    var selector = this.data.modal[modalType];
    var content = $(selector).clone() || false;
    var id = this.getId();
    var modal = $('#modal-template').clone().attr('id', "modal-el-" + id).removeClass('modal-template');
    modal.find('.additional-content').html(content);
    return modal;
  }

  ModalController.prototype.create = function(modalType){
    console.log("modalController: create");
    this.clear();
    var modal = this._setupModal(modalType);
    $('#modal-wrapper').append(modal);
    this._modalEvents(modal, modalType);
    this._animate();
    $('#modal-wrapper').addClass('visible');
    this._focus();
  }

  ModalController.prototype._focus = function(){
    console.log("modalController: _focus");
    $('#modal-wrapper .popup-content').focus();
  }

  return ModalController
}());

window.ModalController = ModalController;
