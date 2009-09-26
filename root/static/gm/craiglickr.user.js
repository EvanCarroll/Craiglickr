// ==UserScript==
// @name          Craiglickr - TOU Auto-Accept
// @namespace     http://www.evancarroll.com
// @description   Automagically accepts Craiglist - TOU, Crops out header in reCaptcha, and clicks continue if all form elements are filled out on post.
// @version       0.0.1
// @author        Evan Carroll
// @license       CC-BY-SA v3 http://creativecommons.org/licenses/by-sa/3.0/
// @include       https://post.craigslist.org/*
// @require       http://code.jquery.com/jquery-latest.js
// ==/UserScript==

// Official TOU can be found at the following address (2009-09-25)
// http://www.craigslist.org/about/terms.of.use

(function() {
	
	// Recaptcha stansa should be first, because it also uses continue button
	if ( $("input[name*=recaptcha]").size() > 0 ) {
		$("*").css('margin', 0).css('padding', 0);
		$("body").css('font-size', '.7em').css('padding','5px');
		$("input").css('font-size', '2em').css('padding','2px');
		$("table[id=header]").remove();
		$("hr").remove();
	}

	// POSTING PAGE
	else if ( $(":submit[value=Continue]").size() == 1 ) {

		// skip if all the good stuff isn't there that we want.
		if (
			$("input[tabindex=1][type=text]").filter(
				function () { return ( $(this).attr('value') && $(this).attr('value').size() > 0 ? false : true ); }
			).size() == 0
		) {
			$(":submit[value=Continue]").click();			
		}
		else {
			alert('not all filled out');
		}
	
	}

	// TOU/TOS Page
	// Not 100% sure, but I think registered users have the TOU acceptance cached.
	else if ( $(":submit[value=ACCEPT the terms of use]").size() == 1 ) {
	
		// only if the TOU has been accepted before, accept now.
		if ( GM_getValue( 'touAccepted', false ) ) {
			$(":submit[value=ACCEPT the terms of use]").click();
		}
		else {
			// set it on first click.
			$(":submit[value=ACCEPT the terms of use]").click(
				function() {
					alert('Craiglickr will now perminantly cache your acceptance to the Craiglist TOU');
					GM_setValue( 'touAccepted', true ) }
			);
		}
	}


}());
// END

