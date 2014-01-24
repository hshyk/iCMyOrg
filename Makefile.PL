#!C:\Perl\bin\perl.exe
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'Site';
all_from 'lib/Site.pm';
requires 'Catalyst::Runtime' => '5.90018';
requires 'namespace::autoclean';
requires 'Class::Load';
requires 'Moose';
requires 'MooseX::NonMoose';
requires 'MooseX::MarkAsMethods';
requires 'Config::General';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::DBI';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Authorization::ACL';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Plugin::Compress::Gzip';
requires 'Catalyst::Plugin::PageCache';
requires 'Catalyst::Plugin::CustomErrorMessage';
requires 'Catalyst::Plugin::Scheduler';
requires 'Catalyst::Plugin::Sitemap';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Authentication::Realm::SimpleDB';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Controller::Combine';
requires 'Catalyst::Controller::REST';
requires 'Template::AutoFilter';
requires 'Catalyst::Helper::View::TT';
requires 'Catalyst::Engine::Apache';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::Model::Factory::PerRequest';
requires 'Catalyst::View::Email';
requires 'Catalyst::View::JSON';
requires 'DBIx::Class::TimeStamp';
requires 'DBIx::Class::EncodedColumn';
requires 'DBIx::Class::PassphraseColumn';
requires 'Authen::Passphrase::BlowfishCrypt';
requires 'DBD::Pg';
requires 'DateTime::Format::Pg';
requires 'HTML::FormHandler::Model::DBIC';
requires 'Net::SSL';
requires 'Net::OAuth';
requires 'LWP::UserAgent';
requires 'HTTP::BrowserDetect';
requires 'JSON';
requires 'Try::Tiny';
requires 'Data::Random';
requires 'Date::Calc';
requires 'Geo::Coder::Google';
requires 'Geo::Coder::GoogleMaps';
requires 'Geo::IP::PurePerl';
requires 'Image::Magick';
requires 'HTML::FormHandlerX::Field::reCAPTCHA';
requires 'Perl6::Junction';
requires 'File::Find::Rule';
requires 'File::Type';
requires 'File::Remove';
requires 'File::Path';
requires 'List::Flatten';
requires 'Archive::Zip';
requires 'Archive::Zip::Member';
requires 'Archive::Zip::MemberRead';
requires 'Getopt::Long';
requires 'Date::Manip';
requires 'XML::LibXML';
requires 'String::Random';
requires 'JavaScript::Minifier::XS';
requires 'CSS::Minifier::XS';
requires 'Template::Plugin::Filter::Minify::JavaScript::XS';
requires 'Template::Plugin::Filter::Minify::CSS::XS';
test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
