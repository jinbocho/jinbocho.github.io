/* Jinbocho — shared site engine: language switcher, mobile menu, cookie consent */
/* Reads translations from window.JINBOCHO_I18N (set by a page-specific *-i18n.js loaded before this file) */
(function () {
  function setLang(lang) {
    if (lang !== 'it' && lang !== 'en') lang = 'en';
    document.documentElement.lang = lang;
    localStorage.setItem('jinbocho-lang', lang);

    var t = window.JINBOCHO_I18N[lang];

    document.querySelectorAll('[data-i18n]').forEach(function (el) {
      var key = el.getAttribute('data-i18n');
      if (t[key] !== undefined) el.textContent = t[key];
    });

    document.querySelectorAll('[data-i18n-html]').forEach(function (el) {
      var key = el.getAttribute('data-i18n-html');
      if (t[key] !== undefined) el.innerHTML = t[key];
    });

    document.querySelectorAll('[data-href-it]').forEach(function (el) {
      el.href = lang === 'it'
        ? el.getAttribute('data-href-it')
        : el.getAttribute('data-href-en');
    });

    document.querySelectorAll('.lang-btn').forEach(function (btn) {
      btn.classList.toggle('active', btn.getAttribute('data-lang') === lang);
    });
  }

  window.setLang = setLang;

  var saved = localStorage.getItem('jinbocho-lang');
  var hamburger = document.getElementById('nav-hamburger');
  var mobileMenu = document.getElementById('mobile-menu');
  if (hamburger && mobileMenu) {
    function toggleMobileMenu(force) {
      var open = force !== undefined ? force : !mobileMenu.classList.contains('open');
      mobileMenu.classList.toggle('open', open);
      hamburger.setAttribute('aria-expanded', open ? 'true' : 'false');
      mobileMenu.setAttribute('aria-hidden', open ? 'false' : 'true');
    }
    hamburger.addEventListener('click', function () { toggleMobileMenu(); });
    mobileMenu.querySelectorAll('a').forEach(function (a) {
      a.addEventListener('click', function () { toggleMobileMenu(false); });
    });
  }
  setLang(saved || 'en');

  function applyConsent(value) {
    if (typeof gtag === 'function') {
      gtag('consent', 'update', { 'analytics_storage': value === 'granted' ? 'granted' : 'denied' });
    }
  }

  var cookieBanner = document.getElementById('privacy-banner');
  if (cookieBanner) {
    var storedConsent = localStorage.getItem('jinbocho-cookie-consent');
    if (storedConsent === 'granted' || storedConsent === 'denied') {
      applyConsent(storedConsent);
    } else {
      cookieBanner.classList.add('show');
    }
    var acceptBtn = document.getElementById('privacy-accept');
    var rejectBtn = document.getElementById('privacy-reject');
    var settingsLink = document.getElementById('privacy-settings-link');
    if (acceptBtn) acceptBtn.addEventListener('click', function () {
      localStorage.setItem('jinbocho-cookie-consent', 'granted');
      applyConsent('granted');
      cookieBanner.classList.remove('show');
    });
    if (rejectBtn) rejectBtn.addEventListener('click', function () {
      localStorage.setItem('jinbocho-cookie-consent', 'denied');
      applyConsent('denied');
      cookieBanner.classList.remove('show');
    });
    if (settingsLink) settingsLink.addEventListener('click', function () {
      cookieBanner.classList.remove('show');
      void cookieBanner.offsetWidth; // restart the pulse even if already open
      cookieBanner.classList.add('show', 'pulse');
    });
    cookieBanner.addEventListener('animationend', function () {
      cookieBanner.classList.remove('pulse');
    });
  }
})();
