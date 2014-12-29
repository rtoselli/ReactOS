-- ReactOS - Computercraft Bigreactors Automation
-- This is a WIP --
-- Author: Raphael Toselli - github.com/rtoselli
-- Version: 1.0.1 

-- Description:
-- The script assumes that a monitor is attached to the left ( a big 4x2 advanced monitor is recommended ) 
-- It displays reactor information while the script is not being interacted via terminal. 
-- All the configurations and options may be altered via terminal and are pretty self explanatory
-- For now, only one reactor is supported through 2 wired modems

-- #### Changelog ####
-- 1.0 	 *Basic Menu System
--		 *Monitoring with advanced monitors
--		 *Pretty bar of fuel x waste x empty space. 
--		 *Event based execution
--
-- 1.0.1 * Manual Control of the reactors control rods.

-- Future Versions:
-- Automatic feeding of yellorium based on the empty reactor space 
-- Auto turn on/off based on the internal energy buffer
-- Control rod automation based on defined maximum fuel consumption


-- Bind the defaults

reactor = peripheral.wrap("BigReactors-Reactor_0")
mon = peripheral.wrap("left")
autoControl = true

-- Menu itens
MenuProto = {name="",color = colors.white}

function MenuProto:new(name,color)
	o = {name = name,color = color}
	setmetatable(o, self)
	self.__index = self
	return o
end


function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function MenuProto:Print (item)
	term.setTextColor(self.color)
	local x,y = term.getCursorPos()
	term.setCursorPos(1,y + 1)
	term.write(item.."- "..self.name)
	term.setCursorPos(1,y + 2)
end

SelectReactor = MenuProto:new("Select Reactor",colors.lime) 

function SelectReactor:Show()
	term.clear()
	self:Print(1)
	sleep(1)
end

PowerControl = MenuProto:new("Auto Power Control",colors.yellow) 

function PowerControl:Show()
	term.clear()
	self:Print(2)
	sleep(1)
end

ManualMode =  MenuProto:new("Manual operation",colors.red)

function ManualMode:Show()

	while true do
		term.clear()
		term.setCursorPos(1,1)
		term.setTextColor(colors.white)
		term.write("Set each control rod individually")
		term.setCursorPos(1,3)
		term.write("0- Leave ")
		local numControlRods = tonumber(reactor.getNumberOfControlRods())
		
		for i=0,numControlRods-1 do
			term.setCursorPos(1,4 + i)
			term.setTextColor(colors.white)
			local num = i+1
			term.write( tostring(num).."- Control rod ".. reactor.getControlRodName(i).." ")
			term.setTextColor(colors.yellow)
			term.write(reactor.getControlRodLevel(i) .. "%")
		end
		term.setCursorPos(1,4 + numControlRods)
		term.setTextColor(colors.white)
		term.write("Select Control Rods [1-"..numControlRods.."] :")
		local rod = tonumber(read())

		if rod ~= nil then 
			if rod == 0 then break end
			rod = rod - 1 
			
			while true do 
				
				local rodlevel = reactor.getControlRodLevel(rod)
				term.clear()
				term.setCursorPos(1,1)
				term.write("Control rod ".. reactor.getControlRodName(rod) .." - ".. rodlevel .."%")
				term.setCursorPos(1,3)
				term.write("0- Leave ")
				term.setCursorPos(1,4)
				term.write("1- Raise 10% ")
				term.setCursorPos(1,5)
				term.write("2- Raise 50% ")
				term.setCursorPos(1,6)
				term.write("3- Lower 10% ")
				term.setCursorPos(1,7)
				term.write("4- Lower 50% ")
				term.setCursorPos(1,9)
				term.write("Select [0-5]: ")
				local percent = tonumber(read())
				if percent ~= nil then 
					if percent == 0 then break
					elseif percent == 1 then rodlevel = rodlevel + 10
					elseif percent == 2 then rodlevel = rodlevel + 50
					elseif percent == 3 then rodlevel = rodlevel - 10
					elseif percent == 4 then rodlevel = rodlevel - 50
					end
					
					if rodlevel > 100 then rodlevel = 100
					elseif rodlevel < 0 then rodlevel = 0
					end
					
					reactor.setControlRodLevel(rod, rodlevel)
				end
			end
			
		end
		
	end
end
 
function DoSelectReactor()
	return peripheral.wrap("BigReactors-Reactor_0")
end

-- Build the menu
menuItens = { SelectReactor, PowerControl, ManualMode }

function Menu()
	term.clear()
	term.setTextColor(colors.lime)
	term.setCursorPos(1,1)
	term.write("########## ReactOS ############")

	for i,m in pairs(menuItens) do
		m:Print(i)
	end
	term.write("Choose ( 0 to exit ): ")
	return read()
end

function MonitorOutput()
	mon.clear()
	if ( reactor ~= nil and reactor.getConnected() ~= nil ) then 
		mon.setTextColor(colors.white)
		mon.setCursorPos(1,1)
		
		if reactor.getActive() == true then
			mon.setCursorPos(1,1)
			mon.setTextColor(colors.white)
			mon.write("Active: ")
			mon.setTextColor(colors.lime)
			mon.write(reactor.getActive())

			mon.setCursorPos(1,2)
			mon.setTextColor(colors.white)
			mon.write("RF/T: ")  
			mon.setTextColor(colors.lime)
			mon.write(math.floor(reactor.getEnergyProducedLastTick()))

			mon.setCursorPos(1,3)
			mon.setTextColor(colors.white)
			mon.write("RF Stored: ")
			mon.setTextColor(colors.lime)
			mon.write(math.floor(reactor.getEnergyStored()))

			mon.setCursorPos(1,4)
			mon.setTextColor(colors.white)
			mon.write("Casing Heat: ")
			mon.setTextColor(colors.lime)
			mon.write(math.floor(reactor.getCasingTemperature()))

			mon.setCursorPos(1,5)
			mon.setTextColor(colors.white)
			mon.write("Fuel Heat: ")
			mon.setTextColor(colors.lime)
			mon.write(math.floor(reactor.getFuelTemperature()))
			
			
			mon.setCursorPos(1,6)
			mon.setTextColor(colors.white)
			mon.write("Fuel x Waste: ")
			mon.setTextColor(colors.yellow)
			local maxFuelWaste = reactor.getFuelAmountMax()
			local fuel = reactor.getFuelAmount()
			local waste = reactor.getWasteAmount()
			local totalfuel = round(fuel / maxFuelWaste,1)  * 10 
			local totalwaste = round(waste  / maxFuelWaste,1)  * 10
			mon.setTextColor(colors.white)
			mon.write("[")
			mon.setTextColor(colors.lime)
			for i=1,totalfuel do
				mon.write("%")
			end
			
			mon.setTextColor(colors.cyan)
			for i=1,totalwaste  do
				mon.write("%")
			end
			
			local spaceLeft = 10 - ( totalwaste+totalfuel )
			mon.setTextColor(colors.white)
			for i=1, spaceLeft do
				mon.write("%")
			end
			mon.write("]")
			mon.setCursorPos(1,7)
			mon.write(totalfuel.." "..totalwaste.." "..spaceLeft)
			
		else
			mon.write("Reactor is ")
			mon.setTextColor(colors.red)
			mon.write("Inactive!")
		end
	else 
		mon.setCursorPos(1,1)
		mon.setTextColor(colors.red)
		mon.write("No Reactor is connected!")
		reactor = peripheral.wrap("BigReactors-Reactor_0")
	end
end

	
stopWatch = os.startTimer(0.5)

while true do 
	term.clear()
	term.setCursorPos(1,1)
	term.write("########## Press E to interact ############")
	
	local  event, param1 = os.pullEvent()
  if event == "char" and param1 == "e" then 
		term.clear()
		term.setCursorPos(1,1)
		local option = tonumber(Menu()) 
		if option ~= nil then 
			option = option
			if option > 0 and option <= table.getn(menuItens)  then
				local item = menuItens[option] 
				if item ~= nil then
					item:Show()
				else
					term.setTextColor(colors.white)
					term.write("Not Found!")
					sleep(0.5)
				end
				stopWatch = os.startTimer(0.2)
			elseif option == 0 then
				break
			
			end 
		end
	elseif event == "timer" and param1 == stopWatch then 
		stopWatch = os.startTimer(0.2)
		MonitorOutput()
  end
	
	
end
