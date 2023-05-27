classdef Appender < Log4Matlab.LogMessageFilterComponent
    properties(Access=protected)
        verboseModeEnabled (1,1) logical = true;
    end

    methods(Abstract,Access=public)
        appendToLog(obj,messageLogLevelStr,sourceFileName,sourceLink,message,errorLineLink);
    end
    
    methods(Access=public)
        function obj=enableVerboseMode(obj)
            obj.verboseModeEnabled=true;
        end

        function obj=disableVerboseMode(obj)
            obj.verboseModeEnabled=false;
        end
    end
end

