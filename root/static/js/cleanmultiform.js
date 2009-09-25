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
				$('#post1').append( $('<iframe style="height:225px;width:520px" src="http://google.com" name="iframe" />') );
				$button.parents( "form" ).attr('target', 'iframe');
				$button.click();
				$(this).css('background-color','LightGreen');
				return false;
			})
		)
	});
});
