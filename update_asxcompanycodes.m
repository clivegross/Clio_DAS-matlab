% Update asxcompanycodes table in daedalusdb database with any unrecorded 
% ASX company codes from asxannouncements table
% also check for errors such as doubling up of records
function update_asxcompanycodes(conn)

% Get all ASX codes from asxcompanycodes table
query = 'SELECT ASX_code FROM asxcompanycodes WHERE 1';
[tabledata,colnames] = queryDatabase(conn,query);
% number of ASX codes recorded 
[Ncodes c] = size(tabledata);

% Check asxcompanycodes table doesnt have any doubling up of records
query = 'SELECT DISTINCT ASX_code FROM asxcompanycodes WHERE 1';
[tabledata_distinct,c] = queryDatabase(conn,query);
% number of distinct ASX codes recorded 
[Ncodes_distinct c] = size(tabledata_distinct);
if Ncodes~=Ncodes_distinct
    errordlg('There appears to be doubling up in asxcompanycodes table','ERROR')
end

% get every dinstinct ASX code that has published an announcement from
% asxannouncements table
query = 'SELECT DISTINCT ASX_code FROM asxannouncements WHERE 1';
[asxcodes,c] = queryDatabase(conn,query);
% number of distinct ASX codes from asxannouncements table
[Nanncmnts c] = size(asxcodes);

% Check if asxcompanycodes table needs to be updated
if Ncodes<Nanncmnts 
%if theres extra ASX codes from asxannouncements not stored in asxcompanycodes then update
    asxcodes_unrecorded = setdiff(asxcodes, tabledata);
    % define table name for export location
    tabname = 'asxcompanycodes';
    % write to database
    fprintf('Writing %3.0f new ASX codes to database...', Nanncmnts-Ncodes);
    fastinsert(conn, tabname, colnames, asxcodes_unrecorded)
%if there is the same number of ASX codes in each then relax    
elseif Ncodes==Nanncmnts
    fprintf('ASX Company Codes table is already up to date with %6.0f records\n',Ncodes)
%if there is the more ASX codes in asxcompanycodes than in asxannouncements then fix
else
    disp('Theres more asxcompanycodes records than distinct ASX codes from Announcements!!!')
end


