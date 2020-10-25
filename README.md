# xml_validator

## Usage 
This program can be run using the following command: `./validate_xml.pl doc_name.xml`

## About
This is a Perl program checks if an XML document is well-formed, according the following criteria:

1. An optional XML header is included at the beginning of document
    - This XML header must take the form `<?xml version="xxxx" encoding="xxxx"?>`, where the `encoding` attribute is optional
2. All XML elements are appropriately nested and non-overlapping
    - Every opening `<tag>` has a corresponding closing `</tag>`
    - `<first><second></second></first>` is allowed
    - `<first><second></first></second>` is not allowed
3. All XML tags have appropriate spacing
    - All tags have appropriate spacing (`<tag >` and `</tag >` are allowed, but `< tag>`, `< /tag>`, and `</ tag>` are not allowed)
4. Opening tags may be followed by `attribute = value` pairs, where `value` is single or double quoted, and attribute names are unique
    - `<tag attr1 = "Hello 'world'" attr2= 'Goodbye "world"'>` is allowed
    - `<tag attr1 = "Hello 'world'" attr1 = "Goodbye "world"'>` is not allowed
    - `<tag attr1>` is not allowed
5. All tags and attributes are appropriately named
    - Tag and attribute names may not begin with a digit or a `-`
    - Tag and attribute names may not contain a space
    - Tag and attribute names may not contain any of the following special characters:``!"#$%&'()*+,/;<=>?@[\]`{|}~``
6. The special character `&` is not used, except in attribute values or in content within elements as part of a character entity reference
    - A character entity reference takes the form `&name;`, where any `name` that does not include special characters is considered valid
    - For example, `&quot;`, `&lt;` and `&amp;`are character entity references for `"`, `<`, and `&`
7. Content that is not itself composed of XML tags may exist within XML elements
    - `<message>Today is the <day>25</day> of October!</message>` is allowed
8. All XML elements are contained within a single root element
    - `<?xml version='1.0' encoding="UTF-8"?><my_root></my_root>` is allowed
    - `<?xml version='1.0' encoding="UTF-8"?><my_first_root></my_first_root><my_second_root></my_second_root>` is not allowed
9. Comments taking the form `<!-- my comment here -->` are allowed
    - Any content between the `<!--` and the first subsequent `-->` is considered valid
