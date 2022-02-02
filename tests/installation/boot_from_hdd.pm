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
# from: https://github.com/OSInside/kiwi-functional-tests/blob/master/tests/boot.pm
# and: https://github.com/os-autoinst/os-autoinst-distri-opensuse/blob/master/tests/jeos/firstrun.pm


use base 'basetest';
use warnings;
use strict;
use testapi;

sub run {
    # We first check whether the bootloader is visible
    assert_screen('kiwi_bootloader', 30);

    # Press the HOME key to stop grub timer and ensure the grub menu looks as
    # expected before booting from the system drive.
    send_key('home');
    assert_screen('kiwi_bootloader_Rockstor_NAS', 30);
    send_key('ret');

    # Check for the appearance of the login prompt. Use a 5-min timeout to give
    # the normal boot process ample time.
    assert_screen('login_prompt', 300);
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;
