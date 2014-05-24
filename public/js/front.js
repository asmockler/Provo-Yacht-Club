$().ready(function(){

// ################ Streaming from SoundCloud! #################

// Initialize
SC.initialize({
  client_id: '91a4f9b982b687d85c9d42e2f4991a09'
});

$pauseButtons = $('#pause, #pause_big');
$playButtons = $('#play, #play_big, #play_start_text');
$playAndPauseButtons = $('#play, #play_big, #play_start_text, #pause, #pause_big');

var current_track_url; // Holds the url fetched from an element's data attribute
var Player; // Variable to perform .play(), .pause(), etc.
var Track; // Variable to perform .title, .id, etc.
var firstTrack = $(".song-selector").find(".song-thumb").first().attr('data-url');

function getFirstTrack (track) {
	$('.song-selector').find('.song-thumb').first().addClass('current-song no-skipping-back');

	SC.get('/resolve', { url: firstTrack }, function (track) {
		$('#title').html(track.title);
		Track = track;
		SC.stream('/tracks/' + track.id, function (song) {
			Player = song;
		});
	});
}

getFirstTrack();

function getAndPlayTrack (track) {
	SC.get('/resolve', { url: current_track_url }, function (track) {
	  // Putting the title in the player
	  $("#title").html(track.title);
	  Track = track;
	  // Streaming the song (play and pause as well)
	  SC.stream('/tracks/' + track.id, function (song) {
	  	Player = song;
	  	Player.play();
	  	// Guts for making the progress bar work
		function trackTime() {
			if(Player != undefined){
				setTimeout(trackTime, 1000);
				$("#songProgress").width( (Player.getCurrentPosition() / Player.getDuration()) * 200);
			}
		}
		setTimeout(trackTime, 1000);
	  });
	}); //SC.get
}

$playButtons.click(function(e){
	e.preventDefault();

	if(Player != "undefined"){
		Player.play();
		$playAndPauseButtons.toggle();
		$("#hidePlay").fadeOut(600);

		// Guts for making the progress bar work
		function trackTime() {
			setTimeout(trackTime, 1000);
			$("#songProgress").width( (Player.getCurrentPosition() / Player.getDuration() ) * 200);
		}
		setTimeout(trackTime, 1000);
	}

});

$pauseButtons.click(function(e){
	e.preventDefault();
	Player.pause();
	$playAndPauseButtons.toggle();
});


// Getting a new track from bottom selector
$(".play-this-song").click(function(){
	if(Player != undefined){
		Player.stop();
		Player = undefined;
	}
	current_track_url = $(this).attr("data-url");
	getAndPlayTrack(current_track_url);
	$("#soundcloudLink").attr('href', current_track_url);


	$playButtons.hide();
	$pauseButtons.show();

	// Changes the current play icon to pause in the song selector toolbar
	$(".song-selector").find(".glyphicon-pause").removeClass("glyphicon-pause").addClass("glyphicon-play");
	$(".song-selector").find('.current-song').removeClass('current-song');
	// Changes the clicked track's play button to a pause button
	$(this).removeClass("glyphicon-play play-this-song").addClass("glyphicon-pause");
	$(this).parents('.song-thumb').addClass('current-song');
});

$('#skip-forward').click(function(e){
	e.preventDefault();
	if(Player != undefined){
		Player.stop();
		Player = undefined;
		var nextSong = $('.current-song').next('.song-thumb');
		$('.current-song').removeClass('current-song');
		nextSong.addClass('current-song');
		current_track_url = nextSong.attr('data-url');
		getAndPlayTrack(current_track_url);
		$playButtons.hide();
		$pauseButtons.show();
	}
});

$("#skip-backward").click(function(e){
	e.preventDefault();
	if ( $('.current-song').hasClass('no-skipping-back') ) {

	}
	else if(Player != undefined){
		Player.stop();
		Player = undefined;
		var prevSong = $('.current-song').prev('.song-thumb');
		$('.current-song').removeClass('current-song');
		prevSong.addClass('current-song');
		current_track_url = prevSong.attr('data-url');
		getAndPlayTrack(current_track_url);
		$playButtons.hide();
		$pauseButtons.show();
	}
});

// ################ Loading more songs in the player #############

$('#view-next-set').click(function(){

	var $songRow = $('.song-selector').find('.row');

	$songRow.fadeOut(500, function(){

		$(this).empty();

		$.get('/load_more_songs', function (data){
			$songRow.append(data).fadeIn(300);
			WireUpPopOvers();
		});
	});

});

var songThumbPosition = 9;

function queueUpSelector () {
		var $songRow = $('.song-selector').find('.row');

	$.get('/load_more_songs', function (data){
		$songRow.append(data);
		$songRow.find('.song-set').last().addClass('queued').hide();
		WireUpPopOvers();
	});
}

queueUpSelector();

$('#view-previous-set').click(function(){
	var $songRow = $('.song-selector').find('.row');
	var thumbCounter = '.song-thumb:lt(' + songThumbPosition + ')';

	$songRow.animate({
		left: '-75%'
	}, 500, function() {
		$(this).find(thumbCounter).hide();
		$(this).css('left', '0');
		songThumbPosition = songThumbPosition + 9;
		$('.queued').show().removeClass('.queued');
		queueUpSelector();
	});

});


// #view-previous-set
// #view-next-set


// ################ Pull-overs for Album Art ##############
function WireUpPopOvers () {
	$(".song-thumb").hover(function(){
		$(".song-popover", this).fadeIn();
	});

	$(".song-thumb").mouseleave(function(){
		$(".song-popover", this).fadeOut();
	});
}

WireUpPopOvers();


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