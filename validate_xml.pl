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
XML documents must have a root element yes
XML elements must have a closing tag yes
XML tags are case sensitive yes
XML elements must be properly nested yes
XML attribute values must be quoted
=cut
print "Validate XML\n";
open(my $in, "<", "sample.xml");
my %xml_doc = ();
my @tags = ();
my $line_num = 1;
my $root_found = 0;
while (<$in>){
    while($_ =~ m/<([^>]*)>/g){
        my $element_col = $-[0];
        my $element = $1;
        $element =~ m/([^\/\s]+)/;
        my $tag = $1;
        if($element =~ m/^\//){
            if(pop(@tags) ne $tag){
                die("Error found: Tag mismatch on line " . $line_num . ", col " . $element_col . ".\n");
            }            
            print "closing tag: " . $tag . " found\n";
        } else {
            if($root_found && @tags == 0){
                die("Error found: Extraneous tag found on line " . $line_num . ", col " . $element_col .
                 ". XML files must have a single root element.\n")
            } else {
                $root_found = 1;
            }
            print "pushing " . $tag . " pushed\n";            
            push(@tags, $tag);
            print "opening tag: " . $tag . " found\n";
        }
    }
    $line_num += 1;
}
if(@tags > 0){
    die("Error found: Missing closing tag for \"" . $tags[$#tags] . "\".\n");
}
print("No errors found.");
close($in);

