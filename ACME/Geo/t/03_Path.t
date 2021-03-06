#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use Data::Dumper;

use ACME::Geo::Point;
use ACME::Geo::Line;

use_ok( 'ACME::Geo::Path' );

test_reverse();
test_square_4_x_4();
test_triangle();
unclosed_poly();
join_lines();
two_path_union();

done_testing();

sub test_reverse {
    diag( 'testing reverse' );

    my $l1p1 = ACME::Geo::Point->new( 0, 0 );
    my $l1p2 = ACME::Geo::Point->new( 4, 0 );
    my $l1 = ACME::Geo::Line->new( $l1p1, $l1p2 );

    my $l2p1 = ACME::Geo::Point->new( 4, 0 );
    my $l2p2 = ACME::Geo::Point->new( 4, 4 );
    my $l2 = ACME::Geo::Line->new( $l2p1, $l2p2 );

    my $l3p1 = ACME::Geo::Point->new( 4, 4 );
    my $l3p2 = ACME::Geo::Point->new( 0, 4 );
    my $l3 = ACME::Geo::Line->new( $l3p1, $l3p2 );

    my $l4p1 = ACME::Geo::Point->new( 0, 4 );
    my $l4p2 = ACME::Geo::Point->new( 0, 0 );
    my $l4 = ACME::Geo::Line->new( $l4p1, $l4p2 );

    my $p1 = ACME::Geo::Path->new( $l1, $l2, $l3, $l4 );
    $p1 = $p1->reverse;

    is_deeply( [ $p1->[0]->[0]->X + 0, $p1->[0]->[0]->Y + 0 ], [ 0, 0 ], 'L1,P1 correct' );
    is_deeply( [ $p1->[1]->[0]->X + 0, $p1->[1]->[0]->Y + 0 ], [ 0, 4 ], 'L2,P1 correct' );
    is_deeply( [ $p1->[2]->[0]->X + 0, $p1->[2]->[0]->Y + 0 ], [ 4, 4 ], 'L3,P1 correct' );
    is_deeply( [ $p1->[3]->[0]->X + 0, $p1->[3]->[0]->Y + 0 ], [ 4, 0 ], 'L4,P1 correct' );
}

sub test_square_4_x_4 {
    diag( 'testing square' );

    my $l1p1 = ACME::Geo::Point->new( 0, 0 );
    my $l1p2 = ACME::Geo::Point->new( 4, 0 );
    my $l1 = ACME::Geo::Line->new( $l1p1, $l1p2 );

    my $l2p1 = ACME::Geo::Point->new( 4, 0 );
    my $l2p2 = ACME::Geo::Point->new( 4, 4 );
    my $l2 = ACME::Geo::Line->new( $l2p1, $l2p2 );

    my $l3p1 = ACME::Geo::Point->new( 4, 4 );
    my $l3p2 = ACME::Geo::Point->new( 0, 4 );
    my $l3 = ACME::Geo::Line->new( $l3p1, $l3p2 );

    my $l4p1 = ACME::Geo::Point->new( 0, 4 );
    my $l4p2 = ACME::Geo::Point->new( 0, 0 );
    my $l4 = ACME::Geo::Line->new( $l4p1, $l4p2 );

    my $p1 = ACME::Geo::Path->new( $l1, $l2, $l3, $l4 );
    is( $p1->closed, 1, 'closed(): it is closed' );

    diag( 'parallel_path(): testing parallel inner square' );
    my $p3 = $p1->parallel_path( 1, 1 );
    is_deeply( [ $p3->[0]->[0]->X + 0, $p3->[0]->[0]->Y + 0 ], [ 1, 1 ], 'L1,P1 correct' );
    is_deeply( [ $p3->[0]->[1]->X + 0, $p3->[0]->[1]->Y + 0 ], [ 3, 1 ], 'L1,P2 correct' );
    is_deeply( [ $p3->[1]->[0]->X + 0, $p3->[1]->[0]->Y + 0 ], [ 3, 1 ], 'L2,P1 correct' );
    is_deeply( [ $p3->[1]->[1]->X + 0, $p3->[1]->[1]->Y + 0 ], [ 3, 3 ], 'L2,P2 correct' );
    is_deeply( [ $p3->[2]->[0]->X + 0, $p3->[2]->[0]->Y + 0 ], [ 3, 3 ], 'L3,P1 correct' );
    is_deeply( [ $p3->[2]->[1]->X + 0, $p3->[2]->[1]->Y + 0 ], [ 1, 3 ], 'L3,P2 correct' );
    is_deeply( [ $p3->[3]->[0]->X + 0, $p3->[3]->[0]->Y + 0 ], [ 1, 3 ], 'L4,P1 correct' );
    is_deeply( [ $p3->[3]->[1]->X + 0, $p3->[3]->[1]->Y + 0 ], [ 1, 1 ], 'L4,P2 correct' );
    diag( 'parallel_path(): done testing parallel inner square' );

    diag( 'parallel_path(): testing parallel outer cube' );
    my $p4 = $p1->parallel_path( 1, 0 );
    is_deeply( [ $p4->[0]->[0]->X + 0, $p4->[0]->[0]->Y + 0 ], [ -1, -1 ], 'L1,P1 correct' );
    is_deeply( [ $p4->[0]->[1]->X + 0, $p4->[0]->[1]->Y + 0 ], [  5, -1 ], 'L1,P2 correct' );
    is_deeply( [ $p4->[1]->[0]->X + 0, $p4->[1]->[0]->Y + 0 ], [  5, -1 ], 'L2,P1 correct' );
    is_deeply( [ $p4->[1]->[1]->X + 0, $p4->[1]->[1]->Y + 0 ], [  5,  5 ], 'L2,P2 correct' );
    is_deeply( [ $p4->[2]->[0]->X + 0, $p4->[2]->[0]->Y + 0 ], [  5,  5 ], 'L3,P1 correct' );
    is_deeply( [ $p4->[2]->[1]->X + 0, $p4->[2]->[1]->Y + 0 ], [ -1,  5 ], 'L3,P2 correct' );
    is_deeply( [ $p4->[3]->[0]->X + 0, $p4->[3]->[0]->Y + 0 ], [ -1,  5 ], 'L4,P1 correct' );
    is_deeply( [ $p4->[3]->[1]->X + 0, $p4->[3]->[1]->Y + 0 ], [ -1, -1 ], 'L4,P2 correct' );
    diag( 'parallel_path(): done testing parallel outer square' );
}

sub test_triangle {
    diag( 'testing triangle' );

    my $l1p1 = ACME::Geo::Point->new( 3, 1 );
    my $l1p2 = ACME::Geo::Point->new( 5, 4 );
    my $l1 = ACME::Geo::Line->new( $l1p1, $l1p2 );

    my $l2p1 = ACME::Geo::Point->new( 5, 4 );
    my $l2p2 = ACME::Geo::Point->new( 1, 4 );
    my $l2 = ACME::Geo::Line->new( $l2p1, $l2p2 );

    my $l3p1 = ACME::Geo::Point->new( 1, 4 );
    my $l3p2 = ACME::Geo::Point->new( 3, 1 );
    my $l3 = ACME::Geo::Line->new( $l3p1, $l3p2 );

    my $p1 = ACME::Geo::Path->new( $l1, $l2, $l3 );
    is( $p1->closed, 1, 'closed(): it is closed' );

    my $p2 = $p1->parallel_path( 1, 0 );

    diag( 'parallel_path(): testing parallel outer triangle' );
    is_deeply( [ $p2->[0]->[0]->X + 0 + 0, sprintf( '%0.2f', $p2->[0]->[0]->Y + 0 ) + 0 ], [  3,    -0.80 ], 'L1,P1 correct' );
    is_deeply( [ sprintf( '%0.2f', $p2->[0]->[1]->X + 0 ) + 0, $p2->[0]->[1]->Y + 0 ], [  6.87,     5 ], 'L1,P2 correct' );
    is_deeply( [ sprintf( '%0.2f', $p2->[1]->[0]->X + 0 ) + 0, $p2->[1]->[0]->Y + 0 ], [  6.87,     5 ], 'L2,P1 correct' );
    is_deeply( [ sprintf( '%0.2f', $p2->[1]->[1]->X + 0 ) + 0, $p2->[1]->[1]->Y + 0 ], [ -0.87,     5 ], 'L2,P2 correct' );
    is_deeply( [ sprintf( '%0.2f', $p2->[2]->[0]->X + 0 ) + 0, $p2->[2]->[0]->Y + 0 ], [ -0.87,     5 ], 'L3,P1 correct' );
    is_deeply( [ $p2->[2]->[1]->X + 0, sprintf( '%0.2f', $p2->[2]->[1]->Y + 0 ) + 0 ], [  3,    -0.80 ], 'L3,P2 correct' );
    diag( 'parallel_path(): done testing parallel outer triangle' );
}

sub unclosed_poly {
    diag( 'testing unclosed_poly' );

    my $l1p1 = ACME::Geo::Point->new( 0, 0 );
    my $l1p2 = ACME::Geo::Point->new( 4, 0 );
    my $l1 = ACME::Geo::Line->new( $l1p1, $l1p2 );

    my $l2p1 = ACME::Geo::Point->new( 4, 0 );
    my $l2p2 = ACME::Geo::Point->new( 4, 4 );
    my $l2 = ACME::Geo::Line->new( $l2p1, $l2p2 );

    my $l3p1 = ACME::Geo::Point->new( 4, 4 );
    my $l3p2 = ACME::Geo::Point->new( 0, 4 );
    my $l3 = ACME::Geo::Line->new( $l3p1, $l3p2 );

    my $p1 = ACME::Geo::Path->new( $l1, $l2, $l3 );
    is( $p1->closed, 0, 'closed(): it is NOT closed' );
}

sub join_lines {
    diag( 'join_lines' );

    my $l1 = ACME::Geo::Line->new_from_point_refs( [ 0,   0 ], [ 5,   0 ] );
    my $l2 = ACME::Geo::Line->new_from_point_refs( [ 5,   0 ], [ 10,  0 ] );
    my $l3 = ACME::Geo::Line->new_from_point_refs( [ 10,  0 ], [ 10,  5 ] );
    my $l4 = ACME::Geo::Line->new_from_point_refs( [ 10,  5 ], [ 10, 10 ] );
    my $l5 = ACME::Geo::Line->new_from_point_refs( [ 10, 10 ], [ 5,  10 ] );
    my $l6 = ACME::Geo::Line->new_from_point_refs( [ 5,  10 ], [ 0,  10 ] );
    my $l7 = ACME::Geo::Line->new_from_point_refs( [ 0,  10 ], [ 0,   5 ] );
    my $l8 = ACME::Geo::Line->new_from_point_refs( [ 0,   5 ], [ 0,   0 ] );

    my $p1 = ACME::Geo::Path->new( $l1, $l2, $l3, $l4, $l5, $l6, $l7, $l8 );

    is_deeply( [ $p1->[0]->[0]->X + 0, $p1->[0]->[0]->Y + 0 ], [ 0,   0 ], 'L1,P1 correct' );
    is_deeply( [ $p1->[0]->[1]->X + 0, $p1->[0]->[1]->Y + 0 ], [ 10,  0 ], 'L1,P2 correct' );
    is_deeply( [ $p1->[1]->[0]->X + 0, $p1->[1]->[0]->Y + 0 ], [ 10,  0 ], 'L2,P1 correct' );
    is_deeply( [ $p1->[1]->[1]->X + 0, $p1->[1]->[1]->Y + 0 ], [ 10, 10 ], 'L2,P2 correct' );
    is_deeply( [ $p1->[2]->[0]->X + 0, $p1->[2]->[0]->Y + 0 ], [ 10, 10 ], 'L3,P1 correct' );
    is_deeply( [ $p1->[2]->[1]->X + 0, $p1->[2]->[1]->Y + 0 ], [ 0,  10 ], 'L3,P2 correct' );
    is_deeply( [ $p1->[3]->[0]->X + 0, $p1->[3]->[0]->Y + 0 ], [ 0,  10 ], 'L4,P1 correct' );
    is_deeply( [ $p1->[3]->[1]->X + 0, $p1->[3]->[1]->Y + 0 ], [ 0,   0 ], 'L4,P2 correct' );
}

sub two_path_union {
    diag( 'two_path_union' );

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

    my $un1 = $la1->union( $la2 );

    is_deeply( [ $un1->[0]->[0]->X + 0, $un1->[0]->[0]->Y + 0 ], [ 6, 6 ], 'L1,P1 correct' );
    is_deeply( [ $un1->[0]->[1]->X + 0, $un1->[0]->[1]->Y + 0 ], [ 2, 6 ], 'L1,P2 correct' );
    is_deeply( [ $un1->[1]->[0]->X + 0, $un1->[1]->[0]->Y + 0 ], [ 2, 6 ], 'L2,P1 correct' );
    is_deeply( [ $un1->[1]->[1]->X + 0, $un1->[1]->[1]->Y + 0 ], [ 2, 4 ], 'L2,P2 correct' );
    is_deeply( [ $un1->[2]->[0]->X + 0, $un1->[2]->[0]->Y + 0 ], [ 2, 4 ], 'L3,P1 correct' );
    is_deeply( [ $un1->[2]->[1]->X + 0, $un1->[2]->[1]->Y + 0 ], [ 0, 4 ], 'L3,P2 correct' );
    is_deeply( [ $un1->[3]->[0]->X + 0, $un1->[3]->[0]->Y + 0 ], [ 0, 4 ], 'L4,P1 correct' );
    is_deeply( [ $un1->[3]->[1]->X + 0, $un1->[3]->[1]->Y + 0 ], [ 0, 0 ], 'L4,P2 correct' );

    SKIP: {
        skip( 'Math::Geometry::Planar seems to be broken here', 8 );
        is_deeply( [ $un1->[4]->[0]->X + 0, $un1->[4]->[0]->Y + 0 ], [ 0, 0 ], 'L4,P1 correct' );
        is_deeply( [ $un1->[4]->[1]->X + 0, $un1->[4]->[1]->Y + 0 ], [ 4, 0 ], 'L4,P2 correct' );
        is_deeply( [ $un1->[5]->[0]->X + 0, $un1->[5]->[0]->Y + 0 ], [ 4, 0 ], 'L4,P1 correct' );
        is_deeply( [ $un1->[5]->[1]->X + 0, $un1->[5]->[1]->Y + 0 ], [ 4, 2 ], 'L4,P2 correct' );
        is_deeply( [ $un1->[6]->[0]->X + 0, $un1->[6]->[0]->Y + 0 ], [ 4, 2 ], 'L4,P1 correct' );
        is_deeply( [ $un1->[6]->[1]->X + 0, $un1->[6]->[1]->Y + 0 ], [ 6, 2 ], 'L4,P2 correct' );
        is_deeply( [ $un1->[7]->[0]->X + 0, $un1->[7]->[0]->Y + 0 ], [ 6, 2 ], 'L4,P1 correct' );
        is_deeply( [ $un1->[7]->[1]->X + 0, $un1->[7]->[1]->Y + 0 ], [ 6, 6 ], 'L4,P2 correct' );
    }
}
