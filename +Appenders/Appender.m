classdef Appender <handle
    properties(Access=protected)
        verboseModeEnabled (1,1) logical = true;
        logLevel (1,1) double = Log4Matlab.WARN;
    end

    methods(Abstract,Access=public)
        appendToLog(obj,level,levelStr,scriptName,message,errorLineLink);
    end
    
    methods(Access=public)
        function obj=setLogLevel(obj,level)
            obj.logLevel = level;
        end

        function logLevel=getLogLevel(obj)
            logLevel=obj.logLevel;
        end

        function enableVerboseMode(obj)
            obj.verboseModeEnabled=true;
        end

        function disableVerboseMode(obj)
            obj.verboseModeEnabled=false;
        end
    end
end

