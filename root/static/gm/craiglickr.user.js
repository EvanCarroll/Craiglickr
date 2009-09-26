// ==UserScript==
// @name          Craiglickr - TOU Auto-Accept
// @namespace     http://www.evancarroll.com
// @description   Automagically accepts Craiglist - TOU
// @include       https://post.craigslist.org/*
// ==/UserScript==

// Official TOU can be found at the following address (2009-09-25)
// http://www.craigslist.org/about/terms.of.use

// CODE BASED ON MIT LICENSED EXAMPLE CODE FROM http://joanpiedra.com/jquery/greasemonkey
// COPYRIGHT Evan Carroll http://www.evancarroll.com
// CODE RELEASED UNDER CC-BY-SA 3.0
// http://creativecommons.org/licenses/by-sa/3.0/

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

