// ==UserScript==
// @name         Twitter/X to Nitter Redirect
// @match        *://twitter.com/*
// @match        *://x.com/*
// @run-at       document-start
// ==/UserScript==

(function() {
    'use strict';
    const nitterHost = "nitter.net";
    if (location.hostname === "twitter.com" || location.hostname === "x.com") {
        const newUrl = "https://" + nitterHost + location.pathname + location.search + location.hash;
        location.replace(newUrl);
    }
})();
