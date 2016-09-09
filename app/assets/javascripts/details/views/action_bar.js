var ActionBar;

ActionBar = (function() {
  function ActionBar(el) {
    this.el = $(el);
    this._setup();
    return this;
  }

  ActionBar.prototype._setup = function() {
    this._event();
    this.setMode('view');
  };

  ActionBar.prototype._event = function() {
    this.saveButton = this.el.find( '.save-button button' );
    this.saveButton.ladda( 'bind' );
    this.saveButtonLadda = this.saveButton.ladda();
    this._setupActionBarClicked('save');
    this._setupActionBarClicked('cancel');
    this._setupActionBarClicked('edit');
    this._saveTriggered();

    (function($,sr){

      // debouncing function from John Hann
      // http://unscriptable.com/index.php/2009/03/20/debouncing-javascript-methods/
      var debounce = function (func, threshold, execAsap) {
          var timeout;

          return function debounced () {
              var obj = this, args = arguments;
              function delayed () {
                  if (!execAsap)
                      func.apply(obj, args);
                  timeout = null;
              };

              if (timeout)
                  clearTimeout(timeout);
              else if (execAsap)
                  func.apply(obj, args);

              timeout = setTimeout(delayed, threshold || 100);
          };
      }
      // smartresize 
      jQuery.fn[sr] = function(fn){  return fn ? this.bind('resize', debounce(fn)) : this.trigger(sr); };

    })(jQuery,'smartresize');
    
    $(window).smartresize(function(){
      console.log(screen.height < window.innerHeight + 150);
      if(screen.height < window.innerHeight + 200){
        $("body").addClass('near-fullscreen');
      } else {
        $("body").removeClass('near-fullscreen');
      }
    });

  };

  /**
   * .on("action-bar-clicked:save")
   * .on("action-bar-clicked:cancel")
   */
  ActionBar.prototype._setupActionBarClicked = function(buttonName) {
    var self = this;
    this.el.find('.' + buttonName + '-button button').on('click', function(){
      self.el.trigger('action-bar-clicked:' + buttonName);
    });
  }

  ActionBar.prototype._saveTriggered = function(buttonName) {
    var actionBar = this;
    actionBar.el.on('action-bar-clicked:saving', function(){
      actionBar.saveButtonLadda.ladda( 'start' );
    })
    actionBar.el.on('action-bar-clicked:saved', function(){
      actionBar.stopLadda();
      actionBar.setMode('view');
    })
  }

  ActionBar.prototype.stopLadda = function() {
    this.saveButtonLadda.ladda( 'stop' );
  }

  ActionBar.prototype.barState = function(el, state) {
    this.el.find(el + ' button').attr("disabled", state);
  }

  ActionBar.prototype.setMode = function(mode) {
    switch(mode){
      case "view":
        this.barState('.cancel-button', "disabled");
        $('.action-bar-template').removeClass('edit-actions').addClass('view-actions');
        break;
      case "edit":
        this.barState('.cancel-button', false);
        $('.action-bar-template').removeClass('view-actions').addClass('edit-actions');
        break;
    }
  }

  return ActionBar;

}());

window.ActionBar = ActionBar;
