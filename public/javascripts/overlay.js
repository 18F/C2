/**
 * Created by alexandermagee on 7/25/14.
 */

var CartItem = Backbone.Model.extend({
  defaults: {
    price: 0,
    title: "",
    itemurl: "",
    imageUrl: "",
    quantity: 0,
    vendor: ""
  },
  validate : function(attrs) {
    if (attrs.price == 0) {
      return "item must have a price!"
    }
  },
  initialize: function() {
    //put event code here.
  }
});

var CartItemView = Backbone.View.extend({
    tagName: 'tr',
//    el: '#itemList',
    events: {
        "click .deleter" : "deleteme"
    },
//    cartTpl: _.template($('#cartitem-template').html()),
    render: function() {
        this.$el.html(this.cartTpl(this.model.attributes));
        return this;
    },
    initialize: function() {
//        this.$el = $('#itemList');
        this.cartTpl = _.template($('#cartitem-template').html());
        this.listenTo(this.model, 'change', this.render);
        this.listenTo(this.model, 'destroy', this.remove);
    },
//
//    syncRemove: function() {
//        var col = this.model.collection;
//        col.sync('delete', this.model, {success: function(rez) {console.log(rez);}});
//        col.remove(this.model);
//        this.remove();
//    },

    deleteme : function(e) {
        e.preventDefault();
        var col = this.model.collection;
        col.sync('delete', this.model, {success: function(rez) {console.log(rez);}});
        col.remove(this.model);
    }
});

var Cart = Backbone.Collection.extend({
    model: CartItem,
    localStorage: new Store("communicart"),
    clear: function(p_handler) {
        var tHandler = function(rez) {console.log(rez);};
        p_handler = p_handler || tHandler;
        var num = this.length;
        while (this.length) {//this.each(function(item){
            var item = this.at(0);
            this.sync('delete', item, {success: ((--num) ?  tHandler : p_handler)});
            this.remove(item);
        };//, this);

    }
});

var CartView = Backbone.View.extend({
    model: Cart,

    initialize: function () {
        _.bindAll(this, "render");
        this.listenTo(this.model, "remove", this.render);

    },
    render: function() {
        this.$el  = $('#itemList');
        this.$el.empty();
        this.model.each( function(item) {
            var iview = new CartItemView({model: item});
            var ir = iview.render().el;
            this.$el.append(iview.render().el);
        }, this);
    }
})

var items = new Cart();
var itemView = new CartView({model: items});

//initialization
setTimeout(function(){
    var qs = (function(a) {
        if (a == "") return {};
        var b = {};
        for (var i = 0; i < a.length; ++i)
        {
            var p=a[i].split('=');
            if (p.length != 2) continue;
            b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "));
        }
        return b;
    })(window.location.search.substr(1).split('&'));
    //fill in form
    if (qs.hasOwnProperty("price")) {
        var price = parseFloat(qs.price);
        price = price ? price.toFixed(2) : "";
        $('#itemprice').val(price);
    }
    if (qs.hasOwnProperty("title")) {
        $('#itemname').val(qs.title);
    }
    $('#itemquantity').val(1);
    if (qs.hasOwnProperty("imageUrl")) {
        loadProdImage(qs.imageUrl);
    }

    //Buttons
    $('#cancel_btn').click(function() {
        closeOverlay();
    });

    $('#add_btn').click(function() {
      if (doValidate()) {
        addCartItem($('#itemname').val(), qs.itemUrl, qs.imageUrl,
          $('#itemprice').val(), $('#itemquantity').val(), qs.vendor);
        switchToCart();
      }
    });

    $('#goto_btn').click(function() {
        switchToCart();
    });

    $('#send_btn').click(function() {
      //do some stuff here to send cart
      sendCart();
      items.clear(closeOverlay);
    });

    $('#shop_btn').click(function(){
      closeOverlay();
    });
    $('#clear_btn').click(function() {
        items.clear(closeOverlay);
    });

}, 200);

function readCart(pCLearFirst) {
  if (typeof pClearFirst != "undefined" && pClearFirst) {
      items = [];
  }
  var j = 0;
  while (true) {
    var item = localStorage.getItem("cartItem_"+j);
    if (item != null && j < 10) {
//      items.push(JSON.parse(item));
        items.add(JSON.parse(item));
    } else {
      break;
    }
    j++;
  }
}

function clearCart() {
//  for (var i = 0; i < items.length; i++) {
//    localStorage.removeItem("cartItem_"+i);
//  }
    items.each()
//    items.sync("delete", items);
}

function saveCart() {
  for (var i = 0; i < items.length; i++) {
    localStorage.setItem("cartItem_" +i, JSON.stringify(items[i]));
  }
}

function closeOverlay() {
  window.parent.postMessage("closeOverlay", "*");
}

function loadProdImage(imageurl) {
    var newImg = new Image();

    newImg.onload = function() {
        var height = newImg.height;
        var width = newImg.width;
        if (height > width) {
            $('#prod_pic').height(160);
            $('#prod_pic').width(160/height * width);
        } else {
            $('#prod_pic').width(160);
            $('#prod_pic').height(160/width * height);
        }
        $('#prod_pic').attr('src', imageurl);
    }

    newImg.src = imageurl;

}

function addCartItem(title, itemUrl, imageUrl, price, quantity, vendor) {
    var item = new CartItem({title: title, itemurl: itemUrl, imageUrl: imageUrl, price: price, quantity: quantity, vendor: vendor});
    items.add(item);
    item.save();
}

function displayCart() {
    $("#itemList").empty();
    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      $("#itemList").append("<tr id='itemrow_"+i+"'><td><a href='"+item.itemurl+"' target='_blank' class='itemlistname'>" + item.title +
        "</a></td><td class='itemlistprice'>$" + item.price +"</td><td>" + item.quantity +
        "</td><td><a class='deleter' id='del_" + i +"'>remove</a><td></tr>");
    }
    $('.deleter').click(function() {
      var itemNum = parseInt($(this).attr("id").split("_")[1]);
      clearCart();
      items.splice(itemNum, 1);
      saveCart();
      displayCart();
    });
}

function switchToCart() {
  $('#formscreen').hide();
  $('#cartscreen').show();
//  displayCart();
    items.fetch();
    itemView.render();
}

function doValidate() {
  if ($('#itemprice').val() == "") {
    $('#priceError').show();
    return false;
  } else {
    $('#priceError').hide();
  }
  //add more conditions here
  return true;
}

function sendCart() {
  var cartdata = {};
  if ($('#cartName').val() != "") {
    cartdata["cartName"] = $('#cartName').val();
  }
  cartdata["cartNumber"] = Math.floor(Math.random() * 1000000) + 300000;
  if ($('#approvalgroup_input').val() != "") {
    cartdata["approvalGroup"] = $('#approvalgroup_input').val();
  }
  cartdata["cartItems"] = [];
  items.each(function (item) {
    var tItem = {};
    tItem.url = item.get("itemurl");
    tItem.imageUrl = item.get("imageUrl");
    tItem.vendor = item.get("vendor");
    tItem.details = item.get("description");
    tItem.description = item.get("title");
    tItem.qty = item.get("quantity");
    tItem.price = item.get("price");
    //notes & partNumber?
    cartdata["cartItems"].push(tItem);
  });
  $.ajax({
      type : "POST",
      url: "http://localhost:3000/send_cart",
      dataType: "json",
      contentType: "application/json",
      data: JSON.stringify(cartdata)
  });
}
