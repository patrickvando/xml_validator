use strict;
use warnings;

my ($filename) = @ARGV;
if (not defined $filename){
    die "Please supply a filename.\n";
}

my $special_chars = quotemeta(q(!"#$%'()*+,/;<=>?@[]^`{|}~\\));
# Maximum number of characters read into the text buffer at once
my $read_size = 50;
my $text_buffer = "";
# Flag for determining whether a single root element has been found
my $root_found = 0;
# Array used as stack for determining whether XML elements are properly nested and non-overlapping
my @tags = ();
my $line_num = 1;

open(my $in, "<", $filename);
read_into_buf();
while (1){
    my $element = read_element();
    validate_element($element);
    my $content = read_content();
    validate_content($content);
}
close($in);

sub read_element {
    # Read a single XML element into memory - everything from a '<' to the first subsequent '>'.
    my $element = "";
    # Throw away comments
    $text_buffer =~ /^(\s*<!--.*?-->)*/sgc;
    if ($text_buffer =~ /\G\s*<!--/) {
        die "Bad comment. See line $..\n";
    }
    if ($text_buffer !~ /\s*</gc){
        die "Expected XML tag. See line $..\n";
    }
    while ($text_buffer =~ /\G([^>]*)$/gc){
        if (eof($in)){
            die "Incomplete XML tag. See line $..\n";            
        }
        $element .= $1;
        read_into_buf();
    }
    $text_buffer =~ /\G([^>]*)>(.*)$/sgc;
    $element .= $1;
    $text_buffer = $2;
    return $element;
}

sub read_content {
    # Read all content between two XML tags into memory - we start reading after a '>' and stop at the first '<'.
    my $content = "";
    while ($text_buffer =~ /^([^<]*)$/){
        $content .= $1;
        if (eof($in)){
            if ($content =~ /[\S]+/){
                die "Hanging content. See line $..\n";                            
            } elsif (@tags > 0){
                die "Hanging XML tags. See line $..\n";
            } elsif ($root_found == 0){
                die "Missing root element. See line $..\n";
            }
            print "This is a well-formed XML document.\n";
            exit 0;
        }
        read_into_buf();
    }
    $text_buffer =~ /([^<]*)(.*)/s;
    $content .= $1;
    $text_buffer = $2;
    return $content;
}

sub validate_element {
    # Check if an element has a legal tag name, legal attribute names, and properly structured attribute=value pairs.
    # Additionally, check that the tag is properly nested in the greater structure of the XML document. 
    my $element = shift;
    if ($root_found == 0 && $element =~ /^\?/) {
        validate_header($element);
        return;
    }
    my $open_tag = ($element !~ /^\//gc);    
    my $tag;
    # Check if the XML tag has bad spacing (< tag>, </ tag>, < /tag> are all illegal)
    if ($element !~ /\G(\S+)/gc){
        die "Invalid tag. See line $..\n";
    } else {
        $tag = $1;
        check_illegal_characters($tag);
    }
    # Check that the XML elements are non-overlapping and that the document contains a single root element
    if ($open_tag){
        if (@tags == 0 && $root_found == 1){
            die "XML documents may contain only a single root element. See line $..\n";
        }
        $root_found = 1;       
        push @tags, $tag;
    } elsif (@tags == 0 || pop @tags ne $tag){
        die "Bad tag nesting. See line $..\n";
    }
    # Check if attribute-value pairs are appropriately structured
    # Check for duplicate attributes
    my %found_attrs = ();
    while ($element =~ /([^=\s]+)\s*=\s*(('[^']*')|("[^"]*"))\s*/gc){
        my $attr = $1;
        my $val = $2;
        check_illegal_characters($attr);
        check_escaped($val);
        if (exists $found_attrs{$attr}){
            die "Duplicate attribute value. See line $..\n";
        }
        $found_attrs{$attr} = 1;
    }
    if ($element !~ /\G\s*$/){
        die "Invalid tag. See line $..\n";
    }
}

sub validate_header {
    # XML Headers must take the form <?xml version="xxxx" encoding="xxxx"?>
    my $header = shift;
    if($header !~ /^\?xml\s*version\s*=\s*(('[^']*')|("[^"]*"))\s*(encoding\s*=\s*(('[^']*')|("[^"]*")))?\s*\?$/){
        die "Bad XML header. See line $..\n.";        
    }
}

sub validate_content {
    # Content within XML elements that does not consist of XML tags is allowed as long as it does not contain invalid '&'s.
    my $content = shift;
    check_escaped($content);
}

sub check_illegal_characters {
    # Check if the tag and attribute names begin with '-', a digit, or contain any of !"#$%'()*+,/;<=>?@[]^`{|}~.
    my $st = shift;
    if($st =~ m/[$special_chars]/ || $st =~ m/^[0-9-]/){
        die "Illegal character found. See line $..\n";
    }
}
sub check_escaped {
    # Check if '&' is being used to represent a character entity of the form '&name;'.
    my $st = shift;
    if($st !~ m/^([^&]|(&[^&$special_chars]*;))*$/){
        die "Bad escaped character found. See line $..\n";
    }
}

sub read_into_buf {
    $text_buffer = <$in>;
}