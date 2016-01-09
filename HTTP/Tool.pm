package HTTP::Tool;

use Moose;
use Template;
use JSON qw();
use HTTP::Tool::Static;
use HTTP::Tool::Comp;
use HTTP::Tool::TemplateHelper;

has 'tt' => (
    is => 'ro',
    isa => 'Template',
    lazy => 1,
    builder => '_build_tt',
);

sub _build_tt {
    my ( $self ) = @_;
    return Template->new( {
        INCLUDE_PATH => $self->directory_root . "/views",
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

has 'static' => (
    is      => 'rw',
    isa     => 'HTTP::Tool::Static',
    lazy    => 1,
    builder => '_build_static',
    documentation => 'Static object',
);

sub _build_static {
    my ( $self ) = @_;
    return HTTP::Tool::Static->new( { tool => $self } );
}

has 'comp' => (
    is      => 'rw',
    isa     => 'HTTP::Tool::Comp',
    lazy    => 1,
    builder => '_build_comp',
    documentation => 'Component processor',
);

sub _build_comp {
    my ( $self ) = @_;
    return HTTP::Tool::Comp->new( { tool => $self } );
}

has 'template_helper' => (
    is      => 'rw',
    isa     => 'HTTP::Tool::TemplateHelper',
    lazy    => 1,
    builder => '_build_template_helper',
    documentation => 'Template helper object',
);

sub _build_template_helper {
    my ( $self ) = @_;
    return HTTP::Tool::TemplateHelper->new( { tool => $self } );
}

has 'directory_root' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_directory_root',
    documentation => 'The location of the config for the site',
);

sub _build_directory_root {
    require FindBin;
    my $bin = $FindBin::Bin;
    return "$bin/..";
}

has 'target_directory' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_target_directory',
    documentation => 'Where the site will be written into',
);

sub _build_target_directory {
    my ( $self ) = @_;
    my $root = $self->directory_root;
    return "$root/static";
}

sub merge_data {
    my ( $self, $data ) = @_;

    for my $key ( %{ $data } ) {
        $self->data->{$key} = $data->{$key};
    }
}

sub render_template {
    my ( $self, $template, $data ) = @_;

    my $output = "";

    $data->{TH} = $self->template_helper;

    $self->tt->process( $template, $data, \$output )
        || die $self->tt->error . "\n";

    return $output;
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
