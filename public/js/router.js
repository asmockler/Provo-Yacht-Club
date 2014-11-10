$(document).ready(function(){
	var formatStr = function (str) {
		return str.replace(/\/$/, "");
	}

	var loadAbout = function() {
		$('#goHome').show();
		$.get('/api/about', function (data) {
			$('.content').html(data).show();
		});
	}

	var loadBlog = function() {
		$('#goHome').show();
		$.get('/api/blog', function (data) {
			$('.content').html(data).show();
		});

		$('.load-more-posts').on('click', function(e){
			e.preventDefault();
			var container = $('.blog-post-container');
			var batch = container.attr('data-batch');
			$.get('/api/load_more_blog_posts/' + batch, function(data){
				$('.media').last().append(data);	
				container.attr('data-batch', parseInt(batch)+1);
			});
		});
	}

	switch ( formatStr(window.location.pathname) ) {
		case '/':
			break;
		case '/about':
			loadAbout();
			break;
		case '/blog':
			loadBlog();
			break;
	}

	if ( (window.location.pathname).match(/\/blog\/.+\/.+/) ) {
		console.log('matched')
	}
});

/* TODO
	Listen for history pop and allow back/forward
	Add big play button again (Fay)
*/