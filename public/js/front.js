$().ready(function(){

// ################ Streaming from SoundCloud! #################

// play()
// stop()
// pause()
// seek(ms)
// setVolume(volume)
// getVolume()
// getType()
// getCurrentPosition()
// getLoadedPosition()
// getDuration()
// getState()

$pauseButtons = $('#pause, #pause_big');
$playButtons = $('#play, #play_big, #play_start_text');
$playAndPauseButtons = $('#play, #play_big, #play_start_text, #pause, #pause_big');

var current_track_url; // Holds the url fetched from an element's data attribute
var Player; // Variable to perform .play(), .pause(), etc.
var Track; // Variable to perform .title, .id, etc.
var firstTrack = $(".song-selector").find(".song-thumb").first().attr('data-url');
var $songRow = $('.song-selector').find('.row');

// ############## Functions #################

// Loads the first track into the player
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

// Guts for setting up the player
function getAndPlayTrack (track) {
	SC.get('/resolve', { url: current_track_url }, function (track) {
	  // Putting the title in the player
	  $("#title").html(track.title);
	  Track = track;
	  // Streaming the song (play and pause as well)
	  SC.stream('/tracks/' + track.id, 
	  	{onfinish: function(){ alert('track finished');}}, 
	  	function (song) {
		  	Player = song;
		  	Player.play();
		  	// Guts for making the progress bar work
		function trackTime() {
			if(Player != undefined){
				setTimeout(trackTime, 1000);
				$("#songProgress").width( (Player.getCurrentPosition() / Player.getDuration()) * 200);
				
				if( Player.getState() == 'ended'){
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
			}
		}
		setTimeout(trackTime, 1000);

	  });
	}); //SC.get
}

// Playing a new song when picked from the song selector
function controlSongFromSelector () {
	if ( $(this).hasClass('currently-paused') ){
		Player.play();
		$(this).removeClass('currently-paused');
		$playButtons.hide();
		$pauseButtons.show();
	}
	else if( $(this).hasClass('glyphicon-play') ){
		if(Player != undefined){
			Player.stop();
			Player = undefined;
		}

		current_track_url = $(this).attr('data-url');
		getAndPlayTrack(current_track_url);
		$('#soundcloudLink').attr('href', current_track_url);
		$playButtons.hide();
		$pauseButtons.show();
		$('.song-selector').find('.glyphicon-pause').removeClass('glyphicon-pause').addClass('glyphicon-play play-this-song');
		$(".song-selector").find('.current-song').removeClass('current-song');
		$(this).removeClass("glyphicon-play play-this-song").addClass("glyphicon-pause");
		$(this).parents('.song-thumb').addClass('current-song');
	}
	else if ( $(this).hasClass('glyphicon-pause') ){
		Player.pause();
		$(this).addClass('currently-paused');
		$playButtons.show();
		$pauseButtons.hide();
	}
}

function queueUpSelector () {
	var lastLoaded = $songRow.find('.song-thumb').last().attr('data-number');
	$.get('/load_more_songs/' + lastLoaded, function (data){
		$songRow.append(data);
	});
	$('#view-next-set').on('click', loadMorePosts);
}

function showFirstTracks () {
	$songRow.find('.song-thumb').slice(0,13).show();
}

function loadMorePosts () {
	var totalSongs = $('body').attr('data-total-songs');
	var lastVisible = $songRow.find('.song-thumb:visible').last().attr('data-number');
	if ( lastVisible < totalSongs ) {
		$(this).off('click');
		$songRow.animate({
			left: '-75%'
		},
		1000, 'easeInOutBack', function(){
			$(this).css('left', '0');
			$('.song-thumb').slice((lastVisible-12), (lastVisible-3)).hide();
			$('.song-thumb').slice(lastVisible, lastVisible*1+9).each(function (index){
				$(this).delay(50*index).fadeIn(400);
				if ( $(this).hasClass('viewed') ) {
				}
				else {
					WireUpContent(this);
					$(this).addClass('viewed');
				}
			}).promise().done(function(){
				var lastLoaded = $songRow.find('.song-thumb').last().attr('data-number');
				if ( lastLoaded < lastVisible*1+12 ) {
					queueUpSelector();
				}
				else {
					$('#view-next-set').on('click', loadMorePosts);
				}
			});
		});
	}
}

function viewPreviousPosts () {
	if ($('.song-thumb:visible').first().hasClass('no-skipping-back') ){

	}
	else {
		var firstVisible = $songRow.find('.song-thumb:visible').first().attr('data-number');
		$('#view-previous-set').off('click');
		$songRow.animate({
			left: '75%'
		},
		1000, 'easeInOutBack', function(){
			$(this).css('left', '0');
			$('.song-thumb').slice(firstVisible*1+2, firstVisible*1+11).hide();
			$('.song-thumb').slice(firstVisible-10, firstVisible).fadeIn(400);
			$('#view-previous-set').on('click', viewPreviousPosts)
		});
	}

}


// Getting everything started up
SC.initialize({
  client_id: '91a4f9b982b687d85c9d42e2f4991a09'
});
getFirstTrack();
WireUpContentFirst();
showFirstTracks();
queueUpSelector();
$('.play-this-song').on('click', controlSongFromSelector);
$('#view-previous-set').on('click', viewPreviousPosts);

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
			
			if( Player.getState() == 'ended'){
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
		}
		setTimeout(trackTime, 1000);
	}
});

$pauseButtons.click(function(e){
	e.preventDefault();
	Player.pause();
	$playAndPauseButtons.toggle();
});


// Click to seek on progress bar

$('.song-progress').on('click', function (e) {
	var clickPosition = e.pageX - this.offsetLeft;
	var totalDuration = Player.getDuration();
	// Total width of the progress bar is 200
	var songTime = (totalDuration / 200) * clickPosition
	Player.seek(songTime);
	$("#songProgress").width( (songTime / totalDuration) * 200);
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


// ################ Pull-overs for Album Art ##############
function WireUpContent (e) {
	$(e).hover(function(){
		$(".song-popover", this).fadeIn(400)
	});

	$(e).mouseleave(function(){
		$(".song-popover", this).fadeOut();
	});

	$(e).find('.play-this-song').on('click', controlSongFromSelector);
}

function WireUpContentFirst () {
	$('.song-thumb').hover(function(){
		$(".song-popover", this).fadeIn(400)
	});

	$('.song-thumb').mouseleave(function(){
		$(".song-popover", this).fadeOut();
	});
}

// ############### Volume Control ###############

	$("#volume-control").on('mouseover', function(){
		$('.volume-bar').show();
	});

	$(".volume-container").on('mouseleave', function(){
		$('.volume-bar').hide();
	});

	$(".volume-bar").on( 'click', function (e) {
		console.log("hello");

		var clickPosition = e.pageX - this.offsetLeft;
		// Total width of the progress bar is 200
		var newVolume = (clickPosition / 200);
		Player.setVolume(newVolume);
		$("#volumeControl").width( newVolume * 200 );
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
