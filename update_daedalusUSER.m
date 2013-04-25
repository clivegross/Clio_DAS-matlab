% Database Update
% MAIN SCRIPT
% -Update ASX Announcements table
% -Update ASX Company Codes table
%
clear all; clc;
% user input
is_g2g = false;
while ~is_g2g
    val1 = input('ASX Company Announcements\nEnter 1 for todays, 2 for previous days and 3 for both\n>>');
    if ~isequal(val1,1) && ~isequal(val1,2) && ~isequal(val1,3)
        disp('Enter 1, 2 or 3 only')
    else
        is_g2g = true;
    end
end
is_g2g = false;
while ~is_g2g
    val2 = input('Yahoo Finance Intra-Day Prices\nEnter 1 for last day, 2 for last 5 days\n>>');
    if ~isequal(val2,1) && ~isequal(val2,2)
        disp('Enter 1 or 2 only')
    else
        is_g2g = true;
    end
end

% connect to database 'daedalusdb'
javaaddpath 'mysql-connector-java-5.1.21-bin.jar';
conn=database('daedalusdb', 'root', '', 'com.mysql.jdbc.Driver', 'jdbc:mysql://localhost/');

% Update ASX Announcements table 'asxannouncements' with previous day
% announcements from ASX website
disp('Updating asxannouncements table...')
update_asxannouncements(conn, val1)
disp('Done');

% Update ASX Company codes table 'asxcompanycodes' with any unrecorded ASX codes from 'asxannouncements'
disp('Updating asxcompanycodes table...')
update_asxcompanycodes(conn)
disp('Done');

% Update 'asxannouncements' table, 'ASX_ID' field for all newly added records
% this process must be run after updating asxcompanycodes in case new company
% codes have to be added to table and IDs assigned
disp('Updating asxannouncements table with ASX_IDs...')
update_asxannASX_IDfield(conn)
disp('Done')

% Update ASX intra-day prices table 'asxintradayprices' with most recent
% quotes from Yahoo Finance
disp('Updating asxintradayprices table...')
switch val2
    case 1
        update_asxintradayprices(conn)
    case 2
        get_missingintraday(conn)
end
disp('Done')
