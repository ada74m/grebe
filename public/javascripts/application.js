$(function() {
	$('table.rows-clickable').each(function(index, table){
		$(table).find('tr').mouseover(function() {
			$(this).addClass('over');
		});
		$(table).find('tr').mouseout(function() {
			$(this).removeClass('over');
		});

		$(table).find('tr').click(function() {
			var a = $(this).find('a')[0];
			var href = $(a).attr('href');
			window.location = href;
		});
	});
	
});