% Stores logs in memory. Stored logs are not filtered when log levels and filters are
% adapted at runtime. Use obj.getTable() to filter logs.
classdef Table < Log4Matlab.Appenders.Appender
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

        % Function called by the logger
        function appendToLog(obj,levelStr,sourceFilename,sourceLink,message,errorLineLink)
            if isempty(obj.data)
                obj.resetData()
            end
            obj.data(end+1,:)={datetime('now'),levelStr,sourceFilename,sourceLink,message,errorLineLink};
        end
    end
end

