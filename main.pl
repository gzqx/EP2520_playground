use warnings;
use utf8;
use 5.027;

use Cwd 'abs_path';
my $abs_path=abs_path();
system "./YamlConfig/YamlConfig.pl $abs_path";
