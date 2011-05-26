c = require( 'connect' )
s = c.createServer (request, response)->
        data = JSON.stringify
                FOO:'BAR',
                foo:"bar",
                f00:"b4r",
                at: new Date()
        console.log 'writting head'                
        response.writeHead 200, 
                "Content-Type": "text/plain"
                "Content-Length": data.length
                "Access-Control-Allow-Origin": "*"
        console.log 'sending response'
        response.end(data)
s.use( c.logger() )
s.listen(7357)
