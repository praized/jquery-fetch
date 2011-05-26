(function() {
  var $, JSONStore, isNode, jQuery, store;
  isNode = typeof process !== "undefined" && process.versions && !!process.versions.node;
  if (isNode) {
    $ = jQuery = require('jquery');
  } else {
    $ = jQuery = window.jQuery;
  }
  /*
      Supplies a default sotrage mechanism reflecting the localStorage/sessionStorage API    
      (without JSON support, just like the real thing)
  */
  store = new function() {
    var data;
    data = {};
    this.clear = function() {
      this.length = 0;
      data = {};
      return this;
    };
    this.getItem = function(k) {
      return data[k];
    };
    this.setItem = function(k, v) {
      this.length++;
      return data[k] = v.toString();
    };
    this.removeItem = function(k) {
      this.length--;
      return delete data[k];
    };
    return this.clear();
  };
  /*
      adds getItemJSON() and setItemJSON() to provided store
  */
  JSONStore = function(store) {
    var proto;
    proto = Object.getPrototypeOf(store);
    if (!proto.getItemJSON) {
      proto.getItemJSON = function(k) {
        var v;
        v = store.getItem(k);
        if (typeof v !== 'string') {
          return JSON.stringify(v);
        }
        return JSON.parse(v);
      };
    }
    if (!proto.setItemJSON) {
      proto.setItemJSON = function(k, v) {
        v = JSON.stringify(v);
        return store.setItem(k, v);
      };
    }
    return store;
  };
  $.fetch = function(options) {
    var promised, reject, request, resolve, response, stored, url;
    options || (options = {});
    /* Deferred response */
    response = $.Deferred();
    /* Default as functions */
    url = options.url || '/';
    store = JSONStore(options.store || store);
    options.success || (options.success = $.noop);
    options.complete || (options.complete = $.noop);
    options.error || (options.error = $.noop);
    /* Get potentially cached */
    stored = store.getItemJSON(url);
    promised = $.fetchRequests[url];
    /* resolves the fetch response  */
    resolve = function(data) {
      store.setItemJSON(url, {
        response: data,
        time: new Date().getTime()
      });
      response.resolve(data);
      return response;
    };
    /* rejects the fetch response  */
    reject = function(error) {
      return response.reject.apply(response, arguments).promise();
    };
    if (stored && stored.response) {
      if (stored.time + $.fetchExpiry >= new Date().getTime()) {
        store.removeItem(url);
      }
      return resolve(stored.response);
    }
    if (promised) {
      /* if promised, we've already fetched that */
      promised.then(resolve, reject);
    } else {
      /* if not a promised request, we need to create one and register it */
      try {
        request = $.ajax(options);
      } catch (E) {
        return reject(E);
      }
      /* beforeSend()'s that return false break ajax promises */
      if (request === false) {
        reject('broken promise');
      } else {
        $.fetchRequests[url] = request;
        request.then(resolve, function() {
          return reject.apply(response, arguments);
        });
      }
    }
    return response.promise();
  };
  $.fetchRequests = {};
  $.fetchExpiry = 1000 * 60 * 30;
  if (isNode) {
    module.exports = $.fetch;
  }
}).call(this);
