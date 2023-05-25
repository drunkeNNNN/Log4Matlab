classdef CommandWindow < Appenders.Appender
    methods(Access=public)
        function appendToLog(obj,levelStr,sourceFilename,sourceLink,message,errorLineLink)
            if ~isempty(errorLineLink) && contains(message,'ERROR STACK')
                if isdeployed()
                else
                    message=['ERROR STACK: ',errorLineLink];
                end
            end
            if obj.verboseModeEnabled
                if isdeployed()
                    disp([char(datetime('now','Format','yyyy-MM-dd HH:mm:ss.SSS')), ' ', levelStr,' ',sourceFilename, ' ',message]);
                else
                    disp([char(datetime('now','Format','yyyy-MM-dd HH:mm:ss.SSS')), ' ', levelStr,' ',sourceLink, ' ',message]);
                end
            else
                disp([levelStr,' ',message]);
            end
        end
    end
end