#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use Data::Dumper;

use ACME::Geo::Point;
use ACME::Geo::Line;

use_ok( 'ACME::Geo::Layer' );

simple_single_path();
double_path();

done_testing();

sub simple_single_path {
    diag( 'simple_single_path' );

    my $l1 = ACME::Geo::Line->new_from_point_refs( [ 0, 0 ], [ 4, 0 ] );
    my $l2 = ACME::Geo::Line->new_from_point_refs( [ 4, 0 ], [ 4, 4 ] );
    my $l3 = ACME::Geo::Line->new_from_point_refs( [ 4, 4 ], [ 0, 4 ] );
    my $l4 = ACME::Geo::Line->new_from_point_refs( [ 0, 4 ], [ 0, 0 ] );

    my $la1 = ACME::Geo::Layer->new_from_unsorted_lines( $l3, $l1, $l4, $l3 );
    is( $la1->nr_paths, 1, 'nr_paths(): is correct' );
}

sub double_path {
    diag( 'double_path' );

    my $l1 = ACME::Geo::Line->new_from_point_refs( [ 0, 0 ], [ 8, 0 ] );
    my $l2 = ACME::Geo::Line->new_from_point_refs( [ 8, 0 ], [ 8, 8 ] );
    my $l3 = ACME::Geo::Line->new_from_point_refs( [ 8, 8 ], [ 0, 8 ] );
    my $l4 = ACME::Geo::Line->new_from_point_refs( [ 0, 8 ], [ 0, 0 ] );

    my $l5 = ACME::Geo::Line->new_from_point_refs( [ 2, 2 ], [ 4, 2 ] );
    my $l6 = ACME::Geo::Line->new_from_point_refs( [ 4, 2 ], [ 4, 4 ] );
    my $l7 = ACME::Geo::Line->new_from_point_refs( [ 4, 4 ], [ 2, 4 ] );
    my $l8 = ACME::Geo::Line->new_from_point_refs( [ 2, 4 ], [ 2, 2 ] );

    my $la1 = ACME::Geo::Layer->new_from_unsorted_lines( $l3, $l6, $l5, $l1, $l7, $l4, $l3, $l8 );
    is( $la1->nr_paths, 2, 'nr_paths(): is correct' );
}
