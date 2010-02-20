package WebService::FamilySearch;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

use LWP::UserAgent;

# use LWP::Debug qw(+);

use XML::Simple;

our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

my $revision_str = '$Revision: 8 $'; 
(our $VERSION = $revision_str) =~ s/^\$Revision: (\d+) \$$/0.01.$1/;


sub new {
    my $proto = shift;
    my %params = @_;
    my $class = ref($proto) || $proto;
    my $self  = {};
    
    $self->{'URL'}       = $params{'URL'};
    $self->{'Name'}      = $params{'Name'};
    $self->{'Password'}  = $params{'Password'};
    $self->{'Key'}       = $params{'Key'};

    bless ($self, $class);
    return $self;
}

sub url {
    my $self = shift;
    if (@_) { $self->{URL} = shift }
    return $self->{URL};
}

sub name {
    my $self = shift;
    if (@_) { $self->{Name} = shift }
    return $self->{Name};
}

sub password {
    my $self = shift;
    if (@_) { $self->{Password} = shift }
    return $self->{Password};
}

sub key {
    my $self = shift;
    if (@_) { $self->{Key} = shift }
    return $self->{Key};
}

sub response_raw {
    my $self = shift;
    return $self->{'response_raw'};
}

sub response_xml {
    my $self = shift;
    return $self->{'response_xml'};
}

sub _request {
    my $self = shift;
    my $uri = shift;

    $self->{'uri'} = $uri;

    my $ua = LWP::UserAgent->new;

    $ua->agent("WebService::FamilySearch/0.1");

    my $req = HTTP::Request->new(GET => $uri);
    $req->authorization_basic($self->name, $self->password);

    my $res = $ua->request($req);

    # Raw LWP::UserAgent response
    $self->{'response_raw'} = $res;

    # Raw XML from response
    $self->{'response_xml'} = $res->content;

    my $xs = XML::Simple->new();
    my $ref = $xs->XMLin($res->content);

    # XML parsed by XML::Simple into hash
    return $ref;

}

##
## Identity Module v1
##

sub login {
    my $self = shift;

    my $uri = $self->url."/identity/v1/login?key=".$self->key;
    
    my $res = $self->_request($uri);

    if ($res->{'statusCode'} eq 200) {
        $self->{'sessionId'} = $res->{'session'}->{'id'};
        return $res; 
    }
    else {
        die "Fatal login error. ".$res->{'statusMessage'}."\n";
        return undef;
    }

}

sub logout {
    my $self = shift;

    my $uri = $self->url."/identity/v1/logout?key=".$self->key;

    my $res = $self->_request($uri);

    if ($res->{'statusCode'} eq 200) {
        $self->{'sessionId'} = $res->{'session'}->{'id'};
        return $res;
    }
    else {
        die "Fatal logout error. ".$res->{'statusMessage'}."\n";
        return undef;
    }

}

##
## Identity Module v2
##



##
## Family Tree Module v2
##

sub search {
    my $self = shift;
    my %params = @_; 

    my $uri = $self->url."/familytree/v2/search/";

    $uri .= "?sessionId=".$self->{'sessionId'};

    foreach my $param (keys %params) {
       $uri .= "&".$param."=".$params{$param};
    }

    my $res = $self->_request($uri);

    if ($res->{'statusCode'} eq 200) {
        return $res;
    }
    else {
        die "Fatal search error. ".$res->{'statusMessage'}."\n";
        return undef;
    }


}

sub user_read {
    my $self = shift;

    my $uri = $self->url."/familytree/v2/user/";

    $uri .= "?sessionId=".$self->{'sessionId'};

    my $res = $self->_request($uri);

    if ($res->{'statusCode'} eq 200) {
        return $res;
    }
    else {
        die "Fatal user read error. ".$res->{'statusMessage'}."\n";
        return undef;
    }


}

##
## Authorities module v1
##


##
## System module v1
##

sub status { 
   my $self = shift;

    my $uri = $self->url."/system/v1/status";

    my $res = $self->_request($uri);

    if ($res->{'status'}->{'code'} eq 'Ok') {
        return $res;
    }
    else {
        die "Fatal system status error. ".$res->{'statusMessage'}."\n";
        return undef;
    }

}

##
## Temple module v1
##

sub temples {
   my $self = shift;

    my $uri = $self->url."/temple/v1/temple";

    $uri .= "?sessionId=".$self->{'sessionId'};

    my $res = $self->_request($uri);

    # if (1) {
    if ($res->{'statusCode'} eq 200) {
        return $res;
    }
    else {
        die "Fatal temple error. ".$res->{'statusMessage'}."\n";
        return undef;
    }

}

1;

__END__

=head1 NAME

WebService::FamilySearch - Perl extension for the Family Search API

=head1 SYNOPSIS

 my $fs = WebService::FamilySearch->new('URL'      => 'http://www.dev.usys.org',
                                        'Name'     => 'api-user-0000',
                                        'Password' => 'xxxx',
                                        'Key'      => 'XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX'
                                       );

 my $xml_hash;

 $xml_hash = $fs->status;

 $xml_hash = $fs->login;

 $xml_hash = $fs->user_read;

 $xml_hash = $fs->temples;

 $xml_hash = $fs->search('familyName' => 'Smith',
                         'givenName'  => 'John',
                         'maxResults' => '2'
                        );

 $xml_hash = $fs->logout;

=head1 DESCRIPTION

Perl extension for the Family Search API

=head1 METHODS

=head2 new 

Constructs the FamilySearch object.

=head2 url

Sets/gets the base URL for searches

=head2 name

Sets/gets the user name

=head2 password

Sets/get the password for the user

=head2 key

Sets/gets the developer's key

=head2 response_raw

Gets the HTTP::Response object for the mose recent request 

=head2 response_xml

Gets the response to the most recent request, in XML

=head2 login

Logs into the family search system. Returns the response parsed by XML::Simple

=head2 logout

Logs out of the family search system. Returns the response parsed by XML::Simple

=head2 search

Performs a search based on the passed parameters. Returns the response parsed by XML::Simple

=head2 user_read

Get information on the currently logged on user. Returns the response parsed by XML::Simple

=head2 status

Gets system status. Returns the response parsed by XML::Simple

=head2 temples

Get a list of temples and their codes. Returns the response parsed by XML::Simple

=head1 REQUIREMENTS

LWP::UserAgent, XML::Simple

=head1 SEE ALSO

L<http://devnet.familysearch.org/docs/>

=head1 AUTHOR

Bill Anderson E<lt>bill@anderson-ent.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Bill Anderson 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
