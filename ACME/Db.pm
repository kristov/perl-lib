package ACME::Db;

use strict;
use warnings;
use DBI;
use Data::Dumper;
use ACME::Config qw( conf );

sub table { die "override table()" }
sub columns { die "override columns()" }
sub primary_key { die "override primary_key()" }

sub dbh {
    my ( $class, $dbh ) = @_;
    return $class->_dbh();
}

sub _dbh {
    my ( $class ) = @_;
    return $class->_connect();
}

sub _connect {
    my ( $class ) = @_;
    my $settings = conf->{db};
    my $user = $settings->{user};
    my $pass = $settings->{pass};
    my $db = $settings->{database} || $settings->{user};
    my $dbh = DBI->connect_cached( "DBI:mysql:database=$db;host=localhost", $user, $pass );
    $dbh->{RaiseError} = 1;
    $dbh->{mysql_enable_utf8} = 1;
    $dbh->do( qq{ SET NAMES 'utf8'; } );
    return $dbh;
}

sub AUTOLOAD {
    my ( $class, @args ) = @_;
    my $dbh = $class->dbh();
    our $AUTOLOAD;
    return if $AUTOLOAD =~ /::DESTROY$/;
    if ( $AUTOLOAD =~ /::([^:]+)$/ ) {
        my $name = $1;
        $dbh->$name( @args );
    }
}

sub create {
    my ( $class, $record ) = @_;

    my $dbh = $class->dbh();

    my @cols  = $class->columns();
    my $table = $class->table();
    my @values;
    for my $col ( @cols ) {
        push @values, ( defined $record->{$col} )
            ? $dbh->quote( $record->{$col} )
            : 'NULL';
    }
    my $vals = join( ',', @values );

    local $" = ',';
    @cols = quote( @cols );
    my $stmt = "INSERT INTO `$table` (@cols) VALUES ($vals)";
    $dbh->do( $stmt );

    my $id = $dbh->{mysql_insertid};
    return $id;
}

sub selectall_where {
    my ( $class, $where, @bind ) = @_;
    my $table = $class->table();
    my @cols = $class->all_columns();
    local $" = ',';
    return $class->dbh->selectall_arrayref( qq{
        SELECT @cols FROM $table WHERE $where
    }, { Slice => {} }, @bind );
}

sub selectall_hash_in {
    my ( $class, $col, @ids ) = @_;
    return [] if !@ids;
    my $dbh = $class->dbh;
    @ids = map { $dbh->quote( $_ ) } @ids;
    my $table = $class->table();
    my @cols = $class->all_columns();
    local $" = ',';
    return $class->dbh->selectall_hashref( qq{
        SELECT @cols FROM $table WHERE $col IN (@ids)
    }, $col, {} );
}

sub selectall_in {
    my ( $class, $col, @ids ) = @_;
    return [] if !@ids;
    my $dbh = $class->dbh;
    @ids = map { $dbh->quote( $_ ) } @ids;
    my $table = $class->table();
    my @cols = $class->all_columns();
    local $" = ',';
    return $class->dbh->selectall_arrayref( qq{
        SELECT @cols FROM $table WHERE $col IN (@ids)
    }, { Slice => {} } );
}

sub create_or_update {
    my ( $class, $record ) = @_;
    $class->create_or_update_bulk( [ $record ] );
}

sub create_or_update_bulk {
    my ( $class, $records, $post, $attrs ) = @_;

    return 1 if scalar( @{ $records } ) == 0;

    my @pks = $class->primary_key();
    my %pkmap = map { $_ => 1 } @pks;

    my $row1 = $records->[0];
    my @all = keys %{ $row1 };
    my @cols = grep { !$pkmap{$_} } @all;

    my $table = ( exists $attrs->{table} )
        ? $attrs->{table}
        : $class->table();

    local $" = ',';
    my $pre = "";
    if ( !@cols ) {
        $pre = "INSERT IGNORE INTO `$table` (@all) VALUES";
    }
    else {
        $pre = "INSERT INTO `$table` (@all) VALUES";
    }

    my @record_list;
    my $dbh = $class->dbh;
    for my $record ( @{ $records } ) {
        my @values;
        for my $col ( @all ) {
            push @values, defined $record->{$col} ? $dbh->quote( $record->{$col} ) : 'NULL';
        }
        my $vals = join( ',', @values );
        push @record_list, "($vals)";
    }

    my $values = join( ',', @record_list );

    if ( !$post ) {
        if ( !@cols ) {
            $post = "";
        }
        else {
            my $update = join( ',', map { "`$_`=VALUES(`$_`)" } @cols );
            $post = "ON DUPLICATE KEY UPDATE $update";
        }
    }

    my $stmt = "$pre $values $post";
    eval {
        $class->dbh->do( $stmt );
        1;
    }
    or do {
        die "$stmt\n -- $@";
    };
}

sub get_all {
    my ( $class ) = @_;

    my @cols = $class->all_columns();
    my $table = $class->table;

    local $" = ',';
    @cols = quote( @cols );
    return $class->dbh->selectall_arrayref( qq{ SELECT @cols FROM $table }, { Slice => {} } );
}

sub get {
    my ( $class, $id ) = @_;
    my $records = $class->get_many( [ $id ] );
    return $records->[0];
}

sub get_many {
    my ( $class, $ids ) = @_;

    my $where;
    my @bind;

    my @pks = $class->primary_key;
    my @cols = $class->columns;
    my @all = ( @pks, @cols );
    my $table = $class->table;

    if ( scalar( @pks ) > 1 ) {
        my $count = 0;
        my @ors;
        for my $id ( @{ $ids } ) {
            if ( ref( $id ) ne 'HASH' ) {
                die "Can not get rows from a multiple column primary key table with "
                  . "only 1 value. Pass a hashref with each primary key column name as"
                  . "a key, and the corresponding value. The value at index $count was"
                  . " not a hashref.";
            }
            $count++;
            my $or = join( ' AND ', map { "`$_`=?" } @pks );
            push @ors, "($or)";
            push @bind, map { $id->{$_} } @pks;
        }
        $where = join( ' OR ', @ors );
    }
    else {
        my $list = join( ',', @{ $ids } );
        $where = "$pks[0] IN ($list)";
    }

    local $" = ',';
    my $stmt = "SELECT @all FROM $table WHERE $where";

    return $class->dbh->selectall_arrayref( $stmt, { Slice => {} }, @bind );
}

sub all_columns {
    my ( $class ) = @_;
    return ( $class->primary_key, $class->columns );
}

sub quote {
    return map { '`' . $_ . '`' } @_;
}

1;
