package WebService::Search123::Ad;

use Moose;
use namespace::autoclean;

use URI;

=head1 NAME

WebService::Affiliate::Voucher::AffiliateWindow - AffiliateWindow specific voucher code model.

=cut

has  title        => ( is => 'rw', isa => 'Str',                                           );
has  description  => ( is => 'rw', isa => 'Str',                                           );
has _redirect_url => ( is => 'rw', isa => 'Str',                                           );
has  redirect_url => ( is => 'rw', isa => 'Maybe[URI]', lazy => 1, builder => '_build_url' );
has  display_url  => ( is => 'rw', isa => 'Str',                                           );

=head1 SYNOPSIS

Models a AffiliateWindow voucher code.

=cut

=head1 DESCRIPTION

=cut



=head1 METHODS

=head2 Attributes

=cut



=head1 METHODS

=head2 Class Methods

=head3 new


=cut

__PACKAGE__->meta->make_immutable;

=head1 AUTHOR

Rob Brown, C<< <rob at intelcompute.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-webservice-affiliate at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-Affiliate>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WebService::Affiliate

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-Affiliate>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-Affiliate>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-Affiliate>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-Affiliate/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Rob Brown.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of WebService::Affiliate
