

--I use states to determine how the player's input should be handled
State={"State_Intro","State_Test","State_Ending","State_Escape", "State_Empty1", "State_Empty2", "State_Choice"}

	--id numbers of the Rorschach tests to be displayed on the screen
	testSprites={258,306,354,402,450,263,311,359,407,455}
--options that will subtract 3 from the total score
minusthree = 
	{"Crab",
		"LA Traffic",
		"Two People Dancing",
		"Really Good Time",
		"Flower",
		"Chandelier",
		"Throne",
		"My Crazy Ex",
		"Puerto Rico",
		"My Sleep Paralysis Demon"
		}
		--options that will subtract 1 from the total score
minusone = 	{"BathTub",
		"My Dream Yacht",
		"An Old Woman",
		"Working At McDonald's",
		"My Mother's Hand",
		"A Smushed Bug",
		"A Soiled Diaper",
		"Vape Tricks",
		"Texas",
		"Elsa from Frozen"}
		--options that will add 3 to the total score
plusthree =	{"Love",
		"Young Queen Elizabeth",
		"The Abyss",
		"Patriarchy",
		"AK-47",
		"A Row of Hammers",
		"Big Brother is Watching",
		"Michael Jackson",
		"Florida",
		"Mark Zuckerberg"}
		

--possible diagnosees 
D = 
	{"Lactose intolerant",
		"Long-term Juul Addict",
		"Too much 4-chan",
		"Right-wing Drifter",
		"Leftist Scumbag",
		"Stinky poo-poo Pants",
		"Mommy Issues",
		"Florida Man",
		"Real-estate Agent",
		"You think you are Neo from The Matrix"}
--each treatment corresponds to its diagnosees
T = 	{"Grow up.",
		"Switch to cigarettes",
		"Holy shit, go outside",
		"Stop going to church",
		"Move to Texas",
		"Watch less Fox News",
		"Make an Only Fans",
		"Find God",
		"Read Marx",
		"Take a shower. Get a job."}


--button values on the controller and their values in TIC80 documentation used to handle input
B_Y=7
B_A=5
B_B=6
B_X=4

--this function displays the rorcsharch test and possible answers

function init() -- starts the game, resets all variables to their original state, used to restart the game as well
	--these boulean variables are used to determine either the player has attempted to escape the ward
	hammer = false
	keyy=false
	escaped=false
	state = 1 -- the game begins with state_intro
	test_n = 1
	counter = 0-- this variable is used to determine what state should the game be in
	total_score = 0	
end

function displayTest(q)
	spr(268,62,91,6,1,0,0,4,4)--displays button icons
	spr (testSprites[q], 108, 25, -1, 3, 0, 0, 4, 2)--displays the test
	print (minusthree[q], 86, 95, 3) --prints 1st answer option
	print (minusone[q], 86, 105, 3)--prints 2nd answer option
	print (plusthree[q], 86, 115, 3)--prints 3rd answer option
end
	

function displayDT() --considers the total score and assigns a diagnoses paired with it's unique treatment to the player

 local thresholds = {-26, -20, -14, -10, -5, 0, 8, 15, 25}

    local x = 1
    for i, threshold in ipairs(thresholds) do
        if total_score >= threshold then
            x = i + 1
        end
    end

    print("Diagnosis:", 25, 20, 0, 0, 2)
    print(D[x], 25, 40, 3)
    print("Treatment:", 25, 70, 0, 0, 2)
    print(T[x], 25, 90, 3)
end

function editScore(n)--edits the total score depending on the value of the answer given by the player
	total_score = total_score+n
end



-- i will use the command pattern to decouple the sender of a request from the object that performs the action. 
--This separation allows to change or add new commands without affecting the player 
-- Definition of the command interface, each command will have a boulean isReady to determine whether or not is should be executed
local Command = {}
function Command:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    isReady = false
    return o
end


function Command:execute()--each command will inherit this method and define it specifically
    -- Execute the command
end

function Command:perform()--checks if the command is ready and executes it if yes. then resets the boulean to avoid executing the same command every frame
	if self.isReady then 
		self:execute()
		self.isReady = false
	end
end




-- Defining concrete commands

local BegCommand = Command:new()--begins the game
function BegCommand:execute()
	init()
end

local TestCommand = Command:new() -- moves the game into a testing phase
function TestCommand:execute()
	state=2
	counter = counter+1
end
local KeyCommand = Command:new()-- allows the player grab a key for further escape
function KeyCommand:execute()
    keyy = true
    counter =counter+1
    state = 2
end

local HammerCommand = Command:new()--allows the player use a hammer to break out
function HammerCommand:execute()
    hammer = true
    counter =counter+1
    state = 2
end

local EscapeCommand = Command:new()--turns game into the escape state and helps user to leave the facility
function EscapeCommand:execute()
    escaped = true
    myState = "State_Escape"
    counter =counter+1 
end

local MinusThreeCommand = Command:new()--is used to pick an answer that subtracts 3 from the total score and moves on to the next test
function MinusThreeCommand:execute()
	editScore(-3)
	test_n = test_n+1
	counter =counter+1
end

local MinusOneCommand = Command:new()--is used to pick an answer that subtracts 1 from the total score and moves on to the next test
function MinusOneCommand:execute()
  editScore(-1) 
  test_n = test_n+1 
  counter =counter+1   
end

local PlusThreeCommand = Command:new()--is used to pick an answer that add 3 to the total score and moves on to the next test
function PlusThreeCommand:execute()
	editScore(3) 
	test_n = test_n+1 
	counter =counter+1    
end


--I separate input handler with commands from the graphics handler 
local GraphicsHandler = {}

function GraphicsHandler:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end





--main method that will be called every frame to process the graphic and sound component of the game
function GraphicsHandler:handleGraphics()
	if myState=="State_Intro" then 
		music(0, 0, 0)
    		map(60,0,240,136)	
    		print("Let me ask you a couple of questions...",9,98)
    		print("Press X to start", 80, 8)

    elseif  myState=="State_Test"  then		
  	  
					map(60,0,240,136)
				
					if keyy then --if the player picked up the key he won't have handcuffs anymore
						map(120,0,240,136)
					end 
					if hammer and keyy then --if the player picked up the key and hammer he won't have handcuffs anymore and the window will be broken
						
						map(150,0,240,136)
					end

				displayTest(test_n)--displays the test in chronological order
				if btnp(B_X) or btnp(B_A) or btnp(B_B) then--makes a little sound effect when the player interacts with the game
					sfx(3)
				end 
					print("What does it look like?", 50, 8)	

				
	elseif myState == "State_Empty1" then --doctor left the room and you see a key
		map(30,0,240,136) --displays the mao without doctor as he conveniently left the room 
		spr(268,62,91,6,1,0,0,4,3)--displays button icons
		print("The doctor left to grab his papers", 50, 8)
		print("You see a key", 80, 18)
		print("Get rid of handcuffs", 86, 95)--option 1
		print("Wait", 86,105)--option2
	elseif myState == "State_Empty2" then --doctor left the room and you see a hammer
		map(90,0,240,136)
		spr(268,62,91,6,1,0,0,4,3)--displays button icons
		print("The doctor left to answer a call", 50, 8)
		print("You see a hammer", 80, 18)--option1
		print("Break the window", 86, 95)--option2
		print("Wait", 86,105)
	elseif myState == "State_Choice" then --here you choose if you want to escape or not
		map(180,0,240,136)
		print("He left giving you the last chance", 30, 8)
		print("to escape ", 80, 18)
	 spr(268,62,91,6,1,0,0,4,3)
		print("Escape", 86, 95)--option1
		print("Stay here 4ever", 86,105)--option2
	elseif myState == "State_Escape" then --player escaped screen
		map(0,0,30,17)
		print("You escaped! Congratulations!", 80, 45)
		print("But you still don't know ", 80, 55)
		print("what's wrong with you... ", 80, 65)
	
	
	elseif myState=="State_Ending" then
				map(60,0,240,136)--if a player did not manage to escape he gets to know his diagnoses so it's a win-win situation
			displayDT()
	end
end

function switchState()--this function considers counter and prompts the empty scenes to the player to attempt to escape
	if counter==3 then --on the count three the player get's prompted to use a key to get rid of the handcuffs
		state = 5
	end	
	if counter==6 and keyy then --it prompts you to get a hammer only if you used the key, otherwise you are still locked in and can only do the test from now on
		state = 6
	end	
	if counter==10 and keyy and hammer and not escaped then -- choice state that gives the player the ultimate choice of leaving or staying in the facility
		state = 7
	end	
	if keyy and hammer and escaped then--escape screen
		state = 4
	end 
	if test_n>10 then --if the player did not make choices that lead them to escape the game ends when the player goes through all the questions
		state = 3
	end	
end

--input handler handles the commands based on the state of the game
local InputHandler = {}

function InputHandler:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end


function InputHandler:setCommand(command)
    self.command = command
end


--main handler function that gets called every frame to interpret players input
function InputHandler:handleInput()
			
    myState=State[state]
    if myState=="State_Intro" then -- initiates the game
     	
      self.command = BegCommand:new()
      self.command.isReady = true
    		
    		if btnp(B_X) then 		
    			self.command = TestCommand:new()--x proceeds to starting the game
    			self.command.isReady = true
    		end

    	elseif myState=="State_Test"  then			

			if btnp(B_X)then 
				self.command = MinusThreeCommand:new();--x subtracts 3 from the score
				self.command.isReady = true
			elseif btnp(B_A ) then 
				self.command = MinusOneCommand:new();; -- a subtracts 1 from the score
				self.command.isReady = true
			elseif btnp(B_B) then 
				self.command = PlusThreeCommand:new();-- b adds three to the score
				self.command.isReady = true
			end


		elseif myState=="State_Ending" then

			if btnp(B_X) then --x will restart the game if the game ended
			
				init()
			end

		elseif myState=="State_Empty1" then -- x is use the key and a is wait
			if btnp(B_X)then 
				self.command = KeyCommand:new();
				self.command.isReady = true
			elseif btnp(B_A ) then 
				self.command = TestCommand:new();;
				self.command.isReady = true			
		end
		elseif myState=="State_Empty2" then -- x is use the hammer and a is wait
			if btnp(B_X)then 
				self.command = HammerCommand:new();
				self.command.isReady = true
			elseif btnp(B_A ) then 
				self.command = TestCommand:new();;
				self.command.isReady = true
			
		end
		elseif myState=="State_Escape" then -- x restarts the game 
		if btnp(B_X) then 
				init()
		end
	elseif myState=="State_Choice" then -- x is leave and a is stay
			if btnp(B_X)then 
				self.command = EscapeCommand:new();
				self.command.isReady = true
			elseif btnp(B_A ) then 
				self.command = TestCommand:new();;
				self.command.isReady = true			
			end

	end		
    self.command:perform() --executes the chosen command
end


init()
--initializing the handlers
local inputHandler = InputHandler:new() 
--initializing the handlers
local graphicsHandler = GraphicsHandler:new()


function TIC()	--built in game loop
	cls()--cleans the screen every frame
	inputHandler:handleInput()
	graphicsHandler:handleGraphics()
	switchState()
end