// ==UserScript==
// @name         Reddit Enhancements
// @match        *://*.reddit.com/*
// ==/UserScript==

(function() {
    'use strict';

    // Remove promoted posts
    function removePromoted() {
        document.querySelectorAll('[data-promoted="true"], .promoted').forEach(el => el.remove());
    }
    removePromoted();
    new MutationObserver(removePromoted).observe(document.body, { childList: true, subtree: true });
})();
