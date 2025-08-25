// ==UserScript==
// @name         Auto Cookie Reject
// @match        *://*/*
// ==/UserScript==

(function() {
    'use strict';
    window.addEventListener('load', () => {
        const rejectTexts = [
            "Refuser", "Refuser tous les cookies", "Refuser les cookies", "Rejeter",
            "Refuse", "Reject all cookies", "Reject cookies", "Decline",
            "Continuer sans accepter", "Continue without accepting", "Tout refuser", "Decline all"
        ];
        const buttons = Array.from(document.querySelectorAll('button, input[type="button"], input[type="submit"]'));
        buttons.forEach(btn => {
            const text = btn.textContent.trim() || btn.value?.trim();
            if (text && rejectTexts.some(t => text.includes(t))) {
                btn.click();
            }
        });
    });
})();
