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

detect <tagname=5> ->>>> should be error?

https://en.wikipedia.org/wiki/Well-formed_document

readme up here:
what the rules are
=cut
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
            if(@tags == 0 || pop(@tags) ne $tag){
                die_tag_mismatch($line_num, $element_col);
            }            
        } else {
            if($root_found && @tags == 0){
                die_extra_tag($line_num, $element_col);
            } else {
                $root_found = 1;
            }
            if($tag =~ m/[!"#$%&'()*+,\/;<=>\?@\[\]^`{|}~]/){
                my $character_col = $-[0];
                die_illegal_character($line_num, $element_col + $character_col);
            } elsif ($tag =~ m/^[0-9-]/){
                my $character_col = $-[0];
                die_illegal_character($line_num, $element_col + $character_col);                
            }
            push(@tags, $tag);
        }

    }
    $line_num += 1;
}
if(@tags > 0){
    die_missing_tag($tags[$#tags]);
}
success_msg();
close($in);

sub die_illegal_character {
    my $line_num = $_[0];
    my $col_num = $_[1];
    die("This is a malformed XML file.\nError found: Illegal character in tag name on line " . $line_num . ", col " . $col_num . ".\n");
}

sub die_tag_mismatch {
    my $line_num = $_[0];
    my $col_num = $_[1];
    die("This is a malformed XML file.\nError found: Tag mismatch on line " . $line_num . ", col " . $col_num . ".\n");
}
sub die_extra_tag {
    my $line_num = $_[0];
    my $col_num = $_[1];
    die("This is a malformed XML file.\nError found: Extraneous tag found on line " . $line_num . ", col " . $col_num . 
        ". XML files must have a single root element.\n")    
}
sub die_missing_tag {
    my $missing_tag = $_[0];
    die("This is a malformed XML file.\nError found: Missing closing tag for \"" . $missing_tag . "\".\n");    
}
sub success_msg {
    print "This is a well-formed XML file.\nNo errors found.\n";
}

