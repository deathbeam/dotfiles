// ==UserScript==
// @name         Object.hasOwn Polyfill
// @match        *://*/*
// ==/UserScript==

(function () {
    'use strict';
    ('hasOwn' in Object) || (Object.hasOwn = Object.call.bind(Object.hasOwnProperty));
})();
