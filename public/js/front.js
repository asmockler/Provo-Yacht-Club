$().ready(function(){

// ################ Streaming from SoundCloud! #################

// Initialize
SC.initialize({
  client_id: '91a4f9b982b687d85c9d42e2f4991a09'
});


var current_track_url;
var songId;

function PlayTrack (track) {
	SC.get('/resolve', { url: current_track_url }, function (track) {
	  // Putting the title in the player
	  $("#title").html(track.title);
	  $("#title").addClass(track.id);
	  songId = track.id;
	  console.log("NewID" + songId);
	  $('body').addClass(songId);
	  // Streaming the song (play and pause as well)
	  SC.stream('/tracks/' + track.id, function (song) {
	  	$("#play, #play_big, #play_start_text").click(function() {
	  		song.play();
	  		$("#play, #pause, #play_big, #pause_big").toggle();
			$("#hidePlay").fadeOut(600);
			// Guts for making the progress bar work
			function trackTime() {
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
}

// Getting a new track from bottom selector
$(".play-this-song").click(function(){
	current_track_url = $(this).attr("data-url");
	PlayTrack(current_track_url);
	console.log("Here is the id outside of the function: " + songId);

	// Changes the current play icon to pause in the song selector toolbar
	$(".song-selector").find(".glyphicon-pause").removeClass("glyphicon-pause").addClass("glyphicon-play");
	// Changes the clicked track's play button to a pause button
	$(this).removeClass("glyphicon-play").addClass("glyphicon-pause");
});


// ################ Pull-overs for Album Art ##############
	$(".song-thumb").hover(function(){
		$(".song-popover", this).fadeIn();
	});

	$(".song-thumb").mouseleave(function(){
		$(".song-popover", this).fadeOut();
	});


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