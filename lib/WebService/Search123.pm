package WebService::Search123;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use Encode;
use LWP::UserAgent;
use URI;
use XML::LibXML;
use Time::HiRes qw(gettimeofday);

use WebService::Search123::Ad;

use constant HOSTNAME => 'cgi.search123.uk.com';
use constant PATH     => '/xmlfeed';

our $DEBUG => 0;

=head1 NAME

WebService::Search123 - Interface to the Search123 API.

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';

$VERSION = eval $VERSION;

=head1 SYNOPSIS

The Search123 API interface.

 use WebService::Search123;

 my $s123 = WebService::Search123->new( aid => 99999 );
 
 foreach my $ad ( $s123->ads )
 {
    print $ad->title;
 }

=cut

=head1 DESCRIPTION

Interface to the Search123 platform for searching for ads.

 use WebService::Search123;
 
 $WebService::Search123::DEBUG = 1;
 
 my $s123 = WebService::Search123->new(
     aid     => 10057,
     keyword => 'ipod',
     client  => {
         ip  => '88.208.204.52',
         ua  => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.59.8 (KHTML, like Gecko) Version/5.1.9 Safari/534.59.8',
         ref => 'http://www.ultimatejujitsu.com/jujitsu-for-beginners/',
     },
 );
 
 binmode STDOUT, ":encoding(UTF-8)";
 
 foreach my $ad ( $s123->ads )
 {
     print $ad->title . "\n";
 }

=cut

=head1 METHODS

=head2 Attributes

=head3 ua

The internal L<LWP::UserAgent> to use.

=cut

has ua => ( is => 'rw', isa => 'LWP::UserAgent', default => sub { LWP::UserAgent->new( agent => 'WebService-Search123/$VERSION' ) } );

=head3 secure

Flag to indicate whether to use https or http (default).

=cut

has secure => ( is => 'rw', isa => 'Bool', default => 0 );

=head3 aid

Your account ID with Search123.

=cut

has aid     => ( is => 'rw', isa => 'Num', trigger => \&_reset );

=head3 keyword

The user-supplied keywords to search against.

=cut

has keyword => ( is => 'rw', isa => 'Str', trigger => \&_reset );

=head3 ads

The returned list of ad objects based on the criteria supplied.

See L<WebService::Search123::Ad> for details on these objects.

=cut

has _ads => ( is      => 'rw',
              isa     => 'ArrayRef[WebService::Search123::Ad]',
              lazy    => 1,
              builder => '_build__ads',
              clearer => '_clear__ads',
              traits  => ['Array'],
              handles => { ads     => 'elements',
                           num_ads => 'count',
              },
);


has client => ( is      => 'rw',
                isa     => 'HashRef',
                traits  => ['Hash'],
                handles => { get_client => 'get',
                             set_client => 'set',
                },
);

has _type => ( is => 'rw', isa => 'Str', default => 'q', trigger => \&_reset );

has _uid => ( is => 'rw', isa => 'Str', default => 1 );

has _request => ( is => 'rw', isa => 'URI', clearer => '_clear__request' );

has _response => ( is => 'rw', isa => 'HTTP::Response', clearer => '_clear__response' );

=head3 took

How long the underlying HTTP API request took.

=cut

has took => ( is => 'rw', isa => 'Num' );

sub _reset
{
    my ( $self ) = @_;

    $self->_clear__request;
    $self->_clear__response;
    $self->_clear__ads;
}

sub _build__ads
{
    my ($self) = @_;

    my $uri = URI->new( ( $self->secure ? 'https' : 'http' ) . '://' . HOSTNAME . PATH );

    $uri->query_form( $uri->query_form, aid => $self->aid );

    $uri->query_form( $uri->query_form, query      => $self->keyword           ) if $self->keyword;
    $uri->query_form( $uri->query_form, type       => $self->_type             ) if $self->_type;
    $uri->query_form( $uri->query_form, uid        => $self->_uid              ) if $self->_uid;
    $uri->query_form( $uri->query_form, ip         => $self->get_client('ip')  ) if $self->get_client('ip');
    $uri->query_form( $uri->query_form, client_ref => $self->get_client('ref') ) if $self->get_client('ref');
    $uri->query_form( $uri->query_form, client_ua  => $self->get_client('ua')  ) if $self->get_client('ua');

    $self->_request( $uri );

    warn $uri->as_string if $DEBUG;

    my $before = gettimeofday();

    $self->_response( $self->ua->get( $uri->as_string ) );

    $self->took( gettimeofday() - $before );

    warn $self->_response->code . ' ' . $self->_response->message if $DEBUG;

    warn $self->took if $DEBUG;

    warn $self->_response->content if $DEBUG;

    my @ads = ();

    if ( $self->_response->is_success )
    {
        my $content = $self->_response->decoded_content;

        my $dom = XML::LibXML->load_xml( string => $content );

        foreach my $node ( $dom->findnodes('/S123_SEARCH/RETURN/LISTING') )
        {
            my $ad = WebService::Search123::Ad->new(
                 title        => $node->findvalue('TITLE'),
                 description  => $node->findvalue('DESCRIPTION'),
                _url          => $node->findvalue('REDIRECT_URL'),
                 display_url  => $node->findvalue('SITE_URL'),
            );

            push @ads, $ad;
        }
    }

    return \@ads;
}


__PACKAGE__->meta->make_immutable;


1;
