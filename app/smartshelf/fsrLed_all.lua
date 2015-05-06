-- TODO: Make library
--FSR = require "fsr" --fsr library
require "cord"
--fsr = FSR:new()
shellip = "2001:470:66:3f9::2" --IP of middleware service
storm.io.set_mode(storm.io.INPUT, storm.io.A0)
storm.io.set_mode(storm.io.OUTPUT, storm.io.D2)
storm.io.set_mode(storm.io.OUTPUT, storm.io.D3)

strip = storm.n.led_init(50, 0x10000, 0x1000)

sendsock = storm.net.udpsocket(1337, function() end)

storm.n.led_show(strip)

listen_port = 2198

ssock = storm.net.udpsocket(listen_port, function(payload, from, port)
				                    print (string.format("from %s port %d: %s",from,port,payload))
				    
                                    local msg = storm.mp.unpack(payload)
                                    local led0 = msg["r"]
				    local g = msg["g"]
				    local b = msg["b"]
				    local index = msg["index"]
                                    --print(index, r, g, b)
				    for i = 0, 5, 1 do
					if msg[tostring(i)] == '0' then
                                    		storm.n.led_set(strip, i, 0, 0, 0)
					elseif msg[tostring(i)] == '1' then
                                    		storm.n.led_set(strip, i, 31, 0, 0)
					elseif msg[tostring(i)] == '2' then
                                    		storm.n.led_set(strip, i, 0, 31, 0)
					elseif msg[tostring(i)] == '3' then
                                    		storm.n.led_set(strip, i, 0, 0, 31)
					elseif msg[tostring(i)] == '4' then
                                    		storm.n.led_set(strip, i, 31, 31, 0)
					elseif msg[tostring(i)] == '5' then
                                    		storm.n.led_set(strip, i, 31, 31, 31)
					end
                                    	storm.n.led_show(strip)
				    end
			       end)


cord.new(function ()
    --fsr:init()
    while true do
        cord.await(storm.os.invokeLater, 3000 * storm.os.MILLISECOND)
        --local data = fsr:get()
        storm.n.adcife_init()
        local data0 = storm.n.adcife_sample_an0(0)
        storm.n.adcife_init()
        local data1 = storm.n.adcife_sample_an0(1)
        storm.n.adcife_init()
        local data2 = storm.n.adcife_sample_an0(2)
        storm.n.adcife_init()
        local data3 = storm.n.adcife_sample_an0(3)
	storm.n.adcife_init()
        local data4 = storm.n.adcife_sample_an0(4)
	storm.n.adcife_init()
        local data5 = storm.n.adcife_sample_an0(5)
	
        local t = {data0, data1, data2, data3, data4, data5, 0, 0, 0}
	print(data0, data1, data2, data3, data4, data5, 0, 0, 0)
        storm.net.sendto(sendsock, storm.mp.pack(t), shellip, 2198)
    end
end)
cord.enter_loop()
