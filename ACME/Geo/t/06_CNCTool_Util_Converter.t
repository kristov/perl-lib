#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use lib qw( lib );

use_ok( 'ACME::Geo::Util::Converter' );

my $converter;
ok( $converter = ACME::Geo::Util::Converter->new, 'created converter' );

my ( $l1, $expected ) = build_layer();
my $json1;
ok( $json1 = $converter->geolayer_to_layerjson( $l1 ), 'converted into json' );
is( $json1, $expected, 'is json correct' );
my $l2;
ok( $l2 = $converter->layerjson_to_geolayer( $json1 ), 'convert from json to data' );
my $json2;
ok( $json2 = $converter->geolayer_to_layerjson( $l2 ), 'converted into json (second encoding)' );
is( $json2, $expected, 'is json correct (second encoding)' );

sub build_layer {
    my $l1 = ACME::Geo::Line->new_from_point_refs( [ 0, 0 ], [ 4, 0 ] );
    my $l2 = ACME::Geo::Line->new_from_point_refs( [ 4, 0 ], [ 4, 4 ] );
    my $l3 = ACME::Geo::Line->new_from_point_refs( [ 4, 4 ], [ 0, 4 ] );
    my $l4 = ACME::Geo::Line->new_from_point_refs( [ 0, 4 ], [ 0, 0 ] );
    my $la1 = ACME::Geo::Layer->new_from_unsorted_lines( $l3, $l1, $l4, $l3 );
    return ( $la1, '[[[[0,4],[4,4]],[[0,4],[0,0]],[[0,0],[4,0]]]]' );
}

done_testing();
