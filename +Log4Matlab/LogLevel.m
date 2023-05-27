% When the message log level is lower or equal than the appender's
% logLevel, the appender prints the message (Can be modified by
% filters, see FilterAction)
classdef LogLevel
    properties (Constant,Access=public)
        OFF = 0;
        FATAL = 1;
        ERROR = 2;
        WARN = 3;
        INFO = 4;
        DEBUG = 5;
        TRACE = 6;
        ALL = 7;
    end
end

