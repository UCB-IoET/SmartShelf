require "cord"

storm.io.set_mode(storm.io.INPUT, storm.io.D2) -- CLK Pin
storm.io.set_mode(storm.io.INPUT, storm.io.D3) -- DATA Pin

cord.new(function()
	--prev = storm.io.get(storm.io.D2)
	while true do
	   --print(prev)
	   --print(storm.io.get(storm.io.D2))
	   --[[if storm.io.get(storm.io.D2) == 0 and prev == 1 then
	      print("Detected!")
	      storm.n.barcode_sample()
	   end]]--
	--code = {}
	--for i = 1,11*8 do
	   cord.await(storm.io.watch_single, storm.io.FALLING, storm.io.D2)
	   --storm.n.barcode_sample()
	   storm.n.barcode_sample_chars()
	   --print(storm.io.get(storm.io.D3))
	   --code[i] = storm.io.get(storm.io.D3)
	--end
	--for i = 1,11*8 do
	   --storm.n.barcode_sample()
	   --print(storm.io.get(storm.io.D3))
	   --print(code[i])
	--end]]--
	--print(code)
	--prev = storm.io.get(storm.io.D2)
	end
end)

sh = require "stormsh"
sh.start()
cord.enter_loop()
