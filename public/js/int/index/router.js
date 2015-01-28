$(document).ready(function(){
	var formatStr = function (str) {
		if ( str === '/' ) {
			return '/'
		} else {
			return str.replace(/\/$/, "");
		}
	}

	var keyEvents = function () {
		if ( $('.logo').hasClass('sidebar') ) {
			$(document).keyup(function(e) {
			  if (e.keyCode == 27) { 
			  	loadHome(); 
			  	window.history.pushState({}, "", '/')
		  	  }   // esc
			});
		} else {
			$(document).keyup(function(e){});
		}
	}

	var loadAbout = function(delay, fade) {
		$('#goHome').show();
		$.get('/api/about', function (data) {
			$('.content').delay(delay).html(data).fadeIn(fade);
			keyEvents();
		});
	}

	var loadBlog = function(delay, fade) {
		$('#goHome').show();
		$.get('/api/blog', function (data) {
			$('.content').delay(delay).html(data).fadeIn(fade);
			keyEvents();
			$('.load-more-posts').on('click', function(e){
				e.preventDefault();
				var container = $('.blog-post-container');
				var batch = container.attr('data-batch');
				$.get('/api/load_more_blog_posts/' + batch, function(data){
					$('.media').last().append(data);	
					container.attr('data-batch', parseInt(batch)+1);
				});
			});
		});
	}

	var loadMelk = function(delay, fade) {
		$('#goHome').show();
		$.get('/api/melk', function (data){
			$('.content').delay(delay).html(data).fadeIn(fade);
			keyEvents();
		});
	}

	var loadHome = function() {
		$('#goHome').fadeOut(500);
		$('.content').fadeOut(500, function(){
			$(this).html('');
			$('.logo').removeClass('sidebar');
			keyEvents();
		});
	}

	switch ( formatStr(window.location.pathname) ) {
		case '/':
			break;
		case '/about':
			loadAbout(0,0);
			break;
		case '/blog':
			loadBlog(0,0);
			break;
		case '/melk':
			loadMelk(0,0);
			break;
	}

	if ( (window.location.pathname).match(/\/blog\/.+/) ) {
		var slug = (window.location.pathname).substr(6); // 6 is the number of characters to get what comes after "/blog/"
		$('#goHome').show();
		$.get('/api/blog/' + slug, function (data) {
			$('.content').html(data).show();
			keyEvents();
			$('.load-more-posts').html('Return to Blog').on('click', function (e) {
				e.preventDefault();
				$('.content').fadeOut(500, function() {
					loadBlog(500, 500);
					window.history.pushState({}, "", '/blog');
				});
			});
		});
	}

	window.addEventListener("popstate", function(e) {
	    switch ( formatStr(window.location.pathname) ) {
	    	case '/':
	    		loadHome();
	    		break;
	    	case '/about':
	    		$('.logo').addClass('sidebar');
	    		loadAbout(500, 500);
	    		break;
	    	case '/blog':
	    		$('.logo').addClass('sidebar');
	    		loadBlog(500, 500);
	    		break;
    		case '/melk':
    			$('.logo').addClass('sidebar');
    			loadMelk(500,500);
    			break;
	    }
	});
});

/* TODO
	Listen for history pop and allow back/forward
	Add big play button again (Fay)
*/