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

				// Only the first forum is editable, so we must copy those fields edited here, prior to the submit.
				$button.parents( "form" ).find('.title').attr( 'value', $("#title1").attr('value') );
				$button.parents( "form" ).find('.price').attr( 'value', $("#price1").attr('value') );
				$button.parents( "form" ).find('.location').attr( 'value', $("#location1").attr('value') );
				$button.parents( "form" ).find('textarea.description').html( $("#description1").html() );;
				alert( $("#description1").val() );
				return false;

				$button.click();
				$(this).css('background-color','LightGreen');
				return false;
			})
		)
	});
});
