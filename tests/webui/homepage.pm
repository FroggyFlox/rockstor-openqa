# Copyright (c) 2012-2022 RockStor, Inc. <http://rockstor.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# Here, we simply verify that the Dashboard is displayed and then shutdown
# the machine.


use base 'basetest';
use warnings;
use strict;
use testapi;

sub run {

    # Dismiss the "save password" prompt from Firefox.
    check_screen('firefox_password_save_prompt', 'timeout' => 10);
    if (match_has_tag('firefox_password_save_prompt')) {
        assert_and_click('firefox_password_save_prompt');
    }

    # Assert banner if no update channel is selected
    my $update_channel = get_var('UPDATE_CHANNEL');
    # unless (length($update_channel)) {
    #     record_info('no update channel is selected, so dismiss the welcome banner');
    #     assert_and_click('welcome_banner', clicktime => 2);
    # }

    # Alternative way, with retries in case the banner dismissal fails:
    unless (length($update_channel)) {
        my $max_tries = 4;
        my $retry = 0;
        do {
            record_info('no update channel is selected, so dismiss the welcome banner');
            assert_and_click('welcome_banner', clicktime => 1, timeout => 10);
            check_screen('homepage', timeout => 10);
            record_soft_failure('The homepage cannot be found so it seems the welcome banner is still up. Try again.') unless match_has_tag('homepage');
            $retry++;
        } while (($retry < $max_tries) && !match_has_tag('homepage'));
    }

    assert_screen('homepage');
    sleep(10); # sleep for a bit to let the homepage settle (likely unnecessary)
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;
