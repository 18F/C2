
describe('Simple object', function() {
  it('should say hi', function() {
    var Foo = function() {
      this.sayHi = function(){
        return 'Dude!'
      }
    };

    var foo = new Foo();
    expect(foo.sayHi()).toEqual('Dude!');
  });
});