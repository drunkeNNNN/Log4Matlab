classdef Table < Appenders.Appender
    properties(Access=private)
        table table;
    end

    methods(Access=public)
        function initTable(obj)
            obj.table  = cell2table(cell(0,5), 'VariableNames', {'LevelStr', 'SourceFilename','SourceLink','Message', 'ErrorLineLink'});
        end

        function tab=getTable(obj)
            tab=obj.table;
        end

        function appendToLog(obj,levelStr,sourceFilename,sourceLink,message,errorLineLink)
            if isempty(obj.table)
                obj.initTable()
            end
            obj.table=[obj.table;{levelStr,sourceFilename,sourceLink,message,errorLineLink}];
        end
    end
end

