function [ax,ay,az,gx,gy,gz,date_time,temp,pressure,bias] = import_tag_gyro2(filename)
% Import tag data from the gyroscope, interpolating datetime.
%
% [ax,ay,az,gx,gy,gz,date_time,temp,pressure] = import_tag_gyro2(filename)
% Pressure, which is currently not implemented, returns 0.
filename = strcat('data/', filename);
fp = fopen(filename);
if fp == -1
    error(['Could not open ' filename]);
end

TAB = sprintf('\t');
% Since NaT is actually a function, I save it here
NAT = NaT;

%% Get Raw Data
sdata = []; % ax ay az gx gy gz
name='unnamed tag';
orient=0;
bias=[0,0,0];
% First line might contain name+orient... or not
tline = fgetl(fp);
if tline(1) ~= TAB
    cells = strsplit(tline, TAB);
    name = cells{1};
    orient = str2double(cells{2});
    bias = sscanf(fgetl(fp), '%f %f %f');
    tline = fgetl(fp);
end
disp(name)
if orient==1
   disp 'Orientation will be corrected.' 
else
   disp 'Orientation is assumed to be correct.'
end

% First line - date/time info
date_time = [datetime(tline(7:end), 'InputFormat', 'y-M-d H:m:s')];
temp = [0];
pressure = [0];
while true
   tline = fgetl(fp);
   if ~ischar(tline), break, end
   if tline(1) == TAB
       line = tline(7:end);
       tabi = strfind(line, TAB);
       
       date_string = line(1:(tabi-1));
       date_time(end) = datetime(date_string, 'InputFormat', 'y-M-d H:m:s');
       
       data_string = line((tabi+1):end);
       data = sscanf(data_string, '%f'); % TODO add in pressure
       temp(end) = data;
       pressure(end) = 0;
   else
       sdata = [sdata; sscanf(tline, '%f %f %f %f %f %f')'];
       if (size(sdata,1) ~= 1)
           date_time = [date_time; NAT];
           temp = [temp; temp(end)];
           pressure = [pressure; pressure(end)];
       end
   end
end

fclose(fp);

%% Finalize Variables
ax = sdata(:,1);
ay = sdata(:,2);
az = sdata(:,3);
% Fix gyroscope misalignment if necessary
if orient == 1
    gy = sdata(:,4);
    gx = sdata(:,5);
else
    gx = sdata(:,4);
    gy = sdata(:,5);
end
gz = sdata(:,6);

%% Datetime interpolation
%this way is faster and gives functionaly identical values to the way below
inds = find(~isnat(date_time));
% from 1 to (inds-1):
%   get the last time value and the current one
%   find the number of indices between the two
%   linspace() the two and assign it to the date_time
for n=1:(length(inds)-1)
   i_old = inds(n);
   i_new = inds(n+1);
   t_old = date_time(i_old);
   t_new = date_time(i_new);
   date_time(i_old:(i_new-1)) = linspace(t_old, t_new, i_new-i_old);
end

% % Stolen from William
% tic
% time_ind=find(~isnat(date_time));
% for n=1:(length(time_ind)-1);
%     time_diff=date_time(time_ind(n+1))-date_time(time_ind(n)); %diff between recorded times
%     num_of_point=time_ind(n+1)-time_ind(n); %number of points that need to be interp
%     time_increase=time_diff/num_of_point; %step size of interp
%     %fill in the blank times
%     for k =time_ind(n)+1:time_ind(n+1)
%         date_time(k)=date_time(k-1)+time_increase;
%     end
% end
% toc



%% Remove Blank Rows

%get rid off all bank rows in accel and gyro
not_data=isnan(ax(1:end));
ax(not_data,:)=[];
ay(not_data,:)=[];
az(not_data,:)=[];
gx(not_data,:)=[];
gy(not_data,:)=[];
gz(not_data,:)=[];

%remove unneeded time stamps as well, this cause problem where
%temp/pressure have no assosated time stamps
date_time(not_data,:)=[];
end
