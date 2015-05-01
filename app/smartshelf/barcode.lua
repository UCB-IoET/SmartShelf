require "cord"
shellip = "2001:470:66:3f9::2" --IP of middleware service

storm.io.set_mode(storm.io.INPUT, storm.io.D2) -- CLK Pin
storm.io.set_mode(storm.io.INPUT, storm.io.D3) -- DATA Pin

sendsock = storm.net.udpsocket(1337, function() end)

barcodeVal = "x"

scanned = true

cord.new(function ()
    while true do
	if scanned then
		storm.io.watch_single(storm.io.FALLING, storm.io.D2, function()
		    barcodeVal = storm.n.barcode_sample_chars()
		    print(barcodeVal)
		    scanned = true
		end)
		scanned = false
	end
        local t = {barcodeVal}
        storm.net.sendto(sendsock, storm.mp.pack(t), shellip, 2199)
	cord.await(storm.os.invokeLater, 5000 * storm.os.MILLISECOND)
    end
end)

sh = require "stormsh"
sh.start()
cord.enter_loop()


--[[
require "cord"

storm.io.set_mode(storm.io.INPUT, storm.io.D2) -- CLK Pin
storm.io.set_mode(storm.io.INPUT, storm.io.D3) -- DATA Pin

cord.new(function()
	while true do
	   cord.await(storm.io.watch_single, storm.io.FALLING, storm.io.D2)
	   barcodeVal = storm.n.barcode_sample_chars()
           print(barcodeVal)
	end
end)

sh = require "stormsh"
sh.start()
cord.enter_loop()]]--
