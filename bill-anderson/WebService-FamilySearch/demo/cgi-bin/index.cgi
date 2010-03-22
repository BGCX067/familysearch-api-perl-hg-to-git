#! /usr/bin/perl

use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser carpout);
use CGI::Session;
use HTML::Template;
use WebService::FamilySearch;

carpout(STDOUT);

use strict;
use warnings;

my $cgi = new CGI;

my $template = HTML::Template->new(filename => 'index.tmpl');

my $cgi_sess = new CGI::Session;
$cgi_sess->expire("2h");

my $fs = WebService::FamilySearch->new('URL'           => 'http://www.dev.usys.org',
                                       'Key'           => 'XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX',
                                       'Redirect'      => 'https://www.yoursite.com/cgi-bin/familysearch/familysearch.cgi?cgi_sess='.$cgi_sess->id,
                                      );

print $cgi->header;

my $status = $fs->status;

my $session;

if ($status eq 'Ok') {

    # Form to send user to family search authorize

    my ($oauth_token, $oauth_token_secret) =  $fs->get_request_token;

    # Store oauth_token_secret for later use;

    $cgi_sess->param('secret', $oauth_token_secret);
    $cgi_sess->param('token', $oauth_token);

    $template->param('auth_url' => $fs->{'authorize.url'});
    $template->param('token' => $oauth_token);

    print $template->output; 

}
else {
   print "Family Search Status is $status";
}

# Store hashref to persistent storage
$cgi_sess->flush;
