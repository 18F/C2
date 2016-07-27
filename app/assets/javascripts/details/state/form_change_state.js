var FormChangeState;

FormChangeState = (function(){
  function FormChangeState(el) {
    this.el = $(el).find('form.request-details-form');
    this._setup();
    return this;
  }

  FormChangeState.prototype._setup = function(){
    this.initDirrty();
    this._events();
  }

  FormChangeState.prototype.initDirrty = function(){
    this.form = this.el.dirrty();
    $('[data-is-dirrty]').attr('data-is-dirrty', 'false');
  }

  FormChangeState.prototype._events = function(){
    var el = this.el;
    this.form.on("dirty", function(e){
      el.trigger("form:dirty");
    });
    this.form.on("clean", function(e){
      el.trigger("form:clean");
    });
  }

  return FormChangeState;

}());

window.FormChangeState = FormChangeState;
