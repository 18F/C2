describe('CartItem', function() {
  it('should set default values', function() {
    var cartItem = new CartItem();
    expect(cartItem.get('price')).toEqual(0.00);
    expect(cartItem.get('title')).toEqual('');
    expect(cartItem.get('itemurl')).toEqual('');
    expect(cartItem.get('imageUrl')).toEqual('');
    expect(cartItem.get('quantity')).toEqual(0);
    expect(cartItem.get('vendor')).toEqual('');
    expect(cartItem.get('subtotal')).toEqual('0.00');
  });

  it('should not be valid', function(){
    var cartItem = new CartItem();
      expect(cartItem.isValid()).toBeFalsy();
  });

  it('should have subtotal of 33', function() {
      var cartItem = new CartItem();
      cartItem.set({price: 11.00, quantity: 3});
      expect(cartItem.get('subtotal')).toEqual('33.00');
  });
});