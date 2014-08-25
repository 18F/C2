function scrapePage(jQ) {
    var ourServer = window.overlayloc + '/';//"http://localhost:3000/"
    console.log("ourServer", ourServer);
    loadOGP(jQ);
    $ = jQ;

    var cartItem = {};
    cartItem.url = window.location.href;

    //determine best descriptors from page
    //try open graph data
    var ogData = $('head').ogp();

    if (ogData.hasOwnProperty("price:amount")) {
        cartItem.price = convertDollar(ogData["price:amount"][0]);
    } else {
        //this should be refactored a touch.

        //for staples
        var price = $("[name='p_1']").val();
        if (price) {
            cartItem.price = (convertDollar(price.trim()));
        } else  {
            //Crate & Barrel etc
            price = $("[class*='price']").html();
            if (price) {
                cartItem.price = (convertDollar(price.trim()));
            }
        }
    }

    if (ogData.hasOwnProperty("title")) {
        cartItem.title = ogData["title"][0];
    } else {
        cartItem.title = document.title;
    }

    if (ogData.hasOwnProperty("url")) {
       cartItem.itemUrl = ogData["url"][0];
    } else {
       cartItem.itemUrl = $(location).attr('href');
    }

    //TODO: what if og:image isn't spec'd?
    if (ogData.hasOwnProperty("image")) {
        cartItem.imageUrl =  ogData["image"][0];
    }

    if (ogData.hasOwnProperty("site_name")) {
      cartItem.vendor = ogData["site_name"][0];
    } else {
      var s = document.domain;
      cartItem.vendor = s;
    }

    for (var i in cartItem) {
        console.log(i + " = " + cartItem[i]);
    }

    $("head").append("<link rel='stylesheet' href='"+ourServer+"assets/overlay.css' type='text/css' media='screen'>");

    var qStr = $.param(cartItem);
    var iframeURL = ourServer+"overlay?v="+qStr;
    console.log("iframe URL= " + iframeURL);

    //do awkward bookmarklet panel insertion
    var div = document.createElement("div");
    div.id = "communicart_bookmarklet";
    $('#communicart_bookmarklet').height(175);
    document.body.insertBefore(div, document.body.firstChild);
    $('#communicart_bookmarklet').html("<iframe frameborder='0' scrolling='no' name='instacalc_bookmarklet_iframe' id='instacalc_bookmarklet_iframe' src='" +
        iframeURL + "' width='600px' height='600px' style='textalign:right;'></iframe>");

     //handle communication from bookmarklet
     window.addEventListener("message", function (e) {
        //  console.log("message: " + e.data);
         if (e.data == "closeOverlay") {
           $('#communicart_bookmarklet').remove();
         }
     });
}

function closeOverlay() {
    $('#communicart_booklet').remove();
}

function convertDollar(dollarsAndCentsString) {
    // Cast the value passed in to a string in case a number was passed in.
    dollarsAndCentsString = dollarsAndCentsString.toString();
    // First, discard the '$' glyph, if it was passed in.
    if (dollarsAndCentsString.split('$').length == 2)
        dollarsAndCentsString = dollarsAndCentsString.split('$')[1];
    // If the user delimmited the groups of digits with commas, remove them.
    dollarsAndCentsString = dollarsAndCentsString.replace(/,/g, '');
    // Next, divide the resulting string in to dollars and cents.
    var hasDecimal = (dollarsAndCentsString.split('.')).length == 2;
    var dollarsString, centsString;
    dollarsString = dollarsAndCentsString.split('.')[0];
    var centsString = hasDecimal ? dollarsAndCentsString.split('.')[1] : '0';
    var dollars = parseInt(dollarsString, 10);
    var cents;
    if (centsString.length == 1)
        cents = parseInt(centsString, 10) * 10;
    else cents = parseInt(centsString, 10);
    if (cents > 99 || isNaN(cents) || isNaN(dollars) || !isFinite(dollars) || !isFinite(cents))
        return 0;
    var totalCents = dollars * 100 + cents;
    var amount = totalCents /100.00
    return amount;
}

var loadOGP = function($) {

    $.fn.ogp = function() {
        var ns = null, data = {};
        $(this).each(function () {

            ns = "og:";
            $('meta', this).each(function () {
                console.log("Looking for data in element", this);
                var prop = $(this).attr("property"), key, value;
                if (prop && prop.substring(0, ns.length) === ns) {
                    key = prop.substring(ns.length);
                    value = $(this).attr("content");
                    console.log("Found OGP data %s=%s", key, value);
                    data[key] = data[key] || [];
                    data[key].push(value);
                }
            });
        });

        // this is the total of everything
        console.log("All the data is ", data);

        return data;
    }
};//(jQuery);
