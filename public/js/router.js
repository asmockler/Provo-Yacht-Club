$(document).ready(function(){
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

	switch (window.location.pathname) {
		case '/':
			console.log("This is the home page!");
			break;
		case '/about':
			loadAbout();
			break;
		case '/blog':
			loadBlog();
			break;
	}	
})
