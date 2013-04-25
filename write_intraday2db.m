function write_intraday2db(conn, intraday_mat, asxid)

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
        
        % Arrange ASX_ID and datetime columns for export to from database
        asxid_cell = cell(N,1);
        dtstr_cell = cell(N,1);
        for j=1:N
            % ASX_ID column
            asxid_cell(j,1) = {asxid};
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
        
        % Export to database
        % define column names for export location
        colnames = {'datetime_SQL' ; 'timestmp_MAT' ; 'ASX_ID'; 'open'; 'high' ; 'low' ; 'close' ; 'volume'};
        % define table name for export location
        tabname = 'asxintradayprices';
        % write to database
        fprintf('Writing %3.0f records to database...', N)
        fastinsert(conn, tabname, colnames, exdata)
        disp('Done')

    end