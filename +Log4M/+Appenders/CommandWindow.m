%% CommandWindow Appender
% Supports printing links to the origin of the message. When deployed, no
% links are printed.
classdef CommandWindow < Log4M.Appenders.Appender
    methods(Access=public)
        % Function called by the logger
        function appendToLog(obj,logLevel,sourceFilename,sourceLink,message,errorLineLink)
            if ~isempty(errorLineLink) && contains(message,'ERROR STACK')
                if isdeployed()
                else
                    message=['ERROR STACK: ',errorLineLink];
                end
            end
            if obj.verboseModeEnabled
                if isdeployed()
                    disp([datestr(now,'yyyy-mm-dd HH:MM:SS.FFF'), ' ', char(logLevel),' ',sourceFilename, ' ',message]);
                else
                    disp([datestr(now,'yyyy-mm-dd HH:MM:SS.FFF'), ' ', char(logLevel),' ',sourceLink, ' ',message]);
                end
            else
                disp([logLevel,' ',message]);
            end
        end
    end
end