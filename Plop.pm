package Plop;

use strict;
use warnings;
use Data::Dumper;
use base 'Exporter';
our @EXPORT_OK = qw( plop );

sub plop {
    my ( %hash ) = @_;
    my @names = sort { $a cmp $b } keys %hash;
    my @values = map { $hash{$_} } @names;
    return Data::Dumper->new( \@values, \@names )->Quotekeys( 0 )->Indent( 1 )->Dump;
}

1;
