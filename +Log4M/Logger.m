%% Log4M.Logger Log4J Implementation of matlab logger
% A modular matlab implementation of the log4j framework. Design and
% behavior closely follow the log4j implementation. The logger instances
% follow a global pattern (different loggers can be acquired at any place
% in the code with Log4M.Logger.getInstance(uniqueCharIdentifier).
%
% The output destinations can be configured by adding Appenders to
% instances of Logger class.
%
% Message filters and LogLevel
% Hirarchy
% Logger1
%   logLevel1
%   logFilters1
%   <-Appender_1
%     logLevel_Appender_1
%     logFilters_Appender_1
%   <-Appender_2
%     logLevel_Appender_2
%     logFilters_Appender_2
% ...
%
% Logging priority is as follows (see obj.messageDoesPrint(...)):
% 1. Logger.LogLevel.OFF || all(Appender.logLevel==LogLevel.OFF) -> deny in logger
% 2. Any appender filter yields FilterAction.ACCEPT -> accept in specific appender
% 3. Any appender filter yields FilterAction.DENY -> deny in specific appender
% 4. Any logger filter yields FilterAction.ACCEPT -> accept in logger
% 5. Any logger filter yields FilterAction.DENY -> deny in logger
% 6. Message LogLevel <= Appender.logLevel &&
%    Message LogLevel <= Logger.logLevel -> accept in specific appender
% 7. -> deny
%
% For details, see the example folder
classdef Logger < Log4M.LogMessageFilterComponent
    properties(Access = private)
        appenders cell = cell(0);

        fileLinkFormat double = Log4M.FileLinkFormat.FILENAME;
        numericFormatSpec char = '%.5f';
        datetimeFormatSpec char = 'yyyy-MM-dd HH:mm:ss.SSS';
        durationFormatSpec char = 'dd:hh:mm:ss.SSS';
    end

    methods (Static,Access=public)
        function loggerInstance = getInstance(loggerIdentifier)
            arguments
                loggerIdentifier char='DEFAULT'
            end
            persistent persistentLoggerMap;
            if isnumeric(persistentLoggerMap)
                persistentLoggerMap=containers.Map();
            end
            if ~persistentLoggerMap.isKey(loggerIdentifier) || ~isvalid(persistentLoggerMap(loggerIdentifier))
                persistentLoggerMap(loggerIdentifier) = Log4M.Logger();
                loggerInstance=persistentLoggerMap(loggerIdentifier);
                loggerInstance.clearFilters();
                loggerInstance.clearAppenders();
            else
                loggerInstance = persistentLoggerMap(loggerIdentifier);
            end
        end
    end

    %% Public Methods Section %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods(Access=public)
        % Removes all added appenders
        function clearAppenders(obj)
            obj.appenders=cell(0);
        end

        % Adds an appender to the logger
        function addAppender(obj,appender)
            arguments
                obj Log4M.Logger;
                appender (1,1) Log4M.Appenders.Appender;
            end
            obj.appenders{end+1,1}=appender;
        end

        % Returns all appenders. Can be used e.g. to filter log messages
        % during runtime using the TableAppender
        function appenders=getAppenders(obj)
            appenders=obj.appenders;
        end

        % Sets format of file links. See Log4M.FileLinkFormat
        function setFileLinkFormat(obj,fileLinkFormat)
            arguments
                obj Log4M.Logger;
                fileLinkFormat (1,1) {isnumeric,ismember(fileLinkFormat,[0,1,2,3])};
            end
            obj.fileLinkFormat=fileLinkFormat;
        end

        % Sets the format of numeric output. See help of num2str(...) for details.
        function setNumericFormat(obj,formatSpec)
            arguments
                obj Log4M.Logger
                % same as in num2str
                formatSpec char; 
            end
            obj.numericFormatSpec=formatSpec;
        end

        % Sets the format of datetime output. See help of char(...) for details.
        function setDatetimeFormat(obj,formatSpec)
            % does not affect log time stamps for performance reasons
            arguments
                obj Log4M.Logger;
                % same as in char()
                formatSpec char;
            end
            obj.datetimeFormatSpec=formatSpec;
        end

        % Sets the format for duration output. See help of char(...) for
        % details.
        function setDurationFormat(obj,formatSpec)
            arguments
                obj Log4M.Logger;
                % same as in char()
                formatSpec char;
            end
            obj.durationFormatSpec=formatSpec;
        end

        %% Logging interface %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Use these methods for logging.
        function all(obj, varargin)
            obj.writeLog(Log4M.LogLevel.ALL,varargin{:});
        end
        
        function trace(obj, varargin)
            obj.writeLog(Log4M.LogLevel.TRACE,varargin{:});
        end

        function debug(obj, varargin)
            obj.writeLog(Log4M.LogLevel.DEBUG,varargin{:});
        end

        function info(obj, varargin)
            obj.writeLog(Log4M.LogLevel.INFO,varargin{:});
        end

        function warn(obj, varargin)
            obj.writeLog(Log4M.LogLevel.WARN,varargin{:});
        end

        function error(obj, varargin)
            obj.writeLog(Log4M.LogLevel.ERROR,varargin{:});
        end

        function fatal(obj,  varargin)
            obj.writeLog(Log4M.LogLevel.FATAL,varargin{:});
            try
                error('Program terminated. See logs.');
            catch e
                obj.writeLog(Log4M.LogLevel.FATAL,e)
                rethrow(e);
            end
        end
    end

    methods (Access = private)
        function writeLog(obj,messageLogLevel,varargin)
            if obj.getLogLevel==Log4M.LogLevel.OFF || ...
               all(cellfun(@(appender)(appender.getLogLevel()==Log4M.LogLevel.OFF),obj.appenders,'UniformOutput',true),"all") 
                return;
            end
            
            messageLogLevelString=Log4M.LogLevel.levelToString(messageLogLevel);
              
            est=Log4M.Core.ExternalStackTrace().init();
            depth=1;
            sourceLink=est.getSourceLink(depth,obj.fileLinkFormat);
            sourceFilename=[est.getFullSourcePath(depth),' (Line ',est.getSourceLine(depth),')'];
            [messageLines,errorLinks]=parseVararginToMessages(obj,varargin{:});
            for i=1:size(messageLines,1)
                % consistent with filter strategy in appender
                filterString=[messageLogLevelString,' ',sourceFilename,' ',messageLines{i,1},' ',errorLinks{i,1}];
                [isLoggerFilterAccepted,isLoggerFilterDenied]=obj.getFilterResult(filterString);
                for k=1:size(obj.appenders,1)
                    [isAppenderFilterAccepted,isAppenderFilterDenied]=obj.appenders{k,1}.getFilterResult(filterString);
                    if obj.messageDoesPrint(messageLogLevel,obj.appenders{k,1}.getLogLevel(),isAppenderFilterAccepted,isAppenderFilterDenied,isLoggerFilterAccepted,isLoggerFilterDenied,messageLines{i,1})
                        obj.appenders{k,1}.appendToLog(messageLogLevelString,sourceFilename,sourceLink,messageLines{i,1},errorLinks{i,1});
                    end
                end
            end
        end

        function doPrint=messageDoesPrint(obj,messageLogLevel,appenderLogLevel,isAppenderFilterAccepted,isAppenderFilterDenied,isLoggerFilterAccepted,isLoggerFilterDenied,message)
            if appenderLogLevel==Log4M.LogLevel.OFF || isempty(message)
                doPrint=false;
            elseif isAppenderFilterAccepted
                doPrint=true;
            elseif isAppenderFilterDenied
                doPrint=false;
            elseif isLoggerFilterAccepted
                doPrint=true;
            elseif isLoggerFilterDenied
                doPrint=false;
            elseif messageLogLevel<=obj.getLogLevel() && messageLogLevel<=appenderLogLevel
                doPrint=true;
            else
                doPrint=false;
            end
        end
    end
end
