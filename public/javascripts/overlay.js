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
      clearCart();
      closeOverlay();
    });

    $('#shop_btn').click(function(){
      closeOverlay();
    });
    readCart(false);
    $('#clear_btn').click(function() {
        clearCart();
        closeOverlay();
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
    var item = {title: title, url: itemUrl, imageUrl: imageUrl, price: price, quantity: quantity, vendor: vendor};
    items.push(item);
    var itemString = JSON.stringify(item);
    localStorage.setItem("cartItem_" + (items.length - 1), itemString);
}

function displayCart() {
    $("#itemList").empty();
    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      $("#itemList").append("<tr id='itemrow_"+i+"'><td><a href='"+item.url+"' target='_blank'>" + item.title +
        "</a></td><td>$" + item.price +"</td><td>" + item.quantity +
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

function sendCart() {
  var cartdata = {};
  if ($('#cartName').val() != "") {
    cartdata["cartName"] = $('#cartName').val();
  }
  cartdata["cartNumber"] = Math.floor(Math.random() * 1000000) + 300000;
  cartdata["cartItems"] = [];
  for (var i = 0; i < items.length; i++) {
    var tItem = items[i];
    tItem.details = tItem.description;
    tItem.description = tItem.title;
    tItem.qty = tItem.quantity;
    //notes & partNumber?
    cartdata["cartItems"].push(tItem);
  }
  $.ajax({
      type : "POST",
      url: "http://localhost:3000/send_cart",
      dataType: "json",
      contentType: "application/json",
      data: JSON.stringify(cartdata)
  });
}
