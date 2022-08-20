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

    # Verify first-login form is displayed and accept EULA
    assert_and_click('first_login_form_eula');
    # Enter hostname
    assert_and_click('eula_checked'); # Verify EULA is accepted and enter hostname field
    wait_screen_change { type_string('rockstor', max_interval => utils::SLOW_TYPING_SPEED); };
    send_key('tab'); # Select username field
    # Enter username
    wait_screen_change { type_string('admin', max_interval => utils::SLOW_TYPING_SPEED); };
    send_key('tab'); # Select password field
    # Enter password
    wait_screen_change { type_string('admin', max_interval => utils::SLOW_TYPING_SPEED); };
    send_key('tab'); # Select confirm password field
    # Enter password
    wait_screen_change { type_string('admin', max_interval => utils::SLOW_TYPING_SPEED); };
    # Submit
    assert_and_click('verify_first_login_form_and_submit');

}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;
