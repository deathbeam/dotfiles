// ==UserScript==
// @name         Auto Cookie Reject
// @match        *://*/*
// ==/UserScript==

(function() {
    'use strict';

    const handleCookieBanners = () => {
        // First, try to find and click reject buttons
        const rejectTexts = [
            "Refuser", "Refuser tous les cookies", "Refuser les cookies", "Rejeter",
            "Refuse", "Reject all cookies", "Reject cookies", "Decline",
            "Continuer sans accepter", "Continue without accepting", "Tout refuser", "Decline all"
        ];

        const buttons = Array.from(document.querySelectorAll('button, input[type="button"], input[type="submit"]'));
        let buttonClicked = false;

        buttons.forEach(btn => {
            if (buttonClicked) return;
            const text = btn.textContent.trim() || btn.value?.trim();
            if (text && rejectTexts.some(t => text.includes(t))) {
                btn.click();
                buttonClicked = true;
            }
        });

        // If no reject button was found, hide cookie banners
        if (!buttonClicked) {
            const selectors = [
                '[class*="cookie"]', '[id*="cookie"]',
                '[class*="gdpr"]', '[id*="gdpr"]',
                '[class*="consent"]', '[id*="consent"]',
                '[class*="privacy"]', '[id*="privacy"]',
                '#eu-cookie-policy', '.cookie-infobar',
                '.cookie-banner', '.cookie-notice', '.cookie-bar',
                '.gdpr-banner', '.consent-banner', '.privacy-banner'
            ];

            selectors.forEach(selector => {
                document.querySelectorAll(selector).forEach(el => {
                    const text = el.textContent.toLowerCase();
                    if (text.includes('cookie') || text.includes('privacy') ||
                        text.includes('consent') || text.includes('gdpr')) {
                        el.style.display = 'none';
                    }
                });
            });
        }
    };

    window.addEventListener('load', handleCookieBanners);
})();
