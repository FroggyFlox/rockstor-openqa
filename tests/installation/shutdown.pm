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
# https://github.com/OSInside/kiwi-functional-tests/blob/6cb9cd58071a03f2377ba069de5f2a14091ce4a2/tests/reboot.pm


use base 'basetest';
use warnings;
use strict;
use testapi;

sub run {
    # Clear the screen and verify we are logged in
    enter_cmd('clear');
    assert_screen('logged_in_textmode', 30);

    # the SUT can shutdown faster than the reply reaching the worker via the
    # serial line, which causes a failure, albeit the SUT has been turned off
    enter_cmd('shutdown -hP now');
    assert_shutdown();
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;
