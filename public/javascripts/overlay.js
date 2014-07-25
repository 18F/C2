/**
 * Created by alexandermagee on 7/25/14.
 */
setTimeout(function(){
    console.log("timeout");
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
    if (qs.hasOwnProperty("price")) {
        $('#itemprice').val(qs.price);
    }
    if (qs.hasOwnProperty("title")) {
        $('#itemname').val(qs.title);
    }
    $('#itemquantity').val(1);
}, 200);