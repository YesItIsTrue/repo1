$( document ).ready(function() {
    var $menuTrigger = $('[data-im-class="button-trigger"]'), $menuOverlay = $('[data-im-class="overlay"]'), $menuItem = $('.menu-item'), activeClass = 'active', $nav = $('.im-nav'), navOpen = false, $parentItem = $('.im-parent-item');
  var isTouch = false;
  if ($('html').hasClass('touch')) {
      isTouch = true;
  }
  function menuFunction() {
      $menuTrigger.toggleClass(activeClass);
      if (!navOpen) {
          navOpen = true;
          $('body').addClass('active');
      } else {
          navOpen = false;
          $('body').removeClass('active');
      }
  }
  function toggleSubmenu() {
      $(this).closest('.im-nav-list-item').toggleClass('im-active');
  }
  if (isTouch) {
      $menuTrigger.on('touchstart', function () {
          menuFunction();
      });
      $parentItem.on('touchstart', function () {
          $(this).closest('.im-nav-list-item').toggleClass('im-active');
      });
  }
  if (!isTouch) {
      $menuTrigger.on('click', function () {
          menuFunction();
      });
      $parentItem.on('click', function () {
          $(this).closest('.im-nav-list-item').toggleClass('im-active');
      });
  }
  $('.im-parent-item').click(function (e) {
      e.preventDefault();
  });

});
