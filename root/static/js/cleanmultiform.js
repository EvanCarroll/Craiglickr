$(document).ready(function(){
	$('.posting').css('display','none');

	$('.email.confirm').attr('readonly', 'readonly');
	$('.email.confirm').css('display', 'none');
	
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
				var $form = $button.parents("form");
				$form.find('input.title').val( $("#title1").attr('value') );
				$form.find('input.price').val( $("#price1").attr('value') );
				$form.find('input.email').val( $("#email1").attr('value') );
				$form.find('input.location').val( $("#location1").attr('value') );
				$form.find('textarea.description').val( CKEDITOR.instances.description1.getData() );

				$button.click();
				$(this).css('background-color','LightGreen');
				return false;
			})
		)
	});
});
