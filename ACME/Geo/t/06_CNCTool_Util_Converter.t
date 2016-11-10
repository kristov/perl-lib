#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use lib qw( lib );

use_ok( 'ACME::Geo::Util::Converter' );

my $converter;
ok( $converter = ACME::Geo::Util::Converter->new, 'created converter' );

test_json( $converter );
test_math_geometry_planar( $converter );

sub test_json {
    my ( $converter ) = @_;
    diag( 'test_json' );

    my $l1 = ACME::Geo::Line->new_from_point_refs( [ 0, 0 ], [ 4, 0 ] );
    my $l2 = ACME::Geo::Line->new_from_point_refs( [ 4, 0 ], [ 4, 4 ] );
    my $l3 = ACME::Geo::Line->new_from_point_refs( [ 4, 4 ], [ 0, 4 ] );
    my $l4 = ACME::Geo::Line->new_from_point_refs( [ 0, 4 ], [ 0, 0 ] );
    my $la1 = ACME::Geo::Path->new( $l3, $l1, $l4, $l3 );

    my $expected = '[[[[0,4],[4,4]],[[0,4],[0,0]],[[0,0],[4,0]]]]';

    my $json1;
    ok( $json1 = $converter->geolayer_to_layerjson( $la1 ), 'converted into json' );
    is( $json1, $expected, 'is json correct' );
    my $la2;
    ok( $la2 = $converter->layerjson_to_geolayer( $json1 ), 'convert from json to data' );
    my $json2;
    ok( $json2 = $converter->geolayer_to_layerjson( $la2 ), 'converted into json (second encoding)' );
    is( $json2, $expected, 'is json correct (second encoding)' );
}

sub test_math_geometry_planar {
    my ( $converter ) = @_;
    diag( 'test_math_geometry_planar' );

    my $l1 = ACME::Geo::Line->new_from_point_refs( [ 0, 0 ], [ 4, 0 ] );
    my $l2 = ACME::Geo::Line->new_from_point_refs( [ 4, 0 ], [ 4, 4 ] );
    my $l3 = ACME::Geo::Line->new_from_point_refs( [ 4, 4 ], [ 0, 4 ] );
    my $l4 = ACME::Geo::Line->new_from_point_refs( [ 0, 4 ], [ 0, 0 ] );
    my $la1 = ACME::Geo::Path->new( $l3, $l1, $l4, $l3 );

    my $l5 = ACME::Geo::Line->new_from_point_refs( [ 2, 2 ], [ 6, 2 ] );
    my $l6 = ACME::Geo::Line->new_from_point_refs( [ 6, 2 ], [ 6, 6 ] );
    my $l7 = ACME::Geo::Line->new_from_point_refs( [ 6, 6 ], [ 2, 6 ] );
    my $l8 = ACME::Geo::Line->new_from_point_refs( [ 2, 6 ], [ 2, 2 ] );
    my $la2 = ACME::Geo::Path->new( $l5, $l6, $l7, $l8 );

    my $mgp1;
    ok( $mgp1 = $converter->geopath_to_mathgeometryplanar( $la1 ), 'converted into Math::Geometry::Planar' );
}

done_testing();
