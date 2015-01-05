local max_x, max_y = term.getSize();
local pmax_x, pmax_y = 0, 0
local mmax_x, mmax_y = 0, 0
local currentLine = 3;
local storeName = "Norman's Computers"
local storeNameDiv = {"Norman's", "Computers"}
local ownerCredit = "176326b7-474a-4125-bb70-52f3bd2921ff"
local modemSide = "top"
local line = 3
local overriddenLetters = 0;
local sides = {"top", "bottom", "left", "right", "front", "back"}
local broke = false
local firstPage = true
local colorExists = term.isColor()
local pageStarted = false

local amount = "";
local product = "";
local price = "";
local lastProduct = "";
local lastProductA = "";
local subtotal = 0;
local payment = "";
local change = 0;

modem = peripheral.wrap(modemSide)
modem.transmit(23, 1, "OPEN")

modem.open(512)

function writeCenter(width, height, text, yDiff)
  term.setCursorPos(math.floor((width - #text) / 2), height);
  term.clearLine()
  term.write(text);
end

function writeError(message)
  if monitorExists then
    m.setCursorPos(1, 5)
    m.write(message)
  end
  writeCenter(max_x, max_y / 2 - 1, message)
  writeCenter(max_x, max_y / 2, "Discard the receipt")
  if printerExists then
    if p.setCursorPos(1, pmax_y - 1) ~= nil then
      p.write(message)
      p.setCursorPos(1, pmax_y)
      p.write("RECEIPT NOT VALID")
    end
  end
end

if colorExists then
  term.setBackgroundColor(colors.orange);
  term.setTextColor(colors.black);
end

term.clear()

writeCenter(max_x, math.floor(max_y / 2), "Printer: ")
side = io.read() 
if side == "" then
  printerExists = false
else
  for i = 1, 6 do
    if string.lower(side) == sides[i] then
      sideMatched = true
    end
  end
  if sideMatched then
    p = peripheral.wrap(string.lower(side))
    sideMatched = false
    printerExists = true
  else
    term.clear()
    writeCenter(max_x, math.floor(max_y / 2), "Printer: ")
    side = io.read()
  end
end

term.clear()
writeCenter(max_x, math.floor(max_y / 2), "Monitor: ")
side = io.read()
if side == "" then
  monitorExists = false
else
  for i = 1, 6 do
    if string.lower(side) == sides[i] then
      sideMatched = true
    end
  end
  if sideMatched then
    m = peripheral.wrap(string.lower(side))
    sideMatched = false
    mmax_x, mmax_y = m.getSize()
    monitorExists = true
  else
    term.clear()
    writeCenter(max_x, math.floor(max_y / 2), "Monitor: ")
    side = io.read()
  end
end

while true do  
  firstPage = true
  pageStarted = false
  term.clear();
  if monitorExists then
    m.clear()
    m.setCursorPos((mmax_x - #"Welcome to") / 2, 2)
    m.write("Welcome to")
    if #storeName >= mmax_x then
      for k,v in pairs(storeNameDiv) do
        m.setCursorPos(math.floor((mmax_x - #v) / 2), line)
        m.write(v)
        line = line + 1
      end
      line = 3
    else
      m.setCursorPos(math.floor((mmax_x - #storeName) / 2), line)
      m.write(storeName)
    end
  end
  
  while true do
    term.clear()
    
    writeCenter(max_x, math.floor(max_y / 2) - 3, "Amount: ");
    writeCenter(max_x, math.floor(max_y / 2) + 0, "Product:");
    writeCenter(max_x, math.floor(max_y / 2) + 3, "Price:  ");
    term.setCursorPos((math.floor(max_x / 2) - (8 / 2)), math.floor(max_y) / 2 + 6);
    term.write(lastProduct);
    term.setCursorPos((math.floor(max_x / 2) - (8 / 2)), math.floor(max_y) / 2 + 7);
    term.write(lastProductA);
    
    term.setCursorPos((math.floor(max_x / 2) - (8 / 2)), math.floor(max_y) / 2 + 9);
    term.write("$" .. subtotal);    

    while tonumber(amount) == nil do
      term.setCursorPos((math.floor(max_x / 2) - (8 / 2)), (math.floor(max_y) / 2 - 2));
      term.clearLine()
      amount = io.read();
      if amount == "" then
        if printerExists and pageStarted then
          break
        elseif printerExists == false then
          break
        end
      end
    end
    
    if amount == "" then
      if pageStarted and printerExists then
        break;
      elseif printerExists == false then
        break
      end
    end
    
    term.setCursorPos((math.floor(max_x / 2) - (8 / 2)), (math.floor(max_y) / 2 + 1));
    product = io.read();
    if product == "" then
      term.setBackgroundColor(colors.black)
      term.setTextColor(colors.white)
      term.setCursorPos(1, 1)
      term.clear()
      if printerExists and not firstPage then
        p.setCursorPos(1, pmax_y - 1)
        p.write("Purchase cancelled")
        p.setCursorPos(1, pmax_y)
        p.write("RECEIPT NOT VALID")
        p.endPage()
      end
      return
    end
  
    while tonumber(price) == nil do
      term.setCursorPos((math.floor(max_x / 2) - (8 / 2)), math.floor(max_y) / 2 + 4);
      term.clearLine()
      price = io.read();
    end
    
    if printerExists and firstPage then
      p.newPage()
      pageStarted = true
      pmax_x, pmax_y = p.getPageSize() 
      p.setPageTitle(storeName)
      p.setCursorPos(1, 1)
      p.write(storeName)
      firstPage = false
    end
    
    if tonumber(amount) > 1 then
      lastProduct = amount .. " x " .. product .. "  $" .. (tonumber(price) * tonumber(amount));
      lastProductA = "  a $" .. tonumber(price);
      
      if monitorExists then
        --[[if #(amount .. " x " .. product .. " $" .. tonumber(price) * tonumber(amount)) >= mmax_x then
          priceString = (amount .. " x " .. product .. " $" .. tonumber(price) * tonumber(amount))
          overriddenLetters = #priceString - mmax_x
          print(overriddenLetters)
          print(mmax_x)
          print(#priceString)
          product = string.sub(product, 1, #product - overriddenLetters - 4)
          print(#priceString - overriddenLetters - 4)
          product = product .. "..."
          print(product)
          sleep(2)
        end]]--
        m.clear()
        m.setCursorPos(1, 2)
        m.write(amount .. " x " .. product .. " $" .. tonumber(price) * tonumber(amount));
        m.setCursorPos(1, 3)
        m.write("  a $" .. tonumber(price));
        m.setCursorPos(1, 4)
        m.write("Subtotal: $" .. subtotal + (tonumber(price) * tonumber(amount)))
      end
      
      if currentLine >= (pmax_y - 3) then
        if printerExists then
          p.setCursorPos(1, currentLine)
          p.write("See next page")
          p.endPage()
          p.newPage()
          p.setPageTitle(storeName)
          p.setCursorPos(1, 1)
          p.write("See previous page")
          currentLine = 3
        end
      end
      
      if printerExists then
        p.setCursorPos(1, currentLine)
        p.write(amount .. " x " .. product .. " $" .. tonumber(price) * tonumber(amount));
        p.setCursorPos(1, currentLine + 1)
        p.write("  a $" .. tonumber(price));
        currentLine = currentLine + 2
      end
    else
      lastProduct = amount .. " x " .. product .. "  $" .. tonumber(price);
      lastProductA = "";
      
      if monitorExists then
        m.clear()
        m.setCursorPos(1, 2)
        m.write(amount .. " x " .. product .. "  $" .. tonumber(price))
        m.setCursorPos(1, 4)
        m.write("Subtotal: $" .. subtotal + (tonumber(price) * tonumber(amount)))
      end
      
      if currentLine >= (pmax_y - 3) then
        if printerExists then
          p.setCursorPos(1, currentLine)
          p.write("See next page")
          p.endPage()
          p.newPage()
          p.setPageTitle("See previous page")
          p.setCursorPos(1, 1)
          p.write(storeName)
          currentLine = 3
        end
      end
      
      if printerExists then
        p.setCursorPos(1, currentLine)
        p.write(amount .. " x " .. product .. "  $" .. tonumber(price))
        currentLine = currentLine + 1
      end
    end
    subtotal = subtotal + (price * amount);
    amount = ""
    product = ""
    price = ""
  end
  term.clear()
  writeCenter(max_x, math.floor(max_y / 2) - 1, "Total:");
  writeCenter(max_x, math.floor(max_y / 2), "$" .. tostring(subtotal));
  
  if monitorExists then
    m.clear()
    m.setCursorPos(1, 1)
    m.write("Total: $" .. subtotal)
  end

  while tonumber(payment) == nil do
    term.setCursorPos((max_x - #"Payment:") / 2, math.floor(max_y / 2) + 3);
    term.clearLine()
    writeCenter(max_x, math.floor(max_y / 2) + 2, "Payment:");
    term.setCursorPos((max_x - #"Payment:") / 2, math.floor(max_y / 2) + 3);
    payment = io.read();
    if payment == "" then
      break
    end
  end
  if payment == "" then
    cardPayment = true
    term.clear()
    writeCenter(max_x, math.floor(max_y / 2), "Insert card into reader")
    if monitorExists then
      m.setCursorPos(1, 3)
      m.write("Insert Card")
    end
    event, side = os.pullEvent("disk")
    if not fs.exists("disk/card") then
      writeError("Not a card")
      if printerExists then
        p.setCursorPos(1, pmax_y - 3)
        p.write("Card payment")
        p.setCursorPos(1, pmax_y - 2)
        p.write("Total: $" .. subtotal)
        p.endPage()
      end
      sleep(2)
      term.setBackgroundColor(colors.black)
      term.setTextColor(colors.white)
      term.clear()
      term.setCursorPos(1, 1)
      break
    end
    file = fs.open("disk/card", "r")
    if monitorExists then
      m.setCursorPos(1, 3)
      m.write("Do not take it out")
    end
    local card_number = file.readLine()
    file.close()
    if not fs.exists("disk/pin") then
      writeError("Expired card")
      if printerExists then
        p.setCursorPos(1, pmax_y - 3)
        p.write("Card payment")
        p.setCursorPos(1, pmax_y - 2)
        p.write("Total: $" .. subtotal)
        p.endPage()
      end
      break
    end
    file = fs.open("disk/pin", "r")
    local card_pin = file.readLine()
    file.close()
    local message = "notconfirm"
    local argumentsString = textutils.serialize({card_number, subtotal, ownerCredit, card_pin})
    http.request("http://localhost/centraldator/transfer.php?account1=" .. card_number .. "&account2=" .. ownerCredit .. "&amount=" .. subtotal .. "&pin=" .. card_pin)
    timeout = os.startTimer(10)
    event, url, message = os.pullEvent()
    if event == "timer" then
      writeError("No connection")
    elseif event == "http_success" then
      message = message.readAll()
      if monitorExists then
        m.clear()
        m.setCursorPos(1, 1)
        m.write("Total: $" .. subtotal)
        m.setCursorPos(1, 3)
        m.write("Card payment")
      end
      if message == "nomoney" then
        writeError("Not enough money")
      elseif message == "error" then
        writeError("An error occured")
      elseif message == "pin" then
        writeError("Wrong pin")
      elseif message == "confirm" then
        if monitorExists then
          m.setCursorPos(1, 5)
          m.write("Remove card")
        end
        writeCenter(max_x, math.floor(max_y / 2), "Remove card from reader")
      else
        writeError("HTTP Error")
      end
    elseif event == "http_failure" then
      writeError("HTTP Failure")
    else
      writeError("HTTP Error")
    end
  else
    cardPayment = false
  end
  
  if cardPayment == false then
    change = payment - subtotal
  else
    change = 0
  end
  
  writeCenter(max_x, math.floor(max_y / 2) + 5, "Change: " .. tostring(change))
  
  if monitorExists and cardPayment == false then
    m.setCursorPos(1, 2)
    m.write("Payment: $" .. payment)
    m.setCursorPos(1, 3)
    m.write("Change: $" .. change)
    m.setCursorPos(1, 5)
    m.write("Come again!")
  end
  
  if printerExists then
    p.setCursorPos(1, pmax_y - 2)
    p.write("Total: $" .. subtotal)
    if not cardPayment then
      p.setCursorPos(1, pmax_y - 1)
      p.write("Payment: $" .. payment)
      p.setCursorPos(1, pmax_y)
      p.write("Change: $" .. change)
    elseif cardPayment then
      p.setCursorPos(1, pmax_y - 3)
      p.write("Card payment")
    end
  end
  
  if printerExists then
    currentLine = 3
  end
  
  io.read();
  lastProduct = ""
  lastProductA = ""
  subtotal = 0
  
  if printerExists then
    p.endPage()
  end
end
