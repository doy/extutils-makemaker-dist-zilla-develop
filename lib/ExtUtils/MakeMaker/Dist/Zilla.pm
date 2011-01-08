package ExtUtils::MakeMaker::Dist::Zilla;
use strict;
use warnings;

use ExtUtils::MakeMaker ();

sub import {
    warn <<'EOF';

  ********************************* WARNING **********************************

  This module uses Dist::Zilla for development. This Makefile.PL will let you
  run the tests, but you are encouraged to install Dist::Zilla and the needed
  plugins if you intend on doing any serious hacking.

  ****************************************************************************

EOF

    ExtUtils::MakeMaker->export_to_level(1, @_);
}

{
    package MY;

    use Config;

    my $message;
    BEGIN {
        $message = <<'MESSAGE';

  ********************************* ERROR ************************************

  This module uses Dist::Zilla for development. This Makefile.PL will let you
  run the tests, but should not be used for installation or building dists.
  Building a dist should be done with 'dzil build', installation should be
  done with 'dzil install', and releasing should be done with 'dzil release'.

  ****************************************************************************

MESSAGE
        $message =~ s/^(.*)$/\t\$(NOECHO) echo "$1";/mg;
    }

    sub install {
        return <<EOF;
install:
$message
	\$(NOECHO) echo "Running dzil install for you...";
	\$(NOECHO) dzil install
EOF
    }

    sub dist_core {
        return <<EOF;
dist:
$message
	\$(NOECHO) echo "Running dzil build for you...";
	\$(NOECHO) dzil build
EOF
    }
}

1;
