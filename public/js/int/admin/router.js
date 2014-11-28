$(document).ready(function{
	var loadPosts = function(delay, fade) {

	}

	var loadUsers = function(delay, fade) {

	}

	var loadAdmin = function(delay, fade) {
		$('#frame').fadeOut(300, function() {
			$('#greeting').fadeIn(300);
			$('#forRemove').remove()
		})
	}

	switch ( window.location.pathname ) {
		case '/admin':
			break;
		case '/admin/users'
			loadUsers(0,0);
			break;
		case '/admin/posts'
			loadPosts(0,0)
			break;
	}

	window.addEventListener('popstate', function (e) {
		switch ( window.location.pathname ) {
			case '/admin':
				loadAdmin();
				break;
			case '/admin/users'
				loadUsers(500,500);
				break;
			case '/admin/posts'
				loadPosts(500,500)
				break;
		}
	})
});