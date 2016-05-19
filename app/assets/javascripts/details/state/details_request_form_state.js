var DetailsRequestFormState;

DetailsRequestFormState = (function(){
  function DetailsRequestFormState(el) {
    this.el = $(el);
    this._setup();
    return this;
  }
  
  DetailsRequestFormState.prototype._setup = function(){ 
    this.form = this.el.dirrty();
    this._events();
  }

  DetailsRequestFormState.prototype._events = function(){ 
    var el = this.el;
    this.form.on("dirty", function(e){
      el.trigger("form:dirty"); 
    });
    this.form.on("clean", function(e){
      el.trigger("form:clean"); 
    });
  }

  return DetailsRequestFormState;

}());

window.DetailsRequestFormState = DetailsRequestFormState;
