%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                GET INTRA-DAY DATA FOR ASX COMPANY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Store time, high, low, open close intra-day data in matrix and update to
% database
function update_asxintradayprices(conn)

% get corresponding ASX ID from asxcompanycodes table
query = ['SELECT ASX_code FROM `asxcompanycodes` WHERE 1'];
[asxcodes_cell,c] = queryDatabase(conn,query);

[Ncodes c] = size(asxcodes_cell);

%
h = waitbar(0,'Updating ASX intra-day data');
for i=1054:Ncodes
    tic
    fprintf('\nupdating %5.0f of %5.0f\n',i,Ncodes)
    
    % get intra-day data for specified asxcode
    asxcode = cell2mat(asxcodes_cell(i,1));
    intraday_mat = get_IntraDayQuotes(asxcode,1);
    disp('intra-day quotes retreived from web')
    
    % if URL read didnt get any data
    if isempty(intraday_mat)
        disp('quotes table empty')
        
    else
        % datetime string in SQL format
        % create cell array of datetime strings in SQL format
        [Nrow Ncol] = size(intraday_mat);
        
        % create new intraday data matrix, excluding intermitent 0 volume intervals
        % store first quote of the day
        n=1;
        intraday_new=zeros(1,6);
        intraday_new(n,:) = intraday_mat(1,:);
        for j=2:Nrow-1
            % if volume>0, store row in new matrix
            if intraday_mat(j,6)>0
                n=n+1;
                intraday_new(n,:) = intraday_mat(j,:);
            else
                % if volume=0, but volume(row+1)>0 or volume(row-1)>0store row in new matrix
                if intraday_mat(j-1,6)>0 || intraday_mat(j+1,6)>0
                    n=n+1;
                    intraday_new(n,:) = intraday_mat(j,:);
                end
            end
        end
        % store final quote of the day
        n=n+1;
        intraday_new(n,:) = intraday_mat(Nrow,:);
        N = n;
        
        % Get ASX_ID from database, asxcompanycodes table
        query = ['SELECT ASX_ID FROM `asxcompanycodes` WHERE ASX_code=''' asxcode ''''];
        [asxid,c] = queryDatabase(conn,query);
        asxid_cell = cell(N,1);
        dtstr_cell = cell(N,1);
        for j=1:N
            % ASX_ID column
            asxid_cell(j,1) = asxid;
            % datetime_SQL column
            dtstr_cell(j,1) = {datestr(intraday_new(j,1), 'yyyy-mm-dd HH:MM:SS')};
        end
        disp('ASX_ID and datetime_SQL columns generated')
        
        % Sort data into export cell matrix
        % convert intraday data matrix to cell for export to database
        intraday_cell = num2cell(intraday_new);
        
        exdata = {};
        % Arrange data into cell array for export to database
        exdata(:,1) = dtstr_cell; % datetime string SQL format 'datetime_SQL'
        exdata(:,2) = intraday_cell(:,1); % time serial Matlab format 'timestmp_MAT'
        exdata(:,3) = asxid_cell; % ASX company code database ID 'ASX_ID'
        exdata(:,4:8) = intraday_cell(:,2:6); % open high low close volume
        fprintf('%4.0 new rows of export data ready',N)
        
        % Check to ensure these records dont alreday exist in table
        query = ['SELECT ID FROM `asxintradayprices` WHERE ASX_ID=' num2str(cell2mat(asxid)) ' AND datetime_SQL =''' cell2mat(dtstr_cell(1,1)) ''''];
        [existing_record,c] = queryDatabase(conn,query);
        % if first row already exists in asxintradayprices table
        if ~isempty(existing_record)
            disp('This data already exists in database')
            
        else
            % Export to database
            % define column names for export location
            colnames = {'datetime_SQL' ; 'timestmp_MAT' ; 'ASX_ID'; 'open'; 'high' ; 'low' ; 'close' ; 'volume'};
            % define table name for export location
            tabname = 'asxintradayprices';
            % write to database
            disp('Writing to database...')
            fastinsert(conn, tabname, colnames, exdata)
            disp('Done')
        end
    end
    
    t(i) = toc;
    tTot = sum(t);
    tRem = tTot*(Ncodes-i)/i;
    fprintf('%2.1f%% complete\n%3.1f minutes remaining\n',100*i/Ncodes,tRem/60)
    waitbar(i/Ncodes)
end
    close(h)