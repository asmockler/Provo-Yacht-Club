$().ready(function () {

  ////////////////////
  // NEW POST MODAL //
  ////////////////////

  // Autocomplete
  $('#soundcloud_url, #soundcloud_urlEdit').keyup(function(){
    if( $(this).val().length != 0 ){
      $('#autocomplete, #autocompleteEdit').fadeIn(200);
    }
    else {
      $('#autocomplete, #autocompleteEdit').fadeOut(200);
    }
  });

  $("#autocomplete, #autocompleteEdit").click(function(){

    SC.initialize({
      client_id: '91a4f9b982b687d85c9d42e2f4991a09'
    });

    var track_url = $('#soundcloud_url, #soundcloud_urlEdit').val();

    SC.get('/resolve', { url: track_url }, function(track) {
      $("#title, #titleEdit").val(track.title);
      $('#artist, #artistEdit').val(track.user.username);
      var artwork = track.artwork_url.replace("large", "t300x300")
      $('#albumArt, #albumArtEdit').val(artwork);
    });

  })

  // Show and hide the description field
  $('#blogPost, #blogPostEdit').click(function(){
    $('.blog-guts').slideToggle();
  });

  //////////////////////
  // ADMIN NAVIGATION //
  //////////////////////

  // Hiding the Frame and Showing the Greeting on Brand Click
  $('#BrandLink').click(function(e){
    e.preventDefault();
    window.history.pushState({}, "", '/admin');
    $('#frame').fadeOut(300, function(){
      $('#greeting').fadeIn(300);
      $('#forRemove').remove();
      $('#userNav').removeClass('active');
      $('#PostNav').removeClass('active');
    });
  });

  // Bringing in the Post Manager Page
  $('#GoToPostManager, #PostFromGreeting').click(function(e) {
    e.preventDefault();
    window.history.pushState({}, "", '/admin/posts');
    $('#greeting').fadeOut(300, function(){
      var div = $('#PostManager');
      $.get('/admin/posts', function(data) {
        div.hide().append(data).fadeIn(300);
      });
      $("#PostNav").addClass('active');
      $("#frame").fadeIn(300);
    });
  });

  // Bringing in the User Manager Page
  $('#GoToUserManager').click(function(e) {
    e.preventDefault();
    window.history.pushState({}, "", '/admin/users')
    $('#greeting').fadeOut(300, function(){
      var div = $('#UserManager');
      $.get('/admin/users', function(data) {
        div.hide().append(data).fadeIn(300);
      });
      $("#userNav").addClass('active');
      $("#frame").fadeIn(300);
    });
  });

  // To User Manager from Post Manager
  $('#userFromPost').click(function(e){
    e.preventDefault();
    window.history.pushState({}, "", '/admin/users');
    $('#forRemove').fadeOut(300, function(){
      $(this).remove();
      var div = $('#UserManager');
      $.get('/admin/users', function(data) {
        div.append(data).hide().fadeIn(400);
        $('#PostNav').removeClass('active');
        $('#userNav').addClass('active');
      });
    });
  });

  // To Post Manager from User Manager
  $('#PostFromUser').click(function(e){
    e.preventDefault();
    window.history.pushState({}, "", '/admin/posts');
    $('#forRemove').fadeOut(300, function(){
      $(this).remove();
      var div = $('#PostManager');
      $.get('/admin/posts', function(data) {
        div.append(data).hide().fadeIn(400);
        $('#userNav').removeClass('active');
        $('#PostNav').addClass('active');
      });
    });
  });

///////////////////////
// POST MANAGER ZONE //
///////////////////////

  // AJAX to load more posts
  $('#PostManager').on('click', '#loadMore', function(event) {
    var table = $("#posts-table");
    var batch = parseInt(table.attr('data-batch'));
    var individual = parseInt(table.attr('data-individual'));
    var tableBody = table.find('tbody');
    $.get('/admin/posts/more_results/' + ((batch*10) + individual), function(data){
      $(data).hide().appendTo(tableBody).fadeIn(400);
      table.attr('data-batch', batch+1);
    });
    event.preventDefault();
  });

  function AddNewPost(post) {
    var table = $("#posts-table");
    var tbody = table.find('tbody');
    var count = parseInt(table.attr('data-individual'));
    $(post).hide().prependTo(tbody).fadeIn(500);
    table.attr('data-individual', count+1);
    $('.alert-success').fadeIn();
  }

  // AJAX for New Published Posts
  var newPostModal = $("#NewPost");
  newPostModal.on('click', "#publishNew", function() {
    $.post('/admin/posts/new/publish',
        newPostModal.find('form').serialize(), 
        AddNewPost
      );
      $(this).closest('form').find("input[type=text], textarea").val("");
  });

  // AJAX for New Save Posts
  newPostModal.on("click", "#saveNew", function() {
    $.post('/admin/posts/new/save',
      newPostModal.find('form').serialize(), 
      AddNewPost);
      $(this).closest('form').find("input[type=text], textarea").val("");
  });

  var deleteModal = $('#delete-modal');
  $('#PostManager').on('click', "#posts-table .delete", function(event) {
    $.get(this.href, function (result) {
      deleteModal.find('.modal-delete-content').html(result);
      deleteModal.modal();
    });
    event.preventDefault();
  });

   // Edit Modal
  var editModal = $('#edit-modal');
  $('#PostManager').on('click', '#posts-table .edit', function (event) {
    $.get(this.href, function (result) {
      editModal.find('.modal-edit-content').html(result);
      editModal.modal();
      $('#blogPost, #blogPostEdit').click(function(){
          $('#blogPost, #blogPostEdit').click(function(){
            $('.blog-guts').slideToggle();
          });
      });
    });
    event.preventDefault();
  });

  editModal.on('click', "button:submit", function (event) {
    var jqForm = $(this.form);
    $.post(this.formAction, jqForm.serialize(), function(data){
      $('#posts-table').find("#" + jqForm.attr('data-post')).replaceWith(data);
      editModal.modal("hide");
      editModal.find('.modal-body').html("");
    });
    event.preventDefault();
  });

//=================  USER MANAGER ZONE  ====================================
    $('#UserManager').on('click', '.remove, .give', function (event) {
      $.post(this.href, function(){
        $(this).parents('tr').fadeOut();
      });
      event.preventDefault();
    });

    $('#UserManager').on('click', '.delete', function (event) {
      $.get(this.href, function (result) {
        deleteModal.find('.modal-delete-content').html(result);
        deleteModal.modal();
      });
      event.preventDefault();
    });

});

// ============== Making the success alerts work ===========================
// Put something here to override the close - make it just hide it instead so it can come back in later


// ================ ISSUES ================
// "Published" icons don't work without refresh
// Delete and Edit don't work without refresh
// Forms should clear out on submit
// Date doesn't show up without refresh but also needs to be fixed in all ways


