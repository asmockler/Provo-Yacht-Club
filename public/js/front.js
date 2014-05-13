$().ready(function(){

	$("div").tooltip();



// ################ SoundCloud! #################

	SC.initialize({
	  client_id: '91a4f9b982b687d85c9d42e2f4991a09'
	});

	// permalink to a track
	var current_track_url = 'https://soundcloud.com/kygo/m83-wait-kygo-remix';

	SC.get('/resolve', { url: current_track_url }, function(track) {

	  $("#title").html(track.title);


	  SC.stream('/tracks/' + track.id, function(song) {
	  	$("#play, #play_big, #play_start_text").click(function() {
	  		song.play();
	  		$("#play, #pause, #play_big, #pause_big").toggle();
			$("#hidePlay").fadeOut(600);
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


	});




});