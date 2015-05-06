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
                                    local r = msg["r"]
				    local g = msg["g"]
				    local b = msg["b"]
				    local index = msg["index"]
                                    print(index, r, g, b)
                                    storm.n.led_set(strip, index, r/8, g/8, b/8)
                                    storm.n.led_show(strip)
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
