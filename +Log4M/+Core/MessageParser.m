classdef MessageParser < handle
    properties(Access=private)
        outputLines;
        outputErrorLineLinks;

        fileLinkFormat double = Log4M.FileLinkFormat.FILENAME;
        numericFormatSpec char = '%.5f';
        datetimeFormatSpec char = 'yyyy-MM-dd HH:mm:ss.SSS';
        durationFormatSpec char = 'dd:hh:mm:ss.SSS';
    end

    methods(Access=public)
        function [outputLines,outputErrorLineLinks]=parseMessage(obj,varargin)
            % PARSEMESSAGE Reduces varargin to two cell arrays containing only chars
            % INPUT
            %   varargin: anything
            % OUTPUT
            %   outputLines: Cell array- with N output chars (-> lines)
            %   outputErrorLineLink: If an error is passed in varargin, this
            %                        variable holds links to the error's stack
            %                        trace. Same size as output lines,
            %                        empty chars if no error was passed.
            
            % Reset internal data. These properties are used to build the
            % output.
            obj.outputLines={''};
            obj.outputErrorLineLinks={''};

            % Idea is to convert all non-trivial datatypes to cell arrays
            % initially.
            [varargin,obj.outputErrorLineLinks]=obj.convertErrorsToCell(varargin);
            varargin=obj.convertTablesToCell(varargin);
            varargin=obj.convertUnsupportedObjectsToCell(varargin);

            % Parse the output. If more than one line is required, output is
            % only parsed if all inputs require the same number of output
            % lines. The output size is increased accordingly.
            for i=1:size(varargin,2)
                requiredLineCount=size(varargin{1,i},1);
                obj.increaseOutputLineCountTo(requiredLineCount);
                obj.parseInputArgument(varargin{1,i});
            end
            % Copy internal data to output.
            outputLines=obj.outputLines;
            outputErrorLineLinks=obj.outputErrorLineLinks;
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
                obj Log4M.Core.MessageParser;
                % same as in num2str
                formatSpec char;
            end
            obj.numericFormatSpec=formatSpec;
        end

        % Sets the format of datetime output. See help of char(...) for details.
        function setDatetimeFormat(obj,formatSpec)
            % does not affect log time stamps for performance reasons
            arguments
                obj Log4M.Core.MessageParser;
                % same as in char()
                formatSpec char;
            end
            obj.datetimeFormatSpec=formatSpec;
        end

        % Sets the format for duration output. See help of char(...) for
        % details.
        function setDurationFormat(obj,formatSpec)
            arguments
                obj Log4M.Core.MessageParser;
                % same as in char()
                formatSpec char;
            end
            obj.durationFormatSpec=formatSpec;
        end
    end

    methods(Access=private)
        function multiline=outputIsMultiline(obj)
            multiline=size(obj.outputLines,1)>1;
        end

        function increaseOutputLineCountTo(obj,newLineCount)
            currentLineCount=size(obj.outputLines,1);
            if obj.outputIsMultiline() && currentLineCount ~= newLineCount && newLineCount>1
                error('Log4M:MessageParser:InvalidInput','Logger supports multiline extensions only once. Use log items with identical row count.');
            end

            if currentLineCount < newLineCount
                for j=(currentLineCount+1):newLineCount
                    obj.outputLines{j,1}=obj.outputLines{1,1};
                    % if no error was detected, fill error line links
                    % empty
                    if j>size(obj.outputErrorLineLinks,1)
                        obj.outputErrorLineLinks{j,1}='';
                    end
                end
            end
        end

        function parseInputArgument(obj,arg)
            if ischar(arg)
                obj.castAtomicArray(arg,@(x)(x),', ');
            elseif isenum(arg)
                obj.castAtomicArray(arg,@char,', ');
            elseif isnumeric(arg)
                obj.castAtomicArray(arg,@(x)(num2str(x,obj.numericFormatSpec)),', ');
            elseif isstring(arg)
                obj.castAtomicArray(arg,@char,' ');
            elseif iscategorical(arg)
                obj.castAtomicArray(arg,@char,', ');
            elseif islogical(arg)
                mask=["FALSE","TRUE"];
                obj.castAtomicArray(arrayfun(@(x)(mask(x+1)),arg),@char,', ');
            elseif isa(arg,'function_handle')
                obj.append(['@',char(arg)],"toLine",1);
            elseif isdatetime(arg)
                obj.castAtomicArray(arg,@(x)(char(x,obj.datetimeFormatSpec)),', ');
            elseif isduration(arg)
                obj.castAtomicArray(arg,@(x)(char(x,obj.durationFormatSpec)),', ');
            elseif iscell(arg(1,1))
                subMp=obj.setupRecursiveSubparser();
                obj.castCellArray(subMp,arg);
            else
                error('Unknown data type.');
            end
        end

        function supported=isSupportedDatatype(~,var)
            supported=ischar(var) || ...
                isnumeric(var) ||...
                isstring(var) || ...
                isempty(var) || ...
                iscategorical(var) || ...
                isdatetime(var) || ...
                isduration(var) || ...
                islogical(var) || ...
                isa(var,'function_handle') || ...
                iscell(var) || ...
                istable(var) || ...
                istimetable(var) || ...
                isa(var,'MException');
        end

        function argout=convertUnsupportedObjectsToCell(obj,argin)
            argout=argin;
            for i=1:size(argin,2)
                if obj.isSupportedDatatype(argin{1,i})
                    continue;
                end
                strCellArray = cellfun(@strtrim,...
                    strsplit(matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(argin{i}),'\n'),...
                    'UniformOutput',false')';

                subMp=obj.setupRecursiveSubparser();
                [subOutputLines,~]=subMp.parseMessage(strCellArray);
                argout{1,i}=subOutputLines;
            end
        end

        function atomic=isAtomic(~,var)
            atomic=all(size(var)==[1,1]);
        end

        function argout=convertTablesToCell(~,argin)
            argout=argin;
            for i=1:size(argin,2)
                if istimetable(argin{i})
                    tableCell=table2cell(timetable2table(argin{i}));
                    varNames=horzcat({'Time'},argin{i}.Properties.VariableNames);
                    argout{i}=vertcat(varNames,tableCell);
                elseif istable(argin{i})
                    tableCell=table2cell(argin{i});
                    varNames=argin{i}.Properties.VariableNames;
                    argout{i}=vertcat(varNames,tableCell);
                end
            end
        end

        function [argout,errorLineLinks]=convertErrorsToCell(obj,argin)
            argout=argin;
            errorLineLinks={''};
            for i=1:size(argin,2)
                if isa(argin{i},'MException')
                    if i~=size(argin,2)
                        % Prevents multiple errors to be inserted in one
                        % message. Makes output formatting simpler.
                        error('Log4M:MessageParser:InvalidInput','MessageParser supports errors only as a final argument.');
                    end
                    est=Log4M.Core.ExternalStackTrace().init(argin{i}.stack);
                    converted=cell(est.getDepth()+1,1);
                    errorLineLinks=cell(est.getDepth()+1,1);

                    converted{1,1}=['ERROR: ',class(argin{i}),'(',argin{i}.identifier,'): ',argin{i}.message];
                    errorLineLinks{1,1}='';
                    for j=1:est.getDepth()
                        converted{j+1,1}=['ERROR STACK ',num2str(j),':',est.getSourceFilename(j),' (Line ',est.getSourceLine(j),')'];
                        errorLineLinks{j+1,1}=est.getStackTraceFileLink(j,obj.fileLinkFormat);
                    end
                    argout{i}=converted;
                end
            end
        end

        function castCellArray(obj,subMp,cellArray)
            for i=1:size(cellArray,1)
                for j=1:size(cellArray,2)
                    [subOutputLines,subErrorLines]=subMp.parseMessage(cellArray{i,j});
                    if size(subOutputLines,1)>1 || size(subErrorLines,1)>1
                        % would require inserting lines with leading spaces
                        error('Log4M:MessageParser:InvalidInput','MessageParser does not support multiline cell contents.');
                    end
                    obj.append(subOutputLines{1,1},"toLine",i);
                    if j<size(cellArray,2)
                        obj.append(', ','toLine',i);
                    end
                end
            end
        end

        function castAtomicArray(obj,array,castFun,delimeter)
            arguments
                obj;
                array;
                castFun function_handle;
                delimeter char;
            end
            if isempty(array)
                return;
            end
            for i=1:size(obj.outputLines,1)
                isMultilineArray=size(obj.outputLines,1) == size(array,1);
                if isMultilineArray
                    newLine=obj.castAtomicRowToLine(array(i,:),castFun,delimeter);
                elseif size(array,1)==1
                    newLine=obj.castAtomicRowToLine(array(1,:),castFun,delimeter);
                else
                    error('Logger does not support multiline logging with more than one line count.')
                end
                obj.append(newLine,"toLine",i);
            end
        end

        function line=castAtomicRowToLine(~,arrayRow,castFun,delimeter)
            if ischar(arrayRow)
                line=arrayRow;
                return;
            end
            line='';
            for i=1:size(arrayRow,2)
                line=[line,castFun(arrayRow(1,i))];
                if i<size(arrayRow,2)
                    line=[line,delimeter];
                end
            end
        end

        function obj=append(obj,chars,target)
            arguments
                obj;
                chars char;
                target.toLine double;
            end
            for i=1:size(chars,1)
                obj.outputLines{target.toLine+i-1,1}=[obj.outputLines{target.toLine+i-1,1},chars(i,:)];
            end
        end

        function subMp=setupRecursiveSubparser(obj)
            subMp=Log4M.Core.MessageParser();
            subMp.setNumericFormat(obj.numericFormatSpec);
            subMp.setDatetimeFormat(obj.datetimeFormatSpec);
            subMp.setDurationFormat(obj.durationFormatSpec);
        end
    end
end

