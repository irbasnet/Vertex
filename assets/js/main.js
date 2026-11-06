(function () {
  'use strict';

  var prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---- Mobile nav ---------------------------------------------------- */
  var navToggle = document.querySelector('[data-nav-toggle]');
  var mobileNav = document.querySelector('[data-mobile-nav]');

  if (navToggle && mobileNav) {
    navToggle.addEventListener('click', function () {
      var isOpen = navToggle.getAttribute('aria-expanded') === 'true';
      navToggle.setAttribute('aria-expanded', String(!isOpen));
      mobileNav.classList.toggle('is-open', !isOpen);
      document.body.style.overflow = !isOpen ? 'hidden' : '';
    });

    mobileNav.querySelectorAll('a').forEach(function (link) {
      link.addEventListener('click', function () {
        navToggle.setAttribute('aria-expanded', 'false');
        mobileNav.classList.remove('is-open');
        document.body.style.overflow = '';
      });
    });
  }

  /* ---- Carousels (hero, reviews, ...) ----------------------------------- */
  function initCarousel(carousel) {
    var slides = Array.prototype.slice.call(carousel.querySelectorAll('[data-slide]'));
    var dots = Array.prototype.slice.call(carousel.querySelectorAll('[data-dot]'));
    var prevBtn = carousel.querySelector('[data-prev]');
    var nextBtn = carousel.querySelector('[data-next]');
    var current = slides.findIndex(function (s) { return s.classList.contains('is-active'); });
    if (current < 0) current = 0;
    var timer = null;
    var intervalMs = Number(carousel.getAttribute('data-interval')) || 6500;

    function goTo(index) {
      slides[current].classList.remove('is-active');
      dots[current] && dots[current].classList.remove('is-active');
      dots[current] && dots[current].setAttribute('aria-selected', 'false');

      current = (index + slides.length) % slides.length;

      slides[current].classList.add('is-active');
      dots[current] && dots[current].classList.add('is-active');
      dots[current] && dots[current].setAttribute('aria-selected', 'true');
    }

    function next() { goTo(current + 1); }
    function prev() { goTo(current - 1); }

    function startAutoplay() {
      if (prefersReducedMotion || slides.length < 2) return;
      stopAutoplay();
      timer = window.setInterval(next, intervalMs);
    }

    function stopAutoplay() {
      if (timer) { window.clearInterval(timer); timer = null; }
    }

    dots.forEach(function (dot, i) {
      dot.addEventListener('click', function () { goTo(i); startAutoplay(); });
    });

    if (nextBtn) nextBtn.addEventListener('click', function () { next(); startAutoplay(); });
    if (prevBtn) prevBtn.addEventListener('click', function () { prev(); startAutoplay(); });

    carousel.addEventListener('mouseenter', stopAutoplay);
    carousel.addEventListener('mouseleave', startAutoplay);
    carousel.addEventListener('focusin', stopAutoplay);
    carousel.addEventListener('focusout', startAutoplay);

    startAutoplay();
  }

  Array.prototype.slice.call(document.querySelectorAll('[data-carousel]')).forEach(initCarousel);

  /* ---- Scroll carousel (reviews: 2-up desktop / 1-up mobile, continuous track) ---- */
  function initScrollCarousel(carousel) {
    var track = carousel.querySelector('.review-carousel-track');
    var items = Array.prototype.slice.call(track.children);
    var dots = Array.prototype.slice.call(carousel.querySelectorAll('[data-dot]'));
    var prevBtn = carousel.querySelector('[data-prev]');
    var nextBtn = carousel.querySelector('[data-next]');
    var current = 0;
    var timer = null;
    var intervalMs = Number(carousel.getAttribute('data-interval')) || 4000;
    var breakpoint = window.matchMedia('(min-width: 860px)');

    function visibleCount() { return breakpoint.matches ? 2 : 1; }
    function maxIndex() { return Math.max(0, items.length - visibleCount()); }

    function render() {
      var gap = parseFloat(window.getComputedStyle(track).columnGap || window.getComputedStyle(track).gap) || 0;
      var step = items[0].getBoundingClientRect().width + gap;
      track.style.transform = 'translateX(' + (-current * step) + 'px)';
      dots.forEach(function (dot, i) {
        var isActive = i === current;
        dot.classList.toggle('is-active', isActive);
        dot.setAttribute('aria-selected', String(isActive));
      });
    }

    function goTo(index) {
      current = Math.max(0, Math.min(index, maxIndex()));
      render();
    }

    function next() { goTo(current >= maxIndex() ? 0 : current + 1); }
    function prev() { goTo(current <= 0 ? maxIndex() : current - 1); }

    function startAutoplay() {
      if (prefersReducedMotion || items.length <= visibleCount()) return;
      stopAutoplay();
      timer = window.setInterval(next, intervalMs);
    }

    function stopAutoplay() {
      if (timer) { window.clearInterval(timer); timer = null; }
    }

    dots.forEach(function (dot, i) {
      dot.addEventListener('click', function () { goTo(i); startAutoplay(); });
    });

    if (nextBtn) nextBtn.addEventListener('click', function () { next(); startAutoplay(); });
    if (prevBtn) prevBtn.addEventListener('click', function () { prev(); startAutoplay(); });

    carousel.addEventListener('mouseenter', stopAutoplay);
    carousel.addEventListener('mouseleave', startAutoplay);
    carousel.addEventListener('focusin', stopAutoplay);
    carousel.addEventListener('focusout', startAutoplay);

    window.addEventListener('resize', function () { goTo(current); });

    render();
    startAutoplay();
  }

  Array.prototype.slice.call(document.querySelectorAll('[data-carousel-scroll]')).forEach(initScrollCarousel);


  /* ---- Enquiry form validation -------------------------------------------- */
  var form = document.querySelector('[data-enquiry-form]');

  if (form) {
    var serviceSelect = form.querySelector('[data-service-select]');
    if (serviceSelect) {
      var requestedService = new URLSearchParams(window.location.search).get('service');
      if (requestedService) {
        var matchingOption = Array.prototype.slice.call(serviceSelect.options)
          .find(function (opt) { return opt.value === requestedService; });
        if (matchingOption) serviceSelect.value = requestedService;
      }
    }

    var fileInput = form.querySelector('[data-file-input]');
    var fileLabel = form.querySelector('[data-file-label]');

    if (fileInput && fileLabel) {
      var fileLabelDefault = fileLabel.textContent;
      fileInput.addEventListener('change', function () {
        if (fileInput.files && fileInput.files.length) {
          fileLabel.textContent = fileInput.files.length === 1
            ? fileInput.files[0].name
            : fileInput.files.length + ' files selected';
        } else {
          fileLabel.textContent = fileLabelDefault;
        }
      });
    }

    function showError(field, message) {
      var errorEl = form.querySelector('[data-error-for="' + field.name + '"]');
      if (errorEl) errorEl.textContent = message || '';
      field.setAttribute('aria-invalid', message ? 'true' : 'false');
    }

    function validateField(field) {
      if (!field.hasAttribute('required')) return true;

      var value = field.value.trim();

      if (!value) {
        showError(field, 'This field is required.');
        return false;
      }

      if (field.type === 'email') {
        var emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailPattern.test(value)) {
          showError(field, 'Enter a valid email address.');
          return false;
        }
      }

      showError(field, '');
      return true;
    }

    form.querySelectorAll('input, textarea, select').forEach(function (field) {
      field.addEventListener('blur', function () { validateField(field); });
    });

    form.addEventListener('submit', function (e) {
      e.preventDefault();

      var fields = Array.prototype.slice.call(form.querySelectorAll('input, textarea, select'));
      var isValid = fields.reduce(function (acc, field) {
        var fieldValid = validateField(field);
        return acc && fieldValid;
      }, true);

      var statusEl = form.querySelector('[data-form-status]');

      if (!isValid) {
        var firstInvalid = form.querySelector('[aria-invalid="true"]');
        if (firstInvalid) firstInvalid.focus();
        if (statusEl) {
          statusEl.textContent = 'Please check the highlighted fields and try again.';
          statusEl.classList.add('is-visible');
        }
        return;
      }

      /* No backend is connected yet - this form is wired for validation only
         and is ready to be pointed at a real submission endpoint. */
      if (statusEl) {
        statusEl.textContent = 'Thank you - this form is not yet connected to a submission service. Please contact us directly in the meantime.';
        statusEl.classList.add('is-visible');
      }
    });
  }
})();
