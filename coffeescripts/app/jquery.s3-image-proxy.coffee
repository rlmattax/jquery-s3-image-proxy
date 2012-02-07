# References jQuery
$ = jQuery

# Adds plugin object to jQuery
$.fn.extend {}=
  # Change the pluginName.
  s3ImageProxy: (options) ->
    Proxy = class
      constructor: (options) ->
        window.addEventListener 'message', @on_message, false
#        @application = options.application
        @load options.url
      load: (url) ->
        @remote_domain = url.match(/http:\/\/[^/]+/)[0]

        loader = document.createElement 'iframe'
        loader.setAttribute 'style', 'display:none'
        loader.src = "#{url}?stamp=#{@timestamp()}" # force the browser to download the file and execute the JS
        document.body.appendChild loader
      is_loaded: ->
        !!@end_point
      on_message: (event) =>
        return unless event.origin == @remote_domain
        message = JSON.parse event.data
        switch message.action
          when 'init'
            @end_point = event.source
          else
            console.log()
            $($('#'+message.id)).trigger("imageData",message.bits)
      send: (message) ->
        if @is_loaded()
          @end_point.postMessage JSON.stringify(message), @remote_domain
        else
          window.setTimeout ( => @send message), 200
      timestamp: ->
        (Math.random() + "").substr(-10)
    load_image = (img) ->
      path = img.attr('data-path')
      # parse the src path, and pass on to the proxy
      i = 0;
      while(settings["s3remote"].charAt(i) == img.attr("src").charAt(i))
        i++
      proxy.send
        action: 'load'
        path: img.attr("src").substring(i)
        id: img.attr('id')

    timestamp = () ->
      (Math.random() + "").substr(-10)

    # Default settings
    settings =
      s3remote: "http://s3.remote/with/trailing/slash"
      proxyFile: "proxy.html"
      debug: false
      
    # Merge default settings with options.
    settings = $.extend settings, options
    proxy = new Proxy
      url: (settings["s3remote"] + settings["proxyFile"])
      application: this
    # Simple logger.
    log = (msg) ->
      console?.log msg if settings.debug

    # _Insert magic here._

    @each ()->
#      log($(this))
      $(this).attr('id',timestamp)
      $(this).bind("imageData", (evt,bits)->
        $(this).attr('src',bits)
        $(this).unbind("imageData")
      )
      load_image $(this)

