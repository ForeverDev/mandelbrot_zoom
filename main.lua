local const = {
  iterations = 1000;
  screen_width = love.window:getWidth();
  screen_height = love.window:getHeight();
  colorscheme = {
    {66, 30, 15};     {25, 7, 26};
    {9, 1, 47};       {4, 4, 73};
    {0, 7, 100};      {12, 44, 138};
    {24, 82, 177};    {57, 125, 209};
    {134, 181, 229};  {211, 236, 248};
    {241, 233, 191};  {248, 201, 95};
    {255, 170, 0};    {204, 128, 0};
    {153, 87, 0};     {106, 52, 3};
  };
}

local screenshot = nil
local points = {}
local tl = {x = -2; y = -1.5;}
local br = {x = 1; y = 1.5;}
local mouse_down = false
local mouse_start_x = 0
local mouse_start_y = 0

local function map(n, a, b, c, d)
  return (n - a)/(b - a)*(d - c) + c
end

local function generate_mandelbrot()
  screenshot = nil
  local points = {}
  local count_i = 0
  for i = tl.x, br.x, (br.x - tl.x) / const.screen_width do
    count_i = count_i + 1
    points[count_i] = {}
    local count_j = 0
    for j = tl.y, br.y, (br.y - tl.y) / const.screen_height do
      count_j = count_j + 1
      local zx, zy = 0, 0
      local iter = 0
      while iter < const.iterations and zx*zx + zy*zy < 4 do
        zx, zy = zx*zx - zy*zy + i, 2*zx*zy + j
        iter = iter + 1
      end
      if iter == const.iterations then
        points[count_i][count_j] = {0, 0, 0}
      else
        points[count_i][count_j] = const.colorscheme[(iter % #const.colorscheme) + 1]
      end
    end
  end
  local data = love.image.newImageData(const.screen_width, const.screen_height)
  for i = 1, #points do
    for j = 1, #points[i] do
      if i >= const.screen_width or j >= const.screen_height then
        break
      end
      data:setPixel(i, j, points[i][j][1], points[i][j][2], points[i][j][3])
    end
  end
  screenshot = love.graphics.newImage(data)
end

function love.load()
  generate_mandelbrot()
end

function love.update(dt)

end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  if screenshot then
    love.graphics.draw(screenshot, 0, 0)
  end
  if mouse_down then
    local size = math.max(love.mouse:getX() - mouse_start_x, love.mouse:getY() - mouse_start_y)
    love.graphics.setColor(255, 255, 0, 180)
    love.graphics.rectangle("fill", mouse_start_x, mouse_start_y, size, size)
  end
end

function love.keypressed(k)
  if k == "escape" then
    love.event.quit()
  end
end

function love.mousepressed(x, y, b)
  if b == "l" then
    mouse_down = true
    mouse_start_x = x
    mouse_start_y = y
  end
end

function love.mousereleased(x, y, b)
  if b == "l" then
    mouse_down = false
    local d = math.max(x - mouse_start_x, y - mouse_start_y)
    local tlx = tl.x
    local tly = tl.y
    tl.x = map(mouse_start_x, 0, const.screen_width, tl.x, br.x)
    tl.y = map(mouse_start_y, 0, const.screen_height, tl.y, br.y)
    br.x = map(mouse_start_x + d, 0, const.screen_width, tlx, br.x)
    br.y = map(mouse_start_y + d, 0, const.screen_height, tly, br.y)
    tl.x, br.x = math.min(tl.x, br.x), math.max(tl.x, br.x)
    tl.y, br.y = math.min(tl.y, br.y), math.max(tl.y, br.y)
    generate_mandelbrot()
  end
end
