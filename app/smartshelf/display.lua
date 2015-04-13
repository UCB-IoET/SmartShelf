require "cord"
sh = require "stormsh"

require "svcd"

newItem = -1
newItemW = -1

shelves = {}

curInd = 0
noShelf = 4

cord.new(function()
    cord.await(SVCD.init, "shelfclient")
    print("inside the cord")
    SVCD.advert_received = function(pay, srcip, srcport)
        local adv = storm.mp.unpack(pay)
        print("got payload", pay)
        for k,v in pairs(adv) do
            --These are the services
            if k == 0x5101 then
                --Characteristic
                for kk,vv in pairs(v) do
                    if vv == 0x6105 and k == 0x5101 then
                        -- This is a SmartShelf new item service
                        if strips[srcip] == nil then
                            print ("Discovered SmartShelf newitem: ", srcip)
			    SVCD.subscribe(srcip,0x5101, 0x6105, function(msg)
                               local rec = storm.array.fromstr(msg) 
                               newItem = rec:get(1)
                               newItemW = rec:get(2)
                               print("Detected change ", newItem, newItemW)
                            end)
                        end
                        shelves[srcip] = storm.os.now(storm.os.SHIFT_16)
                    end
                    if vv == 0x6106 and k == 0x5101 then
                        -- This is a SmartShelf new item service
                        if strips[srcip] == nil then
                            print ("Discovered SmartShelf getWeights: ", srcip)
			    SVCD.subscribe(srcip,0x5101, 0x6106, function(msg)
                                arr = storm.array.fromstr(msg)
                                print("Got weights", arr)
                            end)
                        end
                        shelves[srcip] = storm.os.now(storm.os.SHIFT_16)
                    end
                end
            end
        end
    end
end)

-- Locate a particular item
function locateItem(name)
    cord.new(function()
        for k, v in pairs(shelves) do
            local cmd = name
            local stat = cord.await(SVCD.write, k, 0x5101, 0x6107, cmd, 300)
            if stat ~= SVCD.OK then
                print "FAIL"
            else
                print "OK"
            end
            -- don't spam
            cord.await(storm.os.invokeLater,50*storm.os.MILLISECOND)
        end
    end)
end

sh.start()
cord.enter_loop()
