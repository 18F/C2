var C2;
C2 = (function() {
  
  function C2(){
    this._blastOff();
  }

  C2.prototype._blastOff = function(){
    this.attachmentCardController = new AttachmentCardController(".card-for-attachments");
  }
 
  return C2;

})();

window.C2 = C2;
