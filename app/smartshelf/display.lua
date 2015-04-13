LCD = require "lcd"
Button = require "button"

btn1 = Button:new("D2")
curInd = 0
noShelf = 4
arr = storm.array.create(noShelf, storm.array.UINT16)

lcd = LCD:new(storm.i2c.EXT, 0x7c, storm.i2c.EXT, 0xc4)
cord.new(function ()
    lcd:init(2, 1)
    lcd:writeString("SmartShelf")
end)

btn1:whenever("RISING", function()
    print("Go to next item on list")
    cord.new(function()
        lcd:writeString("                ")
        lcd:setCursor(1, 0)
        lcd:writeString("                ")
        lcd:setCursor(0, 0)
        lcd:writeString("Shelf "+curInd+": "+arr[curInd]);
        if (arr[curInd] < 10) then
            lcd:setBackColor(255, 0, 0)
        else
            lcd:setBackColor(0, 255, 0)
        end
        cord.await(storm.os.invokeLater, 100*storm.os.MILLISECOND)
    end)
    curInd = (curInd + 1)%noShelf
end)

sh.start()
cord.enter_loop()
