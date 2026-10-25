set -lx FISHRC_TEST_RESET_FILE (path resolve (status dirname)/../functions/_fishrc_reset_config.fish)
set -lx FISHRC_TEST_FIXTURE "$XDG_CONFIG_HOME/reset-fixture.fish"
set -lx FISHRC_TEST_LOG "$XDG_CONFIG_HOME/reset.log"
set -lx FISHRC_TEST_TIDE_VERSION 7.2.0
set -lx FISHRC_TEST_CONFIGURE_STATUS 0
mkdir -p "$XDG_CONFIG_HOME"; or exit 1
printf '%s\n' 'source "$FISHRC_TEST_RESET_FILE"
function yes
    echo y
end
function fish_config
    return 0
end
function tide
    switch $argv[1]
        case --version
            echo "tide, version $FISHRC_TEST_TIDE_VERSION"
        case configure
            echo configured >>"$FISHRC_TEST_LOG"
            set -U tide_left_prompt_items pwd vcs
            set -U tide_right_prompt_items status
            return $FISHRC_TEST_CONFIGURE_STATUS
        case reload
            return 0
    end
end
' >"$FISHRC_TEST_FIXTURE"

# Use normal Fish startup so universal variables persist across processes.
fish -c 'source "$FISHRC_TEST_FIXTURE"
set -U __fish_initialized 1
set -U fishrc_test_unrelated old-setting
set -U tide_left_prompt_items pwd git
_fishrc_reset_config --if-needed >/dev/null; or exit 1
set -q fishrc_test_unrelated; and exit 1
test "$__fish_initialized" = 1; or exit 1
test "$tide_left_prompt_items" = "pwd vcs"; or exit 1
test "$_fishrc_config_revision" = 1; or exit 1
'; or exit 1

fish -c 'source "$FISHRC_TEST_FIXTURE"
set -U fishrc_test_unrelated keep-until-reset
_fishrc_reset_config --if-needed >/dev/null; or exit 1
test "$fishrc_test_unrelated" = keep-until-reset; or exit 1
'; or exit 1
test (count (cat "$FISHRC_TEST_LOG")) -eq 1; or exit 1

fish -c 'source "$FISHRC_TEST_FIXTURE"
_fishrc_reset_config >/dev/null; or exit 1
set -q fishrc_test_unrelated; and exit 1
test "$_fishrc_config_revision" = 1; or exit 1
'; or exit 1
test (count (cat "$FISHRC_TEST_LOG")) -eq 2; or exit 1

set FISHRC_TEST_TIDE_VERSION 8.0.0
fish -c 'source "$FISHRC_TEST_FIXTURE"
_fishrc_reset_config --if-needed >/dev/null; or exit 1
'; or exit 1
test (count (cat "$FISHRC_TEST_LOG")) -eq 2; or exit 1

set FISHRC_TEST_CONFIGURE_STATUS 42
fish -c 'source "$FISHRC_TEST_FIXTURE"
set -U _fishrc_config_revision 0
_fishrc_reset_config --if-needed >/dev/null
test $status -eq 42; or exit 1
set -q _fishrc_config_revision; and exit 1
exit 0
'; or exit 1

set FISHRC_TEST_CONFIGURE_STATUS 0
fish -c 'source "$FISHRC_TEST_FIXTURE"
_fishrc_reset_config --if-needed >/dev/null; or exit 1
test "$_fishrc_config_revision" = 1; or exit 1
'; or exit 1
test (count (cat "$FISHRC_TEST_LOG")) -eq 4; or exit 1
exit 0
