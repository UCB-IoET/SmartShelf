require "cord"
sh = require "stormsh"

LCD = require "lcd"
Button = require "button"
require "svcd"

newItem = -1
newItemW = -1

shelves = {}

btn1 = Button:new("D2")
curInd = 0
noShelf = 4
arr = storm.array.create(noShelf, storm.array.UINT16)

lcd = LCD:new(storm.i2c.EXT, 0x7c, storm.i2c.EXT, 0xc4)
cord.new(function ()
    lcd:init(2, 1)
    lcd:writeString("SmartShelf")
end)

cord.new(function()
    cord.await(SVCD.init, "shelfclient")
    SVCD.advert_received = function(pay, srcip, srcport)
        local adv = storm.mp.unpack(pay)
        for k,v in pairs(adv) do
            --These are the services
            if k == 0x5101 then
                --Characteristic
                for kk,vv in pairs(v) do
                    if vv == 0x6105 and k == 0x5101 then
                        -- This is a SmartShelf new item service
                        if strips[srcip] == nil then
                            print ("Discovered SmartShelf: ", srcip)
			        SVCD.subscribe(srcip,0x5101, 0x6105, function(msg)
                                   local rec = storm.array.fromstr(msg) 
                                   newItem = rec:get(1)
                                   newItemW = rec:get(2)
                                   print(newItem, newItemW)
                                end)
			        SVCD.subscribe(srcip,0x5101, 0x6106, function(msg)
                                    arr = storm.array.fromstr(msg)
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
            local stat = cord.await(SVCD.write, k, 0x5101, 0x6105, cmd, 300)
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

btn1:whenever("RISING", function()
    print("Go to next item on list")
    cord.new(function()
        lcd:writeString("                ")
        lcd:setCursor(1, 0)
        lcd:writeString("                ")
        lcd:setCursor(0, 0)
        lcd:writeString("Shelf "+curInd+": "+arr[curInd]);
        if (arr[curInd] < 2100) then
            lcd:setBackColor(255, 0, 0)
        else
            lcd:setBackColor(0, 255, 0)
        end
        cord.await(storm.os.invokeLater, 100*storm.os.MILLISECOND)
    end)
    curInd = (curInd + 1)%#arr
end)

sh.start()
cord.enter_loop()
