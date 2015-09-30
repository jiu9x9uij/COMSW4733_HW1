%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% Team 5                                                                                                                                                                                           %%
%% Hua Tong (ht2334)                                                                                                                                                                      %%
%% Mengdi Zhang (mz2472)                                                                                                                                                            %%
%% Yilin Long (yl3179)                                                                                                                                                                      %%
%%                                                                                                                                                                                                          %%
%% Please find the following demo videos to see some examples of the expected performance of our program %%
%% https://www.youtube.com/watch?v=M7d6kci41KY                                                                                                           %%
%% https://www.youtube.com/watch?v=0xXMM22f9SQ                                                                                                         %%
%% https://www.youtube.com/watch?v=Kkt-AnTr-TY                                                                                                             %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%

function  hw1_team_05(serPort)

%% Global Variables
total_distance = 0;                                                             % Initialize Total Distance
pos_x = 0;                                                                           % Horizontal axis at the beginning of wall following
pos_y = 0;                                                                           % Vertical axis at the beginning of wall following
pos_theta = 0;                                                                    % Turn angle from positive y-axis
flag = false;                                                                         % If left threshold range after first hit, change to true
thr = 0.2;                                                                              % Threshold range for robot to stop

%% Move forward until hit wall and get ready to follow wall
display('Moving straight towards wall...');
while 1
    % Read sensors
    [BumpRight, BumpLeft, WheelDropRight, WheelDropLeft, WheelDropCastor, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort); % Read Bumpers
    
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

display('Start wall following...');
%% Follow the wall until back to original hit point
d_dist = DistanceSensorRoomba(serPort);                     % Reset distance difference sensor
d_theta = AngleSensorRoomba(serPort);                        % Reset angle difference sensor
no_wall_count = 0;                                                               % Counter for consecutive right turn made because wall not detected
while 1
    % Read sensors
    [BumpRight, BumpLeft, WheelDropRight, WheelDropLeft, WheelDropCastor, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);	% Read Bumpers
    WallSensor = WallSensorReadRoomba(serPort);     % Read wall sensor
    d_dist = DistanceSensorRoomba(serPort);                % Update distance difference
    d_theta = AngleSensorRoomba(serPort);                   % Update angle difference
    
    % Update location information
    pos_theta = pos_theta + d_theta;
    pos_x = pos_x + sin(pos_theta) * d_dist;
    pos_y = pos_y + cos(pos_theta) * d_dist;
    
    % Update distances
    dist = sqrt(pos_x^2 + pos_y^2);                                     % Distance from first hit point
    total_distance = total_distance + d_dist;                      % Distance accumulated from starting point
    
    % Set flag to true when leaving the threshold range after first hit
    if (dist > thr)
        flag = true;
    end
    
    % If left threshold range after first hit and enter the threshold range
    % again, stop robot
    if (flag && dist < thr)
        break;
    end
    
    %% Strategy to follow the wall
    if BumpFront
        % Front side bumped into wall, turn left 90 degrees
        turnAngle(serPort, 0.1, 90);
        SetFwdVelRadiusRoomba(serPort, 0, inf);
        no_wall_count = 0;                                          % Reset counter since not consecutively no wall anymore
    elseif (BumpRight)
        turnAngle(serPort, 0.1, 5);
        SetFwdVelRadiusRoomba(serPort, 0.05, inf);
        pause(0.2); 
        no_wall_count = 0;                                          % Reset counter since not consecutively no wall anymore
    elseif ~WallSensor
        if no_wall_count == 1
            % If consecutively not detecting wall, turn right more in place
            % and reset counter
            turnAngle(serPort, 0.05, -5);
            no_wall_count = 0;                                     % Reset counter since not consecutively no wall anymore
        else
            % First time not detecting wall, turn right and move forward
            turnAngle(serPort, 0.05, -5);
            SetFwdVelRadiusRoomba(serPort, 0.05, inf);
            pause(0.2); 
            no_wall_count = no_wall_count + 1;         % Increase counter because consecutively no wall
        end
    else 
        SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        no_wall_count = 0;                                         % Reset counter since not consecutively no wall anymore 
    end

    % Pause before next loop
    pause(0.1); 
   
end

%% Stop
SetFwdVelRadiusRoomba(serPort, 0, inf);
display(thr);
display(pos_x);
display(pos_y);
display(total_distance) ;

end