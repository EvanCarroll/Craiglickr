$(document).ready(function(){
	$('.posting').css('display','none');
	$('.formFooter').css('display','none');
	
	$('#post1').css('display','inherit').after( $('<div id="controller">') );
	$(":submit").each(function(){
		var $button = $(this);
		$('#controller').append(
			$('<button />')
			.text( 'post: ' + $button.attr('alt') )
			.click(function() {
				if ( $('iframe[name=easyReCaptcha]').size() == 0 ) {
					$('#controller')
						.append(
							$('<iframe style="height:210px;width:420px;border:0" src="http://google.com" name="easyReCaptcha" />')
						)
					;
				}
				
				$button.parents( "form" ).attr('target', 'easyReCaptcha');
				$button.click();
				$(this).css('background-color','LightGreen');
				return false;
			})
		)
	});
});
