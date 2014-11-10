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

// New Blog Calling
$('#showBlog').on('click', function (e) {
	e.preventDefault();
	window.history.pushState({}, "", '/blog');
	if ( $('.logo').hasClass('sidebar') ){
		$('.content').fadeOut(500, function(){
			$.get('/api/blog', function (data){
				$('.content').html(data).fadeIn(500);
				setUpClickEvents();
			});
		});
	} else {
		$('#goHome').fadeIn(1000);
		$('.logo').addClass('sidebar');
		$.get('/api/blog', function (data){
			$('.content').html(data).delay(1000).fadeIn(1000);
			setUpClickEvents();
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
			});
		});
	} else {
		$('#goHome').fadeIn(1000);
		$('.logo').addClass('sidebar');
		$.get('/api/about', function (data){
			$('.content').html(data).delay(1000).fadeIn(1000);
		});
	}
});

$('#goHome').on('click', function (e) {
	e.preventDefault();
	window.history.pushState({}, "", '/')
	$('#goHome, .content').fadeOut(500, function(){
		$('.content').html('');
		$('.logo').removeClass('sidebar');
	});
})