_ = require "underscore"



#@objRef: an object reference,
#@keyList an ARRAY of key values, with
#	increasing index implying deeper nesting.
#	
#@val the value to insert into the final key in
#	the sequence given by `keyList`
insertDelimitedKey = (objRef, keyList, val) ->
	lastIndex = keyList.length - 1
	_currentIndex = 0
	_currentScope = objRef
	_.each keyList, (aKey) ->
		if _.has(_currentScope, aKey)
			if _currentIndex isnt lastIndex
				_currentScope = _currentScope[aKey]
				_currentIndex++
		else
			if _currentIndex is lastIndex
				_currentScope[aKey] = val
			else
				_currentScope[aKey] = {}
				_currentScope = _currentScope[aKey]
				_currentIndex++

#
#@keyVals - an object with delimited keys indicating nesting
#	depth, and the corresponding value indicating the value
#	for the final key
#	
#@options - allows client to specify key delimiter.  if a function,
#	then this is assumed to be the callback
#	
#@callback - the usual `(err, res)` business.
#

dedelimit = do ->
	_defaultOpts = 
		delimiter: "."

	(keyVals, options, callback) ->
		#console.log keyVals
		if _.isFunction(options)
			callback = options
			options = _.clone(_defaultOpts)
		else
			options = _.merge({}, _defaultOpts, options)

		#the object reference to be dedelimited
		_obj = {}

		_.each _.keys(keyVals), (oneKey) ->
			#console.log oneKey
			splitKey = oneKey.split(options.delimiter)
			insertDelimitedKey(_obj, splitKey, keyVals[oneKey])

		callback(null, _obj)

module.exports =
	dedelimit: dedelimit
	insertDelimitedKey: insertDelimitedKey

