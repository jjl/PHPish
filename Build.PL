use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'PHPish',
    license             => 'perl',
    build_requires => {
        'Test::More' => 0,
    },
    dist_abstract => '1',
    add_to_cleanup      => [ 'PHPish-*' ],
);

$builder->create_build_script();
