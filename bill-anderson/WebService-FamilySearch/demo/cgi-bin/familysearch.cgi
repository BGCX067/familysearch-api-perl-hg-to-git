#! /usr/bin/perl

use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser carpout);
use CGI::Session;
use WebService::FamilySearch;
use HTML::Template;

carpout(STDOUT);

use strict;
use warnings;

my $cgi = new CGI;

my $template = HTML::Template->new(filename => 'familysearch.tmpl');

my $fs = WebService::FamilySearch->new('URL'      => 'http://www.dev.usys.org',
                                       'Key'      => 'XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX'
                                      );

print $cgi->header;

my $oauth_verifier = $cgi->param('oauth_verifier');
my $oauth_token    = $cgi->param('oauth_token');
my $cgi_sess       = CGI::Session->load($cgi->param('cgi_sess'));

my $oauth_secret   = $cgi_sess->param('secret');
my ($oauth_access_token, $oauth_token_secret) = $fs->get_access_token($oauth_verifier, $oauth_token, $oauth_secret);

# After call to get_access_token, we are all authenticated. The oauth_access_token
# is the sesson ID, which is stored in the module

$template->param('content' => "Your session is: $oauth_access_token");
$cgi_sess->param('fs_sess', $oauth_access_token);

print $template->output;

$cgi_sess->flush;
