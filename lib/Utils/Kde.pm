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


package Utils::Kde;

use base 'Exporter';
use Exporter;
use strict;
use warnings;
use testapi qw(send_key assert_screen);

our @EXPORT = qw(
  launch_krunner
);

=head1 Utils::Kde

C<Utils::Kde> - Library for interacting with the KDE Plasma desktop

=cut


=head2 launch_krunner

    launch_krunner();

Launch KRunner

=cut
sub launch_krunner {
    send_key('alt-f2');
    assert_screen('krunner_started');
}

1;
