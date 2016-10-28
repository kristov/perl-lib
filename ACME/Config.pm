package ACME::Config;

use strict;
use warnings;
require Exporter;
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( conf );

use YAML ();

my $CONF;

sub conf {
    if ( !defined $CONF ) {
        _load_config();
    }
    return $CONF;
}

sub _find_config {
    if ( $ENV{ACME_CONFIG} ) {
        die "config not found via ACME_CONFIG environment variable"
            if ! -f $ENV{ACME_CONFIG};
        return $ENV{ACME_CONFIG};
    }

    return './config.yml'
        if -f './config.yml';

    die "no config found";
}

sub _load_config {
    $CONF = YAML::LoadFile( _find_config() );
}

1;
