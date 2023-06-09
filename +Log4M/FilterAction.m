% Global definition of the actions taken when a message filter matches
classdef FilterAction < double
    enumeration
        % If the appender's logLevel is not LogLevel.OFF, always print on match/mismatch 
        ACCEPT (1);
        % Always print on match/mismatch depending on the appender's logLevel
        NEUTRAL (0);
        % Never print on match/mismatch, independent of the appender's
        % logLevel
        DENY (-1);
    end
end

