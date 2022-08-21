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

# This test was copied (and slightly simplified for testing purposes)
# from: https://github.com/OSInside/kiwi-functional-tests/blob/master/tests/login.pm
# and: https://github.com/os-autoinst/os-autoinst-distri-opensuse/blob/master/tests/jeos/firstrun.pm

# Here, we simply test if we can successfully login at the console on first boot.


use base 'basetest';
use warnings;
use strict;
use testapi;
use Utils::Systemd;

sub run {
    # Verify the login prompt is up
    assert_screen('login_prompt', 300);
    type_string('root');
    send_key('ret');

    assert_screen('password_prompt', 20);
    type_string('SuperS3cr3tPassw0rd');
    send_key('ret');

    # Wait until Rockstor has finished starting up
    # wait_still_screen(30);
    # Rockstor bootstrap can take a while on first run
    assert_screen('rockstsor_bootstrap_complete', 600);
    systemctl('is-active rockstor.service');
    assert_screen('rockstor_service_active', 60);

}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;
