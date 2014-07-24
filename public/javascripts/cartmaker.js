/**
 * Created by alexandermagee on 7/23/14.
 */
function scrapePage() {
    var hasTitle;
    var hasPrice = hasTitle = false;
    var cartItem = {};
    cartItem.url = window.location.href;

    //try open graph data
    var ogData = $('head').ogp();
    if (ogData.hasOwnProperty("price:amount")) {
        cartItem.price = convertDollar(ogData["price:amount"][0]);
        hasPrice = true;
    }
    if (ogData.hasOwnProperty("title")) {
        cartItem.title = ogData["title"][0];
        hasTitle = true;
    }
    if (ogData.hasOwnProperty("description")) {
        cartItem.description = ogData["description"][0];
    }
    if (!hasTitle) {
        cartItem.title = document.title;
        hasTitle = true;
    }
    if (!hasPrice) {
        var price = $("[class*='price']").html();
        if (price) {
            cartItem.price = (convertDollar(price.trim()));
            hasPrice = true;
        }
    }
    for (var i in cartItem) {
        console.log(cartItem[i]);
    }
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

/**
 * jQuery plugin to read Open Graph Protocol data from the page
 */

(function($) {

    var checkNamespacePresent = function (node) {
        console.log("Checking for namespace on node", node);
        var i, attr, attributes = node.attributes || {};
        // we're looking for xmlns:og="http://opengraphprotocol.org/schema/"
        for (i = 0; i < attributes.length; i++) {
            attr = attributes[i];
            if (attr.nodeName.substring(0,5) === "xmlns" && (
                attr.nodeValue === "http://opengraphprotocol.org/schema/" || attr.nodeValue === "http://ogp.me/ns#")) {
                return attr.nodeName.substring(6);
            }
        }
        return null;
    }

    $.fn.ogp = function() {
        var ns = null, data = {};
        $(this).each(function () {
            $(this).parents().andSelf().each(function () {
                ns = checkNamespacePresent(this);
                console.log("Found %s on", ns, this);
                if (ns !== null) {
                    return false;
                }
            });

            // give up if no namespace
            if (ns === null) {
                console.log("No namespace found");
                return null;
            }

            // look for OGP data
            ns = ns + ":";
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
})(jQuery);