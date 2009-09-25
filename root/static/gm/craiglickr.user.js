// ==UserScript==
// @name          Craiglickr - TOU Auto-Accept
// @namespace     http://www.evancarroll.com
// @description   Automagically accepts Craiglist - TOS
// @include       https://post.craigslist.org/*
// ==/UserScript==

// CODE BASED FROM http://joanpiedra.com/jquery/greasemonkey/
// MIT LICENSE
// Add jQuery
var GM_JQ = document.createElement('script');
GM_JQ.src = 'http://jquery.com/src/jquery-latest.js';
GM_JQ.type = 'text/javascript';
document.getElementsByTagName('head')[0].appendChild(GM_JQ);

// Check if jQuery's loaded
function GM_wait() {
	if(typeof unsafeWindow.jQuery == 'undefined') { window.setTimeout(GM_wait,100); }
	else { $ = unsafeWindow.jQuery; letsJQuery(); }
}
GM_wait();

// All your GM code must be inside this function
function letsJQuery() {
	if ( $("input[name*=recaptcha]").size() == 0 ) {
		var $button = $(":submit[value=ACCEPT the terms of use],:submit[value=Continue]");
		$button.click();
	}
	else {
		$("table[id=header]").remove();
		$("hr").remove();
	}
}
// END

