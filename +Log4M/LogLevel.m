% When the message log level is lower or equal than the appender's
% logLevel, the appender prints the message (Can be modified by
% filters, see FilterAction)
classdef LogLevel < double
    enumeration
        OFF (0);
        FATAL (1);
        CRITICAL (2)
        ERROR (3);
        WARN (4);
        INFO (5);
        DEBUG (6);
        DETAIL (7)
        TRACE (8);
        ALL (9);
    end

    methods(Static,Access=public)
        function levelStr=levelToString(level)
            arguments
                level (1,1) Log4M.LogLevel;
            end
            switch level
                case{Log4M.LogLevel.ALL}
                    levelStr = 'ALL';
                case{Log4M.LogLevel.TRACE}
                    levelStr = 'TRACE';
                case{Log4M.LogLevel.DETAIL}
                    levelStr = 'DETAIL';
                case{Log4M.LogLevel.DEBUG}
                    levelStr = 'DEBUG';
                case{Log4M.LogLevel.INFO}
                    levelStr = 'INFO';
                case{Log4M.LogLevel.WARN}
                    levelStr = 'WARN';
                case{Log4M.LogLevel.ERROR}
                    levelStr = 'ERROR';
                case{Log4M.LogLevel.CRITICAL}
                    levelStr = 'CRITICAL';
                case{Log4M.LogLevel.FATAL}
                    levelStr = 'FATAL';
                case{Log4M.LogLevel.OFF}
                    levelStr = 'OFF';
                otherwise
                    error(['Unknown error level: ',num2str(level)]);
            end
        end
    end
end

