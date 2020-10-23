use strict;
use warnings;
$_ = "The year 1752 lost 10 days on the 3rd of September";
#list all the things this program checks for in readme
# may not work????? line numbers??/
# dont read lines, read characters
# while (/(\d+)/gc) {
#     print "Found number $1\n";
# }
#https://www.informit.com/articles/article.aspx?p=27865&seqNum=11
# https://xmlwriter.net/xml_guide/xml_declaration.shtml
# An element may have only one attribute of a given name.
# if (/\G(\S+)/g) {
#     print "Found $1 after the last number.\n";
# }
my $read_size = 2;
my $text_buffer = "";
my @tags = ();
my $line_num = 1;
my $root_found = 0;
#dont forget to parse header
#This takes advantage of the special variable $. which keeps track of the line number in the current file. (See perlvar)
open(my $in, "<", "sample.xml");
read($in, $text_buffer, $read_size);
my $header = read_header();
validate_header();
while (1){
    my $element = read_element();
    validate_element($element);
    my $content = read_content();
    validate_content($content);
}
close($in);

sub read_element {
    #Read everything between a '<' and the first '>' that that follows it.
    my $element = "";
    if ($text_buffer !~ /^\s*</gc){
        die "Expected XML tag on line $.\n";
    }
    #read until we reach the '>' that corresponds to the end of the element
    while ($text_buffer =~ /\G([^>]*)$/gc){
        if (eof($in)){
            die "Incomplete XML tag. See line $.\n";            
        }
        $element .= $1;
        read($in, $text_buffer, $read_size);
    }
    $text_buffer =~ /\G([^>]*)>(.*)/gc;
    $element .= $1;
    $text_buffer = $2;
    return $element;
}

sub read_content {
    my $content = "";
    #read until we reach the '<' that corresponds to the start of a new element
    while ($text_buffer =~ /^([^<]*)$/){
        $content .= $1;
        if (eof($in)){
            if ($content =~ /[\S]+/){
                die "Hanging content. See line $.\n";                            
            }
            print "Success.\n";
            exit 1;
        }
        read($in, $text_buffer, $read_size);
    }
    $text_buffer =~ /([^<]*)(.*)/;
    $content .= $1;
    check_escaped($content);
    $text_buffer = $2;
    return $content;
}

sub validate_element {
    my $element = shift;
    my $open_tag = ($element =~ /^\//gc);    
    my $tag;
    if ($element !~ /\G(\S+)/gc){
        die "Invalid tag.\n";
    } else {
        $tag = $1;
        check_illegal_characters($tag);
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
    print "element is $element\n";

}

sub validate_content {
    # print "Content: $_[0]\n";
}

sub read_header {
    return "";
}

sub validate_header {

}

sub check_illegal_characters {
    my $st = shift;
    if($st =~ m/[!"#$%'()*+,\/;<=>\?@\[\]^`{|}~]/ || $st =~ m/^[0-9-]/){
        die "Illegal characters found in $st\n";
    }
}
sub check_escaped {
    my $st = shift;
    if($st !~ m/^([^&]|&#60;|&lt;|&#62;|&gt;|&#38;|&#39;|&#34;)*$/){
        die "Bad escaped character found\n";
    }
}

sub check_illegal_val {
    my $st = shift;
    if($st !~ m/^"[^"]*"$/ or $st =~ m/^'[^']*'$/g){
        die "Bad attribute value, see $st\n";
    }
    check_escaped($st);
}