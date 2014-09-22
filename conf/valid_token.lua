
function get_token()
   local header =  ngx.var.http_Authorization
   if header == nil or header:find(" ") == nil then
      return
   end
   local divider = header:find(' ')
   if header:sub(0, divider-1) ~= 'Bearer' then
      return
   end
   local auth = header:sub(divider+1) 
   return auth 
end 
function get_redis(key)
    local redis = require "resty.redis"
    
    local cache = redis.new()
    
    local ok, err = cache.connect(cache, '121.199.33.9', '6379')
    
    cache:set_timeout(60000)
    
    if not ok then
       ngx.say("failed to connect:", err)
    return
    end
    
    --res, err = cache:set("dog", "an aniaml1")
    --           if not ok then
    --           ngx.say("failed to set dog: ", err)
    --return
    --end
    
    --ngx.say("set result: ", res)
    
    local res, err = cache:get(key)
                     if not res then
                     ngx.say("failed to get dog: ", err)
    return
    end
    
    if res == ngx.null then
              ngx.say("dog not found.")
    return
    end 

    local ok, err = cache:close()
                    if not ok then
                    ngx.say("failed to close:", err)
    return
    end
    return res
end
local token = get_token()
if ngx.var.uri == "/oauth/token" then
 return 
end 
if token == nil then     
   ngx.status = ngx.HTTP_UNAUTHORIZED
   ngx.say('401 Access Denied')
else
   local res = get_redis(token) 

   if res == nil then 
      ngx.status = ngx.HTTP_UNAUTHORIZED
      ngx.say('401 token out of date')
      ngx.exit(ngx.HTTP_OK) 
   end
end
