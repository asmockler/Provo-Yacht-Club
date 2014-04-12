$().ready(function () {

  function WireUpContent () {
    $('span').tooltip();
    $(".alert").alert();
  };

  WireUpContent();

  //------ Manager Main Nav Controls -----------------
  // Hiding the Greeting and showing the frame on Button Click
  $('#GoToFeatureManager').click(function(){
    $('#greeting').fadeOut(300, function(){
      $('#frame').fadeIn(300);
    });
  });

  // Hiding the Frame and Showing the Greeting on Brand Click
  $('#BrandLink').click(function(){
    $('#frame').fadeOut(300, function(){
      $('#greeting').fadeIn(300);
      $('#forRemove').remove();
      $('#FeatureNav').removeClass('active');
      $('#PostNav').removeClass('active');
    });
  });

  // Bringing in the Post Manager Page
  $('#GoToPostManager, #PostFromGreeting').click(function() {
    $('#greeting').fadeOut(300, function(){
      var div = $('#PostManager');
      $.get('/Manager/PostManager', function(data) {
        div.append(data);
      });
      $("#PostNav").addClass('active');
      $("#frame").fadeIn(300);
    });
  });

  // Bringing in the Feature Manager Page
  $('#GoToFeatureManager').click(function() {
    $('#greeting').fadeOut(300, function(){
      var div = $('#FeatureManager');
      $.get('/Manager/PostManager', function(data) {
        div.append(data);
      });
      $("#FeatureNav").addClass('active');
      $("#frame").fadeIn(300);
    });
  });

  //=================POST MANAGER ZONE ====================================
  // Form Controls for New Posts
  $('#soundcloudRadio').click(function() { 
    $("#SpotifyInput").prop("disabled",true);
    $("#SoundcloudInput").prop("disabled",false);
  });

  $('#spotifyRadio').click(function() { 
    $("#SoundcloudInput").prop("disabled",true);
    $("#SpotifyInput").prop("disabled",false);
  });

  // AJAX to load more posts
  $('#PostManager').on('click', '#loadMore', function(event) {
    var table = $("#posts-table");
    var batch = parseInt(table.attr('data-batch'));
    var individual = parseInt(table.attr('data-individual'));
    var tableBody = table.find('tbody');
    $.get('/Manager/moreResults/' + ((batch*5) + individual), function(data){
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
    table.attr('data-individual', count+1)
  }

  // AJAX for New Published Posts
  var newPostModal = $("#NewPost");
  newPostModal.on('click', "#publishNew", function() {
    $.post('/NewPost/publish',
      newPostModal.find('form').serialize(), 
      AddNewPost);
  });

  // AJAX for New Save Posts
  newPostModal.on("click", "#saveNew", function() {
    $.post('/NewPost/save',
      newPostModal.find('form').serialize(), 
      AddNewPost);

    $.get('/StatusAlert', function(data){
      $(data).appendTo('#Status');
    });
  });

  //================= FEATURE MANAGER ZONE ==============
  
  $("#FeatureManager").on('click', '#loadMore', function(event) {
    var table = $("#posts-table");
    var batch = parseInt(table.attr('data-batch'));
    var tableBody = table.find('tbody')
    $.get('/ManagerTest/moreResults/' + batch, function(data){
      $(data).hide().appendTo(tableBody).fadeIn();
      table.attr('data-batch', batch+1);
      WireUpContent();
    });
  });

  // Delete Modal
  var deleteModal = $('#delete-modal');
  $("#posts-table").on('click', '.delete', function (event) {
    $.get(this.href, function (result) {
      deleteModal.find('.modal-delete-content').html(result);
      deleteModal.modal();
    });
    event.preventDefault();
  });

  // Edit Modal
  var editModal = $('#edit-modal');
  $("#posts-table").on('click', '.edit', function (event) {
    $.get(this.href, function (result) {
      editModal.find('.modal-body').html(result);
      editModal.modal();
    });
    event.preventDefault();
  });

});
