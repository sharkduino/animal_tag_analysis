function [ pitch, roll ] = accel_pr( x, y, z )
%ACCEL_PR Get pitch and roll from the accelerometer
%   This uses filtering and a bit of trig to get an approximation
%   of the pitch and roll from accelerometer inputs x, y, and z.
%   The coordinate system used is x=pitch, y=roll, and z=yaw.
%   There may be instability around certain angles (Gimbal lock &c.).

% The atan2 difference between small positive numbers and small negative
% numbers is huge. I want to defeat noise errors when close to 0.
% if abs(x_f) < 0.0001; x_f = 0; end
% if abs(y_f) < 0.0001; y_f = 0; end
% if abs(z_f) < 0.0001; z_f = 0; end

% Stolen from:
% https://theccontinuum.com/2012/09/24/arduino-imu-pitch-roll-from-accelerometer/
pitch = -rad2deg(atan2(-x, z));
roll = rad2deg(atan2(y, sqrt(x.^2 + z.^2)));

end

