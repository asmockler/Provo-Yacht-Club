$('#submit').on('click', function (e){
	e.preventDefault();

	var name = $('#name').val();
	var email = $('#email').val();

	if (name === "") {
		$('#name-error').html('Please Enter a Name.')
		return;
	} else { $('#name-error').html("") }

	if (email === "") {
		$('#email-error').html('Please Enter an Email Address.');
		return;
	} else if (email.indexOf("@") === -1 || email.indexOf(".") === -1) {
		$('#email-error').html('Please Enter a Valid Email Address');
		return;
	} else { $('#email-error').html("") }

	$.ajax({
		type: 'POST',
		url: '/list/'+email+'/'+name,
		success: function (data) {
			$('#myModal').modal('show');
		},
		error: function(data) {
			if (data.status === 403) {
				$('#myModal').modal('show');
				$('#myModalLabel').html('Sorry...');
				$('.modal-body>p').html('Looks like the list is already full.');
			} else if (data.status === 409) {
				$('#myModal').modal('show');
				$('#myModalLabel').html('Uh oh...');
				$('.modal-body>p').html('That email address has already been used.');
			} 
		}
	});
});