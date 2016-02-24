package pfappserver::Form::Config::PortalModule::AuthModule;

=head1 NAME

pfappserver::Form::Config::PortalModule::AuthModule

=head1 DESCRIPTION

Form definition to create or update an authentication portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule';

use captiveportal::DynamicRouting::AuthModule;
sub for_module {'captiveportal::DynamicRouting::AuthModule'}

## Definition
has_field 'source_id' =>
  (
   type => 'Select',
   multiple => for_module->does('captiveportal::DynamicRouting::MultiSource'),
   label => 'Sources',
   options_method => \&options_sources,
   element_class => ['chzn-select'],
   element_attr => {'data-placeholder' => 'Click to add a source'},
   tags => { after_element => \&help,
             help => 'The sources to use in the module' },
  );

has_field 'custom_fields' =>
  (
   type => 'Select',
   multiple => 1,
   label => 'Sources',
   options_method => \&options_custom_fields,
   element_class => ['chzn-select'],
   element_attr => {'data-placeholder' => 'Click to add a required field'},
   tags => { after_element => \&help,
             help => 'The additionnal fields that should be required for registration' },
  );

has_field 'with_aup' =>
  (
   type => 'Checkbox',
   label => 'Require AUP',
   checkbox_value => '1',
   default => for_module->meta->get_attribute('with_aup')->default,
   tags => { after_element => \&help,
             help => 'Require the user to accept the AUP' },
  );

has_field 'signup_template' =>
  (
   type => 'Text',
   label => 'Signup template',
   required => 1,
   default => for_module->meta->get_attribute('signup_template')->default,
   tags => { after_element => \&help,
             help => 'The template to use for the signup' },
  );


sub child_definition {
    return (qw(source_id custom_fields with_aup signup_template), auth_module_definition());
}

# To override in the child modules
sub auth_module_definition {
    return ();
}

sub options_sources {
    my ($self) = @_;
    require pf::authentication;
    return map { 
        pf::authentication::getAuthenticationSource($_)->isa(for_module->meta->get_attribute('source')->isa) ? $_->id : ()
    } @{pf::authentication::getAllAuthenticationSources()};
}

sub options_custom_fields {
    return @pf::person::PROMPTABLE_FIELDS;
}


=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2016 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
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

__PACKAGE__->meta->make_immutable;
1;