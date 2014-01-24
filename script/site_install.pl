#!/usr/bin/perl

use Catalyst::Runtime;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods;
use Config::General;
use Catalyst::Plugin::ConfigLoader;
use Catalyst::Plugin::Static::Simple;
use Catalyst::Plugin::Authentication;
use Catalyst::Plugin::Session;
use Catalyst::Plugin::Session::State::Cookie;
use Catalyst::Plugin::Session::Store::DBI;
use Catalyst::Plugin::Authorization::Roles;
use Catalyst::Plugin::Authorization::ACL;
use Catalyst::Plugin::StackTrace;
use Catalyst::Plugin::Compress::Gzip;
use Catalyst::Plugin::PageCache;
use Catalyst::Plugin::CustomErrorMessage;
use Catalyst::Plugin::Scheduler;
use Catalyst::Plugin::Sitemap;
use Catalyst::Authentication::Store::DBIx::Class;
use Catalyst::Authentication::Realm::SimpleDB;
use Catalyst::Action::RenderView;
use Catalyst::Controller::Combine;
use Catalyst::Controller::REST;
use Template::AutoFilter;
use Catalyst::Helper::View::TT;
use Catalyst::Engine::Apache;
use Catalyst::Model::DBIC::Schema;
use Catalyst::Model::Factory::PerRequest;
use Catalyst::View::Email;
use Catalyst::View::JSON;
use DBIx::Class::TimeStamp;
use DBIx::Class::EncodedColumn;
use DBIx::Class::PassphraseColumn;
use Authen::Passphrase::BlowfishCrypt;
use DBD::Pg;
use DateTime::Format::Pg;
use HTML::FormHandler::Model::DBIC;
use Net::OAuth;
use LWP::UserAgent;
use HTTP::BrowserDetect;
use JSON;
use Try::Tiny;
use Data::Random;
use Date::Calc;
use Geo::Coder::Google;
use Geo::Coder::GoogleMaps;
use Geo::IP::PurePerl;
use Image::Magick;
use HTML::FormHandlerX::Field::reCAPTCHA;
use Perl6::Junction;
use File::Find::Rule;
use File::Type;
use File::Remove;
use File::Path;
use List::Flatten;
use Archive::Zip;
use Archive::Zip::Member;
use Archive::Zip::MemberRead;
use Getopt::Long;
use Date::Manip;
use XML::LibXML;
use String::Random;
use JavaScript::Minifier::XS;
use CSS::Minifier::XS;
use Template::Plugin::Filter::Minify::JavaScript::XS;
use Template::Plugin::Filter::Minify::CSS::XS;

my $conffile = '../site.conf';
if (-e $conffile) {
	print "Your application already has a configuration file (site.conf), please delete it if you are installing for the first time.";
	exit();
}

my $dbname = &promptUser("Please enter the name of your database ");
my $dbhost = &promptUser("Please enter the hostname of your database (leave blank for default) ");
my $dbport = &promptUser("Please enter the port of your database (leave blank for default) ");

my $dbusername = &promptUser("Please enter the username of your database ");

my $dbpassword = &promptUser("Please enter the password of your database ");


my $dbstring = "dbi:Pg:dbname=".$dbname;

if ($dbhost ne '') {
	$dbstring .= ";host=".$dbhost;
}

if ($dbport ne '') {
	$dbstring .= ";port=".$dbport;
}

my $dbh = DBI->connect($dbstring, $dbusername, $dbpassword, {AutoCommit => 0}) || die "Could not connect to the database with the following error: ".$_;

open(FILE, "<:utf8", "../db/site.sql") || die "Cannot open SQL file!: $!";
my @sql = <FILE>;
close(FILE);

open(FILE, "<:utf8", "../site.conf.template") || die "Cannot open Template (site.conf.template) file!: $!";
my @newconffile = <FILE>;
close(FILE);

for (@newconffile) {
	s/DB_NAME/$dbname/g;
	s/DB_STRING/$dbstring/g;
	s/DB_USER/$dbusername/g;
	s/DB_PASSWORD/$dbpassword/g;
}

print "Creating your database....";
$dbh->do(join(" ", @sql)) || die "Could not create your database with the following error: ".$_;
my $adminpassword = '{CRYPT}$2a$14$sjUZKyMQ0B7ZWy4i8GeJTOkxVeKAkVBRMA6wgj.7S2ZYyMx89y/.i';
$dbh->do("INSERT INTO users (email, first_name, last_name, date_added, date_modified, username, authid, password, provider_id, status_id) SELECT 'test\@test.com','Admin','User', NOW(), NOW(), 'administrator','administrator','$adminpassword', providers.provider_id, status.status_id FROM authproviders providers, status status WHERE providers.provider_name = 'Site' AND status.status_name = 'Active'");

$dbh->do("INSERT INTO users_roles (user_id, role_id) SELECT users.user_id, roles.role_id FROM roles roles, users users WHERE role = 'Admin' AND users.username = 'administrator';");

my $name = &promptUser("Please enter the name of your application ");
for (@newconffile) {
	s/SITE_NAME/$name/g;
}

my $organism = &promptUser("Please enter the name of the organism (plural form, first letter uppercase) ");
for (@newconffile) {
	s/PLURAL_ORGANISM_NAME/$organism/g;
}

my $organism_singular = &promptUser("Please enter the name of the organism (singular form, first letter uppercase) ");
for (@newconffile) {
	s/SINGULAR_ORGANISM_NAME/$organism_singular/g;
}

my $hashost = &promptUser("Will this organism have a host (0 for NO, 1 for YES)? ");
my $host = '';
my $host_singular = '';
if ($hashost != 0) {
	$host =  &promptUser("Please enter the name of the host (plural form, first letter uppercase) ");
	$host_singular =  &promptUser("Please enter the name of the host (singular form, first letter uppercase) ");
	for (@newconffile) {
		s/HOST_ENABLED/1/g;
		s/PLURAL_HOST_NAME/$host/g;
		s/SINGULAR_HOST_NAME/$host_singular/g;
	}
}
else {
	for (@newconffile) {
		s/HOST_ENABLED/0/g;
	}
}

my $latitude = &promptUser("Please enter the default central latitude of your application for the map ");
my $longitude = &promptUser("Please enter the default central longitude of your application map ");
my $zoom = &promptUser("Please enter the default zoom level of your application map ");

for (@newconffile) {
	s/MAP_LATITUDE/$latitude/g;
	s/MAP_LONGITUDE/$longitude/g;
	s/MAP_ZOOM/$zoom/g;
}

my $characters = &promptUser("Please enter all characters, separated by a pipe character (|) ");
my $allcharacters = '';
my $allnoimage = '';
my $x = 1;

$dbh->do("INSERT INTO charactertypes (character_type) VALUES ('All');");
my @characters = split('\|', $characters);
foreach my $character(@characters) {
	$dbh->do("INSERT INTO charactertypes (character_type) VALUES ('".$character."');");
	$allcharacters .= $character.'	'.$x.'
				';
	$allnoimage .= $character.'	/static/images/no-image.jpg
				';
	for (@newconffile) {
		s/CHARACTER_TYPES/$allcharacters/g;
		s/NO_IMAGE/$allnoimage/g;
	}
	$x++;
}


my $defaultcharactertype =  &promptUser("Please enter the default character type from the list above ");

for (@newconffile) {
	s/DEFAULT_CHARACTER_TYPE/$defaultcharactertype/g;
}

my $hashabitat =  &promptUser("Will the ".lc($organism_singular)." have a habitat set as a state for the description search (0 for NO, 1 for YES)? ");
my $habitatstate = '';
my $habitats = '';
if ($hashabitat ne 0) {
	$habitatstate = &promptUser("Please enter the name of the habitat state ");
	$dbh->do("INSERT INTO characters (character_name, is_numeric, character_type_id) SELECT '".$habitatstate."', FALSE, character_type_id FROM charactertypes WHERE character_type = 'All';");
	$habitats = &promptUser("Please enter the characters which will use the habitat (or enter All for all characters), separated by a pipe character (|) ");
	my $allhabitats = '';
	my @habitats = split('\|', $habitats);
	foreach my $habitat(@habitats) {
		$allhabitats .= $habitat.'	'.'1
				';
	}
	for (@newconffile) {
		s/HABITAT_ENABLED/1/g;
		s/HABITAT_CHARACTER/$habitatstate/g;
		s/ALL_HABITATS/$allhabitats/g;
	}
}
else {
	for (@newconffile) {
		s/HABITAT_ENABLED/0/g;
	}
}


my $hasdatesearch =  &promptUser("Do you want to enable character day of year searching (0 for NO, 1 for YES)? ");
my $datestate = '';
my $datescharacter = '';

if ($hasdatesearch != 0) {
	$datestate = &promptUser("Please enter the name of the day of year state ");
	$datescharacter = &promptUser("Please enter the characters which will use the day of year search (or enter All for all characters), separated by a pipe character (|) ");
	my $alldates = '';
	my @datescharacter = split('\|', $datescharacter);
	foreach my $date(@datescharacter) {
		$datescharacter .= $date.'	'.'1
				';
	}
	for (@newconffile) {
		s/DATE_SEARCH_ENABLED/1/g;
		s/DATE_CHARACTER_TYPE/$datestate/g;
		s/ALL_CHARACTER_DATES/$datescharacter/g;
	}
}
else {
	for (@newconffile) {
		s/HABITAT_ENABLED/0/g;
	}
}

my $hasraritysearch =  &promptUser("Do you want to enable character rarity searching (0 for NO, 1 for YES)? ");
my $rarityname = '';
my $raritystates = '';
my $raritysearchcharacters = '';

if ($hasraritysearch != 0) {
	$rarityname = &promptUser("What is the name of the rarity character?");
	my $raritycount =  &promptUser("How many rarity states are there? ");
	for (my $x = 1; $x <= $raritycount; $x++) {
		my $state = &promptUser("Please enter the name of the rarity state.  The first ones entered are the rarest ones.");
		$raritystates .= $state.'	'.$x.'
				';
	}
	
	my $raritysearch = &promptUser("Please enter the rarity states which you would like to search on (or enter All for all characters), separated by a pipe character (|) ");
	my @raritysearch = split('\|', $raritysearch);
	foreach my $rare(@raritysearch) {
		$raritysearchcharacters .= $rare.'	'.'1
				';
	}
	for (@newconffile) {
		s/RARITY_ENABLED/1/g;
		s/RARITY_CHARACTER/$rarityname/g;
		s/RARITY_ORDER/$raritystates/g;
		s/ALL_RARITY/$raritysearchcharacters/g;
	}
}
else {
	for (@newconffile) {
		s/RARITY_ENABLED/0/g;
	}
}

my $habitatscore = 0;
my $rarityscore = 0;
my $datescore = 0;
my $locationscore = 0;
my $pointscore = 0;
my $statescore = &promptUser("Choose a number between 1 (lowest) and 20 (highest) for how much the states should be weighted");

if ($hashabitat) {
	 $habitatscore = &promptUser("Choose a number between 1 (lowest) and 20 (highest) for how much the habitat should be weighted");
}
if ($hasraritysearch) {
	$rarityscore = &promptUser("Choose a number between 1 (lowest) and 20 (highest) for how much the rarity should be weighted");
}
if ($hasdatesearch) {
	my $datescore = &promptUser("Choose a number between 1 (lowest) and 20 (highest) for how much the date should be weighted");
}

$locationscore = &promptUser("Choose a number between 1 (lowest) and 20 (highest) for how much the location nearby an observation should be weighted");
$pointscore = &promptUser("Choose a number between 1 (lowest) and 20 (highest) for how much the observation points nearby a specified point should be weighted");

for (@newconffile) {
		s/STATE_SCORE/1/g;
		s/HABITAT_SCORE/$rarityname/g;
		s/RARITY_SCORE/$raritystates/g;
		s/DATE_SCORE/$datescore/g;
		s/LOCATION_SCORE/$locationscore/g;
		s/POINTS_SCORE/$pointscore/g;
}

my $areasearch = &promptUser("Should the observations and searches entered be restricted to an area(0 for NO, 1 for YES)?");
my $areasearchtype;
my $areasearchkey;
my $areasearchfullname;
if ($areasearch) {
	$areasearchtype = &promptUser("Enter the type of area search restriction (city, state, country, postal)");
	$areasearchtype = lc($areasearchtype);
	$areasearchkey = &promptUser("Enter the area name that you will check against.  For example, the state of New York would be NY. This corresponds to the Google Maps value.");
	$areasearchfullname = &promptUser("Enter the full name of the area you are searching against.");
	
		for (@newconffile) {
			s/AREA_SEARCH/1/g;
			s/AREA_TYPE/$areasearchtype/g;
			s/AREA_KEY/$areasearchkey/g;
			s/AREA_FULL_NAME/$areasearchfullname/g;
		}
}
else {
	for (@newconffile) {
		s/AREA_SEARCH/0/g;
	}
}

my $mobile = &promptUser("Use a mobile version (0 for NO, 1 for YES)?");
my $tablet = &promptUser("Use a tablet version (0 for NO, 1 for YES)?");
my $kiosk = &promptUser("Use a kiosk version (0 for NO, 1 for YES)?");
my $kioskip = '0.0.0.0';
if ($kiosk) {
	$kioskip = &promptUser("Enter the IP addresses of the kiosk (seperated by commas");
}
my $caching = &promptUser("Use caching (0 for NO, 1 for YES)?");

for (@newconffile) {
	s/USE_MOBILE/$mobile/g;
	s/USE_TABLET/$tablet/g;
	s/USE_KIOSK/$kiosk/g;
	s/KIOSK_IP/$kioskip/g;
	s/USE_CACHING/$caching/g;
}


my $facebook = &promptUser("Use a Facebook authentication (0 for NO, 1 for YES)? You must have a Facebook app to use the authentication method.");
my $facebookappid = '';
my $facebookkey = '';
my $facebooksecret = '';
if ($facebook) {
	$facebookappid = &promptUser("Enter your Facebook App ID");
	$facebookkey = &promptUser("Enter your Facebook Consumer Key");
	$facebooksecret = &promptUser("Enter your Facebook Consumer Secret");
	
	for (@newconffile) {
			s/USE_FACEBOOK/1/g;
			s/FACEBOOK_APP_ID/$facebookappid/g;
			s/FACEBOOK_KEY/$facebookkey/g;
			s/FACEBOOK_SECRET/$facebooksecret/g;
		}
}
else {
	for (@newconffile) {
		s/USE_FACEBOOK/0/g;
	}
}

my $twitter = &promptUser("Use a Twitter authentication (0 for NO, 1 for YES)? You must have a Twitter app to use the authentication method.");
my $twitterappid = '';
my $twittersecret = '';
if ($twitter) {
	$twitterappid = &promptUser("Enter your Twitter App ID");
	$twittersecret = &promptUser("Enter your Twitter Consumer Secret");
	
	for (@newconffile) {
			s/USE_TWITTER/1/g;
			s/TWITTER_APP_ID/$twitterappid/g;
			s/TWITTER_KEY/$twitterappid/g;
			s/TWITTER_SECRET/$twittersecret/g;
		}
}
else {
	for (@newconffile) {
		s/USE_UTWITTER/0/g;
	}
}


my $gmaps = &promptUser("Enter your Google Maps API Key");
for (@newconffile) {
	s/GMAP_KEY/$gmaps/g;
}

my $analytics = &promptUser("Use Google Analytics (0 for NO, 1 for YES)?");
my $analyticsid = '';
if ($analytics) {
	$analyticsid = &promptUser("Enter your Google Analytics ID");
	
	for (@newconffile) {
			s/USE_ANALYTICS/1/g;
			s/ANALYTICS_ID/$analyticsid/g;
		}
}
else {
	for (@newconffile) {
		s/USE_ANALYTICS/0/g;
	}
}

my $googlewebmaster = &promptUser("Use Google Webmaster Tools (0 for NO, 1 for YES)?");
my $googlewebmasterkey = '';
if ($googlewebmaster) {
	$googlewebmasterkey = &promptUser("Enter your Google Webmaster Verification Key");
	
	for (@newconffile) {
			s/USE_GOOGLE_WEBMASTER/1/g;
			s/GOOGLE_WEBMASTER_KEY/$googlewebmasterkey/g;
		}
}
else {
	for (@newconffile) {
		s/USE_GOOGLE_WEBMASTER/0/g;
	}
}

my $bingwebmaster = &promptUser("Use Bing Webmaster Tools (0 for NO, 1 for YES)?");
my $bingwebmasterkey = '';
if ($bingwebmaster) {
	$bingwebmasterkey = &promptUser("Enter your Bing Webmaster Verification Key");
	
	for (@newconffile) {
			s/USE_BING_WEBMASTER/1/g;
			s/BING_WEBMASTER_KEY/$bingwebmasterkey/g;
		}
}
else {
	for (@newconffile) {
		s/USE_BING_WEBMASTER/0/g;
	}
}

my $recaptcha = &promptUser("Use reCAPTCHA (0 for NO, 1 for YES)?");
my $recaptchapublic = '';
my $recaptchaprivate = '';
if ($recaptcha) {
	$recaptchapublic = &promptUser("Enter your reCAPTCHA Public Key");
	$recaptchaprivate = &promptUser("Enter your reCAPTCHA Public Key");
	
	
	for (@newconffile) {
			s/USE_RECAPTCHA/1/g;
			s/RECAPTCHA_PUBLIC_KEY/$recaptchapublic/g;
			s/RECAPTCHA_PRIVATE_KEY/$recaptchaprivate/g;
		}
}
else {
	for (@newconffile) {
		s/USE_RECAPTCHA/0/g;
	}
}

my $picup = &promptUser("Use Picup app (0 for NO, 1 for YES)? This is for image uploads for older iOS devices");

if ($picup) {
	for (@newconffile) {
			s/USE_PICUP/1/g;
		}
}
else {
	for (@newconffile) {
		s/USE_PICUP/0/g;
	}
}

my $os =  &promptUser("Will this site be hosted on a Unix or Windows operating system?");
my $separator = '/';
my $convert = '/usr/bin/convert';
my $mogrify = '/usr/bin/mogrify';
if ($os eq 'Windows') {
	$separator = '\\\\';
	$convert = &promptUser("Enter the path to Imagemagick's convert function");
	$mogrify = &promptUser("Enter the path to Imagemagick's mogrify function");

}

for (@newconffile) {
	s/IM_FILE_SEPARATOR/$separator/g;
	s/SYSTEM_CONVERT/$convert/g;
	s/SYSTEM_MOGRIFY/$mogrify/g;
}

my $email =  &promptUser("Enter From email address for the site");
my $replyemail =  &promptUser("Enter Default Reply email address for the site (may be same as previous)");

for (@newconffile) {
	s/DEFAULT_FROM_EMAIL/$email/g;
	s/REPLY_EMAIL/$replyemail/g;
	s/SYSTEM_MOGRIFY/$separator/g;
}

open (MYFILE, '>>../site.conf');
print MYFILE @newconffile;
close (MYFILE); 

$dbh->commit();


#----------------------------(  promptUser  )-----------------------------#
#                                                                         #
#  FUNCTION:	promptUser                                                #
#                                                                         #
#  PURPOSE:	Prompt the user for some type of input, and return the    #
#		input back to the calling program.                        #
#                                                                         #
#  ARGS:	$promptString - what you want to prompt the user with     #
#		$defaultValue - (optional) a default value for the prompt #
#                                                                         #
#-------------------------------------------------------------------------#

sub promptUser {

   #-------------------------------------------------------------------#
   #  two possible input arguments - $promptString, and $defaultValue  #
   #  make the input arguments local variables.                        #
   #-------------------------------------------------------------------#

   my ($promptString,$defaultValue) = @_;

   #-------------------------------------------------------------------#
   #  if there is a default value, use the first print statement; if   #
   #  no default is provided, print the second string.                 #
   #-------------------------------------------------------------------#

   if ($defaultValue) {
      print $promptString, "[", $defaultValue, "]: ";
   } else {
      print $promptString, ": ";
   }

   $| = 1;               # force a flush after our print
   $_ = <STDIN>;         # get the input from STDIN (presumably the keyboard)


   #------------------------------------------------------------------#
   # remove the newline character from the end of the input the user  #
   # gave us.                                                         #
   #------------------------------------------------------------------#

   chomp;

   #-----------------------------------------------------------------#
   #  if we had a $default value, and the user gave us input, then   #
   #  return the input; if we had a default, and they gave us no     #
   #  no input, return the $defaultValue.                            #
   #                                                                 # 
   #  if we did not have a default value, then just return whatever  #
   #  the user gave us.  if they just hit the <enter> key,           #
   #  the calling routine will have to deal with that.               #
   #-----------------------------------------------------------------#

   if (defined $defaultValue) {
      return $_ ? $_ : $defaultValue;    # return $_ if it has a value
   } else {
      return $_;
   }
}


