var setUpClickEvents = function() {
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

var keyEvents = function () {
	if ( $('.logo').hasClass('sidebar') ) {
		$(document).keyup(function(e) {
		  if (e.keyCode == 27) { $('#goHome').click() }   // esc
		});
	} else {
		$(document).keyup(function(e){});
	}
}

// New Blog Calling
$('#showBlog').on('click', function (e) {
	e.preventDefault();
	window.history.pushState({}, "", '/blog');
	if ( $('.logo').hasClass('sidebar') ){
		$('.content').fadeOut(500, function(){
			$.get('/api/blog', function (data){
				$('.content').html(data).fadeIn(500);
				$('.ad').empty().html('<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>\n<!-- January 2015 PYC -->\n<ins class="adsbygoogle"\nstyle="display:block"\ndata-ad-client="ca-pub-7928191738919617"\ndata-ad-slot="6637017281"\ndata-ad-format="auto"></ins>\n<script>\n(adsbygoogle = window.adsbygoogle || []).push({});\n</script>\n');
				setUpClickEvents();
				keyEvents();
			});
		});
	} else {
		$('#goHome').fadeIn(1000);
		$('.logo').addClass('sidebar');
		$.get('/api/blog', function (data){
			$('.content').html(data).delay(1000).fadeIn(1000);
			$('.ad').empty().html('<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>\n<!-- January 2015 PYC -->\n<ins class="adsbygoogle"\nstyle="display:block"\ndata-ad-client="ca-pub-7928191738919617"\ndata-ad-slot="6637017281"\ndata-ad-format="auto"></ins>\n<script>\n(adsbygoogle = window.adsbygoogle || []).push({});\n</script>\n');
			setUpClickEvents();
			keyEvents();
		})
	}
});

$('#showAbout').on('click', function(e){
	e.preventDefault();
	window.history.pushState({}, "", '/about');
	if ( $('.logo').hasClass('sidebar') ) {
		$('.content').fadeOut(500, function(){
			$.get('/api/about', function (data){
				$('.content').html(data).fadeIn(500);
				$('.ad').empty().html('<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>\n<!-- January 2015 PYC -->\n<ins class="adsbygoogle"\nstyle="display:block"\ndata-ad-client="ca-pub-7928191738919617"\ndata-ad-slot="6637017281"\ndata-ad-format="auto"></ins>\n<script>\n(adsbygoogle = window.adsbygoogle || []).push({});\n</script>\n');
				keyEvents();
			});
		});
	} else {
		$('#goHome').fadeIn(1000);
		$('.logo').addClass('sidebar');
		$.get('/api/about', function (data){
			$('.content').html(data).delay(1000).fadeIn(1000);
			$('.ad').empty().html('<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>\n<!-- January 2015 PYC -->\n<ins class="adsbygoogle"\nstyle="display:block"\ndata-ad-client="ca-pub-7928191738919617"\ndata-ad-slot="6637017281"\ndata-ad-format="auto"></ins>\n<script>\n(adsbygoogle = window.adsbygoogle || []).push({});\n</script>\n');
			keyEvents();
		});
	}
});

$('#showMelk').on('click', function (e){
	e.preventDefault();
	window.history.pushState({}, "", '/melk');
	if ( $('.logo').hasClass('sidebar') ) {
		$('.content').fadeOut(500, function(){
			$.get('/api/melk', function (data){
				$('.content').html(data).fadeIn(500);
				$('.ad').empty().html('<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>\n<!-- January 2015 PYC -->\n<ins class="adsbygoogle"\nstyle="display:block"\ndata-ad-client="ca-pub-7928191738919617"\ndata-ad-slot="6637017281"\ndata-ad-format="auto"></ins>\n<script>\n(adsbygoogle = window.adsbygoogle || []).push({});\n</script>\n');
				keyEvents();
			});
		});
	} else {
		$('#goHome').fadeIn(1000);
		$('.logo').addClass('sidebar');
		$.get('/api/melk', function (data){
			$('.content').html(data).delay(1000).fadeIn(1000);
			$('.ad').empty().html('<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>\n<!-- January 2015 PYC -->\n<ins class="adsbygoogle"\nstyle="display:block"\ndata-ad-client="ca-pub-7928191738919617"\ndata-ad-slot="6637017281"\ndata-ad-format="auto"></ins>\n<script>\n(adsbygoogle = window.adsbygoogle || []).push({});\n</script>\n');
			keyEvents();
		});
	}
})

$('#goHome').on('click', function (e) {
	e.preventDefault();
	window.history.pushState({}, "", '/')
	$('#goHome, .content').fadeOut(500, function(){
		$('.content').html('');
		$('.ad').empty();
		$('.logo').removeClass('sidebar');
		keyEvents();
	});
})