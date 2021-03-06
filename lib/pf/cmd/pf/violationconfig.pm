package pf::cmd::pf::violationconfig;
=head1 NAME

pf::cmd::pf::violationconfig add documentation

=head1 SYNOPSIS

 pfcmd violationconfig get <all|defaults|vid>
       pfcmd violationconfig add <vid> [assignments]
       pfcmd violationconfig edit <vid> [assignments]
       pfcmd violationconfig delete <vid>

query/modify violations.conf configuration file

=head1 DESCRIPTION

pf::cmd::pf::violationconfig

=cut

use strict;
use warnings;
use pf::ConfigStore::Violations;
use base qw(pf::base::cmd::config_store);

sub configStoreName { "pf::ConfigStore::Violations" }

sub display_fields { qw(vid desc enabled auto_enable actions max_enable grace window vclose priority template button_text trigger vlan whitelisted_roles target_category ) }

sub idKey { 'vid' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2016 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and::or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;

