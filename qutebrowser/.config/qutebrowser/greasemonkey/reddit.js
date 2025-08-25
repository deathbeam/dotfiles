// ==UserScript==
// @name         Reddit Infobar Remover
// @match        *://*.reddit.com/*
// ==/UserScript==

(function() {
    'use strict';
    document.querySelectorAll('.infobar-toaster-container').forEach(el => el.remove());
})();
