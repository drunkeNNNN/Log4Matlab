classdef Table < Log4Matlab.Appenders.Appender
    properties(Access=private)
        data (:,6) cell;
    end

    methods(Access=public)
        function resetData(obj)
            obj.data=cell(0,6);
        end

        function tab=getTable(obj)
            if isempty(obj.data)
                obj.resetData();
            end
            tab=cell2table(obj.data, 'VariableNames', {'Date','LevelStr', 'SourceFilename','SourceLink','Message', 'ErrorLineLink'});
        end

        function appendToLog(obj,levelStr,sourceFilename,sourceLink,message,errorLineLink)
            if isempty(obj.data)
                obj.resetData()
            end
            obj.data(end+1,:)={datetime('now'),levelStr,sourceFilename,sourceLink,message,errorLineLink};
        end
    end
end

