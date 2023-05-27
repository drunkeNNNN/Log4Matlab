%% CommandWindow Appender
% Supports printing links to the origin of the message. When deployed, no
% links are printed.
classdef CommandWindow < Log4Matlab.Appenders.Appender
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
                    disp([datestr(now,'yyyy-mm-dd HH:MM:SS.FFF'), ' ', levelStr,' ',sourceFilename, ' ',message]);
                else
                    disp([datestr(now,'yyyy-mm-dd HH:MM:SS.FFF'), ' ', levelStr,' ',sourceLink, ' ',message]);
                end
            else
                disp([levelStr,' ',message]);
            end
        end
    end
end