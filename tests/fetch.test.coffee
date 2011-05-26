require.paths.unshift require('path').resolve(__dirname,"../src")
$ = jQuery = require 'jquery'
if typeof XMLHttpRequest is 'undefined'
    XMLHttpRequest = require( 'xmlhttprequest' ).XMLHttpRequest
fetch      = require 'fetch'


    
analyze = (msg,fn)->
    module.exports[msg] = fn


analyze "$.fetch() output should be a promise even if beforeSend() returns false", (test)->
    test.expect(1)
    fetch({beforeSend: ()-> false }).always ()->
        test.ok true, 'is in fact a promise'
        test.done()
        
analyze "$.fetch() output should be a promise even if abort()'ed", (test)->
    test.expect(1)
    fetch({beforeSend: (j)-> j.abort() }).always ()->
        test.ok true, 'is in fact a promise'
        test.done()

analyze "$.fetch() output should be a promise even if something throws", (test)->
    test.expect(1)
    fetch({dataFilter: ()-> throw 'datafilter error' }).always ()->
        test.ok true, 'is in fact a promise'
        test.done()

analyze "$.fetch() should accept empty object", (test)->
    test.expect(1)
    fetch({}).always ()->
        test.ok true, 'expects empty object'
        test.done()
    
analyze "$.fetch() should accept no argument", (test)->
    test.expect(1)
    fetch().always ()->
        test.ok true, 'expects nothing'
        test.done()
