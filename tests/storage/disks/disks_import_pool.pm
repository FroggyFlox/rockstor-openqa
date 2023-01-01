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

# This module is used to navigate to test the import of a pool


use base 'basetest';
use warnings;
use strict;
use testapi;
use Utils::Rockstor_webui qw(
    navigate_to_disks
    navigate_to_pools
);

sub run {

    # Get pool name from ENV or set it if not yet defined
    my $raid_level = get_var('RAID_LEVEL');

    # Navigate to the main Disks page
    navigate_to_disks();

    # Click the "import data" icon
    assert_and_click($raid_level . '_pool_click_import', 'timeout' => 30);

    # Confirm
    assert_and_click('disks_import_pool_confirm', 'timeout' => 30);
    # Verify we are back to the Disks page
    assert_screen('disks_page', 'timeout' => 60);

    # Navigate to the pools page and verify the presence of the imported pool
    navigate_to_pools();
    assert_screen('pools_page_'. $raid_level . '-pool_created', 'timeout' => 120);

}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;