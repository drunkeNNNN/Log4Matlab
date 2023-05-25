classdef Log4Matlab < handle
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

    properties(Access = private)
        filters cell = cell(0);
        acceptFilterArray=Log4Matlab.disabledFilter();
        denyFilterArray=Log4Matlab.disabledFilter();

        appenders cell = cell(0);
    end

    methods (Static,Access=public)
        function obj = getInstance(loggerIdentifier)
            arguments
                loggerIdentifier char='DEFAULT'
            end
            persistent persistentLoggerMap;
            if isnumeric(persistentLoggerMap)
                persistentLoggerMap=containers.Map();
            end
            if ~persistentLoggerMap.isKey(loggerIdentifier) || ~isvalid(persistentLoggerMap(loggerIdentifier))
                persistentLoggerMap(loggerIdentifier) = Log4Matlab();
            end
            obj = persistentLoggerMap(loggerIdentifier);
        end

        function levelStr=levelToString(level)
            arguments
                level (1,1) {isnumeric}
            end
            switch level
                case{Log4Matlab.ALL}
                    levelStr = 'ALL';
                case{Log4Matlab.TRACE}
                    levelStr = 'TRACE';
                case{Log4Matlab.DEBUG}
                    levelStr = 'DEBUG';
                case{Log4Matlab.INFO}
                    levelStr = 'INFO';
                case{Log4Matlab.WARN}
                    levelStr = 'WARN';
                case{Log4Matlab.ERROR}
                    levelStr = 'ERROR';
                case{Log4Matlab.FATAL}
                    levelStr = 'FATAL';
                case{Log4Matlab.OFF}
                    levelStr = 'OFF';
                otherwise
                    error(['Unknown error level: ',num2str(level)]);
            end
        end
    end

    methods(Static,Access=private)
        function filter=disabledFilter()
            filter=cell(0);
        end
    end

    %% Public Methods Section %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods(Access=public)
        function clearFilters(obj)
            obj.filters=cell(0);
        end

        function addFilter(obj,filter)
            arguments
                obj Log4Matlab;
                filter Filters.Filter;
            end
            obj.filters{end+1,1}=filter;
        end

        function clearAppenders(obj)
            obj.appenders=cell(0);
        end

        function addAppender(obj,appender)
            arguments
                obj Log4Matlab;
                appender (1,1) Appenders.Appender;
            end
            obj.appenders{end+1,1}=appender;
        end

        function setAcceptFilter(obj,filter)
            if isempty(filter)
                filter=Log4Matlab.disabledFilter();
            end
            if ischar(filter) || isstring(filter) || isdatetime(filter)
                filter={char(filter)};
            end
            obj.acceptFilterArray=filter;
        end

        function setDenyFilter(obj,filter)
            if isempty(filter)
                filter=Log4Matlab.disabledFilter();
            end
            if ischar(filter) || isstring(filter) || isdatetime(filter)
                filter={char(filter)};
            end
            obj.denyFilterArray=filter;
        end

        %% Logging interface %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function trace(obj, varargin)
            obj.writeLog(obj.TRACE,varargin{:});
        end

        function debug(obj, varargin)
            obj.writeLog(obj.DEBUG,varargin{:});
        end

        function info(obj, varargin)
            obj.writeLog(obj.INFO,varargin{:});
        end

        function warn(obj, varargin)
            obj.writeLog(obj.WARN,varargin{:});
        end

        function error(obj, varargin)
            obj.writeLog(obj.ERROR,varargin{:});
        end

        function fatal(obj,  varargin)
            obj.writeLog(obj.FATAL,varargin{:});
            error('Program terminated. See logs.');
        end
    end

    methods (Access = private)
        % Singleton pattern
        function obj = Log4Matlab()
        end

        function writeLog(obj,messageLogLevel,varargin)
            % Set up our level string
%             if all(cellfun(@(appender)(appender.getLogLevel()<messageLogLevel),obj.appenders,'UniformOutput',true),"all")
%                 return;
%             end
            
            stackTraceInformation=dbstack("-completenames");
            try
                scriptName=[stackTraceInformation(3,1).file,': ', num2str(stackTraceInformation(3,1).line)];
            catch
                scriptName='';
            end
            [messageLines,errorLinks]=parseVararginToMessages(obj,varargin{:});

            for i=1:size(messageLines,1)
                sourceLink=obj.getStackTraceFileLink([],[]);
                levelStr=Log4Matlab.levelToString(messageLogLevel);
                filterResultActions=cellfun(@(filter)(filter.applyFilter([stackTraceInformation(3,1).name,messageLines{i,1}])),obj.filters,'UniformOutput',true);
                isFilterAccepted=obj.isAccepted(filterResultActions);
                isFilterDenied=obj.isDenied(filterResultActions);
                for k=1:size(obj.appenders,1)
                    if obj.messageDoesPrint(messageLogLevel,obj.appenders{k,1}.getLogLevel(),isFilterAccepted,isFilterDenied,messageLines{i,1})
                        obj.appenders{k,1}.appendToLog(levelStr,scriptName,sourceLink,messageLines{i,1},errorLinks{i,1})
                    end
                end
            end
        end

        function [outputLines,errorLineLinks]=parseVararginToMessages(obj,varargin)
            outputLines=cell(1,1);
            errorLineLinks=cell(1,1);
            outputLines{1,1}='';
            errorLineLinks{1,1}='';
            for i=1:numel(varargin)
                if ischar(varargin{i}) || isstring(varargin{i}) || isdatetime(varargin{i}) || iscategorical(varargin{i})
                    outputLines{1,1}=[outputLines{1,1},char(varargin{i})];
                elseif isnumeric(varargin{i})
                    if size(varargin{i},1)> size(varargin{i},2)
                        varargin{i}=varargin{i}';
                    end
                    outputLines{1,1}=[outputLines{1,1},num2str(varargin{i})];
                elseif islogical(varargin{i})
                    if varargin{i}
                        outputLines{1,1}=[outputLines{1,1},'true'];
                    else
                        outputLines{1,1}=[outputLines{1,1},'false'];
                    end
                elseif isa(varargin{i},'MException')
                    outputLines{end+1,1}=['ERROR: ',class(varargin{i}),'(',varargin{i}.identifier,'): ',varargin{i}.message];
                    errorLineLinks{end+1,1}='';
                    for j=1:size(varargin{i}.stack,1)
                        outputLines{end+1,1}=['ERROR STACK ',num2str(j),':',varargin{i}.stack(j).file,' (Line ',num2str(varargin{i}.stack(j).line),')'];
                        errorLineLinks{end+1,1}=obj.getStackTraceFileLink(varargin{i}.stack,j);
                    end
                elseif isa(varargin{i},'cell')
                    for j=1:size(varargin{i},1)
                        cellLine='';
                        for k=1:size(varargin{i},2)
                            parsedCellArrayContent=obj.parseVararginToMessages(varargin{i}{j,k});
                            if k<size(varargin{i},2)
                                cellLine=[cellLine,parsedCellArrayContent{:},', '];
                            else
                                cellLine=[cellLine,parsedCellArrayContent{:}];
                            end
                        end
                        outputLines{end+1,1}=[outputLines{1,1},strtrim(cellLine)];
                        errorLineLinks{end+1,1}='';
                    end
                elseif istable(varargin{i})
                    tableCell=table2cell(varargin{i});
                    [tableLines,tableErrorLineLinks]=obj.parseVararginToMessages(outputLines{1,1},tableCell);
                    outputLines=tableLines;
                    errorLineLinks=cat(1,errorLineLinks(:),tableErrorLineLinks(:));
                else
                    error(['varargin{',num2str(i),'}',' could not be parsed.']);
                end
            end
        end

        function scriptLink=getStackTraceFileLink(obj,stack,depth)
            if isempty(stack)
                stack=dbstack('-completenames');
            end
            if isempty(depth)
                depth=find(cellfun(@(x)(~startsWith(x,class(obj))),{stack.name},'UniformOutput',true),1,'first');
            end
            try
                [~,filename,ext]=fileparts(stack(depth,1).file);
                scriptLink=['<a href="matlab:opentoline(''',stack(depth,1).file ,''',', num2str(stack(depth,1).line),',0)">', filename,ext,':', num2str(stack(depth,1).line),':',stack(depth,1).name,'</a>'];
            catch
                scriptLink='';
            end
            if ispc
                scriptLink=strrep(scriptLink, '\','\\');
            end
        end

        function doPrint=messageDoesPrint(obj,messageLogLevel,appenderLogLevel,isFilterAccepted,isFilterDenied,message)
            % filter only below warn
            if isempty(message)
                doPrint=false;
            elseif isFilterAccepted
                doPrint=true;
            elseif isFilterDenied
                doPrint= false;
            elseif messageLogLevel<=appenderLogLevel
                doPrint= true;
            else
                doPrint=false;
            end
        end

        function deny=isDenied(~, resultActions)
            deny= any(resultActions==Filters.Filter.DENY);

%             if isempty(obj.denyFilterArray)
%                 notDenied=true;
%                 return;
%             end
%             for j=1:length(obj.denyFilterArray)
%                 if isempty(obj.denyFilterArray{j}) || contains(string,obj.denyFilterArray{j})
%                     notDenied=false;
%                     return
%                 end
%             end
%             notDenied=true;
%             return;
        end

        function accepted=isAccepted(~, resultActions)
            accepted= any(resultActions==Filters.Filter.ACCEPT);
%             if isempty(obj.acceptFilterArray)
%                 accepted=true;
%                 return;
%             end
%             for j=1:length(obj.acceptFilterArray)
%                 if isempty(obj.acceptFilterArray{j}) || contains(resultActions,obj.acceptFilterArray{j})
%                     accepted=true;
%                     return;
%                 end
%             end
%             accepted=false;
%             return;
        end
    end
end
