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
            %             varargin=obj.convertTablesToCell(varargin{:});
            %             atomicSizes=cellfun(@obj.isSingleLineOutput,varargin,'UniformOutput',false);
            %             isAtomic=cellfun(@obj.isAtomic,varargin,'UniformOutput',true);
            %
            %
            obj.outputLines={''};
            [varargin,obj.outputErrorLineLinks]=obj.convertErrorToCell(varargin{:});
            varargin=obj.convertTablesToCell(varargin{:});
            varargin=obj.convertUnsupportedObjectToCell(varargin{:});


            wasExtended=false;
            for i=1:size(varargin,2)
                currentLineCount=size(obj.outputLines,1);
                targetLineCount=size(varargin{1,i},1);
                if wasExtended && currentLineCount ~= targetLineCount && targetLineCount>1
                    error('Log4M:MessageParser:InvalidInput','Logger supports multiline extensions only once. Use log items with identical row count.');
                end

                if currentLineCount < targetLineCount
                    for j=(currentLineCount+1):targetLineCount
                        obj.outputLines{j,1}=obj.outputLines{1,1};
                        % if no error was detected, fill error line links
                        % empty
                        if j>size(obj.outputErrorLineLinks,1)
                            obj.outputErrorLineLinks{j,1}='';
                        end
                        wasExtended=true;
                    end
                end

                if ischar(varargin{1,i})
                    obj.castAtomicArray(varargin{1,i},@(x)(x),', ');
                elseif isnumeric(varargin{1,i})
                    obj.castAtomicArray(varargin{1,i},@(x)(num2str(x,obj.numericFormatSpec)),', ');
                elseif isstring(varargin{1,i})
                    obj.castAtomicArray(varargin{1,i},@char,' ');
                elseif iscategorical(varargin{1,i})
                    obj.castAtomicArray(varargin{1,i},@char,', ');
                elseif islogical(varargin{1,i})
                    mask=["FALSE","TRUE"];
                    obj.castAtomicArray(arrayfun(@(x)(mask(x+1)),varargin{1,i}),@char,', ');
                elseif isa(varargin{1,i},'function_handle')
                    obj.append(['@',char(varargin{1,i})],"toLine",1);
                elseif isdatetime(varargin{1,i})
                    obj.castAtomicArray(varargin{1,i},@(x)(char(x,obj.datetimeFormatSpec)),', ');
                elseif isduration(varargin{1,i})
                    obj.castAtomicArray(varargin{1,i},@(x)(char(x,obj.durationFormatSpec)),', ');
                elseif iscell(varargin(1,i))
                    subMp=obj.setupSubparser();
                    obj.castCellArray(subMp,varargin{1,i});
                else
                    error('Unknown data type.');
                end
            end
            outputLines=obj.outputLines;
            outputErrorLineLinks=obj.outputErrorLineLinks;

            %
            %             for i=1:size(varargin,1)
            %                 if ischar(varargin{i})
            %                     obj.outputLines{1,1}=[obj.outputLines{1,1},char(varargin{i})];
            %                 elseif isstring(varargin{i}) || iscategorical(varargin{i})
            %                     if size(varargin{i},1)==1
            %                         % Print skalars and row vectors in same line
            %                         obj.outputLines{1,1}=[obj.outputLines{1,1},char(varargin{i})];
            %                     else
            %                         % Matrix in multiline
            %                         for j=1:size(varargin{i},1)
            %                             obj.outputLines{end+1,1}=[obj.outputLines{1,1},char(varargin{i}(j,:))];
            %                             errorLineLinks{end+1,1}='';
            %                         end
            %                     end
            %
            %                 end
            %             end

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

        function supported=isSupportedDatatype(~,var)
            supported=  ischar(var) || ...
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

        function atomic=isAtomic(~,var)
            atomic=all(size(var)==[1,1]);
        end


    end

    methods(Access=private)
        function argout=convertTablesToCell(~,varargin)
            argout=varargin;
            for i=1:size(varargin,2)
                if istimetable(varargin{i})
                    tableCell=table2cell(timetable2table(varargin{i}));
                    varNames=horzcat({'Time'},varargin{i}.Properties.VariableNames);
                    argout{i}=vertcat(varNames,tableCell);
                elseif istable(varargin{i})
                    tableCell=table2cell(varargin{i});
                    varNames=varargin{i}.Properties.VariableNames;
                    argout{i}=vertcat(varNames,tableCell);
                end
            end
        end

        function [argout,errorLineLinks]=convertErrorToCell(obj,varargin)
            argout=varargin;
            errorLineLinks={''};
            for i=1:size(varargin,2)
                if isa(varargin{i},'MException')
                    if i~=size(varargin,2)
                        % Prevents multiple errors to be inserted in one
                        % message. Makes output formatting simpler.
                        error('Log4M:MessageParser:InvalidInput','MessageParser supports errors only as a final argument.');
                    end
                    est=Log4M.Core.ExternalStackTrace().init(varargin{i}.stack);
                    converted=cell(est.getDepth()+1,1);
                    errorLineLinks=cell(est.getDepth()+1,1);

                    converted{1,1}=['ERROR: ',class(varargin{i}),'(',varargin{i}.identifier,'): ',varargin{i}.message];
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

        function argout=convertUnsupportedObjectToCell(obj,varargin)
            argout=varargin;
            for i=1:size(varargin,2)
                if obj.isSupportedDatatype(varargin{1,i})
                    continue;
                end
                strCellArray = cellfun(@strtrim,...
                    strsplit(matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(varargin{i}),'\n'),...
                    'UniformOutput',false')';

                subMp=obj.setupSubparser();
                [subOutputLines,~]=subMp.parseMessage(strCellArray);
                argout{1,i}=subOutputLines;
            end
            %             for i=1:size(var,1)
            %                 for j=1:size(cellArray,2)
            %                     [subOutputLines,subErrorLines]=subMp.parseMessage(cellArray{i,j});
            %                     if size(subOutputLines,1)>1 || size(subErrorLines,1)>1
            %                         % would require inserting lines with leading spaces
            %                         error('Log4M:MessageParser:InvalidInput','MessageParser does not support multiline cell contents.');
            %                     end
            %                     obj.append(subOutputLines{1,1},"toLine",i);
            %                     if j<size(cellArray,2)
            %                         obj.append(', ','toLine',i);
            %                     end
            %                 end
            %             end
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
                    newLine=obj.castToLine(array(i,:),castFun,delimeter);
                elseif size(array,1)==1
                    newLine=obj.castToLine(array(1,:),castFun,delimeter);
                else
                    error('Logger does not support multiline logging with more than one line count.')
                end
                obj.append(newLine,"toLine",i);
            end
        end

        function line=castToLine(~,arrayRow,castFun,delimeter)
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

        function subMp=setupSubparser(obj)
            subMp=Log4M.Core.MessageParser();
            subMp.setNumericFormat(obj.numericFormatSpec);
            subMp.setDatetimeFormat(obj.datetimeFormatSpec);
            subMp.setDurationFormat(obj.durationFormatSpec);
        end
    end
end

