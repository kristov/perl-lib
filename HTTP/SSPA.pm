package HTTP::SSPA;

use Moose;
use Plack::Request;
use Plack::Response;
use JSON;
use Template;
use Moose::Util::TypeConstraints;

subtype 'SiteObject'
    => as 'Object'
    => where { $_->can( 'dispatch' ) }
    => message { 'The site object needs a dispatch() method: see the manual' };

has req => (
    is  => 'rw',
    isa => 'Plack::Request',
);

has site => (
    is  => 'rw',
    isa => 'SiteObject',
    required => 1,
);

has params => (
    is  => 'rw',
    isa => 'HashRef',
    default => sub { {} },
);

has template => (
    is  => 'rw',
    isa => 'Maybe[Str]',
);

has app_root => (
    is  => 'rw',
    isa => 'Str',
    required => 1,
);

has theme => (
    is  => 'rw',
    isa => 'Str',
    required => 0,
    default => 'Cyborg',
);

has 'static_manifest' => (
    is      => 'rw',
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_static_manifest',
    documentation => 'Hashref of static libraries and their versions',
);

sub _build_static_manifest {
    my ( $self ) = @_;
    return $self->load_json( $self->static_manifest_file );
}

has 'static_manifest_file' => (
    is => 'rw',
    isa => 'Str',
    default => '/opt/www/static/static_manifest.json',
);

has 'tt' => (
    is => 'ro',
    isa => 'Template',
    lazy => 1,
    builder => '_build_tt',
);

sub _build_tt {
    my ( $self ) = @_;
    return Template->new( {
        INCLUDE_PATH => $self->app_root . "/views",
        START_TAG    => '<%',
        END_TAG      => '%>',
    } );
}

has 'json' => (
    is      => 'ro',
    isa     => 'JSON',
    default => sub {
        return JSON->new();
    },
);

sub BUILD {
    my ( $self ) = @_;
    if ( $self->site->can( 'APP_INIT' ) ) {
        $self->site->APP_INIT( $self );
    }
}

my $HANDLER_STATIC = sub {
    my ( $self ) = @_;
    my $file = $self->req->path;
    my $app_root = $self->app_root;
    if ( -e "$app_root/public$file" ) {
        return $self->slurp( "$app_root/public/$file" );
    }
    return;
};

my $HANDLER_404 = sub {
    my ( $self ) = @_;
    return;
};

sub process {
    my ( $self, $env ) = @_;

    my $req = Plack::Request->new( $env );
    my $res = Plack::Response->new( 404 );

    $self->req( $req );

    my $params = $req->parameters->mixed;
    $self->params( $params );

    my %DISPATCH = $self->site->dispatch;

    if ( $DISPATCH{BEFORE} ) {
        $DISPATCH{BEFORE}->( $self );
    }

    my $path   = $req->path;
    my $method = $req->method;

    my $handler_group;
    my $handler;

    if ( $DISPATCH{$method} ) {
        $handler_group = $DISPATCH{$method};
    }
    elsif ( $DISPATCH{ANY} ) {
        $handler_group = $DISPATCH{ANY};
    }
    elsif ( exists $DISPATCH{404} ) {
        $handler_group = $DISPATCH{404};
        die "here";
    }
    else {
        $handler_group = $HANDLER_STATIC;
    }

    if ( ref $handler_group eq 'CODE' ) {
        $handler = $handler_group;
    }
    else {
        if ( $handler_group->{$path} ) {
            $handler = $handler_group->{$path};
        }
        elsif ( $handler_group->{'*'} ) {
            $handler = $handler_group->{'*'};
        }
        else {
            $handler = $HANDLER_STATIC;
        }
    }

    my $response = $handler->( $self );

    if ( $self->template ) {
        $response = $self->render( $self->template, $response );
        $self->template( undef );
    }
    elsif ( $response && ref $response ) {
        $response = JSON::encode_json( $response );
    }

    if ( $response ) {
        $res->status( 200 );
        $res->body( $response );
    }
    else {
        $res->status( 404 );
        $res->body( $response );
    }

    $res->finalize;
}

sub render {
    my ( $self, $template, $data ) = @_;

    my $output = "";

    if ( $self->site->can( 'template_helper' ) ) {
        my $site_helper = $self->site->template_helper;
        $data->{TH} = $site_helper if $site_helper;
    }

    $self->tt->process( $template, $data, \$output )
        || die $self->tt->error . "\n";

    return $output;
}

sub set_theme {
    my ( $self, $theme ) = @_;
    $self->theme( $theme );
}

sub add_lib {
    my ( $self, @libs ) = @_;
}

sub libs {
    my ( $self ) = @_;

    my $manifest = $self->static_manifest;
    my $libs = $manifest->{libs};

    my @js;
    my @css;

    push @js, "/static/libs/$_" for @{ $libs->{jquery}->{'2.1.4'}->{js} };
    push @js, "/static/libs/$_" for @{ $libs->{bootstrap}->{'3.3.5'}->{js} };
    #push @css, "/static/libs/$_" for @{ $libs->{bootstrap}->{'3.3.5'}->{css} };
    my $theme = $self->theme;
    push @css, "/static/libs/BootstrapThemes/$theme/bootstrap.css";

    return {
        js  => \@js,
        css => \@css,
    };
}

sub load_json {
    my ( $self, $file ) = @_;
    return $self->json->decode( $self->slurp( $file ) );
}

sub slurp {
    my ( $self, $file ) = @_;
    my $text = "";
    open( my $fh, '<', $file ) || die "$file: $!";
    while ( <$fh> ) {
        $text .= $_;
    }
    return $text;
}

1;
