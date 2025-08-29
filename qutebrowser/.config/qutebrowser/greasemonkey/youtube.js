// ==UserScript==
// @name         Youtube Enhancements
// @match        *://*.youtube.com/*
// ==/UserScript==

(function() {
    'use strict';

    function skipAds() {
        const skipBtn = document.querySelector('.videoAdUiSkipButton, .ytp-ad-skip-button-modern, .ytp-skip-ad-button');
        if (skipBtn) skipBtn.click();
        const adVideo = document.querySelector('.ad-showing .video-stream');
        if (adVideo && adVideo.duration > 0 && adVideo.currentTime < adVideo.duration) {
            adVideo.currentTime = adVideo.duration;
        }
    }

    function removeSponsored() {
        document.querySelectorAll('ytd-in-feed-ad-layout-renderer').forEach(el => el.remove());
        document.querySelectorAll('ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-ads"]').forEach(el => el.remove());
    }

    function observer() {
        skipAds();
        removeSponsored();
    }

    window.addEventListener('load', observer);
    new MutationObserver(observer).observe(document.body, { childList: true, subtree: true });
})();
