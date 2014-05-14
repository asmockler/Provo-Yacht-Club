$().ready(function(){

	$("#testingThings").hover(function(){
		$("#a").slideDown();
	});

	$("#testingThings").mouseleave(function(){
		$("#a").slideUp();
	});



// ################ SoundCloud! #################

	// Initialize
	SC.initialize({
	  client_id: '91a4f9b982b687d85c9d42e2f4991a09'
	});

	// Permalink to a track from data-url
	var current_track_url = $("#testingThings").attr("data-url");

	// Resolving the URL
	SC.get('/resolve', { url: current_track_url }, function(track) {
	  // Getting the artwork
	  $("#firstOne").attr('src', track.artwork_url)
	  // Putting the title in the player
	  $("#title").html(track.title);

	  // Streaming the song (play and pause as well)
	  SC.stream('/tracks/' + track.id, function(song) {
	  	$("#play, #play_big, #play_start_text").click(function() {
	  		song.play();
	  		$("#play, #pause, #play_big, #pause_big").toggle();
			$("#hidePlay").fadeOut(600);
			// Guts for making the progress bar work
			function trackTime() {
				console.log((song.position / song.durationEstimate) * 100);
				setTimeout(trackTime, 1000);
				$("#songProgress").width( (song.position / song.durationEstimate) * 100);
			}
			setTimeout(trackTime, 1000);
	  	});

    	$("#pause, #pause_big").click(function(){
    		event.preventDefault();
    		song.pause();
    		$("#play, #pause, #play_big, #pause_big").toggle();
    	});
	  });
	}); //SC.get

// ############### Showing the Blog #############
	$("#showBlog").click(function() {
		$('#landing').fadeIn(1000);
		$('#goHome').fadeIn(1000);
		$('#about').fadeOut(300, function(){
			$(this).empty();
			$.get('/load_blog', function(data){
				$('#blog').fadeOut(300).empty().append(data).fadeIn(300);
			});
		});
	});



// ############### Showing the About Page #############
	$("#showAbout").click(function() {
		$('#landing').fadeIn(1000);
		$("#goHome").fadeIn(1000);
		$('#blog').fadeOut(300, function() {
			$(this).empty();
			$.get('load_about', function(data){
				$("#about").fadeOut(300).empty().append(data).fadeIn(300);
			});
		});
	});

// ############### Going Back to the Home Page #############
	$("#goHome").click(function(){
		$('#landing').fadeOut(1000);
		$("#goHome").fadeOut(1000);
		$('#blog, #about').fadeOut(1000, function(){
			$(this).empty();
		});
	});

}); //Document Ready