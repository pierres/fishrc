function firefox-tmp --wraps firefox --description 'Launch a clean Firefox instance with a temporary profile'
    if not _fishrc_check_command firefox
        return 1
    end

    set -l tmpdir (mktemp -d -t firefox-tmp.XXXXXXXXXX)
    set -x XDG_CACHE_HOME "$tmpdir/cache"
    mkdir "$XDG_CACHE_HOME" "$tmpdir/data"

    trap "rm -rf '$tmpdir'" EXIT INT

    echo '
        user_pref("browser.shell.checkDefaultBrowser", false);
        user_pref("browser.aboutwelcome.enabled", false);
        user_pref("trailhead.firstrun.didSeeAboutWelcome", true);
        user_pref("datareporting.policy.firstRunURL", "");
        user_pref("browser.aboutConfig.showWarning", false);
        user_pref("browser.startup.page", 0);
        user_pref("browser.startup.homepage", "about:blank");
        user_pref("browser.newtabpage.enabled", false);
        user_pref("browser.newtabpage.activity-stream.showSponsored", false);
        user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
        user_pref("browser.newtabpage.activity-stream.default.sites", "");
        user_pref("extensions.pocket.enabled", false);
        user_pref("browser.startup.homepage_override.mstone", "ignore");
        user_pref("datareporting.policy.dataSubmissionEnabled", false);
        user_pref("browser.translations.automaticallyPopup", false);
        user_pref("browser.translations.neverTranslateLanguages", "de");
        user_pref("browser.translations.panelShown", true);
        user_pref("browser.toolbars.bookmarks.visibility", "never");
    ' >"$tmpdir/data/user.js"

    firefox \
        --profile "$tmpdir/data" \
        --no-remote \
        $argv

    rm -rf "$tmpdir"
end
