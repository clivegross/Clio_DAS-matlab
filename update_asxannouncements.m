% Get Previous Days ASX Announcements to 'daedalusdb' database
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script takes the previous days announcements from the ASX website
% URL: http://www.asx.com.au/asx/statistics/prevBusDayAnns.do
% and arranges the table data into a cell array for export to the 
% local database 'daedalusdb', table 'asxannouncements'
% exdata is the 4xN export cell array to the following table fields:
%  MATLABts- Matlab time serial of announcement (double)
%  ASX_code- ASX company code of announcement (char)
%  headline- announcement headline (char)
%  is_price_sensitive- whether announcement is labelled price sensitive (logical)
% Note that table field ASX_ID isnt defined or exported to database in this function, 
% see 'update_asxannASX_IDfield.m'
% must be executed once per weekday
% requires function 'get_PDasxann.m' in same directory
% requires function 'htmltab2cell.m' in same directory
function update_asxannouncements(conn, aday)

% fetch announcement time serials from database to check against web table
results = fetch(conn, 'select timestmp_MAT from asxannouncements');
NewestTableRecord = max(cell2mat(results)); %Last database announcement datetime
if aday == 1
    [datacell dtstr] = get_TDasxann;
elseif aday == 2
    % get ASX previous days announcements table in cell array 'datacell' from
    % function get_PDasxann.m
    [datacell dtstr] = get_PDasxann;
else
    beep
    disp('Error: aday must be 1 or 2')
    return
end

NewestWebRecord = datenum([dtstr ' ' cell2mat(datacell(1,2))]); %Last website announcement datetime
% check if this data has already been recorded
if NewestTableRecord >= NewestWebRecord
    disp(['You already have announcements for this date. The latest record is at ' datestr(NewestTableRecord)])

elseif NewestTableRecord < NewestWebRecord
    
% get table dimensions
[R C] = size(datacell);

% if day of month is single digit, add 0 in front
if length(dtstr)<12
    dtstr = ['0',dtstr];
end
ds = dtstr(1:2); %day
ms = dtstr(4:6); %month
ys = dtstr(length(dtstr)-3:length(dtstr)); %year
dstr = [ds '-' ms '-' ys]; % dd-Mon-yyyy
tstamp_c = cell(R,1);
datetimestr = cell(R,1);
for i=1:R %datacell(:,2) contains 12-hour time string
    % parse date and time into one string and convert to Matlab time serial
    u = datenum([dstr ' ' cell2mat(datacell(i,2))]);
    tstamp_c{i,1} = u;
    datetimestr{i,1} = datestr(u,'yyyy-mm-dd HH:MM:SS');
end

% Arrange data into cell array for export to database
exdata(:,1) = datetimestr;
exdata(:,2) = tstamp_c; %Matlab time serial
exdata(:,3) = datacell(:,1); %ASX code
exdata(:,4) = datacell(:,4); %Headline
exdata(:,5) = datacell(:,3); %Price sensitive?

% define column names for export location
colnames = {'datetime_SQL' ; 'timestmp_MAT' ; 'ASX_code'; 'headline'; 'is_price_sensitive'};
% define table name for export location
tabname = 'asxannouncements';
% write to database
fprintf('Writing %6.0f new announcements to database...',R);
fastinsert(conn, tabname, colnames, exdata)


end