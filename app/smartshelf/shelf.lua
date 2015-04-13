
require "cord"
require "svcd"

storm.io.set_mode(storm.io.OUTPUT, storm.io.D2, storm.io.D3)

strip = storm.n.led_init(50, 0x10000, 0x1000)
fsrs = storm.array.create(4,storm.array.UINT16)
storm.n.adcife_init()
fsrs:set(1, storm.n.adcife_sample_an0(0))
storm.n.adcife_init()
fsrs:set(2, storm.n.adcife_sample_an0(1))
storm.n.adcife_init()
fsrs:set(3, storm.n.adcife_sample_an0(2))
storm.n.adcife_init()
fsrs:set(4, storm.n.adcife_sample_an0(3))

shelves = {}
shelves[1] = "apples"
shelves[2] = "bananas"
shelves[3] = "oranges"
shelves[4] = "pineapples"

MOTDs = {"Default message!!1" }

SVCD.init("SmartShelf", function()
    print "starting"
    SVCD.add_service(0x5101)

    -- New item notifications
    SVCD.add_attribute(0x5101, 0x6105, function(pay, srcip, srcport)
    end)

    -- Get weights notifications
    SVCD.add_attribute(0x5101, 0x6106, function(pay, srcip, srcport)
    end)

    -- locateItem("name")
    SVCD.add_attribute(0x5101, 0x6107, function(pay, srcip, srcport)
        print ("got a request to locate item")
	local ps = storm.array.fromstr(pay)
        local itemName = ps:get(1)
        print ("got a request to locate item")
	for i=1,4 do
		if shelves[i] == itemName then
			storm.n.led_set(strip, i, 0, 0, 31)
			break
		else storm.n.led_set(strip, i, 0, 0, 0)
		end
	end
        storm.n.led_show(strip)
    end)


    cord.new(function()
        while true do
	    storm.n.adcife_init()
            local fsr1 = storm.n.adcife_sample_an0(0)
	    storm.n.adcife_init()
            local fsr2 = storm.n.adcife_sample_an0(1)
	    storm.n.adcife_init()
            local fsr3 = storm.n.adcife_sample_an0(2)
	    storm.n.adcife_init()
            local fsr4 = storm.n.adcife_sample_an0(3)
	    print(fsr1, fsr2, fsr3, fsr4)
	    
	    if (math.abs(fsr1 - fsrs:get(1)) > 100) then
            	print ("sending new item notification, shelf 1")
		local arr = storm.array.create(2,storm.array.UINT16)
	    	arr:set(1, 1)
		arr:set(2, fsr1)
            	SVCD.notify(0x5101, 0x6105, arr:as_str())
	    elseif (math.abs(fsr2 - fsrs:get(2)) > 100) then
            	print ("sending new item notification, shelf 2")
		local arr = storm.array.create(2,storm.array.UINT16)
	    	arr:set(1, 2)
		arr:set(2, fsr2)
            	SVCD.notify(0x5101, 0x6105, arr:as_str())
	    elseif (math.abs(fsr3 - fsrs:get(3)) > 100) then
            	print ("sending new item notification, shelf 3")
		local arr = storm.array.create(2,storm.array.UINT16)
	    	arr:set(1, 3)
		arr:set(2, fsr3)
            	SVCD.notify(0x5101, 0x6105, arr:as_str())
	    elseif (math.abs(fsr4 - fsrs:get(4)) > 100) then
            	print ("sending new item notification, shelf 4")
		local arr = storm.array.create(2,storm.array.UINT16)
	    	arr:set(1, 4)
		arr:set(2, fsr4)
            	SVCD.notify(0x5101, 0x6105, arr:as_str())

	    -- Else give all weights
	    else
		print ("Sending all weights")
		local arr = storm.array.create(4,storm.array.UINT16)
	    	arr:set(1, fsr1)
		arr:set(2, fsr2)
	    	arr:set(3, fsr3)
		arr:set(4, fsr4)
            	SVCD.notify(0x5101, 0x6106, arr:as_str())
	    end

	    fsrs:set(1, fsr1)
	    fsrs:set(2, fsr2)
	    fsrs:set(3, fsr3)
	    fsrs:set(4, fsr4)
	    cord.await(storm.os.invokeLater, 1*storm.os.SECOND)
        end
    end)

--[[TODO figure out what to do widdis
    cord.new(function()
        while true do
            local msg = MOTDs[math.random(1,#MOTDs)]
            local arr = storm.array.create(#msg+1,storm.array.UINT8)
            arr:set_pstring(0, msg)
            SVCD.notify(0x3101, 0x4108, arr:as_str())
            cord.await(storm.os.invokeLater, 3*storm.os.SECOND)
        end
    end)]]--
end)


cord.enter_loop()

