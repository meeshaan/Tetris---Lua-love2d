-- Meeshaan Shah
-- CPSC 354
-- Final Project
-- Tetris

-- Tetris pieces
-- I, O, L, J, S, Z, T
pieces = {
    { -- O
        {0,0,0,0},
        {0,1,1,0},
        {0,1,1,0},
        {0,0,0,0}
    },
    { -- I
        {0,0,0,0},
        {0,0,0,0},
        {1,1,1,1},
        {0,0,0,0}
    },
    { -- L
        {0,0,0,0},
        {0,0,1,0},
        {1,1,1,0},
        {0,0,0,0}
    },
    { -- J
        {0,0,0,0},
        {0,1,0,0},
        {0,1,1,1},
        {0,0,0,0}
    },
    { -- S
        {0,0,0,0},
        {0,0,1,1},
        {0,1,1,0},
        {0,0,0,0}
    },
    { -- Z
        {0,0,0,0},
        {1,1,0,0},
        {0,1,1,0},
        {0,0,0,0}
    },
    { -- T
        {0,0,0,0},
        {0,0,1,0},
        {0,1,1,1},
        {0,0,0,0}
    }
}

-- tetris board
field = {
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0}
}

-- window colors
clearBg = {0,0,0}
clearFieldBg = {0,0,0}
clearFieldBorder = {0,255,255}
clearMain = {255,0,0}

-- piece sizes
blockSize = 32
fieldWidth = 10
fieldHeight = 20

--getting next random piece, for displaying preview and spawning piece
pieceActive = pieces[love.math.random(#pieces)]
pieceActiveFallen = false
pieceActiveX = 3
pieceActiveY = 0
pieceNext = pieces[love.math.random(#pieces)]

-- for rotations
dx = 0
rotation = false
forceFall = false

soundLocked = false

-- points and to check if piece is alive
isAlive = true
points = 0

 -- for frame manip
delta = 0
timeStep = 1

-- ---------------------------------------------------------------------
--MAIN

--default for love, loads general resources
function love.load()
	-- window width and size
    windowWidth = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()
	
	--background color
    love.graphics.setBackgroundColor(clearBg)
	
	--sound
    soundCorrect = love.audio.newSource('resources/correct.wav')
    soundWrong = love.audio.newSource('resources/wrong.wav')
    --soundLose = love.audio.newSource('resources/lose.wav')
    soundPoints = love.audio.newSource('resources/points.wav')
	
	--font
    mainFont = love.graphics.newFont("resources/bebas.ttf", 24);
    smallFont = love.graphics.newFont("resources/bebas.ttf", 16);
end

--for key presses
function love.keypressed(key, unicode)
    if key == 'escape' then
        r = love.event.quit()
    elseif key == 'w' or key == 'up' then			--rotates piece
        rotation = true
    elseif key == 'a' or key == 'left' then			--move left
        dx = -1
    elseif key == 'd' or key == 'right' then		--move right
        dx = 1
    elseif key == 's' or key == 'down' then			--drops piece
        forceFall = true
    end
end

--update functions that updates screen every frame
function love.update(dt)
	--check if lost
    if not isAlive then
       --if soundEnabled then
            --playSound(soundLose)
      --  end
        return true
    end

    delta = delta + dt
	
	--check for rotation
    if rotation then
        rotation = false

        if canRotate(pieceActive, pieceActiveX, pieceActiveY) then
            pieceActive = rotate(pieceActive)
        else
            playSound(soundWrong)
        end
    end
	
	--check if can move
    if dx ~= 0 then
        mx = canMove(pieceActive, pieceActiveX, pieceActiveY, dx)
        if mx == 0 then
            playSound(soundWrong)
        end
        dx = dx * mx
        pieceActiveX = pieceActiveX + dx
        dx = 0
    end
	
	--for force fall
    if forceFall then
        pieceActiveY = Drop(field, pieceActive, pieceActiveX, pieceActiveY)

        -- make that player can not do anything before we merge the piece
        delta = timeStep + 1

        forceFall = false
    end
	
	--merging figues to form a tetris
    if delta > timeStep then
        pieceActiveFallen = Gravity(field, pieceActive, pieceActiveX, pieceActiveY)

        if pieceActiveFallen then
            mergePiece(field, pieceActive, pieceActiveX, pieceActiveY)
			
			--remove tetris's
            gainedPoints = removeFilled()
            if gainedPoints > 0 then
                playSound(soundPoints)
                points = points + gainedPoints

                if points > 1000 / timeStep then
                    timeStep = timeStep * 0.9
                end
            else
                playSound(soundCorrect)
            end
			
			--for getting next piece
            pieceActive = pieceNext
            pieceActiveX = 3
            pieceActiveY = 0
            isAlive = checkAlive(pieceActive, pieceActiveX, pieceActiveY)
            if not isAlive then
                pieceActive = {
                    {1,1,1,1},
                    {1,1,1,1},
                    {1,1,1,1},
                    {1,1,1,1}
                }
            end
            pieceNext = pieces[love.math.random(#pieces)]
        end

        delta = 0
    end
end

--draw objects to screen
function love.draw()
    drawInterface()
    drawField(field)

    drawPieceField(pieceActive, pieceActiveX, pieceActiveY)
    drawPieceSide(pieceNext)

    if not isAlive then
    	--playSound(soundLose)
        love.graphics.print(
            'GAME OVER!',
            (fieldWidth) * blockSize/3,
            7.5 * blockSize,
            0,
            1.5,
            1.5
        )
    end
end

-- ---------------------------------------------------------------------

--force piece to drop
function Drop(field, piece, posx, posy)
    continueFall = true
    dy = 0

    while continueFall do
        y = 1
        while y < 5 do
            x = 1
            while x < 5 do
                if piece[y][x] == 1 then
                    if posy+y+dy >= 20 then
                        continueFall = false
                    elseif field[posy+y+dy+1][posx+x] == 1 then
                        continueFall = false
                    end
                end
                x = x + 1
            end
            y = y + 1
        end

        dy = dy + 1
    end

    return posy+dy-1
end

-- check if piece is active
function checkAlive(piece, posx, posy)
    y = 1
    while y < 5 do
        x = 1
        while x < 5 do
            if piece[y][x] == 1 then
                if field[posy+y][posx+x] == 1 then
                    return false
                end
            end
            x = x + 1
        end
        y = y + 1
    end

    return true
end

--remove tetris when blocks have been filled
function removeFilled()
    removedLines = 0

    y = fieldHeight
    while y > 0 do
        filledSpots = 0
        for x = 1, fieldWidth do
            filledSpots = filledSpots + field[y][x]
        end
        if filledSpots == 10 then
            i = y
            while i > 0 do
                if i > 1 then
                    field[i] = field[i-1]
                else
                    field[i] = {0,0,0,0,0,0,0,0,0,0}
                end
                i = i - 1
            end
            removedLines = removedLines + 1
        else
            y = y - 1
        end
    end

    return calculatePoints(removedLines)
end

--to calculate scores based on rows removed
function calculatePoints(lines)
    if lines == 0 then
        return 0
    else
        return lines + calculatePoints(lines-1)
    end
end

--check if rotation is available, rotates until false
function canRotate(piece, posx, posy)
    ghostPiece = {
        {},{},{},{}
    }

    ghostPiece = rotate(piece)

    y = 1
    while y < 5 do
        x = 1
        while x < 5 do
            if ghostPiece[y][x] == 1 then
                if posx+x+dx > fieldWidth or posx+x+dx < 1 then
                    return false
                elseif field[posy+y][posx+x+dx] == 1 then
                    return false
                end
            end
            x = x + 1
        end
        y = y + 1
    end

    return true
end

--rotoates piece
function rotate(pieceIn)
    pieceOut = {
        {},{},{},{}
    }

    for j = 1, 4 do
        for i = 1, 4 do
            pieceOut[j][5-i] = pieceIn[i][j]
        end
    end

    return pieceOut
end

--play sound
function playSound(sound)
    --if sound_enabled then
        if not soundLocked then
            soundLocked = true
            love.audio.play(sound)
            love.audio.rewind(sound)
            soundLocked = false
        end
    --end
end

--check if piece can move, moves until false
function canMove(piece, posx, posy, dx)
    mx = 1

    y = 1
    while y < 5 do
        x = 1
        while x < 5 do
            if piece[y][x] == 1 then
                if posx+x+dx > fieldWidth or posx+x+dx < 1 then
                    mx = 0
                elseif field[posy+y][posx+x+dx] == 1 then
                    mx = 0
                end
            end
            x = x + 1
        end
        y = y + 1
    end

    return mx
end

--merges pieces when place has been placed
function mergePiece(field, piece, posx, posy)
    y = 1
    while y < 5 do
        x = 1
        while x < 5 do
            if piece[y][x] == 1 then
                field[posy+y][posx+x] = 1
            end
            x = x + 1
        end
        y = y + 1
    end
end

--activate gravity to make piece fall when activated by user
function Gravity(field, piece, posx, posy)
    isFallen = false

    y = 1
    while y < 5 do
        x = 1
        while x < 5 do
            if piece[y][x] == 1 then
                if posy + y + 1 > fieldHeight or field[posy+y+1][posx+x] == 1 then
                    isFallen = true
                end
            end
            x = x + 1
        end
        y = y + 1
    end

    if isFallen then
        return true
    else
        pieceActiveY = pieceActiveY + 1
        return false
    end
end

--draws the tetris field 
function drawField(field)
    y = 1
    while y < fieldHeight + 1 do
        x = 1
        while x < fieldWidth + 1 do
            if field[y][x] == 1 then
                posxd = x * blockSize
                posyd = y * blockSize
                drawBlock(posxd, posyd, clearFieldBorder)
            end
            x = x + 1
        end
        y = y + 1
    end
end

--draws piece into field
function drawPieceField(piece, posx, posy)
    y = 1
    while y < 5 do
        x = 1
        while x < 5 do
            if piece[y][x] == 1 then
                posxd = (posx + x) * blockSize
                posyd = (posy + y) * blockSize
                drawBlock(posxd, posyd, clearMain)
            end
            x = x + 1
        end
        y = y + 1
    end
end

--draws side piece or next piece
function drawPieceSide(piece)
    y = 1
    while y < 5 do
        x = 1
        while x < 5 do
            if piece[y][x] == 1 then
                posx = (fieldWidth + x + 0.5) * blockSize
                posy = (y + 0.5) * blockSize
                drawBlock(posx, posy, clearMain)
            end
            x = x + 1
        end
        y = y + 1
    end
end

--draws blocks to screen
function drawBlock(posx, posy, color)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill",
        posx - blockSize,
        posy - blockSize,
        blockSize,
        blockSize
    )
end

-- Draws interfaces for ui functionality score/controls etc.
function drawInterface()
    love.graphics.setColor(clearFieldBg)
    love.graphics.rectangle("fill", 0, 0, fieldWidth * blockSize, fieldHeight * blockSize)

    love.graphics.setColor(clearFieldBorder)
    y = 0
    while y <= fieldHeight * blockSize do
        x = 0
        while x <= fieldWidth * blockSize do

            love.graphics.line(x, 0, x, windowHeight)
            love.graphics.line(0, y, fieldWidth * blockSize, y)
            x = x + blockSize
        end
        y = y + blockSize
    end

    love.graphics.setColor(clearFieldBorder)
    love.graphics.rectangle( "line",
        (fieldWidth + 0.5) * blockSize,
        0.5 * blockSize,
        blockSize*4,
        blockSize*4
    )

    love.graphics.setFont(mainFont);
    love.graphics.printf(
        'Score: \n' .. points*100,
        (fieldWidth + 0.5) * blockSize,
        5.5 * blockSize,
        128,
        'left'
    )

    love.graphics.setFont(smallFont);
    love.graphics.printf(
        'Controls:\n\nA - left\nD - right\nW - rotate\nS - force fall\n\nESC - exit',
        (fieldWidth + 0.5) * blockSize,
        8.5 * blockSize,
        128,
        'left'
    )
end    