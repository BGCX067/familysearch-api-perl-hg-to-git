use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'WebService::FamilySearch',
    VERSION_FROM      => 'lib/WebService/FamilySearch.pm', # finds $VERSION
    PREREQ_PM         => {LWP::UserAgent, XML::Simple}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/WebService/FamilySearch.pm', # retrieve abstract from module
       AUTHOR         => 'Bill Anderson <bill#anderson-ent.com>') : ()),
);
