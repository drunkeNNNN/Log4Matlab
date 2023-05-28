classdef ExternalStackTrace < handle
    properties
        externalStack;
    end
    
    methods(Access=public)
        function obj=init(obj,stack)
            if nargin<2
                stack = dbstack('-completenames');
            end
            externalCallerDepth=obj.getCallerStackDepth(stack);
            if isempty(externalCallerDepth)
                % logger called from command window
                f = fieldnames(stack)';
                f{2,1} = {};
                obj.externalStack=struct(f{:});
            else
                obj.externalStack=stack(externalCallerDepth:end);
            end
        end

        function depth=getDepth(obj)
            depth=size(obj.externalStack,1);
        end

        function sourceLink=getSourceLink(obj,depth,fileLinkFormat)
            if depth>obj.getDepth()
                sourceLink='';
            else
                sourceLink=obj.getStackTraceFileLink(depth,fileLinkFormat);
            end
        end

        function sourceLine=getSourceLine(obj,depth)
            if depth>obj.getDepth()
                sourceLine='';
            else
                sourceLine=num2str(obj.externalStack(depth,1).line);
            end
        end

        function sourcePath=getFullSourcePath(obj,depth)
            if depth>obj.getDepth()
                sourcePath='';
            else
            sourcePath=obj.externalStack(depth,1).file;
            end
        end

        function sourceName=getSourceName(obj,depth)
            if depth>obj.getDepth()
                sourceName='';
            else
                sourceName=obj.externalStack(depth,1).name;
            end
        end

        function sourceFilename=getSourceFilename(obj,depth)
            [~,fname,ext]=fileparts(obj.getFullSourcePath(depth));
            sourceFilename=[fname,ext];
        end

        function scriptLink=getStackTraceFileLink(obj,depth,fileLinkFormat)
            [~,filename,ext]=fileparts(obj.getFullSourcePath(depth));
            switch fileLinkFormat
                case Log4M.FileLinkFormat.OFF
                    scriptLink=[filename,ext,'(',num2str(obj.externalStack(depth,1).line),')'];
                case Log4M.FileLinkFormat.FILENAME
                    scriptLink=['<a href="matlab:opentoline(''',obj.getFullSourcePath(depth) ,''',', obj.getSourceLine(depth),',0)">', obj.getSourceFilename(depth),'(', obj.getSourceLine(depth),')</a>'];
                case Log4M.FileLinkFormat.SOURCE_NAME
                    scriptLink=['<a href="matlab:opentoline(''',obj.getFullSourcePath(depth) ,''',', obj.getSourceLine(depth),',0)">', obj.getSourceName(depth),'</a>'];
                case Log4M.FileLinkFormat.FULL
                    scriptLink=['<a href="matlab:opentoline(''',obj.getFullSourcePath(depth) ,''',', obj.getSourceLine(depth),',0)">', obj.getSourceFilename(depth),'(', obj.getSourceLine(depth),'):',obj.getSourceName(depth),'</a>'];
                
            end
            if ispc
                scriptLink=strrep(scriptLink, '\','\\');
            end
        end
    end

    methods(Access=private)
        function depth=getCallerStackDepth(~,stack)
            depth=find(cellfun(@(x)(~contains(x,'\+Log4M') & ~contains(x,'\+log')),{stack.file},'UniformOutput',true),1,'first');
        end
    end
end

