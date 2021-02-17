#!/usr/bin/env perl
# File              : cli.pl
# Author            : gzqx <jerryzh0524@sjtu.edu.cn>
# Date              : 14.02.2021
# Last Modified Date: 14.02.2021
# Last Modified By  : gzqx <jerryzh0524@sjtu.edu.cn>
use warnings;
use utf8;
use 5.027;

use YAML::Tiny;
use File::Copy;
use Class::Struct;

#my $yaml=YAML::Tiny->read('test.yaml');
#my $config=$yaml->[0];
#$config->{ktt}->{like}={current => 'salut'};
#say %{$config->{ktt}->{like}};
#delete $config->{ktt}->{like}->{current};
#$config->{ktt}->{like}={current => 'jyy'};
#$yaml->write('test.yaml');
#for (keys %{$config->{ktt}}){
#	say $_;
#}
#say $config->{ktt}->{like} or die $!;

#change and read config file
say "Please input config file [Empty to use default]:";
my $configFile_name=<STDIN>;
chomp $configFile_name;
my $default_configFile='config.yaml.default';
my $useDefault_bool=0;
if ($configFile_name eq "") {
	copy("config.yaml.default","config.yaml") or die "Copy default config failed: $!";
	$useDefault_bool=1;
	$configFile_name="config.yaml";
}
#open(READ_CONFIG,'<',"config.yaml") or die "Config file don't exist: $!";
#open(WRITE_CONFIG,'>',"config.yaml") or die "Cannot edit config file: $!";
my $configFile;
if (-e $configFile_name){
	my $configFile=YAML::Tiny->read($configFile_name);
} else {
	die "Config file don't exist: $!";
}

my $configFileDoc=$configFile->[0];
my $changeConfig_bool=0;
if ($useDefault_bool) {
	say "Do you want to interactively change the config file(y/n)? [y]";
	$changeConfig_bool=1;
} else {
	say "Do you want to interactively change the config file(y/n)? [n]";
	$changeConfig_bool=0;
}

chomp(my $changeConfigInput=<STDIN>);
my @yes=qw /y yes Y Yes YES/;
my @no=qw /n no N No NO/;
if (grep(/^$changeConfigInput/, @yes)) {
	$changeConfig_bool=1;
} elsif (grep(/^$changeConfigInput/, @no)){
	$changeConfig_bool=0;
} elsif ($changeConfigInput !=""){
	say "Invalid input, assuming affirmative.";
	$changeConfig_bool=1;
}

struct(	Address=>{
		ip=>'$',
		port=>'$',
		protocol=>'$',
	});
struct( Config=>{
		platform=> '$',
		pac=> 'Address',
		ssh=> 'Address',
		local_proxy=>'Address',
	});
my $config=Config->new(
	platform=>$configFileDoc->{platform},
	pac=>Address->new(ip=>$configFileDoc->{PAC_address},port=>$configFileDoc->{PAC_port},protocol=>"pac"),
	ssh=>Address->new(ip=>$configFileDoc->{SSH_address},port=>$configFileDoc->{SSH_port},protocol=>"ssh"),
	local_proxy=>Address->new(ip=>$configFileDoc->{local_proxy_address},port=>$configFileDoc->{local_proxy_port},protocol=>$configFileDoc->{local_proxy_proto}),
);
if ($changeConfig_bool==1) {	
	say "What is your Platform(Linux/Windows/MacOS)? [empty to auto detect]";
	chomp(my $platform=<STDIN>);
	if ($platform eq "") {
		
	}
}

