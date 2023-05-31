% Stores logs in memory. Stored logs are not filtered when log levels and filters are
% adapted at runtime. Use obj.getTable() to filter logs.
classdef Memory < Log4M.Appenders.Appender
    properties(Access=private)
        data (:,6) cell;
    end

    methods(Access=public)
        % Clears the data in memory
        function resetData(obj)
            % Use cell array for performance
            obj.data=cell(0,6);
        end

        % Returns the saved data as a table
        function tab=getTable(obj)
            if isempty(obj.data)
                obj.resetData();
            end
            tab=cell2table(obj.data, 'VariableNames', {'Date','LevelStr', 'SourceFilename','SourceLink','Message', 'ErrorLineLink'});
        end

         % Returns the saved data as a cell array
        function data=getData(obj)
            if isempty(obj.data)
                obj.resetData();
            end
            data=obj.data;
        end

        % Function called by the logger
        function appendToLog(obj,levelStr,sourceFilename,sourceLink,message,errorLineLink)
            if isempty(obj.data)
                obj.resetData()
            end
            obj.data(end+1,:)={datetime('now'),levelStr,sourceFilename,sourceLink,message,errorLineLink};
        end

        function showData(obj)
            table=obj.getTable();
            f=uifigure('Name','Log');
            th=uitable(f,'data',table(:,[1,2,4,5,6]),'ColumnSortable',true(1,6),'ColumnWidth','fit','Units','normalized','Position',[0,0,1,1]);
            th.addStyle(uistyle('Interpreter','html'));
            
            addStyle(th,uistyle('BackgroundColor', [.85,.85,.85]),"row",find(th.Data{:,2}=="TRACE"))
            addStyle(th,uistyle('BackgroundColor', [.9,.9,.9]),"row",find(th.Data{:,2}=="FINE"))
            addStyle(th,uistyle('BackgroundColor', [.95,.95,.95]),"row",find(th.Data{:,2}=="DEBUG"))
            addStyle(th,uistyle('BackgroundColor', [1,1,1]),"row",find(th.Data{:,2}=="INFO"))
            addStyle(th,uistyle('BackgroundColor', [1,1,0.8]),"row",find(th.Data{:,2}=="WARN"))
            addStyle(th,uistyle('BackgroundColor', [1,.9,0.8]),"row",find(th.Data{:,2}=="ERROR"))
            addStyle(th,uistyle('BackgroundColor', [1,.8,0.8]),"row",find(th.Data{:,2}=="CRITICAL"))
            addStyle(th,uistyle('BackgroundColor', [1,.6,0.6]),"row",find(th.Data{:,2}=="FATAL"))
        end
    end
end

