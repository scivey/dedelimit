_ = require "underscore"
should = require "should"
path = require "path"
dedelimitSrc = path.join __dirname, "../index.js"
{dedelimit} = require dedelimitSrc

delimited =
	"ident.name.first": "Nancy"
	"ident.name.last": "Drew"
	"ident.email": "nancyD_fluffybunny16@myspace.com"
	"age": 26
	"address.street": "184 West Terrace Ave"
	"address.city": "Miami"
	"pets": ["Rex", "Spike", "Klifford the Kow"]

notDelimited =
	ident:
		name:
			first: "Nancy"
			last: "Drew"
		email: "nancyD_fluffybunny16@myspace.com"
	age: 26
	address:
		street:"184 West Terrace Ave"
		city: "Miami"
	pets: ["Rex", "Spike", "Klifford the Kow"]


describe "dedelimit", ->
		it "should instantiate a nested object from a delimited string of object properties.", (done) ->
			dedelimit delimited, (err, restored) ->
				restored.should.eql(notDelimited)
				done()

		it "should convert {'foo.bar':'whatzit'} into { foo: { bar: 'whatzit'} }", (done) ->
			_inflated = 
				foo:
					bar: "whatzit"
			dedelimit {"foo.bar": "whatzit"}, (err, restored) ->
				restored.should.eql(_inflated)
				done()
