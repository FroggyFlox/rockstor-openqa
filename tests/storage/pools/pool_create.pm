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
use utils;
use Utils::Rockstor_webui;

sub run {

    # Get pool name from ENV or set it if not yet defined
    set_pool_name unless get_var('POOL_NAME');
    my $pool_name = get_var('POOL_NAME');
    my $raid_level = get_var('RAID_LEVEL');

    # Navigate to Pools page
    navigate_to_pools();

    # Click on Create Pool
    assert_and_click('create_pool_button', 'timeout' => 30);

    # Enter name
    ## Focus on the 'Name' field
    assert_and_click('create_pool_name_field', 'timeout' => 30);
    wait_screen_change { type_string($pool_name, max_interval => utils::SLOW_TYPING_SPEED); };
    send_key('tab');

    # Choose raid level
    ## Click drop-down menu
    assert_and_click('create_pool_raid_configuration_click_drop_down', 'timeout' => 30);
    ## Click raid level
    assert_and_click('create_pool_raid_configuration_click_' . $raid_level, 'timeout' => 30);
    send_key('tab');

    # Click submit
    ## Because no disk was selected, the UI should alert the user
    ## that the minimum number of disks required for $raid_level is not met
    assert_and_click('create_pool_' . $raid_level . '_no_disk_submit', 'timeout' => 30);
    assert_screen('create_pool_' . $raid_level . '_missing_disks', 'timeout' => 30);

    # Select disks
    ## Click select all
    assert_and_click('create_pool_select_all_disks', 'timeout' => 30);
    # Verify results and click Submit
    assert_and_click('create_pool_' . $raid_level . '_verify_and_submit', 'timeout' => 30);

    # Verify Pool created
    assert_screen('pools_page_' . $raid_level . '-pool_created', 'timeout' => 120);
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;