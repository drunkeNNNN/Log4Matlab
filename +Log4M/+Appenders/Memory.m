% Stores logs in memory. Stored logs are not filtered when log levels and filters are
% adapted at runtime. Use obj.getTable() to filter logs.
classdef Memory < Log4M.Appenders.Appender
    properties(Access=private)
        data (:,7) cell;
    end

    methods(Access=public)
        % Clears the data in memory
        function resetData(obj)
            % Use cell array for performance
            obj.data=cell(0,7);
        end

        % Returns the saved data as a table
        function tab=getTable(obj)
            if isempty(obj.data)
                obj.resetData();
            end
            tab=cell2table(obj.data, 'VariableNames', {'Date','LogLevel','LogLevelStr', 'SourceFilename','SourceLink','Message', 'ErrorLineLink'});
        end

         % Returns the saved data as a cell array
        function data=getData(obj)
            if isempty(obj.data)
                obj.resetData();
            end
            data=obj.data;
        end

        % Function called by the logger
        function appendToLog(obj,logLevel,sourceFilename,sourceLink,message,errorLineLink)
            if isempty(obj.data)
                obj.resetData()
            end
            obj.data(end+1,:)={datetime('now'),double(logLevel),string(logLevel),sourceFilename,sourceLink,message,errorLineLink};
        end
    end
end