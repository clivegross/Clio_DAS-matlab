% Database Update
% MAIN SCRIPT
% -Update ASX Announcements table
% -Update ASX Company Codes table
% -Update intra day prices
clear all; clc;
%% connect to database 'daedalusdb'
javaaddpath 'mysql-connector-java-5.1.21-bin.jar';
conn=database('daedalusdb', 'root', '', 'com.mysql.jdbc.Driver', 'jdbc:mysql://localhost/');

%% Update ASX Announcements table 'asxannouncements' with previous day
% announcements from ASX website
disp('Updating asxannouncements table...')
update_asxannouncements(conn, 2)
disp('Done');

%% Update ASX Company codes table 'asxcompanycodes' with any unrecorded ASX codes from 'asxannouncements'
disp('Updating asxcompanycodes table...')
update_asxcompanycodes(conn)
disp('Done');

%% Update 'asxannouncements' table, 'ASX_ID' field for all newly added records
% this process must be run after updating asxcompanycodes in case new company
% codes have to be added to table and IDs assigned
disp('Updating asxannouncements table with ASX_IDs...')
update_asxannASX_IDfield(conn)
disp('Done')

%% Update ASX intra-day prices table 'asxintradayprices' with most recent
% quotes from Yahoo Finance
disp('Updating asxintradayprices table...')
% update_asxintradayprices(conn)
get_missingintraday(conn)
disp('Done')
