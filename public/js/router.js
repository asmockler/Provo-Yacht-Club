$(document).ready(function(){
	var formatStr = function (str) {
		return str.replace(/\/$/, "");
	}

	var loadAbout = function() {
		$('#goHome').show();
		$.get('/api/about', function (data) {
			$('.content').html(data).show();
		})
	}

	var loadBlog = function() {
		$('#goHome').show();
		$.get('/api/blog', function (data) {
			$('.content').html(data).show();
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