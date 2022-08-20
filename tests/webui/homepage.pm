# Copyright (C) 2020-2021 SUSE LLC
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

# Here, we simply test if we can successfully login at the console on first boot.


use base 'basetest';
use warnings;
use strict;
use testapi;
# use lockapi;
# use mmapi;

sub run {

    # Dismiss the "save password" prompt from Firefox.
    check_screen('firefox_password_save_prompt', 'timeout' => 10);
    if (match_has_tag('firefox_password_save_prompt')) {
        assert_and_click('firefox_password_save_prompt');
    }

    # Assert banner if no update channel is selected
    my $update_channel = get_var('UPDATE_CHANNEL');
    unless (length($update_channel)) {
        record_info('no update channel is selected, so dismiss the welcome banner');
        assert_and_click('welcome_banner');
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
