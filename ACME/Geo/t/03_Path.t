#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use Data::Dumper;

use ACME::Geo::Point;
use ACME::Geo::Line;

use_ok( 'ACME::Geo::Path' );

test_square_4_x_4();
test_triangle();
unclosed_poly();

done_testing();

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
    my $p3 = $p1->parallel_path( 1 );
    is_deeply( [ $p3->[0]->[0]->X, $p3->[0]->[0]->Y ], [ 1, 1 ], 'L1,P1 correct' );
    is_deeply( [ $p3->[0]->[1]->X, $p3->[0]->[1]->Y ], [ 3, 1 ], 'L1,P2 correct' );
    is_deeply( [ $p3->[1]->[0]->X, $p3->[1]->[0]->Y ], [ 3, 1 ], 'L2,P1 correct' );
    is_deeply( [ $p3->[1]->[1]->X, $p3->[1]->[1]->Y ], [ 3, 3 ], 'L2,P2 correct' );
    is_deeply( [ $p3->[2]->[0]->X, $p3->[2]->[0]->Y ], [ 3, 3 ], 'L3,P1 correct' );
    is_deeply( [ $p3->[2]->[1]->X, $p3->[2]->[1]->Y ], [ 1, 3 ], 'L3,P2 correct' );
    is_deeply( [ $p3->[3]->[0]->X, $p3->[3]->[0]->Y ], [ 1, 3 ], 'L4,P1 correct' );
    is_deeply( [ $p3->[3]->[1]->X, $p3->[3]->[1]->Y ], [ 1, 1 ], 'L4,P2 correct' );
    diag( 'parallel_path(): done testing parallel inner square' );

    diag( 'parallel_path(): testing parallel outer cube' );
    my $p4 = $p1->parallel_path( 0 );
    is_deeply( [ $p4->[0]->[0]->X, $p4->[0]->[0]->Y ], [ -1, -1 ], 'L1,P1 correct' );
    is_deeply( [ $p4->[0]->[1]->X, $p4->[0]->[1]->Y ], [  5, -1 ], 'L1,P2 correct' );
    is_deeply( [ $p4->[1]->[0]->X, $p4->[1]->[0]->Y ], [  5, -1 ], 'L2,P1 correct' );
    is_deeply( [ $p4->[1]->[1]->X, $p4->[1]->[1]->Y ], [  5,  5 ], 'L2,P2 correct' );
    is_deeply( [ $p4->[2]->[0]->X, $p4->[2]->[0]->Y ], [  5,  5 ], 'L3,P1 correct' );
    is_deeply( [ $p4->[2]->[1]->X, $p4->[2]->[1]->Y ], [ -1,  5 ], 'L3,P2 correct' );
    is_deeply( [ $p4->[3]->[0]->X, $p4->[3]->[0]->Y ], [ -1,  5 ], 'L4,P1 correct' );
    is_deeply( [ $p4->[3]->[1]->X, $p4->[3]->[1]->Y ], [ -1, -1 ], 'L4,P2 correct' );
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

    my $p2 = $p1->parallel_path( 0 );

    diag( 'parallel_path(): testing parallel outer triangle' );
    is_deeply( [ $p2->[0]->[0]->X, sprintf( '%0.2f', $p2->[0]->[0]->Y ) + 0 ], [  3,    -0.80 ], 'L1,P1 correct' );
    is_deeply( [ sprintf( '%0.2f', $p2->[0]->[1]->X ) + 0, $p2->[0]->[1]->Y ], [  6.87,     5 ], 'L1,P2 correct' );
    is_deeply( [ sprintf( '%0.2f', $p2->[1]->[0]->X ) + 0, $p2->[1]->[0]->Y ], [  6.87,     5 ], 'L2,P1 correct' );
    is_deeply( [ sprintf( '%0.2f', $p2->[1]->[1]->X ) + 0, $p2->[1]->[1]->Y ], [ -0.87,     5 ], 'L2,P2 correct' );
    is_deeply( [ sprintf( '%0.2f', $p2->[2]->[0]->X ) + 0, $p2->[2]->[0]->Y ], [ -0.87,     5 ], 'L3,P1 correct' );
    is_deeply( [ $p2->[2]->[1]->X, sprintf( '%0.2f', $p2->[2]->[1]->Y ) + 0 ], [  3,    -0.80 ], 'L3,P2 correct' );
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
