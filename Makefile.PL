use inc::Module::Install;

name 'Catalyst-Controller-FormBuilder';
all_from 'lib/Catalyst/Controller/FormBuilder.pm';

# Specific dependencies

requires 'CGI::FormBuilder'               => '3.02';
requires 'Catalyst::Runtime'              => '5.7';
requires 'Class::Accessor::Fast'          => '0.25';
requires 'Test::WWW::Mechanize::Catalyst' => '0.37';
requires 'Tie::IxHash'                    => '1.21';
recommends 'Catalyst::View::TT'           => '0.23';

auto_install;
WriteAll;
