// ==UserScript==
// @name         Reddit Enhancements
// @match        *://*.reddit.com/*
// ==/UserScript==

(function() {
    'use strict';

    function removePromoted() {
        document.querySelectorAll('[data-promoted="true"], .promoted').forEach(el => el.remove());
    }

    function observer() {
        removePromoted();
    }

    window.addEventListener('load', observer);
    new MutationObserver(observer).observe(document.body, { childList: true, subtree: true });
})();
