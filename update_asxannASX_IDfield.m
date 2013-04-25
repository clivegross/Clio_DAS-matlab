% Update ASX_ID field in asxannouncements table for all records with NULL
% value
function update_asxannASX_IDfield(conn)

% get the ASX codes for records containing a NULL (incomplete) ASX_ID
query = 'SELECT DISTINCT ASX_code FROM `asxannouncements` WHERE ISNULL(ASX_ID)';
[asxcodeNullID_cell,c] = queryDatabase(conn,query);
[Nrows c] = size(asxcodeNullID_cell);

% If there are existing records with ASX_ID=NULL, update
if Nrows > 0
    
    h = waitbar(0,'Updating ASX IDs in asxannouncements tab');
    fprintf('\n%5.0f ASX IDs are being updated',Nrows)
    for i=1:Nrows
        % get ASX code string of incomplete record
        asxcode = cell2mat(asxcodeNullID_cell(i,1));
        % get corresponding ASX ID from asxcompanycodes table
        query = ['SELECT ASX_ID FROM `asxcompanycodes` WHERE ASX_code=''' asxcode ''''];
        [asxid_cell,c] = queryDatabase(conn,query);
        % update ASX ID in asxannouncements table for all records where:
        % ASX_ID = NULL and ASX_code = asxcode
        whereclause = ['WHERE ISNULL(ASX_ID) && ASX_code=''' asxcode ''''];
        update(conn, 'asxannouncements', {'ASX_ID'}, asxid_cell, whereclause)
        % update loop waitbar
        waitbar(i/Nrows)
    end
    close(h)

% If not, report ok
else

    disp('All ASX ID fields are complete')
    
end
