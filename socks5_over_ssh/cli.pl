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
my $default_configFile='config.default.yaml';
my $useDefault_bool=0;
if ($configFile_name eq "") {
	copy($default_configFile,"config.yaml") or die "Copy default config failed: $!";
	$useDefault_bool=1;
	$configFile_name="config.yaml";
}
my $configDefault=YAML::Tiny->read("config.default,yaml");
#open(READ_CONFIG,'<',"config.yaml") or die "Config file don't exist: $!";
#open(WRITE_CONFIG,'>',"config.yaml") or die "Cannot edit config file: $!";
my $configFile;
if (-e $configFile_name){
	my $configFile=YAML::Tiny->read($configFile_name);
} else {
	die "Config file don't exist: $!";
}

my $config=\%{$configFile->[0]};
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
sub yesNo {
	#Handle yes and no judgement
	my $input=pop @_;
	if (grep(/^$input/, @yes)) {
		return 1;
	} elsif (grep(/^$input/, @no)){
		return 0;
	} elsif ($changeConfigInput !=""){
		say "Invalid input, assuming affirmative.";
		return 0;
	}
	return 1;
}


#struct(	Address=>{
#		ip=>'$',
#		port=>'$',
#		protocol=>'$',
#	});
#struct( Config=>{
#		platform=> '$',
#		pac=> 'Address',
#		ssh=> 'Address',
#		local_proxy=>'Address',
#	});
#my $config=Config->new(
#	platform=>$configFileDoc->{platform},
#	pac=>Address->new(ip=>$configFileDoc->{PAC_address},port=>$configFileDoc->{PAC_port},protocol=>"pac"),
#	ssh=>Address->new(ip=>$configFileDoc->{SSH_address},port=>$configFileDoc->{SSH_port},protocol=>"ssh"),
#	local_proxy=>Address->new(ip=>$configFileDoc->{local_proxy_address},port=>$configFileDoc->{local_proxy_port},protocol=>$configFileDoc->{local_proxy_proto}),
#);

sub changeConfig {
	# accept hash of (part) of config file
	my ($hash)=@_;
	say "Do you want to add new settings or change old config? (add/change)";
	chomp(my $isChange=<STDIN>);
	if ($isChange eq "add") {
		say "What is its name?";
		chomp(my $newKey_temp=<STDIN>);
		say "Does it have multiple setting(y/n)? [y]";
		chomp(my $isMultiple=<STDIN>);
		if (&yesNo($isMultiple)) {
			&changeConfig(%{$hash->{$newKey_temp}});
		} else{
			say "What is its value?";
			chomp(my $newValue_temp=<STDIN>);
		}
	} elsif ($isChange eq "change") {
		foreach my $node_temp (keys %$config) {
			if(not ref $config->{$node_temp} eq ref {}){
				if ($node_temp eq "platform") {
					say "What is your Platform(Linux/Windows/MacOS)? [empty to auto detect]";
					chomp(my $platform_temp=<STDIN>);
					if ($platform_temp eq "") {	
						$config->{platform}=$^O;
					} elsif($platform_temp=="linux" or $platform_temp=="Linux"){
						$config->{platform}="linux";
					} elsif($platform_temp=="windows" or $platform_temp=="Windows"){
						$config->{platform}="windows";
					} elsif($platform_temp=="macOS" or $platform_temp=="MacOS"){
						$config->{platform}="macos";
					} elsif($platform_temp=="android" or $platform_temp=="Android"){
						$config->{platform}="android";
					} 
					continue;
				}
				my $default_temp;
				$default_temp=$configDefault->[0]->{$node_temp};
				say "Please input $node_temp: [empy to use default ($default_temp)]";
				chomp(my $input_temp=<STDIN>);
				$hash->{$node_temp}=$input_temp;
			} else{
				say "Following configs $node_temp which has multiple settings.";
				&changeConfig(%{$hash->{$node_temp}});
			}
		}
	} else {
		die "Invalid input $!";
	}
}


if ($changeConfig_bool==1) {	
	my $default_temp;
	$default_temp=$configDefault->[0]->{PAC_address};
	say "What is the ip/address of PAC list? [empty to use default ($default_temp)]";
	chomp(my $pacAddress_temp=<STDIN>);
	$default_temp=$configDefault->[0]->{PAC_port};
	say "What is the port of PAC list? [empty to use default ($default_temp)]";
	chomp(my $pacPort_temp=<STDIN>);
	$default_temp=$configDefault->[0]->{SSH_address};
	say "What is the ip/address of SSH? [empty to use default ($default_temp)]";
	chomp(my $sshAddress_temp=<STDIN>);
	$default_temp=$configDefault->[0]->{SSH_port};
	say "What is the port of SSH? [empty to use default ($default_temp)]";
	chomp(my $sshPort_temp=<STDIN>);
	$default_temp=$configDefault->[0]->{local_proxy_address};
	say "What is the ip/address of local proxy? [empty to use default ($default_temp)]";
	chomp(my $localProxyAddress_temp=<STDIN>);
	$default_temp=$configDefault->[0]->{local_proxy_port};
	say "What is the port of local proxy? [empty to use default ($default_temp)]";
	chomp(my $localProxyPort_temp=<STDIN>);
	$default_temp=$configDefault->[0]->{local_proxy_proto};
	say "What is the protocol of local proxy? [empty to use default ($default_temp)]";
	chomp(my $localProxyProto_temp=<STDIN>);
}

