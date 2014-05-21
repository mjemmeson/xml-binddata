use strict;
use warnings;

use Test::More;

use_ok 'XML::BindData';

my $tests = [
	[
		'<foo tmpl-bind="foo"/>', { foo => 'bar' },
		'<foo>bar</foo>', 'Single binding'
	],

	[
		'<foo><multi tmpl-each="foo"/></foo>', { foo => [(1) x 3] },
		'<foo><multi/><multi/><multi/></foo>',
		'Each over multiple entities'
	],

	[
		'<foo><bar tmpl-each="bar" tmpl-bind="this"/></foo>',
		{ bar => [ 1, 2, 3 ] },
		'<foo><bar>1</bar><bar>2</bar><bar>3</bar></foo>',
		'This binds inside each'
	],

	[
		'<foo tmpl-attr-map="bar:baz"/>', { baz => 'quux' },
		'<foo bar="quux"/>', 'Attribute binds'
	],

	[
		'<foo tmpl-attr-map="a:aaa,b:bbb"/>', { aaa => 1, bbb => 2 },
		'<foo a="1" b="2"/>', 'Multiple attributes bind'
	],

	[
		'<foo><bar tmpl-each="bar"><baz tmpl-each="this" tmpl-bind="this"/></bar></foo>',
		{
			bar => [
				[ qw/ 1 2 / ],
				[ qw/ 3 4 / ],
			]
		},
		'<foo><bar><baz>1</baz><baz>2</baz></bar><bar><baz>3</baz><baz>4</baz></bar></foo>',
		'Nested arrays'
	],

	[
		'<foo><bar tmpl-each="bar"><id tmpl-bind="id"/></bar></foo>',
		{
			bar => [
				{ id => 1 },
				{ id => 2 },
			]
		},
		'<foo><bar><id>1</id></bar><bar><id>2</id></bar></foo>',
		'Each uses individual items as context'
	],

	[
		'<foo tmpl-bind="foo.bar.baz"/>',
		{ foo => { bar => { baz => 1 } } },
		'<foo>1</foo>', 'Dot notation references nested hashes'
	],

	[
		'<foo><bar tmpl-if="show">bar</bar></foo>', { show => 1 },
		'<foo><bar>bar</bar></foo>', 'If true keeps node'
	],

	[
		'<foo><bar tmpl-if="show">bar</bar></foo>', { show => 0 },
		'<foo/>', 'If false removes node'
	],

	[
		'<foo><bar tmpl-if="!show">bar</bar></foo>', { show => 0 },
		'<foo><bar>bar</bar></foo>', 'If not false keeps node'
	],

	[
		'<foo><bar tmpl-if="!show">bar</bar></foo>', { show => 1 },
		'<foo/>', 'If not true removes node'
	],

	[
		'<foo><bar tmpl-if="show" tmpl-each="bar" tmpl-bind="this"/></foo>',
		{
			show => 1,
			bar  => [ 1, 2, 3 ],
		},
		'<foo><bar>1</bar><bar>2</bar><bar>3</bar></foo>',
		'If + each + this all on one tag works'
	],
];

foreach my $t (@$tests) {
	my ($source_xml, $data, $output, $msg) = @$t;
	is(
		XML::BindData->bind($source_xml, $data),
		"<?xml version=\"1.0\"?>\n$output\n",
		$msg
	);
}

done_testing;
