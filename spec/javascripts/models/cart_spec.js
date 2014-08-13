describe('CartItem', function() {
  it('should set default values', function() {
    var cartItem = new CartItem();
    expect(cartItem.get('price')).toEqual(0);
    expect(cartItem.get('title')).toEqual('');
    expect(cartItem.get('itemurl')).toEqual('');
    expect(cartItem.get('imageUrl')).toEqual('');
    expect(cartItem.get('quantity')).toEqual(0);
    expect(cartItem.get('vendor')).toEqual('');
  });
});