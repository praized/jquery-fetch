sessionStorage.clear()

$.fetchExpiry = 2000;
var storedAt=null,
getStored = function() {
    return JSON.parse(sessionStorage.getItem('http://localhost:7357'))
}
asyncTest("fetch in a browser", function() {  
  expect(1);
  $.fetch({url:'http://localhost:7357',store:sessionStorage}).then(function(v) {
      ok(v)
      storedAt = getStored().time
  },function(e) {
      alert("Is the test server running?")
  }).always(function() {
      start()
  })

});

asyncTest("cache is invaidated after 2 seconds (because explicitly set to 2 seconds in test file)", function() {  
  expect(1)
  setTimeout(function() {
      $.fetch({url:'http://localhost:7357',store:sessionStorage}).done(function(v) {
            ok(  storedAt < getStored().time)
        }).always(function() {
            start()
        })
  },3000)
 
});
