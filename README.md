
Node.js: dedelimit
=================
Scott Ivey -> http://www.scivey.net

Takes an object with flattened key-value pairs, like this:

```javascript
{
	"user.name.first": "Tim",
	"user.name.last": "Generic",
	"user.age": 27,
	"user.messages.latest": ["Pick up the pace, Tim."]
}
```

And builds an object with the nested structure indicated by the delimited key order, like this:

```javascript
{
	user: {
		name: {
			first: "Tim",
			last: "Generic"
		},
		age: 27,
		messages: {
			latest: ["Pick up the pace, Tim."]
		}
	}
}
```


Installation
------------

    npm install dedelimit


Usage
------------
```javascript
var dedelimit = require("dedelimit").dedelimit;

var flattenedKeys = {
	"user.name.first": "Tim",
	"user.name.last": "Generic",
	"user.age": 27,
	"user.messages.latest": ["Pick up the pace, Tim."],
};

dedelimit(flattenedKeys, function(err, restoredObject) {
	// restoredObject is the object with restored hierarchy
});
```

`dedelimit` has an async interface, but the implementation is basically synchronous -- the call is returned on `process.nextTick`.  It's async because a future version may split the task into several async chunks if there are a large number of keys.  So far that doesn't seem necessary.

`dedelimit` can also take an options object as its second argument, which currently provides a `delimiter` attribute for customizing the delimiter used to split the original keys into sequences.  The delimiter defaults to a single period (".").  If an options object is passed, `dedelimit` expects a callback as its third argument.

```javascript
var dedelimit = require("dedelimit").dedelimit;

var flattenedKeys = {
	"user,name,first": "Tim",
	"user,name,last": "Generic",
	"user,age": 27,
	"user,messages,latest": ["Pick up the pace, Tim."],
};

dedelimit(flattenedKeys, {delimiter: ","}, function(err, restoredObject) {
	// restoredObject is the object with restored hierarchy,
	// in this case using "," as the delimiter
});
```

The module also exports `insertDelimitedKey`, the internal method used for handling each key sequence.  This function takes a pre-split array of keys, which is assumed to represent the ordering from a flattened string in an object like `flattenedKeys`, and the value to assign to the terminal key in the sequence.  Its first argument is an object reference, which _will be mutated_.  `dedelimit` uses this to build a reconstituted object one (nested) key-value pair at a time.

If a sequence of keys needs to be calculated in a way too complex to be handled by passing a different delimiter, custom key-splitting code can be paired with `insertDelimitedKey` to provide the same functionality as `dedelimit`.

If you just need an object rebuilt out of delimited keys, use `dedelimit`.


```javascript
var insertDelimitedKey = require("dedelimit").insertDelimitedKey;

var _objectRef = {};

insertDelimitedKey(_objectRef, ["user", "name", "first"], "Gary");

console.log(_objectRef);

//	output:
//	{
//		user: {
//			name: {
//				first: "Gary"
//			}
//		}
//	}
//

```


API
------------

- `dedelimit(flattenedObject[, options], callback)` 
	- `flattenedObject` is a one-level object with nested structure indicated by delimiters in its keys, e.g. `"user.name": "name"` for `{user: { name: "name"} }`.
	- `options` takes one property, `delimiter`, which is used to split flattened keys into the intermediate form used to rebuild their structure.  A single period, `"."`, is the default delimiter.
	- `callback` has a typical `(err, results)` signature.  `results` is the hierarchical object created from `flattenedObject`'s split keys.
	- If `options` is omitted, `callback` is assumed to be the second parameter.  (i.e. if the second parameter is a function, it will be treated as the callback.)

- `insertDelimitedKey(objectRef, keyList, value)`
	- `objectRef` is a reference to a plain object which will have the keys in `keyList` added to it recursively.  _This object reference is mutated._
	- `keyList` is an array of pre-split keys, i.e. `['user', 'name']` instead of the `"user.name"` key used in `dedelimit`.  Each subsequent key is assumed to be one level deeper, i.e. `name` is a property of `user`.
	- `value` is the value assigned to the property described by the last element of `keyList`.  In the case of the same `['user', 'name']` array, `value` would be assigned to the `name` field of `user`, with `user` itself a property of the top-level object.


Use Cases
------------
This module was created to rebuild objects from delimited property lists in the `name` attributes of HTML form inputs, e.g. from the following Handlebars view:

```html
<form action="/customers/{{_id}}" method="post">
	<input type="text" name="name.first" value="{{name.first}}"/>
	<input type="text" name="name.last" value="{{name.last}}"/>
	<input type="text" name="address.ZIP" value="{{address.ZIP}}"/>
	<!-- and so on -->
	<input type="submit" value="Submit"/>
</form>
```

`dedelimit` can be used to recreate objects from flattened keys on the client-side or server-side.  In the most straightforward case, this form will just be serialized and passed via POST call to `/api/customers`, with no further action on the client side.  Recreating the original object is pointless there.  If client-side models also need updating, then handling it in-browser is more important.

Used server-side with Express, parsing the form looks like this:
```javascript
app.use(express.bodyParser());
	// parses POST data into req.body

app.post("/customers/:id", function(req, res) {
	var flattenedKeyVals = req.body;
	var _id = req.params.id;

	dedelimit(flattenedKeyVals, function(err, restoredObj) {
		// handle the restored object, e.g. pass to a Mongoose
		// model to update properties in persistence layer
	});

	res.redirect("/customers/" + _id);
});
```
This can easily be implemented as middleware for a group of form-handling routes.

GitHub
------------
https://github.com/scivey/dedelimit


Contact
------------
https://github.com/scivey

http://www.scivey.net

scott.ivey@gmail.com

License
------------
MIT