-- Builds a drivable car at game start. Walk up to it and press the "Enter Car" prompt.
-- Drive with W/A/S/D, jump to get out.

local SPAWN_POSITION = Vector3.new(20, 4, 0)

local MAX_SPEED = 80 -- studs/second
local MAX_STEER_ANGLE = 30 -- degrees
local WHEEL_RADIUS = 1.5
local DRIVE_SIGN = -1 -- if the car drives backwards, change this to 1

local BODY_SIZE = Vector3.new(6, 1, 12)
local WHEEL_WIDTH = 1
local WHEEL_X = BODY_SIZE.X / 2 + WHEEL_WIDTH / 2 + 0.1
local WHEEL_Y = -0.5
local WHEEL_Z = 4

local function makePart(name: string, size: Vector3, cframe: CFrame, color: Color3): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

local function makeAttachment(parent: BasePart, position: Vector3, rotation: CFrame?): Attachment
	local attachment = Instance.new("Attachment")
	attachment.CFrame = CFrame.new(position) * (rotation or CFrame.identity)
	attachment.Parent = parent
	return attachment
end

local function makeWheel(car: Model, name: string, cframe: CFrame): Part
	local wheel = makePart(name, Vector3.new(WHEEL_WIDTH, WHEEL_RADIUS * 2, WHEEL_RADIUS * 2), cframe, Color3.fromRGB(30, 30, 30))
	wheel.Shape = Enum.PartType.Cylinder
	wheel.CustomPhysicalProperties = PhysicalProperties.new(1, 2, 0, 100, 1)
	wheel.Parent = car
	return wheel
end

local function buildCar(): (Model, VehicleSeat)
	local car = Instance.new("Model")
	car.Name = "Car"

	local origin = CFrame.new(SPAWN_POSITION)

	local body = makePart("Body", BODY_SIZE, origin, Color3.fromRGB(196, 40, 28))
	body.Parent = car
	car.PrimaryPart = body

	local cabin = makePart("Cabin", Vector3.new(5, 1.5, 5), origin * CFrame.new(0, 1.25, 1.5), Color3.fromRGB(150, 30, 20))
	cabin.Parent = car
	local cabinWeld = Instance.new("WeldConstraint")
	cabinWeld.Part0 = body
	cabinWeld.Part1 = cabin
	cabinWeld.Parent = body

	local seat = Instance.new("VehicleSeat")
	seat.Name = "DriverSeat"
	seat.Size = Vector3.new(2, 0.5, 2)
	seat.CFrame = origin * CFrame.new(0, 0.75, -2)
	seat.Color = Color3.fromRGB(40, 40, 40)
	seat.Parent = car
	local seatWeld = Instance.new("WeldConstraint")
	seatWeld.Part0 = body
	seatWeld.Part1 = seat
	seatWeld.Parent = body

	-- Hinge axis is the attachment's X axis; turning it onto Y makes a steering pivot.
	local steerRotation = CFrame.Angles(0, 0, math.rad(90))
	local motors: { HingeConstraint } = {}
	local steerServos: { HingeConstraint } = {}

	local function addWheel(name: string, side: number, z: number, steered: boolean)
		local localOffset = Vector3.new(side * WHEEL_X, WHEEL_Y, z)
		local wheel = makeWheel(car, name, origin * CFrame.new(localOffset))

		local motor = Instance.new("HingeConstraint")
		motor.ActuatorType = Enum.ActuatorType.Motor
		motor.MotorMaxTorque = 20000
		motor.MotorMaxAcceleration = 200
		motor.AngularVelocity = 0
		motor.Attachment1 = makeAttachment(wheel, Vector3.zero)

		if steered then
			-- A small invisible knuckle sits between the body and the wheel so the wheel can both spin and turn.
			local knuckle = makePart(name .. "Knuckle", Vector3.new(1, 1, 1), origin * CFrame.new(localOffset), Color3.new())
			knuckle.Transparency = 1
			knuckle.CanCollide = false
			knuckle.Parent = car

			local steer = Instance.new("HingeConstraint")
			steer.ActuatorType = Enum.ActuatorType.Servo
			steer.ServoMaxTorque = 50000
			steer.AngularSpeed = 4
			steer.TargetAngle = 0
			steer.Attachment0 = makeAttachment(body, localOffset, steerRotation)
			steer.Attachment1 = makeAttachment(knuckle, Vector3.zero, steerRotation)
			steer.Parent = knuckle
			table.insert(steerServos, steer)

			motor.Attachment0 = makeAttachment(knuckle, Vector3.zero)
		else
			motor.Attachment0 = makeAttachment(body, localOffset)
		end

		motor.Parent = wheel
		table.insert(motors, motor)
	end

	addWheel("FrontLeftWheel", -1, -WHEEL_Z, true)
	addWheel("FrontRightWheel", 1, -WHEEL_Z, true)
	addWheel("RearLeftWheel", -1, WHEEL_Z, false)
	addWheel("RearRightWheel", 1, WHEEL_Z, false)

	-- Drive the wheels from the driver's input.
	local function update()
		local angularSpeed = DRIVE_SIGN * seat.ThrottleFloat * MAX_SPEED / WHEEL_RADIUS
		for _, motor in motors do
			motor.AngularVelocity = angularSpeed
		end
		for _, servo in steerServos do
			-- Positive hinge angle turns left, positive steer is right.
			servo.TargetAngle = -seat.SteerFloat * MAX_STEER_ANGLE
		end
	end
	seat:GetPropertyChangedSignal("ThrottleFloat"):Connect(update)
	seat:GetPropertyChangedSignal("SteerFloat"):Connect(update)

	-- "Enter Car" button that shows up when a player walks near.
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Enter Car"
	prompt.ObjectText = "Car"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = seat

	prompt.Triggered:Connect(function(player: Player)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 and seat.Occupant == nil then
			seat:Sit(humanoid)
		end
	end)

	-- Hide the button while someone is driving.
	seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		prompt.Enabled = seat.Occupant == nil
	end)

	return car, seat
end

local car = buildCar()
car.Parent = workspace
