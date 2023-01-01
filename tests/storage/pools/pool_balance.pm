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

# This module is used to navigate to the Storage > Pools page


use base 'basetest';
use warnings;
use strict;
use testapi;

sub run {

    # Click on the "Balance" tab
    assert_and_click('pool_detail_click_balance_tab', 'timeout' => 30);

    # Click on "Start a new balance"
    assert_and_click('pool_detail_balance_click_start_balance', 'timeout' => 30);

    # Click Start
    assert_and_click('pool_detail_start_balance_click_start', 'timeout' => 30);

    # Assert status says running
    assert_and_click('pool_detail_balance_running', 'timeout' => 30);

    # Reload and revisit balance tab until balance has finished
    for my $retry (1 .. 10) {
        send_key('f5');
        # Click on the balance tab
        assert_and_click('pool_detail_click_balance_tab', 'timeout' => 30);
        # Assert status says finished:
        #   - if finished: exit loop
        #   - if not: keep trying
        last if check_screen('pools_detail_balance_finished', 'timeout' => 60);
        die "Unable to see the balance as 'finished'" if $retry == 10;
    }
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;