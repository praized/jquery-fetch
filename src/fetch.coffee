isNode = typeof process isnt "undefined" and process.versions and !!process.versions.node
if isNode
    $ = jQuery = require 'jquery' 
else 
    $ = jQuery = window.jQuery

###
    Supplies a default sotrage mechanism reflecting the localStorage/sessionStorage API    
    (without JSON support, just like the real thing)
###

store = new ()->
    data = {}
    @clear = ()->
        @length = 0
        data    = {}
        return @
    @getItem = (k)->
        return data[k]
    @setItem = (k,v)->
        @length++
        return data[k] = v.toString()
    @removeItem = (k)->
        @length--
        delete data[k]
    return @clear()
    
###
    adds getItemJSON() and setItemJSON() to provided store
### 
JSONStore = (store)->
    proto = Object.getPrototypeOf( store )
    if !proto.getItemJSON
        proto.getItemJSON = (k)->
            v = store.getItem(k)
            if typeof v isnt 'string' then return JSON.stringify( v ) 
            JSON.parse( v )
    if !proto.setItemJSON
        proto.setItemJSON = (k,v)->
            v = JSON.stringify(v)
            store.setItem( k, v )
    return store

$.fetch = ( options )->
    options||={}
    ### Deferred response ###
    response = $.Deferred()    
    ### Default as functions ###
    url   = ( options.url || '/' )
    store = JSONStore( options.store || store )
    options.success  ||= $.noop
    options.complete ||= $.noop
    options.error    ||= $.noop
    
    ### Get potentially cached ###
    stored          = store.getItemJSON( url )
    promised        = $.fetchRequests[ url ]
    
    ### resolves the fetch response  ###
    resolve = ( data )->
        store.setItemJSON url, response: data, time: new Date().getTime()
        response.resolve( data )
        return response
        
    ### rejects the fetch response  ###        
    reject  = ( error )->
        
        response.reject.apply( response, arguments ).promise()
        
    if stored && stored.response
        if stored.time+$.fetchExpiry >= new Date().getTime()
            store.removeItem url
        return resolve( stored.response  )  
        
    if promised
        ### if promised, we've already fetched that ###
        promised.then resolve, reject
    else
        ### if not a promised request, we need to create one and register it ###
        try
            request = $.ajax( options )
        catch E
            return reject E
        ### beforeSend()'s that return false break ajax promises ###
        if request is false
            reject 'broken promise' 
        else
            $.fetchRequests[url] = request
            request.then resolve, ()->
                reject.apply response, arguments
    return response.promise()
    
$.fetchRequests  = { }
$.fetchExpiry    = 1000*60*30 # 30 minutes

if isNode
    module.exports = $.fetch