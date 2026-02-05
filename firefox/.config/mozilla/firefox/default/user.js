/******
 * MINIMAL PRIVACY-FOCUSED USER.JS
 * Streamlined from arkenfox - keeps essential privacy, prioritizes functionality
 * Focus: Block telemetry, AI bloat, tracking; Allow WebRTC for video conferencing
 ******/

user_pref("_user.js.parrot", "START: Minimal config loaded");

/*** [SECTION 0100]: STARTUP ***/
user_pref("_user.js.parrot", "0100 syntax error: STARTUP");
/* 0102: set startup page */
user_pref("browser.startup.page", 1);
user_pref("browser.startup.homepage", "https://duckduckgo.com/");
/* 0103-0104: blank new tab */
user_pref("browser.newtabpage.enabled", false);
/* 0105-0106: disable sponsored content */
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);
user_pref("browser.newtabpage.activity-stream.default.sites", "");

/*** [SECTION 0200]: GEOLOCATION ***/
user_pref("_user.js.parrot", "0200 syntax error: GEOLOCATION");
user_pref("geo.provider.ms-windows-location", false);
user_pref("geo.provider.use_corelocation", false);
user_pref("geo.provider.use_geoclue", false);

/*** [SECTION 0300]: DISABLE MOZILLA BLOAT ***/
user_pref("_user.js.parrot", "0300 syntax error: BLOAT");
/* Disable recommendations and discovery */
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("browser.discovery.enabled", false);
/* Disable Activity Stream telemetry */
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
/* Disable Studies */
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");
/* Disable Crash Reports */
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);
/* Disable Captive Portal detection */
user_pref("captivedetect.canonicalURL", "");
user_pref("network.captive-portal-service.enabled", false);
user_pref("network.connectivity-service.enabled", false);
/* Disable Shopping Experience */
user_pref("browser.shopping.experience2023.enabled", false);
/* Disable Pocket */
user_pref("browser.urlbar.pocket.featureGate", false);

/*** [SECTION 0400]: SAFE BROWSING ***/
user_pref("_user.js.parrot", "0400 syntax error: SAFE BROWSING");
/* Disable remote checks (privacy) */
user_pref("browser.safebrowsing.downloads.remote.enabled", false);

/*** [SECTION 0600]: NETWORK ***/
user_pref("_user.js.parrot", "0600 syntax error: NETWORK");
/* Disable prefetching */
user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.dns.disablePrefetchFromHTTPS", true);
user_pref("network.predictor.enabled", false);
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("browser.places.speculativeConnect.enabled", false);

/*** [SECTION 0700]: PROXY/SOCKS ***/
user_pref("_user.js.parrot", "0700 syntax error: PROXY");
user_pref("network.proxy.socks_remote_dns", true);
user_pref("network.file.disable_unc_paths", true);
user_pref("network.gio.supported-protocols", "");

/*** [SECTION 0800]: LOCATION BAR / SEARCH ***/
user_pref("_user.js.parrot", "0800 syntax error: SEARCH");
/* Disable search suggestions and URL bar bloat */
user_pref("browser.urlbar.speculativeConnect.enabled", false);
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.suggest.searches", false);
user_pref("browser.urlbar.trending.featureGate", false);
user_pref("browser.urlbar.addons.featureGate", false);
user_pref("browser.urlbar.fakespot.featureGate", false);
user_pref("browser.urlbar.mdn.featureGate", false);
user_pref("browser.urlbar.weather.featureGate", false);
user_pref("browser.urlbar.wikipedia.featureGate", false);
user_pref("browser.urlbar.yelp.featureGate", false);
user_pref("browser.formfill.enable", false);
/* Separate search engine for private windows */
user_pref("browser.search.separatePrivateDefault", true);
user_pref("browser.search.separatePrivateDefault.ui.enabled", true);

/*** [SECTION 0900]: PASSWORDS ***/
user_pref("_user.js.parrot", "0900 syntax error: PASSWORDS");
user_pref("signon.autofillForms", false);
user_pref("signon.formlessCapture.enabled", false);
user_pref("network.auth.subresource-http-auth-allow", 1);

/*** [SECTION 1000]: DISK AVOIDANCE ***/
user_pref("_user.js.parrot", "1000 syntax error: DISK");
user_pref("browser.cache.disk.enable", false);
user_pref("browser.privatebrowsing.forceMediaMemoryCache", true);
user_pref("media.memory_cache_max_size", 65536);
user_pref("browser.sessionstore.privacy_level", 2);
user_pref("toolkit.winRegisterApplicationRestart", false);
user_pref("browser.shell.shortcutFavicons", false);

/*** [SECTION 1200]: HTTPS / TLS / CERTIFICATES ***/
user_pref("_user.js.parrot", "1200 syntax error: HTTPS");
user_pref("security.ssl.require_safe_negotiation", true);
user_pref("security.tls.enable_0rtt_data", false);
/* OCSP */
user_pref("security.OCSP.enabled", 1);
user_pref("security.OCSP.require", true);
/* CRLite and PKP */
user_pref("security.cert_pinning.enforcement_level", 2);
user_pref("security.remote_settings.crlite_filters.enabled", true);
user_pref("security.pki.crlite_mode", 2);
/* HTTPS-Only Mode */
user_pref("dom.security.https_only_mode", true);
user_pref("dom.security.https_only_mode_send_http_background_request", false);
/* UI */
user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
user_pref("browser.xul.error_pages.expert_bad_cert", true);

/*** [SECTION 1600]: REFERERS ***/
user_pref("_user.js.parrot", "1600 syntax error: REFERERS");
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);

/*** [SECTION 1700]: CONTAINERS ***/
user_pref("_user.js.parrot", "1700 syntax error: CONTAINERS");
user_pref("privacy.userContext.enabled", true);
user_pref("privacy.userContext.ui.enabled", true);

/*** [SECTION 2000]: WEBRTC - CONFIGURED FOR VIDEO CONFERENCING ***/
user_pref("_user.js.parrot", "2000 syntax error: WEBRTC");
/* IMPORTANT: WebRTC configured for Google Meet/Teams functionality */
/* Keep proxy enforcement for privacy */
user_pref("media.peerconnection.ice.proxy_only_if_behind_proxy", true);
/* Allow multiple interfaces for better video call reliability */
/* NOTE: Disabling default_address_only reduces some IP privacy but is necessary for Teams/Meet */
user_pref("media.peerconnection.ice.default_address_only", false);

/* CRITICAL: Enable encoder fallbacks for VP8/VP9 (fixes Arch Linux system libvpx issues) */
user_pref("media.encoder.webm.enabled", true);
user_pref("media.ffmpeg.encoder.enabled", true);
user_pref("media.webrtc.platformencoder", true);
user_pref("media.webrtc.platformencoder.sw_only", false);
user_pref("media.webrtc.software_encoder.fallback", true);

/*** [SECTION 2400]: DOM ***/
user_pref("_user.js.parrot", "2400 syntax error: DOM");
user_pref("dom.disable_window_move_resize", true);

/*** [SECTION 2600]: MISCELLANEOUS ***/
user_pref("_user.js.parrot", "2600 syntax error: MISC");
user_pref("browser.download.start_downloads_in_tmp_dir", true);
user_pref("browser.helperApps.deleteTempFileOnExit", true);
user_pref("browser.uitour.enabled", false);
user_pref("devtools.debugger.remote-enabled", false);
user_pref("permissions.manager.defaultsUrl", "");
user_pref("network.IDN_show_punycode", true);
/* PDF.js */
user_pref("pdfjs.disabled", false);
user_pref("pdfjs.enableScripting", false);
user_pref("browser.tabs.searchclipboardfor.middleclick", false);
/* DLP */
user_pref("browser.contentanalysis.enabled", false);
user_pref("browser.contentanalysis.default_result", 0);
/* CSP Reporting */
user_pref("security.csp.reporting.enabled", false);

/** DOWNLOADS **/
user_pref("browser.download.useDownloadDir", false);
user_pref("browser.download.alwaysOpenPanel", false);
user_pref("browser.download.manager.addToRecentDocs", false);
user_pref("browser.download.always_ask_before_handling_new_types", true);

/** EXTENSIONS **/
user_pref("extensions.enabledScopes", 5);
user_pref("extensions.postDownloadThirdPartyPrompt", false);

/*** [SECTION 2700]: ENHANCED TRACKING PROTECTION ***/
user_pref("_user.js.parrot", "2700 syntax error: ETP");
user_pref("browser.contentblocking.category", "strict");

/*** [SECTION 2800]: SHUTDOWN & SANITIZING ***/
user_pref("_user.js.parrot", "2800 syntax error: SANITIZE");
user_pref("privacy.sanitize.sanitizeOnShutdown", true);

/* Clear on shutdown - but keep cookies for convenience */
user_pref("privacy.clearOnShutdown_v2.cache", true);
user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false); // Keep cookies
user_pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", false);
user_pref("privacy.clearOnShutdown_v2.browsingHistoryAndDownloads", false);
user_pref("privacy.clearOnShutdown_v2.downloads", false);
user_pref("privacy.clearOnShutdown_v2.formdata", true);

/* Manual clear data defaults */
user_pref("privacy.clearSiteData.cache", true);
user_pref("privacy.clearSiteData.cookiesAndStorage", false);
user_pref("privacy.clearSiteData.historyFormDataAndDownloads", false);
user_pref("privacy.clearSiteData.browsingHistoryAndDownloads", false);
user_pref("privacy.clearSiteData.formdata", true);

/* Manual clear history defaults */
user_pref("privacy.clearHistory.cache", true);
user_pref("privacy.clearHistory.cookiesAndStorage", false);
user_pref("privacy.clearHistory.historyFormDataAndDownloads", false);
user_pref("privacy.clearHistory.browsingHistoryAndDownloads", false);
user_pref("privacy.clearHistory.formdata", true);

/* Timespan */
user_pref("privacy.sanitize.timeSpan", 0);

/*** [SECTION 4000]: FINGERPRINTING PROTECTION ***/
user_pref("_user.js.parrot", "4000 syntax error: FPP");
/* Use FPP (not RFP) for better compatibility - enabled automatically with ETP Strict */
user_pref("privacy.window.maxInnerWidth", 1600);
user_pref("privacy.window.maxInnerHeight", 900);

/*** [SECTION 4500]: RFP - DISABLED FOR FUNCTIONALITY ***/
user_pref("_user.js.parrot", "4500 syntax error: RFP");
/* RFP disabled - causes too much breakage, FPP is sufficient */
user_pref("privacy.spoof_english", 1); // Don't force English
user_pref("widget.non-native-theme.use-theme-accent", false);
user_pref("browser.link.open_newwindow", 2); // Open in new window
user_pref("browser.link.open_newwindow.restriction", 0);

/*** [SECTION 8500]: TELEMETRY - COMPLETELY DISABLED ***/
user_pref("_user.js.parrot", "8500 syntax error: TELEMETRY");
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.coverage.opt-out", true);
user_pref("toolkit.coverage.endpoint.base", "");

/*** [SECTION 9000]: NON-PROJECT RELATED ***/
user_pref("_user.js.parrot", "9000 syntax error: MISC");
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.urlbar.showSearchTerms.enabled", false);

/* END: syntax error check */
user_pref("_user.js.parrot", "SUCCESS: Minimal config completed!");

// -------------------------------------------------
// CUSTOM PREFERENCES
// -------------------------------------------------

// Enable userChrome.css and userContent.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Fix fullscreen behavior
user_pref("full-screen-api.ignore-widgets", true);

// Dark mode
user_pref("ui.systemUsesDarkTheme", 1);
user_pref("layout.css.prefers-color-scheme.content-override", 0);
