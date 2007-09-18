Village.Search = {
    highlight: function(searchTerms) {
        function wrapTerms(match) {
            return "<span class='search-highlight'>" + match + "</span>";
        }
        
        var haikuLines = YAHOO.util.Dom.getElementsByClassName('haiku-line');
        re = new RegExp(searchTerms, 'gi');
        for (var i = 0; i < haikuLines.length; i++) {
            haikuLines[i].innerHTML = haikuLines[i].innerHTML.replace(re, wrapTerms);
        }
        
        var searchHighlights = YAHOO.util.Dom.getElementsByClassName('search-highlight');
        for (var i = 0; i < searchHighlights.length; i++) {
            var anim = new YAHOO.util.ColorAnim(searchHighlights[i],
                {backgroundColor: { from: '#77db08', to: '#fff' }}, 1, YAHOO.util.Easing.easeOut);
    		anim.animate();     
        }
    }
}