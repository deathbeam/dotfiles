// ==UserScript==
// @name         Youtube Enhancements
// @match        *://*.youtube.com/*
// ==/UserScript==

(function() {
    'use strict';

    function skipAds() {
        const skipBtn = document.querySelector('.videoAdUiSkipButton, .ytp-ad-skip-button-modern, .ytp-skip-ad-button');
        if (skipBtn) {
            setTimeout(() => skipBtn.click(), 500 + Math.random() * 1000); // 0.5-1.5s delay
        }
        const adVideo = document.querySelector('.ad-showing .video-stream');
        if (adVideo && adVideo.duration > 0 && adVideo.currentTime < adVideo.duration) {
            // Fast-forward in small steps
            let interval = setInterval(() => {
                if (adVideo.currentTime < adVideo.duration - 0.5) {
                    adVideo.currentTime += 2;
                } else {
                    adVideo.currentTime = adVideo.duration;
                    clearInterval(interval);
                }
            }, 200 + Math.random() * 200); // 0.2-0.4s interval
        }
    }

    function removeSponsored() {
        document.querySelectorAll('ytd-in-feed-ad-layout-renderer').forEach(el => el.remove());
        document.querySelectorAll('ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-ads"]').forEach(el => el.remove());
    }

    function observer() {
        // skipAds();
        removeSponsored();
    }

    window.addEventListener('load', observer);
    new MutationObserver(observer).observe(document.body, { childList: true, subtree: true });
})();
