// ==UserScript==
// @name         Youtube Enhancements
// @match        *://*.youtube.com/*
// ==/UserScript==

(function() {
    'use strict';

    // Auto fast forward ads
    function skipAds() {
        const skipBtn = document.querySelector('.videoAdUiSkipButton, .ytp-ad-skip-button-modern');
        if (skipBtn) skipBtn.click();
        const adVideo = document.querySelector('.ad-showing video');
        if (adVideo) adVideo.currentTime = adVideo.duration || 999999;
    }
    skipAds();
    new MutationObserver(skipAds).observe(document.body, { childList: true, subtree: true });
})();
