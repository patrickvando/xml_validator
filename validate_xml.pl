use strict;
use warnings;

my $read_size = 1000;
my $text_buffer = "";
my $root_found = 0;
my @tags = ();
my $line_num = 1;
#dont forget to parse header
open(my $in, "<", "sample.xml");
read($in, $text_buffer, $read_size);
# print "1 $text_buffer\n";
while (1){
    my $element = read_element();
    print "Element: $element\n";
    # print "2 $text_buffer\n";
    validate_element($element);
    my $content = read_content();
    print "Content: $content\n";
    validate_content($content);
}
close($in);

sub read_element {
    # Read a single XML element into memory - everything from a '<' to the first subsequent '>'.
    my $element = "";
    if ($text_buffer !~ /^\s*</gc){
        die "Expected XML tag on line $.\n";
    }
    while ($text_buffer =~ /\G([^>]*)$/gc){
        # print("READ READ READ\n");
        if (eof($in)){
            die "Incomplete XML tag. See line $.\n";            
        }
        $element .= $1;
        read($in, $text_buffer, $read_size);
    }
    # print("before, text buffer is $text_buffer x\n");
    # print("before, element is $element x\n");
    $text_buffer =~ /\G([^>]*)>(.*)$/sgc;
    $element .= $1;
    $text_buffer = $2;
    # print("capture group 1: $1\ncapture group 2: $2\n");
    # print("After, text buffer is $text_buffer x\n");
    # print("found element\n$element\n$text_buffer\nthere\n");
    return $element;
}

sub read_content {
    # Read all content between two XML tags into memory - we start reading after a '>' and stop at the first '<'.
    my $content = "";
    while ($text_buffer =~ /^([^<]*)$/){
        $content .= $1;
        if (eof($in)){
            if ($content =~ /[\S]+/){
                die "Hanging content.\n";                            
            } elsif (@tags > 0){
                die "Hanging XML tags.\n";
            }
            print "Success.\n";
            exit 1;
        }
        read($in, $text_buffer, $read_size);
    }
    $text_buffer =~ /([^<]*)(.*)/s;
    $content .= $1;
    $text_buffer = $2;
    # print "in buffer $text_buffer\n";
    return $content;
}

sub validate_element {
    # Check if an element has a legal tag name, legal attribute names, and properly structured attribute=value pairs.
    # Additionally, check that the tag is properly nested in the greater structure of the XMl document. 
    my $element = shift;
    # print "element is $element\n";        
    if ($root_found == 0 && $element =~ /^\?/) {
        validate_header($element);
        return;
    }
    my $open_tag = ($element !~ /^\//gc);    
    my $tag;
    if ($element !~ /\G(\S+)/gc){
        die "Invalid tag.\n";
    } else {
        $tag = $1;
        check_illegal_characters($tag);
    }
    # print "see here @tags\n";
    if ($open_tag){
        if (@tags == 0 && $root_found == 1){
            die "XML documents may contain only a single root element.\n";
        }
        $root_found = 1;       
        push @tags, $tag;
    } elsif (@tags == 0 || pop @tags ne $tag){
        die "Bad tag nesting\n";
    }
    my %found_attrs = ();
    while ($element =~ /([^=\s]+)\s*=\s*(\S+)\s*/gc){
        my $attr = $1;
        my $val = $2;
        check_illegal_characters($attr);
        check_illegal_val($val);
        print "found attr-value: $1=$2\n";
        if (exists $found_attrs{$attr}){
            die "Duplicate attribute value.\n";
        }
        $found_attrs{$attr} = 1;
    }
    if ($element !~ /\G\s*$/){
        die "Invalid tag.\n";
    }
}

sub validate_header {
    my $header = shift;
    # print "header is $header\n";    
    if($header =~ /^\?xml\s*version\s*=\s*(\S+)\s*encoding\s*=\s*(\S+)\s*\?$/){
        check_illegal_val($1);
        check_illegal_val($2);
    } else {
        die "Bad XML header\n.";        
    }
}

sub validate_content {
    my $content = shift;
    # print "Content is $content\n";
    check_escaped($content);
}

sub check_illegal_characters {
    # Check if the given string contains an illegal character. Tag and attribute names are not allowed to contain certain characters.
    my $st = shift;
    if($st =~ m/[!"#$%'()*+,\/;<=>\?@\[\]^`{|}~]/ || $st =~ m/^[0-9-]/){
        die "Illegal characters found in $st\n";
    }
}
sub check_escaped {
    # Check if the escaped characters are legal special characters.
    my $st = shift;
    if($st !~ m/^([^&]|&#60;|&lt;|&#62;|&gt;|&#38;|&#39;|&#34;)*$/){
        die "Bad escaped character found\n";
    }
}

sub check_illegal_val {
    #Check if the value in an attribute=value pair is a properly quoted string.
    my $st = shift;
    if($st !~ /^"[^"]*"$/ and $st !~ /^'[^']*'$/g){
        die "Bad attribute value, see $st\n";
    }
    check_escaped($st);
}