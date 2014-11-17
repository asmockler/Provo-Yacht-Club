$(document).ready(function(){

	//////////////
	//  NAVBAR  //
	//////////////

	$(document).scroll(function(){
		if ( $(this).scrollTop() > 50 ){
			$('.navbar').css('background', 'rgba(0,0,0,.75)')
		} else if ( $(this).scrollTop() < 50 ) {
			$('.navbar').css('background', 'rgba(0,0,0,0')
		}
	});

	//////////////////////////////////
	//  SLIDER - HORIZONTAL SCROLL  //
	//////////////////////////////////

	$('.song-thumb-row').mousewheel(function(event, delta){
		this.scrollLeft -= (delta / 1.5);
		event.preventDefault();
	});

	//////////////////////
	//  MUSIC CONTROLS  //
	//////////////////////

	var Song; // Stores Player object - .play(), .stop(), .pause(), .seek(ms), .setVolume(volume), getVolume(), .getType, .getCurrentPosition(), .getLoadedPosition(), getDuration(), .getState()
	var Track; // Stores Track object - id, created_at, user_id, user, title, permalink, permalink_url, uri, sharing, embeddable_by, purchase_url, artwork_url, description, label, duration, genre, shared_to_count, tag_list, label_id, label_name, release, release_day, release_month, release_year, streamable, downloadable, state, license, track_type, waveform_url, download_url, stream_url, video_url, bpm, commentable, isrc, key_signature, comment_count, download_count, playback_count, favoritings_count, orginal_format, original_content_size, created_with, asset_data, artwork_data, user_favorite

	SC.initialize({ client_id: '91a4f9b982b687d85c9d42e2f4991a09' });

	//* url: A soundcloud url
	//* action: play or load. A parameter defining what the function should do with the track. 
	var newTrack = function (url, action) {
		if ( Song != undefined ) {
			Song.stop();
		}
		SC.get('/resolve', { url: url }, function(track) {
			Track = track;
			stream(Track, action);
			$('#title').html(Track.title);
			$('#soundcloudLink').attr('href', url);
		});
	}

	var stream = function (track, action) {
		SC.stream('/tracks/' + track.id, function (song) {
			Song = song;
			if (action === 'play') { 
				Song.play();
				if ( $('.fay-play-default').attr('data-fay-play') == "true"){
					$('.fay-play-default').triggerHandler('click'); 
				}
			}
		});
	}

	var nextSong = function () {
		if (Song != undefined) {
			Song.stop();
			Song = undefined;
			$('.active').next('.song-thumb').click();
		}
	}

	var previousSong = function () {
		if ( $('.active').hasClass('first') ) {	}
		else {
			if (Song != undefined) {
				Song.stop();
				Song = undefined;
				$('.active').prev('.song-thumb').click();
			}
		}
	}

	var trackTime = function () {
		setTimeout(trackTime, 1000);
		if ( Song != undefined ) {
			$('#song-progress').width( (Song.getCurrentPosition() / Song.getDuration()) * 200 );
		}
	}

	var setUpAutoAdvance = function () {
		setTimeout(setUpAutoAdvance, 1000);
		if ( Song != undefined ) {
			if ( Song.getState() === 'ended' ){
				Song.stop();
				Song = undefined;
				var new_song_url = $('.active').next('.song-thumb').attr('data-url');
				var next_song = $('.active').next('.song-thumb');

				$('.active').removeClass('active');
				next_song.addClass('active');
				newTrack( new_song_url, 'play');
			}
		}
	}

	var loadMoreSongs = function(){
		var numberLoaded = $('.song-thumb').length;
		$.get('/load_more_songs/' + numberLoaded, function (data){
			$('.song-thumb').last().after(data);
			$('.just-loaded').on('click', function(e){
				e.preventDefault();
				var url = $(this).attr('data-url');
				newTrack(url, 'play');
				$('.song-thumb-row').find('.active').removeClass('active');
				$(this).addClass('active');
			});
			$('.just-loaded').removeClass('just-loaded');
		});
	}

	////////////////////
	//  CLICK EVENTS  //
	////////////////////
	var setUpClickEvents = function () {
		$('#play-button').on('click', function (e) {
			e.preventDefault();
			if ( Song.getState() === 'playing' ) {
				Song.pause();
			} else if ( Song.getState() === 'paused' || Song.getState() === 'idle' ) {
				Song.play();
			}
		});

		$('.song-progress').on('click', function (e) {
			e.preventDefault();
			var clickPosition = e.pageX - this.offsetLeft;
			var totalDuration = Song.getDuration();
			// Total width of the progress bar is 200
			var songTime = (totalDuration / 200) * clickPosition
			Song.seek(songTime);
			$("#song-progress").width( (songTime / totalDuration) * 200);
		})

		$('.song-thumb').on('click', function(e){
			e.preventDefault();
			var url = $(this).attr('data-url');
			newTrack(url, 'play');
			$('.song-thumb-row').find('.active').removeClass('active');
			$(this).addClass('active');
		});

		$('#skip-forward').on('click', function(e){
			e.preventDefault();
			nextSong();
		});

		$('#skip-backward').on('click', function(e){
			e.preventDefault();
			previousSong();
		});

		$('.load-more').on('click', function(e){
			e.preventDefault();
			loadMoreSongs();
		})
	}

	//////////////////////////////
	//  INITIALIZE APPLICATION  //
	//////////////////////////////

	var init = function () {
		Fay.init();
		setUpClickEvents();
		setTimeout(trackTime, 1000);
		setTimeout(setUpAutoAdvance, 1000);

		var firstSong = $('.song-thumb').first();
		firstSong.addClass('active first');
		newTrack(firstSong.attr('data-url'), 'load');
	}

	init();

	// TODO
	// WIRE UP CLICK EVENTS FOR LOADED SONGS

});