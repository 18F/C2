 describe('Cart', function() {
    it('Should have 3 items', function() {
        var cart = new Cart();
        for (var i = 0; i < 3; i++) {
            cart.add(new CartItem());
        }
        expect(cart.length).toEqual(3);
    });

    it('Should have no items after being cleared', function() {
        var cart = new Cart();
        for (var i = 0; i < 3; i++) {
            cart.add(new CartItem());
        }
        cart.clear();
        expect(cart.length).toEqual(0);
    });
 });