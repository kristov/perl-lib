package ACME::Geo::Config;

use strict;
use warnings;
use parent qw( Exporter );

our @EXPORT_OK = qw( PT );

our $PRECISION = 4;
my $ptemplate;

sub PT {
    if ( !defined $ptemplate ) {
        $ptemplate = return '%0.' . $PRECISION . 'f';
    }
    return $ptemplate;
}

1;
