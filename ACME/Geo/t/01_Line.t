#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use ACME::Geo::Point;

use_ok( 'ACME::Geo::Line' );

my $l1p1 = ACME::Geo::Point->new( 0, 0 );
my $l1p2 = ACME::Geo::Point->new( 3, 3 );
my $l2p1 = ACME::Geo::Point->new( 0, 3 );
my $l2p2 = ACME::Geo::Point->new( 3, 0 );

my $l1 = ACME::Geo::Line->new( $l1p1, $l1p2 );
my $l2 = ACME::Geo::Line->new( $l2p1, $l2p2 );

my $in1 = $l1->intersect( $l2 );
is( $in1->X + 0, 1.5, 'intersect(): X correct' );
is( $in1->Y + 0, 1.5, 'intersect(): Y correct' );

my $l3p1 = ACME::Geo::Point->new( 0, 0 );
my $l3p2 = ACME::Geo::Point->new( 0, 3 );
my $l4p1 = ACME::Geo::Point->new( 3, 0 );
my $l4p2 = ACME::Geo::Point->new( 2, 3 );

my $l3 = ACME::Geo::Line->new( $l3p1, $l3p2 );
my $l4 = ACME::Geo::Line->new( $l4p1, $l4p2 );

my $in2 = $l3->intersect( $l4 );
is( $in2, undef, 'intersect(): correct no intersect' );

my $in3 = $l3->intersect_imaginary_line( $l4 );
is( $in3->X + 0, 0, 'intersect_imaginary_line(): X correct' );
is( $in3->Y + 0, 9, 'intersect_imaginary_line(): Y correct' );

is( $l3->distance_to_point( $l4p2 ) + 0, 2, 'distance_to_point()' );
is( $l3->distance_to_point( $l1p1 ) + 0, 0, 'distance_to_point(): no distance' );

done_testing();
