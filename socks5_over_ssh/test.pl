use warnings;
use utf8;
use 5.027;

use YAML::Tiny;

my $yaml=YAML::Tiny->read('test.yaml');
my $config=\%{$yaml->[0]};
#$config->{food}="apple";
#say "@{[%{$yaml->[0]}]}";
#$yaml->write('test.yaml');
#foreach	my $key (keys %$config){
#	$config->{$key}="rua";
#}
sub test {
	my ($b)=@_;
	$b->{food}={};
}
&test(\%{$config});
foreach my $temp (keys %{$config}){
	if (ref $config->{$temp} eq ref {}) {
		foreach my $sub_temp (keys %{$config->{$temp}}){
			say "$temp, $sub_temp,$config->{$temp}->{$sub_temp}";
		}
	}else{
		say "$temp, $config->{$temp}";
	}
}
