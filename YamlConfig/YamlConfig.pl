#!/usr/bin/env perl
# File              : cli.pl
# Author            : gzqx <jerryzh0524@sjtu.edu.cn>
# Date              : 14.02.2021
# Last Modified Date: 14.02.2021
# Last Modified By  : gzqx <jerryzh0524@sjtu.edu.cn>

package ConfigYaml;
use warnings;
use utf8;
use 5.027;

use YAML::Tiny;
use File::Copy;
use Class::Struct;

my $isTest=0;
my $isVerbose=0;


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
my $directory=$ARGV[0]."/";
&testPrintVar($directory);
say "Please input config file [Empty to use default]:";
chomp (my $configFile_name=<STDIN>);
my $default_configFilePath=$directory.'config.default.yaml';
my $useDefault_bool=0;
if ($configFile_name eq "") {
	copy($default_configFilePath,$directory."config.yaml") or die "Copy default config failed: $!";
	$useDefault_bool=1;
	$configFile_name="config.yaml";
}
my $configFileDefault=YAML::Tiny->read($default_configFilePath);
my $configDefault=\%{$configFileDefault->[0]};
#open(READ_CONFIG,'<',"config.yaml") or die "Config file don't exist: $!";
#open(WRITE_CONFIG,'>',"config.yaml") or die "Cannot edit config file: $!";
my $configFile;
if (-e $configFile_name){
	$configFile=YAML::Tiny->read($directory.$configFile_name);
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
	my ($input,$default)=@_;
	if($input eq ""){
		if ($default) {
			return 1;
		}else{
			return 0;
		}
	} elsif (grep(/^$input/, @yes)) {
		return 1;
	} elsif (grep(/^$input/, @no)){
		return 0;
	} elsif (not $input eq ""){
		say "Invalid input, assuming affirmative.";
		return 1;
	}
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
	my ($hash,$father)=@_;
	while(1){
		say "Do you want to add new settings or change old config under $father? (add/change) [empty to change, input \"n\" to other config]";
		chomp(my $isChange=<STDIN>);
		if ($isChange eq 'n') {
			return;
		}
		
		if ($isChange eq "add") {
			say "What is its name?";
			chomp(my $newKey_temp=<STDIN>);
			say "Does it have multiple setting(y/n)? [n]";
			chomp(my $isMultiple=<STDIN>);
			if (&yesNo($isMultiple,0)) {
				&changeConfig(\%{$hash->{$newKey_temp}},$newKey_temp);
			} else{
				say "What is its value?";
				chomp(my $newValue_temp=<STDIN>);
				$hash->{$newKey_temp}=$newValue_temp;
			}
			&testUpdateConfig;
		} elsif ($isChange eq "change" || $isChange eq "") {
			foreach my $node_temp (keys %{$hash}) {
				if(not ref $hash->{$node_temp} eq ref {}){
					if ($node_temp eq "platform") {
						say "What is your Platform(Linux/Windows/MacOS)? [empty to auto detect]";
						chomp(my $platform_temp=<STDIN>);
						if ($platform_temp eq "") {	
							$config->{platform}=$^O;
						} elsif($platform_temp eq "linux" or $platform_temp eq "Linux"){
							$config->{platform}="linux";
						} elsif($platform_temp eq "windows" or $platform_temp eq "Windows"){
							$config->{platform}="windows";
						} elsif($platform_temp eq "macOS" or $platform_temp eq "MacOS" or $platform_temp eq "macos"){
							$config->{platform}="macos";
						} elsif($platform_temp eq "android" or $platform_temp eq "Android"){
							$config->{platform}="android";
						} else{
							say "Unknown OS, assuming Linux";
						}
						next;
					}
					my $default_temp=$hash->{$node_temp};
					my $input_temp;
					if (not defined $hash->{$node_temp}) {
						say "Please input $node_temp: [empty for none]";
						chomp($input_temp=<STDIN>);
						$hash->{$node_temp}=$input_temp;
					}else{
						say "Please input $node_temp: [empty to skip, current value is ($default_temp), input \"-d\" to delete this]";
						chomp($input_temp=<STDIN>);
						$hash->{$node_temp}=$input_temp;
						if ($input_temp eq "") {
							next;
						} elsif($input_temp eq "-d"){
							delete $hash->{$node_temp};
						}
					}
				} else{
					say "Do you want to configure $node_temp which has multiple settings? [empty to config, input \"n\" to skip this, input \"d\" to delete this] ";
					chomp(my $input_temp=<STDIN>);
					if ($input_temp eq "") {
						&changeConfig(\%{$hash->{$node_temp}},$node_temp);
					}elsif($input_temp eq "d"){
						delete $hash->{$node_temp};
					}else{
						next;
					}
				}
			}
			&testUpdateConfig;
		} else {
			say "Invalid input $!";
			next;
		}
	}
}


if ($changeConfig_bool==1) {	
	&changeConfig($config,"Root");
	$configFile->[0]=$config;
	$configFile->write($directory.'config.yaml');
	say "Config completed";
}
	#my $default_temp;
	#$default_temp=$configDefault->[0]->{PAC_address};
	#say "What is the ip/address of PAC list? [empty to use default ($default_temp)]";
	#chomp(my $pacAddress_temp=<STDIN>);
	#$default_temp=$configDefault->[0]->{PAC_port};
	#say "What is the port of PAC list? [empty to use default ($default_temp)]";
	#chomp(my $pacPort_temp=<STDIN>);
	#$default_temp=$configDefault->[0]->{SSH_address};
	#say "What is the ip/address of SSH? [empty to use default ($default_temp)]";
	#chomp(my $sshAddress_temp=<STDIN>);
	#$default_temp=$configDefault->[0]->{SSH_port};
	#say "What is the port of SSH? [empty to use default ($default_temp)]";
	#chomp(my $sshPort_temp=<STDIN>);
	#$default_temp=$configDefault->[0]->{local_proxy_address};
	#say "What is the ip/address of local proxy? [empty to use default ($default_temp)]";
	#chomp(my $localProxyAddress_temp=<STDIN>);
	#$default_temp=$configDefault->[0]->{local_proxy_port};
	#say "What is the port of local proxy? [empty to use default ($default_temp)]";
	#chomp(my $localProxyPort_temp=<STDIN>);
	#$default_temp=$configDefault->[0]->{local_proxy_proto};
	#say "What is the protocol of local proxy? [empty to use default ($default_temp)]";
	#chomp(my $localProxyProto_temp=<STDIN>);

sub testPrintVar{
	if ($isVerbose) {
		my ($package, $filename, $line) = caller;
		say "I am printing variable from call at $filename Line $line.";
	}
	if ($isTest) {
		say "@_";
	}
}
sub printHash {
	if ($isVerbose) {
		my ($package, $filename, $line) = caller;
		say "I am printing Hash from call at $filename Line $line.";
	}
	if ($isTest) {
		my ($conf)=@_;
		foreach my $temp (keys %{$conf}){
			if (ref $conf->{$temp} eq ref {}) {
				foreach my $sub_temp (keys %{$conf->{$temp}}){
					say "$temp, $sub_temp,$conf->{$temp}->{$sub_temp}";
				}
			}else{
				say "$temp, $conf->{$temp}";
			}
		}
	}
}
sub testUpdateConfig{
	if ($isVerbose) {
		my ($package, $filename, $line) = caller;
		say "I am updating Config hash from call at $filename Line $line.";
	}
	if ($isTest) {
		$configFile->[0]=$config;
		$configFile->write($directory.'config.yaml');
	}
}
