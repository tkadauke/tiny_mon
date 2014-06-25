/*!
 * Simple jQuery Equal Heights
 *
 * Copyright (c) 2013 Matt Banks
 * Dual licensed under the MIT and GPL licenses.
 * Uses the same license as jQuery, see:
 * http://docs.jquery.com/License
 *
 * @edited by Jan Renz
 */
(function($) {

    $.fn.equalHeights = function(minWidth) {
        var maxHeight = 0,
            $this = $(this);
        $this.each( function() {
            if (!minWidth || minWidth == 'undefined'){
                minWidth=0;
            }
            $this.css('min-height', '0px');
            if ($(window).innerWidth() <   minWidth){
                maxHeight = '0';
            }else{
                var height = $(this).innerHeight();
                if ( height > maxHeight ) { maxHeight = height; }
            }
        });

        return $this.css('min-height', maxHeight);
    };
    $(document).ready(function(){
        // auto-initialize plugin
        $('[data-equal]').each(function(){
            var $this = $(this),
                target = $this.data('equal');
                minwidth = $this.data('equal-minwidth');
            $this.find(target).equalHeights(minwidth);
        });

    });
    $( document ).ajaxComplete(function() {
        // auto-initialize plugin
        $('[data-equal]').each(function(){
            var $this = $(this),
                target = $this.data('equal');
            minwidth = $this.data('equal-minwidth');
            $this.find(target).equalHeights(minwidth);
        });
    });
    $(window).on("resize", function(){
        $('[data-equal]').each(function(){
            var $this = $(this),
                target = $this.data('equal');
                minwidth = $this.data('equal-minwidth');
            $this.find(target).equalHeights(minwidth);
        });
    });

})(jQuery);