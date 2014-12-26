$(document).ready(function(){

	var Player;
	var Track;

	SC.initialize({
	  client_id: '91a4f9b982b687d85c9d42e2f4991a09'
	});

	SC.get('/resolve', { url: 'https://soundcloud.com/nautilus-provo/booty-call-snapchat/' }, function (track){
		Track = track;

		SC.stream('/tracks/' + track.id, function (song) {
			Player = song;
		});
	});

	$('.glyphicon').on('click', function(){
		playerState = Player.getState();

		if ( playerState == "playing" ){
			Player.pause()
		}
		else {
			Player.play();
		}

		$('.glyphicon-play').toggle();
		$('.glyphicon-pause').toggle();
	});


})
