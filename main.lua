
-- Initialisation function, set up the global variables 
function love.load()

    x = 100 
    
    circleList = {}
    maxRadius = 50 
    
    circleColor = {}
    circleColor.red   = 0.961
    circleColor.green = 0.42
    circleColor.blue  = 0.043

    lineList = {}
    drawnLine = False 
    radiusIncrement = 1 
    
    lineSpeed = 1 
    lineSpeedIncrement = 0.2

    lineColor = {}
    lineColor.red   = 0.91
    lineColor.green = 0.898
    lineColor.blue  = 0.153

    rectangleList = {}
    rectangleColor   = 0.812
    rectangleHeight = 100
    rectangleWidth  = 75 
   
    timeForNewLine = 1.0 
    timeofLastLineAdd = love.timer.getTime()
    timeForNewLineIncrement = 0.2

    inGame = false 


    linesPerLevel = 5
    linesInCurrentLevel = 0

    print( "Starting game" )
end

function resetGlobals()
    lineSpeed = 1 
    timeForNewLine = 1.0 
    linesInCurrentLevel = 0

    rectangleList = {}
    circleList = {}
    lineList = {}
end

function setupNextLevel()
    lineSpeed = lineSpeed + lineSpeedIncrement
    
    if ( timeForNewLine >= timeForNewLineIncrement ) then 
        timeForNewLine = timeForNewLine - timeForNewLineIncrement
    end

    linesInCurrentLevel = 0 

    timeofLastLineAdd = love.timer.getTime()

    circleList = {}
    lineList = {}
end


function startGame() 
    inGame = true 
    addRectangles()
end

function updateCircles() 
    -- Expand the circles' radiuses 
    for i,v in ipairs(circleList) do
        v.radius = v.radius + radiusIncrement
    end

    -- Remove circles that have a bigger radius than maxRadius
    newCircleList = {}
    for i,v in ipairs(circleList) do
        if v.radius < maxRadius then
            table.insert(newCircleList, v)
        end
    end

    circleList = newCircleList
end

function addLine()

    if ( linesInCurrentLevel < linesPerLevel ) then 

        -- add a line from somewhere on top to the bottom. Calculate the length 
        -- when it goes from the top to the bottom 
        width = love.graphics.getWidth()
        height = love.graphics.getHeight()

        newLine = {}
        newLine.x_start = width * math.random()
        newLine.x_end = width * math.random()
        newLine.y_end = height 
        newLine.gradient = ( newLine.x_end - newLine.x_start ) / height
        newLine.current_end = 1 
  
        table.insert(lineList, newLine)  

        linesInCurrentLevel = linesInCurrentLevel + 1 
    end
end

function addRectangles()
    
    maxRectangles = 3

    next_x = 110 
    increment = rectangleWidth + 50 

    for x=1,5 do
        rectangle = {}


        rectangle.x = next_x
        rectangle.y = love.graphics.getHeight() - rectangleHeight 
        rectangle.width  = rectangleWidth
        rectangle.height = rectangleHeight
        rectangle.keep = true         

        next_x = next_x + increment

        table.insert( rectangleList, rectangle )
    end

end

function updateLines()
    
    for i,v in ipairs(lineList) do
        v.current_end = v.current_end + lineSpeed      
    end
    
    newLineList = {}

    height = love.graphics.getHeight()
    keepLine = true

    for i,v in ipairs(lineList) do
        keepLine = true 

        -- check if the line intercepts any buildings 
        -- love.graphics.rectangle( "fill", v.x, v.y, v.width, v.height )
        for q,r in ipairs(rectangleList) do
            current_x = v.current_end * v.gradient + v.x_start
            if ( ( r.y < v.current_end ) and ( v.current_end < ( r.y + r.height ) ) and  -- within the y values 
                 ( ( current_x < r.x + r.width ) and ( current_x > r.x ) ) ) then 
                    addExpandingCircle( v.gradient * v.current_end + v.x_start, v.current_end  )
                    r.keep = false
            end
        end

        -- check if the line is now at the bottom 
        -- if it is then add an explosion 
        if ( v.current_end > height ) then
            keepLine = false 
            addExpandingCircle( v.gradient * v.current_end + v.x_start, v.current_end  )
        end

        -- check if the line is with radius of any of the circles 
        for x,z in ipairs(circleList) do
            ydiff = ( v.current_end - z.y ) ^ 2 
            xdiff = ( v.current_end * v.gradient + v.x_start - z.x ) ^ 2 
            if ( ( z.radius ) ^ 2 > ( xdiff + ydiff ) ) then
                keepLine = false 
            end
        end

        if keepLine then 
            table.insert(newLineList, v)
        end
    end

    lineList = newLineList
end

function drawLines() 
    love.graphics.setColor( lineColor.red, lineColor.green, lineColor.blue, 1.0 )
    for i,v in ipairs(lineList) do
        
        love.graphics.line( v.x_start, 0, v.gradient * v.current_end + v.x_start, v.current_end )
    end
end

function updateRectangles() 
    newRectangleList = {}
    rectangles_left = false

    for q,r in ipairs(rectangleList) do
        if r.keep then
            table.insert( newRectangleList, r) 
            rectangles_left = true
        end
    end

    if rectangles_left == false then 
        endGame() 
    end    

    rectangleList = newRectangleList    
end

function endGame() 
    inGame = false
    resetGlobals() 
end

function addExpandingCircle(x,y)
    newCircle = {}
    newCircle.x = x
    newCircle.y = y
    newCircle.radius = 10
     
    table.insert(circleList, newCircle)
end

function love.mousepressed( x, y, button, istouch, presses) 
    if ( inGame ) then
        addExpandingCircle(x,y)
    end
end

function drawCircles()
    love.graphics.setColor( circleColor.red, circleColor.green, circleColor.blue, 1.0 )
    for i,v in ipairs(circleList) do
        
        love.graphics.circle( "fill", v.x, v.y, v.radius )
    end
end

function drawRectangles()
    for i,v in ipairs(rectangleList) do 
        love.graphics.setColor( rectangleColor, rectangleColor, rectangleColor, 1.0 )
        love.graphics.rectangle( "fill", v.x, v.y, v.width, v.height )
    end
end

function drawTitleScreen() 
    font = love.graphics.newFont(40)
    love.graphics.setFont(font)
    love.graphics.setColor( 0.8, 0.3, 0.3 )
    love.graphics.print( "Missile Command", 150, 150, 0, 1, 1)
    love.graphics.print( "Press q to quit", 150, 250, 0, 1, 1)
    love.graphics.print( "Any other key to begin", 150, 350, 0, 1, 1)
    
end

function love.keypressed(key, scancode, isrepeat) 
    if ( key == 'q' ) then 
        love.event.quit(0)
    end
    
    startGame()
 end

function love.update(dt)
    
    if ( inGame ) then
        currentTime = love.timer.getTime() 
        if ( ( currentTime - timeofLastLineAdd ) > timeForNewLine ) then
            addLine()
            timeofLastLineAdd = currentTime
        end
    
        updateCircles()
        updateLines()
        updateRectangles()

        if ( inGame == false ) then
            resetGlobals()
        end
    end


    -- print( #lineList ) 

    if ( linesInCurrentLevel >= linesPerLevel ) and ( #lineList == 0 ) then
        setupNextLevel()
    end

end

function love.draw()
    if inGame then 
        drawCircles()
        drawLines()
        drawRectangles()
    else
        drawTitleScreen() 
    end
end