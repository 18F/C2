/**
 * Created by alexandermagee on 7/25/14.
 */

 var items = [];

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
        window.parent.postMessage("closeOverlay", "*");
    });

    $('#add_btn').click(function() {
      if (doValidate()) {
        addCartItem($('#itemname').val(), qs.itemUrl, qs.imageUrl,
          $('#itemprice').val(), $('#itemquantity').val(), qs.vendorName);
        switchToCart();
      }
    });

    $('#send_btn').click(function() {
      //do some stuff here to send cart
      clearCart();
    });

    $('#shop_btn').click(function(){
      window.parent.postMessage("closeOverlay", "*");
    });
    readCart(false);

}, 200);

function readCart(pCLearFirst) {
  if (typeof pClearFirst != "undefined" && pClearFirst) {
      items = [];
  }
  var j = 0;
  while (true) {
    var item = localStorage.getItem("cartItem_"+j);
    if (item != null && j < 10) {
      items.push(JSON.parse(item));
    } else {
      break;
    }
    j++;
  }
}

function clearCart() {
  for (var i = 0; i < items.length; i++) {
    localStorage.removeItem("cartItem_"+i);
  }
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

function addCartItem(title, itemUrl, imageUrl, price, quantity, vendorName) {
    var item = {title: title, itemUrl: itemUrl, imageUrl: imageUrl, price: price, quantity: quantity, vendorName: vendorName};
    items.push(item);
    var itemString = JSON.stringify(item);
    localStorage.setItem("cartItem_" + (items.length - 1), itemString);
}

function displayCart() {
    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      $("#itemList").append("<tr><td><a href='"+item.itemUrl+"' target='_blank'>" + item.title +
        "</a></td><td>$" + item.price +"</td><td>" + item.quantity +
        "</td><td><a class='deleter' id='del" + i +"'>remove</a><td></tr>");
    }
}

function switchToCart() {
  $('#formscreen').hide();
  $('#cartscreen').show();
  displayCart();
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
