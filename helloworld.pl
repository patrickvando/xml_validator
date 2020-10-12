use strict;
use warnings;
=pod
make an xml sample validator using perl
!!!! :)))))

use stacks

deal with whether or not an xml file is well-formed?
https://www.informit.com/articles/article.aspx?p=27865&seqNum=11
single versus double quotations?
https://www.w3schools.com/xml/xml_syntax.asp
xml comments

stack to hold open/closing tags
avoid reading entire document into memory?
buffer system?
skip the buffer because that's too much complexity to deal with right now?
what about <> nested inside quotations?
https://stackoverflow.com/questions/29398950/is-there-a-way-to-include-greater-than-or-less-than-signs-in-an-xml-file
read lines into the buffer until we have a tag match?
throw lines away if we are not inside a tag already?
forget about these issues until we know more?
bring up errors
=cut
print "Validate XML\n";
open(my $in, "<", "sample.xml");
my %xml_doc = ();
my @tags = {};
while (<$in>){
    #print $_;
    while($_ =~ /<([^>]*)>/g){
        if($1 =~ /\/.*$/){
            print "closing tag found\n";
        } else {
            print "opening tag found\n";
        }
    }
}
close($in);

