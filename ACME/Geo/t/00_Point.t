#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use constant NINTEY_DEG_IN_RAD      => 1.5707963268;
use constant FOURTY_FIVE_DEG_IN_RAD => 0.7853981634;

use_ok( 'ACME::Geo::Point' );

my $p1 = ACME::Geo::Point->new( 0, 0 );
my $p2 = ACME::Geo::Point->new( 5, 0 );

is( $p2->X, 5, 'X accessor' );
is( $p1->Y, 0, 'Y accessor' );
is( $p1->distance( $p2 ), 5, 'distance()' );
is( $p1->distance( $p1 ), 0, 'distance() from self' );
is( $p2->distance( $p1 ), 5, 'distance() in negative' );

my $p3 = $p2->point_angle_distance_from( NINTEY_DEG_IN_RAD, 10 );
is( sprintf( '%0.0f', $p3->X ), 5, 'point_angle_distance_from(): X correct' );
is( sprintf( '%0.0f', $p3->Y ), 10, 'point_angle_distance_from(): Y correct' );

my $pc = $p3->closest_of_two( $p1, $p2 );
is( $pc->X, 5, 'closest_of_two(): X correct' );
is( $pc->Y, 0, 'closest_of_two(): Y correct' );

my $p4 = ACME::Geo::Point->new( 10, 10 );
is( sprintf( '%0.5f', $p1->angle_between( $p4 ) ), sprintf( '%0.5f', FOURTY_FIVE_DEG_IN_RAD ), 'angle_between(): 45 degree case' );
is( sprintf( '%0.5f', $p1->angle_between( $p2 ) ), sprintf( '%0.5f', 0 ), 'angle_between(): 0 degree case' );

done_testing();
