use inc::Module::Install;

name		'EP2520';
abstract	'gzqx <jerryzh0524@sjtu.edu.cn>';
include		'Module::AutoInstall';
all_from	'main.pl';

requires	'YAML::Tiny'=>1.73;

auto_install(
    make_args   => '--hello',   # option(s) for CPAN::Config
    force       => 1,           # pseudo-option to force install
    do_once     => 1,           # skip previously failed modules
);

WriteAll;
