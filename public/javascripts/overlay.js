/**
 * Created by alexandermagee on 7/25/14.
 */

 var items = [];

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
        $('#itemprice').val(parseFloat(qs.price).toFixed(2));
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
      addCartItem($('#itemname').val(), qs.url, qs.imageUrl,
        $('#itemprice').val(), $('#itemquantity').val());
      switchToCart();

    });
}, 200);

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

function addCartItem(title, url, imageUrl, price, quantity) {
    var item = {title: title, url: url, imageUrl: imageUrl, price: price, quantity: quantity};
    items.push(item);
    var itemString = JSON.stringify(item);
    sessionStorage.setItem("cartItem" + items.length - 1, itemString);
}

function displayCart() {
    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      $("#itemList").append("<tr><td><a href='"+item.url+"' target='_blank'>" + item.title +
        "</a></td><td>$" + item.price +"</td><td>" + item.quantity +
        "</td><td><a class='deleter' id='del" + i +"'>remove</a><td></tr>");
    }
}

function switchToCart() {
  $('#formscreen').fadeOut(500);
  $('#cartscreen').fadeIn(500);
  displayCart();
}
