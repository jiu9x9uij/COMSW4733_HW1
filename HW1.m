function  HW1(serPort)

%% Move forward until hit wall and get ready to follow wall
% Variable Declaration
total_distance = 0;                                                             % Initialize Total Distance
pos_x = 0;
pos_y = 0;
pos_theta = 0;
flag = false;                                                                           % If left threshold range after first hit, change to true
thr = 0.2;

while 1
    display('while1');
    % Read sensors
    [BumpRight, BumpLeft, WheelDropRight, WheelDropLeft, WheelDropCastor, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort); % Read Bumpers
    % DEBUG Print sensor values if it is triggered
    if(BumpLeft ~= 0)
        display(BumpLeft)
    end
    if(BumpRight ~= 0)
        display(BumpRight)
    end
    if(BumpFront)
        display(BumpFront)
    end
    WallSensor = WallSensorReadRoomba(serPort);
    if(WallSensor ~= 0)
        display(WallSensor)
    end
    
    % Turn wall sensor to face wall, or move forward until hit wall
    if(BumpRight)
        % Right side bump into wall, turn left 45 degrees
        turnAngle(serPort, 0.1, 45);
        SetFwdVelRadiusRoomba(serPort, 0, inf);
        break;
    elseif(BumpFront)
        % Front side bump into wall, turn left 90 degrees
        turnAngle(serPort, 0.1, 90);
        SetFwdVelRadiusRoomba(serPort, 0, inf);
        break;
    elseif(BumpLeft)
        % Left side bump into wall, turn left 135 degrees
        turnAngle(serPort, 0.1, 135);
        SetFwdVelRadiusRoomba(serPort, 0, inf);
        break;
    else
        % Hasn't bumped into wall, keep moving forward
        SetFwdVelRadiusRoomba(serPort, 0.3, inf);
    end
    
     % Pause before next loop
    pause(0.1);
    
end

%% Follow the wall until back to original hit point
d_dist = DistanceSensorRoomba(serPort);                     % Reset distance difference sensor
d_theta = AngleSensorRoomba(serPort);                        % Reset angle difference sensor
while 1 
    display('while2');
    % Read sensors
    [BumpRight, BumpLeft, WheelDropRight, WheelDropLeft, WheelDropCastor, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);	% Read Bumpers
    WallSensor = WallSensorReadRoomba(serPort);     % Read wall sensor
    d_dist = DistanceSensorRoomba(serPort);                % Update distance difference
    d_theta = AngleSensorRoomba(serPort);                   % Update angle difference
    
    % Update location information
    pos_theta = pos_theta + d_theta;
    pos_x = pos_x + sin(pos_theta) * d_dist;
    pos_y = pos_y + cos(pos_theta) * d_dist;
    
    % Update distance to first hit point
    dist = sqrt(pos_x^2 + pos_y^2);
    
    % Set flag to true when leaving the threshold range after first hit
    if (dist > thr)
        flag = true;
    end
    
    % If left threshold range after first hit and enter the threshold range
    % again, stop robot
    if (flag && dist < thr)
        break;
    end
    
    % DEBUG Print
    display(pos_x);
    display(pos_y);
    if(BumpLeft ~= 0)
        display(BumpLeft)
    end
    if(BumpRight ~= 0)
        display(BumpRight)
    end
    if(BumpFront)
        display(BumpFront)
    end
    if(WallSensor ~= 0)
    display(WallSensor)
    end
    
    % Strategy to follow the wall
    if BumpFront
        turnAngle(serPort, 0.1, 90);
        SetFwdVelRadiusRoomba(serPort, 0, inf);
    elseif (BumpRight)
        turnAngle(serPort, 0.1, 10);
        SetFwdVelRadiusRoomba(serPort, 0.1, inf);
    elseif ~WallSensor
        turnAngle(serPort, 0.05, -5);
        SetFwdVelRadiusRoomba(serPort, 0.1, inf);
    else 
        SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        % Accumulate distance since first hit point
        total_distance = total_distance + d_dist; 
    end

    % Pause before next loop
    pause(0.1); 
   
end

%% Stop
SetFwdVelRadiusRoomba(serPort, 0, inf);                                       
display(total_distance) 
display(pos_x);
display(pos_y);

end