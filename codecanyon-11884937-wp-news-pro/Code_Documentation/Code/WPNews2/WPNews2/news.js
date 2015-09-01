/* News.js version 2.0, 10.05.2015 mactechinteractiv */

var News = {
    transformFontSize: function(f) {
        var $target = $("div.content");
        var fontSize = parseInt($target.css("font-size"));
        var newFontSize = f(fontSize);
        $target.css("font-size", newFontSize);
    },
    textUp: function() {
        this.transformFontSize(function(x) {
            return x + 5;
        });
    },
    textDown: function() {
        this.transformFontSize(function(x) {
            if (0 < x - 5) {
                return x - 5;
            } else {
                return x;
            }
        });
    }
};

News.loadPage = function(pageInfo) {
    var container = $('#article');
    try {
        var t = _.template(document.getElementById("template").innerText);
        container.html(t(pageInfo));
    } catch (e) {
        alert("Error in template: " + e.name + "; " + e.message);
    }

    $.fn.fixLinks = function(attr) {
        return this.each(function() {
            var url = $(this).attr(attr);
            if (pageInfo.baseURL) {
                if (url && url.indexOf("/") == 0) {
                    $(this).attr(attr, pageInfo.baseURL + url);
                }
            }
        });
    };
    
    container.find("div[style]").each(function(idx, div) {
        div.removeAttribute("style");
    });
    
    var fixIframeWidth = function(el) {
        
        $(el).attr("width", "100%").attr("height", 300);
    };
    
    container.find("iframe").each(function(idx, iframe) {
                                  fixIframeWidth(iframe);
                                  var src = $(iframe).attr("src");
                                  $(iframe).attr("src", src + "?showinfo=0;controls=1");
                                  });
    
    $(window).on("resize", function(e) {
                 $("iframe").each(function(idx, iframe) {
                                  fixIframeWidth(iframe);
                                  });
                 });
}

// End
