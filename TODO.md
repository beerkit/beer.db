# Todos

### fix uninitialized constant Beer

```
[debug] Webservice::Base.get - add route GET '/beer/:key' to >< (31739568)
[debug] Webservice::Base.get - add route GET '/brewery/:key' to >< (31739568)
app_class:
#<Class:0x3c89d60>
dump routes:
{"GET"=>
  [[[/^\/beer\/([^\/?#]+)$/, ["key"]], #<Proc:0x3917be0@(eval):7>],
   [[/^\/brewery\/([^\/?#]+)$/, ["key"]], #<Proc:0x3917208@(eval):18>]]}
starting server...
[debug] Webservice::Base.run! - self: >< (31739568) : Class
[2017-08-18 18:50:23] INFO  WEBrick 1.3.1
[2017-08-18 18:50:23] INFO  ruby 2.3.3 (2016-11-21) [i386-mingw32]
[2017-08-18 18:50:23] INFO  WEBrick::HTTPServer#start: pid=7556 port=4567
[2017-08-18 18:50:44] ERROR NameError: uninitialized constant Beer
        (eval):13:in `block in load_file'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/gems/2.3.0/gems/webservice-0.2.0/lib/webservice/base.rb:93:in `instance_eval'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/gems/2.3.0/gems/webservice-0.2.0/lib/webservice/base.rb:93:in `block (2 levels)
in route_eval'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/gems/2.3.0/gems/webservice-0.2.0/lib/webservice/base.rb:87:in `each'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/gems/2.3.0/gems/webservice-0.2.0/lib/webservice/base.rb:87:in `block in route_ev
al'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/gems/2.3.0/gems/webservice-0.2.0/lib/webservice/base.rb:86:in `catch'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/gems/2.3.0/gems/webservice-0.2.0/lib/webservice/base.rb:86:in `route_eval'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/gems/2.3.0/gems/webservice-0.2.0/lib/webservice/base.rb:67:in `call!'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/gems/2.3.0/gems/webservice-0.2.0/lib/webservice/base.rb:58:in `call'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/gems/2.3.0/gems/rack-2.0.3/lib/rack/urlmap.rb:68:in `block in call'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/gems/2.3.0/gems/rack-2.0.3/lib/rack/urlmap.rb:53:in `each'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/gems/2.3.0/gems/rack-2.0.3/lib/rack/urlmap.rb:53:in `call'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/gems/2.3.0/gems/rack-2.0.3/lib/rack/builder.rb:153:in `call'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/gems/2.3.0/gems/rack-2.0.3/lib/rack/handler/webrick.rb:86:in `service'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/2.3.0/webrick/httpserver.rb:140:in `service'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/2.3.0/webrick/httpserver.rb:96:in `run'
        C:/prg/ri330/Ruby2.3.0/lib/ruby/2.3.0/webrick/server.rb:296:in `block in start_thread'
::1 - - [18/Aug/2017:18:50:43 Mitteleuropõische Sommerzeit] "GET /beer/r HTTP/1.1" 500 307
- -> /beer/r
```
