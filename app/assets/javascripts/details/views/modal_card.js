var ModalController;

ModalController = (function(){
  
  function ModalController(el, opts){
    this.el = $(el);
    this.data = { 
      id: 1,
      modal: {
        cancel: ".cancel-modal-content",
        save_confirm: ".save_confirm-modal-content"
      }
    }
    this._setup(el, opts);
    return this;
  }

  ModalController.prototype._setup = function(el, opts){
    $.extend(this, opts);
    this._initTriggers();
  }

  ModalController.prototype._initTriggers = function(){
    var self = this;
    $('[data-modal-type]').on('click', function(e){
      var el = this;
      e.preventDefault();
      var modalType = $(el).attr('data-modal-type');
      self.create(modalType);
    });
    this.el.on("modal:close", function(){
      self._closeModal();
    });
  }

  ModalController.prototype._modalEvents = function(el, modalType){
    this._undoButtonSetup(el);
    this._buttonDependence(el);
    this._createCustomEvents(el, modalType);
  }

  ModalController.prototype._createCustomEvents = function(el, modalType){
    var self = this;
    $(el).find('[data-modal-event]').each(function(i, item){
      var event = $(item).attr('data-modal-event');
      $(item).on('click', function(){
        var eventName = modalType + '-modal:' + event;
        self.el.trigger(eventName);
      });
    })
  }

  ModalController.prototype._buttonDependence = function(el){
    checkRequiredForSubmit();
  }

  ModalController.prototype._undoButtonSetup = function(el){
    var self = this;
    $(el).find('.cancel-cancel-link').on('click', function(){
      self._closeModal();
      return false;
    })
  }

  ModalController.prototype.clear = function(){
    $('#modal-wrapper').html("");
  }

  ModalController.prototype.getId = function(){
    var id = this.data.id;
    this.data.id = this.data.id + 1;
    return id;
  }

  ModalController.prototype._closeModal = function(){
    var self = this;
    $('#modal-wrapper').addClass('animated fadeOut');
    $('#modal-wrapper').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
      $('#modal-wrapper').removeClass('visible');
      self.clear();
      $('#modal-wrapper').removeClass('animated fadeOut');
    });
  }

  ModalController.prototype._animate = function(){
    $('#modal-wrapper').addClass('animated fadeIn');
    $('#modal-wrapper').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
      $('#modal-wrapper').removeClass('animated fadeIn');
    });
  }

  ModalController.prototype._setupModal = function(modalType){
    var selector = this.data.modal[modalType];
    var content = $(selector).clone() || false;
    var id = this.getId();
    var modal = $('#modal-template').clone().attr('id', "modal-el-" + id).removeClass('modal-template');
    modal.find('.additional-content').html(content);
    return modal;
  }

  ModalController.prototype.create = function(modalType){
    this.clear();
    var modal = this._setupModal(modalType);
    $('#modal-wrapper').append(modal);
    this._modalEvents(modal, modalType);
    this._animate();
    $('#modal-wrapper').addClass('visible');
  }

  return ModalController
}());

window.ModalController = ModalController;
