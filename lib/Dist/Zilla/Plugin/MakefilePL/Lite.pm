package Dist::Zilla::Plugin::MakefilePL::Lite;
use Moose;

with qw(
    Dist::Zilla::Role::FileGatherer
    Dist::Zilla::Role::FileMunger
    Dist::Zilla::Role::FilePruner
);

sub gather_files {
    my $self = shift;
    return unless $self->zilla->isa('Dist::Zilla::Dist::Minter');

    (my $mod_name = $self->zilla->name) =~ s/-/::/g;
    my $content = <<CONTENTS;
# This module uses Dist::Zilla for development. This Makefile.PL will let you
# run the tests, but you are encouraged to install Dist::Zilla and the needed
# plugins if you intend on doing any serious hacking.

use strict;
use warnings;

use ExtUtils::MakeMaker::Dist::Zilla;

WriteMakefile(
    NAME => '$mod_name',
);
CONTENTS

    $self->add_file(
        Dist::Zilla::File::InMemory->new(
            name    => 'Makefile.PL',
            content => $content,
        )
    );
}

sub munge_files {
    my $self = shift;
    return unless $self->zilla->isa('Dist::Zilla::Dist::Minter');

    my ($dist_ini) = grep { $_->name eq 'dist.ini' } @{ $self->zilla->files };
    return unless $dist_ini;

    if ($dist_ini->isa('Dist::Zilla::File::OnDisk')) {
        my $content = $dist_ini->content;
        Dist::Zilla::File::InMemory->meta->rebless_instance(
            $dist_ini,
            content => $content . "\n[MakefilePL::Lite]\n",
        );
    }
    elsif ($dist_ini->isa('Dist::Zilla::File::InMemory')) {
        $dist_ini->content($dist_ini->content . "\n[MakefilePL::Lite]\n");
    }
    elsif ($dist_ini->isa('Dist::Zilla::File::FromCode')) {
        my $code = $dist_ini->code;
        my $weak_dist_ini = $dist_ini;
        Scalar::Util::weaken($weak_dist_ini);
        $dist_ini->code(sub {
            $weak_dist_ini->$code . "\n[MakefilePL::Lite]\n"
        });
    }
}

sub prune_files {
    my $self = shift;
    return unless $self->zilla->isa('Dist::Zilla::Dist::Builder');
    for my $file (@{ $self->zilla->files }) {
        next unless $file->name eq 'Makefile.PL';
        $self->zilla->prune_file($file);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
