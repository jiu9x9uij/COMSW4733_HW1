function  HW1(serPort)

%% Move forward until hit wall and get ready to follow wall
% Variable Declaration
tStart= tic;                                                                             % Time limit marker
maxDuration = 20;                                                               % 20 seconds of max duration time
Initial_Distance = DistanceSensorRoomba(serPort);     % Get the Initial Distance
Total_Distance = 0;                                                             % Initialize Total Distance
WallSensor = WallSensorReadRoomba(serPort);

while 1
    display('while1');
    % Read sensors
    [BumpRight, BumpLeft, WheelDropRight, WheelDropLeft, WheelDropCastor, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort); % Read Bumpers
%     WallSensor = WallSensorReadRoomba(serPort);
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
        SetFwdVelRadiusRoomba(serPort, 0.1, inf);
        % Update the Total_Distance covered so far
        Total_Distance = Total_Distance + DistanceSensorRoomba(serPort);    
%         display(Total_Distance)
    end
    
    pause(0.1);
    
end

pos_x = 0;
pos_y = 0;
pos_theta = 0;
flag = false; % if left threshold after first hit, change to true
thr = 0.2;

while 1 
    display('while2');
    % Read sensors
    [BumpRight, BumpLeft, WheelDropRight, WheelDropLeft, WheelDropCastor, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort); % Read Bumpers
    WallSensor = WallSensorReadRoomba(serPort);
    d_dist = DistanceSensorRoomba(serPort);                % Poll for Distance delta
    d_theta = AngleSensorRoomba(serPort); 
    
    pos_theta = pos_theta + d_theta;
    pos_x = pos_x + sin(pos_theta) * d_dist;
    pos_y = pos_y + cos(pos_theta) * d_dist;
    
    dist = sqrt(pos_x^2 + pos_y^2);
    
    if (dist > thr)
        flag = true;
    end
    
    if (flag && dist < thr)
        break;
    end
    
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
    
    if BumpFront
        turnAngle(serPort, 0.1, 90);
        SetFwdVelRadiusRoomba(serPort, 0, inf);
    elseif (BumpRight && WallSensor)
        turnAngle(serPort, 0.1, 3);
        SetFwdVelRadiusRoomba(serPort, 0.1, inf);
    elseif ~WallSensor
        turnAngle(serPort, 0.1, -15);
        SetFwdVelRadiusRoomba(serPort, 0, inf);
    else 
        SetFwdVelRadiusRoomba(serPort, 0.1, inf);
        Total_Distance = Total_Distance + DistanceSensorRoomba(serPort); 
    end

    pause(0.1); 
   
end
%% Follow the wall until back to original hit point
% while not back to original place...

%% Stop and display the Total_Distance covered so far
SetFwdVelRadiusRoomba(serPort, 0, inf);                                       
display(Total_Distance)                                             

end